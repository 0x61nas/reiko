// https://man.freebsd.org/cgi/man.cgi?query=sysexits&sektion=3&apropos=0&manpath=FreeBSD+15.0-CURRENT
const EX_USAGE = 64;
const EX_DATAERR = 65;
const EX_SOFTWARE = 70;

pub fn main() !void {
    var gpa = std.heap.DebugAllocator(.{}){};
    const allocator = if (builtin.mode == .Debug) gpa.allocator() else std.heap.c_allocator;
    defer if (builtin.mode == .Debug) {
        if (false and gpa.detectLeaks()) { // TODO(anas): re-enable this
            process.exit(EX_SOFTWARE);
        }
    };

    const stderr = std.io.getStdErr();

    const args = try process.argsAlloc(allocator);
    if (args.len < 2) {
        try stderr.writer().print("usage: {s} <class file>\n", .{args[0]});
        process.exit(EX_USAGE);
    }
    const byte_code = try fs.cwd().readFileAlloc(allocator, args[1], std.math.maxInt(usize));
    errdefer allocator.free(byte_code);
    var class_reader = lib.ClassReader.init(allocator, byte_code);
    if (!class_reader.is_somewhat_valid()) {
        try stderr.writeAll("Invalid class file\n");
        process.exit(EX_DATAERR);
    }
    const class = try class_reader.read_class();
    defer class.deinit();
    errdefer class.deinit();
    allocator.free(byte_code); // the `class_reader'is invalid at this point
    const cp = class.constant_pool;

    std.log.info("{s}{s}{s} {s}", .{ blk: {
        if (class.access_flags.public) break :blk "public ";
        break :blk "";
    }, blk: {
        if (class.access_flags.abstract) break :blk "abstract ";
        break :blk "";
    }, blk: {
        if (class.access_flags.interface) break :blk "interface";
        if (class.access_flags.@"enum") break :blk "enum";
        break :blk "class";
    }, cp.at(class.this_class).class.resolve_idx(&cp) });
    std.log.info("\tminor version: {d}\n\tmajor version: {d}", .{ class.minor_version, class.major_version });
    std.log.info("access_flags: (0x{x:0>4})", .{@as(u16, @bitCast(class.access_flags))});
    std.log.info("this_class: #{d}\t\t// {s}", .{ class.this_class, cp.at(class.this_class).class.resolve_idx(&cp) });
    std.log.info("super_class: #{d}\t\t// {s}", .{ class.super_class, cp.at(class.super_class).class.resolve_idx(&cp) });
    std.log.info("interfaces: {d}, fields: {d}, methods: {d}, attributes: {d}", .{ class.interfaces.items.len, class.fields.items.len, class.methods.items.len, class.attributes.items.len });
    std.log.info("CONSTANT POOL:", .{});
    {
        var i: usize = 0;
        while (i < cp.items().len) {
            const c = cp.items()[i];
            i += 1;
            switch (c) {
                .class => std.log.info("\t#{d} = Class\t\t\t#{d}\t// {s}", .{ i, c.class.name_index, c.class.resolve_idx(&cp) }),
                .fieldref => std.log.info("\t#{d} = Fieldref\t\t\t#{d}.#{d}", .{ i, c.fieldref.class_index, c.fieldref.name_and_type_index }),
                .methodref => {
                    const name_and_type_index = c.methodref.resolve_name_and_typ_idx(&cp);
                    std.log.info("\t#{d} = Methodref\t\t#{d}.#{d}\t\t// {s}.{s}:{s}", .{ i, c.methodref.class_index, c.methodref.name_and_type_index, c.methodref.resolve_class_idx(&cp), name_and_type_index.resolve_name_idx(&cp), name_and_type_index.resolve_descriptor_idx(&cp) });
                },
                .interface_methodref => std.log.info("\t#{d} = InterfaceMethodref\t#{d}.#{d}", .{ i, c.interface_methodref.class_index, c.interface_methodref.name_and_type_index }),
                .string => std.log.info("\t#{d} = String\t\t\t#{d}", .{ i, c.string.string_index }),
                .integer => std.log.info("\t#{d} = Integer\t\t\t{d}", .{ i, c.integer.bytes }),
                .float => std.log.info("\t#{d} = Float\t\t\t{d}", .{ i, c.float.bytes }),
                .long => std.log.info("\t#{d} = Long\t\t\t{d}", .{ i, blk: {
                    const num = big_number_as_long(c.long.high_bytes, cp.items()[i].long.low_bytes);
                    i += 1;
                    break :blk num;
                } }),
                .double => std.log.info("\t#{d} = Double\t\t{d}", .{ i, blk: {
                    const num = big_number_as_double(c.double.high_bytes, cp.items()[i].double.low_bytes);
                    i += 1;
                    break :blk num;
                } }),
                .name_and_type => std.log.info("\t#{d} = NameAndType\t\t#{d}:#{d}", .{ i, c.name_and_type.name_index, c.name_and_type.descriptor_index }),
                .utf8 => std.log.info("\t#{d} = Utf8\t\t\t{s}", .{ i, c.utf8.bytes }),
                .method_handle => std.log.info("\t#{d} = MethodHandle\t\t{any}:#{d}", .{ i, c.method_handle.refrence_kind, c.method_handle.refrence_index }),
                .method_type => std.log.info("\t#{d} = MethodType\t\t#{d}", .{ i, c.method_type.descriptor_index }),
                .dynamic => std.log.info("\t#{d} = Dynamic\t\t\t#{d}:#{d}", .{ i, c.dynamic.bootstrap_method_attr_index, c.dynamic.name_and_type_index }),
                .invoke_dynamic => std.log.info("\t#{d} = InvokeDynamic\t\t#{d}:#{d}", .{ i, c.invoke_dynamic.bootstrap_method_attr_index, c.invoke_dynamic.name_and_type_index }),
                .module => std.log.info("\t#{d} = Module\t\t\t#{d}", .{ i, c.module.name_index }),
                .package => std.log.info("\t#{d} = Package\t\t#{d}", .{ i, c.package.name_index }),
            }
        }
    }
    std.log.info("{{", .{});
    for (class.fields.items) |f| {
        const field_name = cp.at(f.name_index).utf8.bytes;
        const descriptor = cp.at(f.descriptor_index).utf8.bytes;
        std.log.info("{s}{s}{s}{s} {s};", .{
            blk: {
                if (f.access_flags.public) break :blk "public ";
                if (f.access_flags.protected) break :blk "protected ";
                if (f.access_flags.private) break :blk "private ";
                break :blk "";
            },
            blk: {
                if (f.access_flags.static) break :blk "static ";
                break :blk "";
            },
            blk: {
                if (f.access_flags.final) break :blk "final ";
                break :blk "";
            },
            descriptor,
            field_name,
        });
        std.log.info("descriptor: {s}", .{descriptor});
        std.log.info("flags: (0x{x:0>4})", .{@as(u16, @bitCast(f.access_flags))});

        std.log.info("\n", .{});
    }

    for (class.methods.items) |m| {
        // public EmptyClass();
        //    descriptor: ()V
        //    flags: (0x0001) ACC_PUBLIC
        //    Code:
        //      stack=1, locals=1, args_size=1
        const method_name = cp.at(m.name_index).utf8.bytes;
        std.log.info("{s}{s}{s}", .{ blk: {
            if (m.access_flags.abstract) break :blk "abstract ";
            break :blk "";
        }, blk: {
            if (m.access_flags.public) break :blk "public ";
            if (m.access_flags.protected) break :blk "protected ";
            if (m.access_flags.private) break :blk "private ";
            break :blk "";
        }, method_name });
        std.log.info("descriptor: {s}", .{cp.at(m.descriptor_index).utf8.bytes});
        std.log.info("flags: (0x{x:0>4})", .{@as(u16, @bitCast(m.access_flags))});

        for (m.attributes.items) |attr| {
            const attr_name = cp.at(attr.name_index).utf8.bytes;
            std.log.info("{s}:", .{attr_name});
            if (attr.info == .Code) {
                const code = attr.info.Code;
                std.log.info("satack={d}, locals={d}", .{ code.max_stack, code.max_locals });
                for (code.attributes.items) |a| {
                    const name = cp.at(a.name_index).utf8.bytes;
                    std.log.info("{s}:", .{name});
                }
            }
        }

        std.log.info("\n", .{});
    }

    std.log.info("}}", .{});
}

