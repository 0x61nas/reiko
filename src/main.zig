pub fn main() !void {
    // Prints to stderr (it's a shortcut based on `std.io.getStdErr()`)
    std.debug.print("All your {s} are belong to us.\n", .{"codebase"});

    const class_file = try fs.cwd().openFile("test/samples/EmptyClass.class", .{});
    defer class_file.close();
    const reader = class_file.reader();
    const allocator = std.heap.page_allocator;
    const class = try lib.ClassFile.read(reader, allocator);
    const cp = class.constant_pool;

    std.log.info("{s}class {s}", .{ blk: {
        if (class.access_flags.public) {
            break :blk "public ";
        } else {
            break :blk "";
        }
    }, cp.at(class.this_class).class.resolve_idx(&cp) });
    std.log.info("\tminor version: {d}\n\tmajor version: {d}", .{ class.minor_version, class.major_version });
    std.log.info("access_flags: (0x{x:0>4})", .{@as(u16, @bitCast(class.access_flags))});
    std.log.info("this_class: #{d}\t\t// {s}", .{ class.this_class, cp.at(class.this_class).class.resolve_idx(&cp) });
    std.log.info("super_class: #{d}\t\t// {s}", .{ class.super_class, cp.at(class.super_class).class.resolve_idx(&cp) });
    std.log.info("interfaces: {d}, fields: {d}, methods: {d}, attributes: {d}", .{ class.interfaces.items.len, class.fields.items.len, class.methods.items.len, class.attributes.items.len });
    std.log.info("CONSTANT POOL:", .{});
    for (cp.items(), 1..) |c, i| {
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
            .long => std.log.info("\t#{d} = Long\t\t\t{d}", .{ i, c.long.as_long() }),
            .double => std.log.info("\t#{d} = Double\t\t{d}", .{ i, c.double.as_double() }),
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
    std.log.info("{{", .{});
    for (class.methods.items) |m| {
        // public EmptyClass();
        //    descriptor: ()V
        //    flags: (0x0001) ACC_PUBLIC
        //    Code:
        //      stack=1, locals=1, args_size=1
        const method_name = cp.at(m.name_index).utf8.bytes;
        std.log.info("{s}{s}", .{ blk: {
            if (m.access_flags.public) {
                break :blk "public ";
            } else if (m.access_flags.protected) {
                break :blk "protected";
            } else if (m.access_flags.private) {
                break :blk "private";
            } else {
                break :blk "";
            }
        }, method_name });
        std.log.info("descriptor: {s}", .{cp.at(m.descriptor_index).utf8.bytes});
        std.log.info("flags: (0x{x:0>4})", .{@as(u16, @bitCast(m.access_flags))});
    }

    std.log.info("}}", .{});
}

const std = @import("std");
const fs = std.fs;

/// This imports the separate module containing `root.zig`. Take a look in `build.zig` for details.
const lib = @import("reiko_lib");
