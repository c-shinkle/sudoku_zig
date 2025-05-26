const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const is_x86_linux = target.result.cpu.arch.isX86() and target.result.os.tag == .linux;
    const exe_mod = b.createModule(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });
    const exe = b.addExecutable(.{
        .name = "sudoku_zig",
        .root_module = exe_mod,
        .use_llvm = is_x86_linux,
    });
    b.installArtifact(exe);
    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    const test_step = b.step("test", "Run unit tests");

    compile_unit_tests(b, "Board", target, optimize, test_step);
    compile_unit_tests(b, "algorithm", target, optimize, test_step);
}

fn compile_unit_tests(
    b: *std.Build,
    comptime name: []const u8,
    target: std.Build.ResolvedTarget,
    optimize: std.builtin.OptimizeMode,
    test_step: *std.Build.Step,
) void {
    const is_x86_linux = target.result.cpu.arch.isX86() and target.result.os.tag == .linux;
    const unit_tests = b.addTest(.{
        .name = std.fmt.comptimePrint("{s}_tests", .{name}),
        .use_llvm = !is_x86_linux,
        .root_module = b.createModule(.{
            .root_source_file = b.path(std.fmt.comptimePrint("src/{s}.zig", .{name})),
            .target = target,
            .optimize = optimize,
        }),
    });

    b.installArtifact(unit_tests);
    const run_unit_tests = b.addRunArtifact(unit_tests);
    test_step.dependOn(&run_unit_tests.step);
    const unit_test_step = b.step(name, std.fmt.comptimePrint("Run {s}", .{name}));
    unit_test_step.dependOn(&run_unit_tests.step);
}
