const std = @import("std");

pub fn build(b: *std.build.Builder) !void {
    // Standard release options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall.
    const mode = b.standardReleaseOptions();

    const output_dir = blk: {
        var buf: [std.fs.MAX_PATH_BYTES]u8 = undefined;
        const cwd = try std.os.getcwd(&buf);
        break :blk b.pathJoin(&.{ cwd, "lua" });
    };

    const lib = b.addSharedLibrary("zhiyuan", "src/main.zig", .unversioned);
    lib.setBuildMode(mode);
    lib.setOutputDir(output_dir);
    lib.linkLibC();
    lib.linkSystemLibrary("libnotify");
    lib.linkSystemLibrary("luajit");
    lib.install();

    const tests = b.addTest("src/main.zig");
    tests.setBuildMode(mode);
    tests.linkLibC();
    tests.linkSystemLibrary("libnotify");
    tests.linkSystemLibrary("luajit");

    const tests_step = b.step("test", "Run library tests");
    tests_step.dependOn(&tests.step);
}
