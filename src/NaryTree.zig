const std = @import("std");
const ArrayList = std.ArrayList;

test "Add And Remove Node Child" {
    var tree = try NaryTree(f32).init(std.testing.allocator, 1);
    const child = try tree.root.addChild(std.testing.allocator, 5);
    try std.testing.expectEqual(1, tree.root.children.items.len);
    try std.testing.expectEqual(1, tree.root.elem);
    try std.testing.expectEqual(5, tree.root.children.items[0].elem);

    tree.root.removeChild(std.testing.allocator, child);

    try std.testing.expectEqual(0, tree.root.children.items.len);

    tree.deinit();
}

test "Deallocation of children " {
    var tree = try NaryTree(f32).init(std.testing.allocator, 1);
    const child = try tree.root.addChild(std.testing.allocator, 5);
    const childsChild = try child.addChild(std.testing.allocator, 10);
    const childsChildsChild = try childsChild.addChild(std.testing.allocator, 20);
    _ = try childsChildsChild.addChild(std.testing.allocator, 50);

    childsChild.removeChild(std.testing.allocator, childsChildsChild);
    try std.testing.expectEqual(0, childsChild.children.items.len);

    tree.deinit();
}

pub fn Node(comptime T: type) type {
    return struct {
        const Self = @This();

        elem: T,
        children: ArrayList(*Self),

        fn init(alloc: std.mem.Allocator, element: T) Self {
            const children = ArrayList(*Self).init(alloc);

            return .{ .elem = element, .children = children };
        }

        pub fn create(alloc: std.mem.Allocator, element: T) !*Self {
            const node = try alloc.create(Self);
            node.* = init(alloc, element);
            return node;
        }

        pub fn addChild(self: *Self, alloc: std.mem.Allocator, element: T) !*Self {
            const ptr = try Self.create(alloc, element);
            try self.children.append(ptr);
            return ptr;
        }

        pub fn hasChildren(self: *Self) bool {
            return self.children.items.len > 0;
        }

        pub fn removeChild(self: *Self, alloc: std.mem.Allocator, toRemove: *Self) void {
            for (self.children.items, 0..) |item, i| {
                if (item == toRemove) {
                    _ = self.children.swapRemove(i);
                    toRemove.deinit(alloc);
                    break;
                }
            }
        }

        pub fn deinit(self: *Self, alloc: std.mem.Allocator) void {
            for (self.children.items) |item| {
                item.deinit(alloc);
            }
            self.children.deinit();
            alloc.destroy(self);
        }
    };
}
pub fn NaryTree(comptime T: type) type {
    return struct {
        const Self = @This();
        root: *Node(T),
        allocator: std.mem.Allocator,

        fn init(alloc: std.mem.Allocator, rootElement: T) !Self {
            const root = try Node(T).create(alloc, rootElement);
            return .{ .root = root, .allocator = alloc };
        }

        fn deinit(self: *Self) void {
            self.root.deinit(self.allocator);
        }
    };
}
