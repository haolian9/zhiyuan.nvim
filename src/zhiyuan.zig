const std = @import("std");
const print = std.debug.print;
const assert = std.debug.assert;
const log = std.log;

const c = @cImport(@cInclude("libnotify/notify.h"));

const app = "zhiyuan";

fn gbool(val: c_int) bool {
    return val == 1;
}

// todo thread-safety?
var state: struct {
    inited: bool = false,
    succeeded: bool = false,

    const Self = @This();

    fn init(self: *Self, retry: bool) bool {
        if (retry and !self.succeeded) {
            self.inited = false;
            self.succeeded = false;
        }

        if (self.inited) return self.succeeded;

        self.inited = true;
        self.succeeded = c.notify_init(app) == 1;
        return self.succeeded;
    }

    fn deinit(self: *Self) void {
        if (self.inited and self.succeeded) {
            c.notify_uninit();
        }
    }
} = .{};

// todo: proper way to deinit libnotify
// param timeout: milliseconds
export fn zhiyuan(title: [*:0]const u8, msg: [*:0]const u8, icon: [*:0]const u8, timeout: c_int) c_int {
    if (!state.init(true)) return 0;

    // todo: limit msg length
    var noti: *c.NotifyNotification = c.notify_notification_new(title, msg, icon);
    c.notify_notification_set_timeout(noti, timeout);
    // todo: handle errors properly
    return c.notify_notification_show(noti, null);
}

test "libnotify: primitive way" {
    assert(gbool(c.notify_init(app)));
    defer c.notify_uninit();

    var noti: *c.NotifyNotification = c.notify_notification_new("hello", "world", null);
    c.notify_notification_set_timeout(noti, std.time.ms_per_s * 2);
    // todo: handle errors properly
    assert(gbool(c.notify_notification_show(noti, null)));
}

test "libnotify: zhiyuan way" {
    defer state.deinit();
    assert(gbool(zhiyuan("纸鸢",
        \\ 碧落秋方静，腾空力尚微。
        \\ 清风如可托，终共白云飞。
    , "", 5_000)));
}
