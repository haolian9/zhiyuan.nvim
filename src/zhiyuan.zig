const std = @import("std");
const print = std.debug.print;
const assert = std.debug.assert;
const log = std.log;

const c = @cImport(@cInclude("libnotify/notify.h"));

const app = "zhiyuan";

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

///param timeout: milliseconds
///param urgency: Urgency; 0 low, 1 normal, 2 critical
export fn zhiyuan(summary: [*:0]const u8, body: [*:0]const u8, icon: [*:0]const u8, urgency: c_uint, timeout: c_int) c_int {
    // todo: proper way to deinit libnotify
    if (!state.init(true)) return 0;

    // todo: leak?
    const noti: *c.NotifyNotification = c.notify_notification_new(summary, body, icon);
    c.notify_notification_set_urgency(noti, urgency);
    c.notify_notification_set_timeout(noti, timeout);
    // todo: handle errors properly
    return c.notify_notification_show(noti, null);
}

const Urgency = enum(u8) {
    low,
    normal,
    critical,

    const Self = @This();
    fn asUint(self: Self) c_uint {
        return @enumToInt(self);
    }
};

fn gbool(val: c_int) bool {
    return val == 1;
}

test "libnotify: primitive way" {
    assert(gbool(c.notify_init(app)));
    defer c.notify_uninit();

    const noti: *c.NotifyNotification = c.notify_notification_new("hello", "world", null);
    c.notify_notification_set_urgency(noti, Urgency.normal.asUint());
    c.notify_notification_set_timeout(noti, std.time.ms_per_s * 2);
    assert(gbool(c.notify_notification_show(noti, null)));
}

test "libnotify: zhiyuan way" {
    defer state.deinit();
    assert(gbool(zhiyuan("纸鸢",
        \\ 碧落秋方静，腾空力尚微。
        \\ 清风如可托，终共白云飞。
    , "", Urgency.normal.asUint(), 5_000)));
}
