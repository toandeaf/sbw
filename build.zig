const std = @import("std");
const rlz = @import("raylib_zig");

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const raylib_dep = b.dependency("raylib_zig", .{
        .target = target,
        .optimize = optimize,
        .raudio = false,
    });

    const raylib = raylib_dep.module("raylib");
    const raylib_artifact = raylib_dep.artifact("raylib");

    if (target.query.os_tag == .emscripten) {
        const exe_lib = try rlz.emcc.compileForEmscripten(b, "sbw", "src/main.zig", target, optimize);
        exe_lib.linkLibrary(raylib_artifact);
        exe_lib.root_module.addImport("raylib", raylib);

        const link_step = try rlz.emcc.linkWithEmscripten(b, &[_]*std.Build.Step.Compile{
            exe_lib, raylib_artifact,
        });

        link_step.addArg("--embed-file");
        link_step.addArg("resources/");

        b.getInstallStep().dependOn(&link_step.step);

        const run_step = try rlz.emcc.emscriptenRunStep(b);
        run_step.step.dependOn(&link_step.step);

        const run_option = b.step("run", "Run sbw");
        run_option.dependOn(&run_step.step);
        return;
    }

    // Main executable
    const exe = b.addExecutable(.{
        .name = "sbw",
        .root_source_file = b.path("src/main.zig"),
        .optimize = optimize,
        .target = target,
    });

    const zaudio = b.dependency("zaudio", .{});
    exe.root_module.addImport("zaudio", zaudio.module("root"));
    exe.linkLibrary(zaudio.artifact("miniaudio"));

    exe.linkLibrary(raylib_artifact);
    exe.root_module.addImport("raylib", raylib);

    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);
    const run_step = b.step("run", "Run sbw");
    run_step.dependOn(&run_cmd.step);

    // Additional executable: audio_handler
    const audio_exe = b.addExecutable(.{
        .name = "audio_handler",
        .root_source_file = b.path("src/audio_handler.zig"),
        .optimize = optimize,
        .target = target,
    });

    audio_exe.linkLibrary(raylib_artifact);
    audio_exe.root_module.addImport("raylib", raylib);

    audio_exe.root_module.addImport("zaudio", zaudio.module("root"));
    audio_exe.linkLibrary(zaudio.artifact("miniaudio"));

    const run_audio = b.addRunArtifact(audio_exe);
    const run_audio_step = b.step("run-audio", "Run audio handler");
    run_audio_step.dependOn(&run_audio.step);
}