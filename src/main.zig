const std = @import("std");
const print = std.debug.print;
const assert = std.debug.assert;
const testing = std.testing;

const h = @cImport({
    @cInclude("libnotify/notify.h");
    @cInclude("lua.h");
    @cInclude("lauxlib.h");
    @cInclude("lualib.h");
});

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
        self.succeeded = h.notify_init(app) == 1;
        return self.succeeded;
    }

    fn deinit(self: *Self) void {
        if (self.inited and self.succeeded) {
            h.notify_uninit();
        }
    }
} = .{};

fn notify(L: ?*h.lua_State) callconv(.C) c_int {
    if (h.lua_gettop(L) != 5) {
        h.lua_pushboolean(L, 0);
        h.lua_pushstring(L, "not enough args");
        return 2;
    }

    const summary = h.luaL_checklstring(L, 1, 0);
    const body = h.luaL_checklstring(L, 2, 0);
    const icon = h.luaL_checklstring(L, 3, 0);
    // todo: when uncastable, dont crash
    const urgency = @intCast(c_uint, h.luaL_checkinteger(L, 4));
    const timeout = @intCast(c_int, h.luaL_checkinteger(L, 5));

    // todo: deinit libnotify
    if (!state.init(true)) {
        h.lua_pushboolean(L, 0);
        h.lua_pushstring(L, "failed to init libnotify");
        return 2;
    }

    // todo: leak?
    const noti: *h.NotifyNotification = h.notify_notification_new(summary, body, icon);

    h.notify_notification_set_urgency(noti, urgency);
    h.notify_notification_set_timeout(noti, timeout);

    // todo: provides *Error for accurate error reporting
    const showed = h.notify_notification_show(noti, null);
    if (showed == 1) {
        h.lua_pushboolean(L, 1);
        h.lua_pushnil(L);
        return 2;
    }

    h.lua_pushboolean(L, 1);
    h.lua_pushstring(L, "failed to show notification");
    return 2;
}

const mod = [_]h.luaL_Reg{
    .{ .name = "notify", .func = notify },
    .{ .name = 0, .func = null },
};

export fn luaopen_libzhiyuan(L: ?*h.lua_State) c_int {
    h.luaL_register(L, "zhiyuan", &mod);
    return 1;
}

test "test zhiyuan.notify" {
    const L = h.luaL_newstate();
    defer h.lua_close(L);

    h.luaL_openlibs(L);
    try testing.expect(luaopen_libzhiyuan(L) == 1);

    // todo: check return values
    {
        const failed = h.luaL_dostring(L,
            \\require'zhiyuan'.notify()
        );
        try testing.expect(!failed);
        h.lua_pop(L, h.lua_gettop(L));
    }

    // todo: check return values
    {
        const failed = h.luaL_dostring(L,
            \\print(require"zhiyuan".notify("hello", "world", "/my/icon", 1, 1001))
        );
        try testing.expect(!failed);
        h.lua_pop(L, h.lua_gettop(L));
    }

    // todo: ensure no crash
    if (false) {
        const failed = h.luaL_dostring(L,
            \\require'zhiyuan'.notify("hello", "world", "icon", -1, 1001)
        );
        try testing.expect(!failed);
        h.lua_pop(L, h.lua_gettop(L));
    }
}
