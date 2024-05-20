const std = @import("std");

pub fn build(b: *std.Build) !void {
    const optimize = b.standardOptimizeOption(.{});
    const target = b.standardTargetOptions(.{});

    const lib = b.addSharedLibrary(.{
        .name = "zhiyuan",
        .root_source_file = .{ .path = "src/main.zig" },
        .target = target,
        .optimize = optimize,
    });
    lib.linkLibC();
    lib.linkSystemLibrary("libnotify");
    lib.linkSystemLibrary("luajit");
    b.installArtifact(lib);

    const tests_step = b.step("test", "Run library tests");
    tests_step.dependOn(blk: {
        const tests = b.addTest(.{ .root_source_file = .{ .path = "src/main.zig" } });
        tests.linkLibC();
        tests.linkSystemLibrary("libnotify");
        tests.linkSystemLibrary("luajit");
        break :blk &tests.step;
    });
}
