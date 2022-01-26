const std = @import("std");
const CrossTarget = std.zig.CrossTarget;

pub fn build(b: *std.build.Builder) void {
    const target = CrossTarget{ .os_tag = .windows, .cpu_arch = .i386, .abi = .msvc };
    
    const lib = b.addSharedLibrary("chuniio_tasoller", "src/main.zig", .unversioned);
    lib.setBuildMode(b.standardReleaseOptions());
    lib.setTarget(target);
    lib.install();
    
    // const exe = b.addExecutable("tasoller_test", "src/main.zig");
    // exe.setTarget(target);
    // exe.install();
}