pub inline fn big_number_as_long(high_bytes: u32, low_bytes: u32) u64 {
    return (@as(u64, high_bytes) << 32) | low_bytes;
}

pub fn big_number_as_double(high_bytes: u32, low_bytes: u32) f64 {
    // Combine the high and low bytes into a single u64
    const bits: u64 = (@as(u64, high_bytes) << 32) | low_bytes;

    // Extract sign bit
    const s: i32 = if ((bits >> 63) == 0) 1 else -1;

    // Extract exponent
    const e: i32 = @intCast((bits >> 52) & 0x7FF);

    // Extract mantissa
    const m: u64 = if (e == 0)
        (bits & 0xFFFFFFFFFFFFF) << 1
    else
        (bits & 0xFFFFFFFFFFFFF) | 0x10000000000000;

    // Handle special cases
    if (e == 0x7FF) {
        // Infinity or NaN
        if (m == 0) {
            return if (s == 1) std.math.inf(f64) else -std.math.inf(f64);
        } else {
            return std.math.nan(f64);
        }
    }

    // Calculate the value
    const exponent = e - 1023;
    const mantissa_value = @as(f64, @floatFromInt(m)) / @as(f64, @floatFromInt(0x10000000000000));
    const result = @as(f64, @floatFromInt(s)) * mantissa_value * std.math.pow(f64, 2.0, @floatFromInt(exponent));

    return result;
}

const std = @import("std");
const builtin = @import("builtin");
const fs = std.fs;
const process = std.process;

/// This imports the separate module containing `root.zig`. Take a look in `build.zig` for details.
const lib = @import("reiko_lib");
