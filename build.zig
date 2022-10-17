const std = @import("std");

pub fn build(b: *std.build.Builder) void {
    // Standard release options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall.
    const mode = b.standardReleaseOptions();

    const lib = b.addSharedLibrary("zhiyuan", "src/zhiyuan.zig", .unversioned);
    lib.setBuildMode(mode);
    lib.linkLibC();
    lib.linkSystemLibrary("libnotify");
    lib.install();

    const tests = b.addTest("src/zhiyuan.zig");
    tests.setBuildMode(mode);
    tests.linkLibC();
    tests.linkSystemLibrary("libnotify");
    const tests_step = b.step("test", "Run library tests");
    tests_step.dependOn(&tests.step);
}
