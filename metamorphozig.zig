const std = @import("std");
const Self = @This();

fn root() []const u8 {
    return std.fs.path.dirname(@src().file) orelse ".";
}

const root_path = root() ++ "/";
const package_path = root_path ++ "src/main.zig";

pub const Options = struct {
    import_name: ?[]const u8 = null,
};

pub const Library = struct {
    step: *std.build.LibExeObjStep,

    pub fn link(self: Library, other: *std.build.LibExeObjStep, opts: Options) void {
        other.linkLibrary(self.step);

        if (opts.import_name) |import_name|
            other.addAnonymousModule(
                import_name,
                .{ .source_file = .{ .path = package_path } },
            );
    }
};

pub fn create(b: *std.build.Builder, target: std.zig.CrossTarget, optimize: std.builtin.OptimizeMode) Library {
    const ret = b.addStaticLibrary(.{
        .name = "metamorphozig",
        .target = target,
        .optimize = optimize,
    });
    ret.linkLibC();
    ret.addCSourceFiles(srcs, &.{"-std=c89"});

    return Library{ .step = ret };
}

const srcs = &.{};
