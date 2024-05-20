const std = @import("std");

pub fn build(b: *std.Build) void {
    const optimize = b.standardOptimizeOption(.{});
    const target = b.standardTargetOptions(.{});

    const lib = b.addSharedLibrary(.{
        .name = "zhiyuan",
        .root_source_file = .{ .path = "src/zhiyuan.zig" },
        .target = target,
        .optimize = optimize,
    });
    lib.linkLibC();
    lib.linkSystemLibrary("libnotify");
    b.installArtifact(lib);

    const tests = b.addTest(.{
        .root_source_file = .{ .path = "src/zhiyuan.zig" },
        .target = target,
        .optimize = optimize,
    });
    tests.linkLibC();
    tests.linkSystemLibrary("libnotify");

    const tests_step = b.step("test", "Run library tests");
    tests_step.dependOn(&b.addRunArtifact(tests).step);
}
