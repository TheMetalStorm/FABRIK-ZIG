const std = @import("std");
const ArrayList = std.ArrayList;

test "Add And Remove Node Child" {
    var node = try Node.create(std.testing.allocator, 1);
    const child = try node.addChild(std.testing.allocator, 5);
    try std.testing.expectEqual(1, node.children.items.len);
    try std.testing.expectEqual(1, node.elem);
    try std.testing.expectEqual(5, node.children.items[0].elem);

    node.removeChild(std.testing.allocator, child);

    try std.testing.expectEqual(0, node.children.items.len);

    node.deinit(std.testing.allocator);
}

pub const Node = struct {
    const Self = @This();

    elem: f32,
    children: ArrayList(*Self),

    fn init(alloc: std.mem.Allocator, element: f32) Self {
        const children = ArrayList(*Self).init(alloc);

        return .{ .elem = element, .children = children };
    }

    pub fn create(alloc: std.mem.Allocator, element: f32) !*Self {
        const node = try alloc.create(Self);
        node.* = init(alloc, element);
        return node;
    }

    pub fn addChild(self: *Self, alloc: std.mem.Allocator, element: f32) !*Self {
        const ptr = try Node.create(alloc, element);
        try self.children.append(ptr);
        return ptr;
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

pub const NaryTree = struct {
    const Self = @This();
    root: ?*Node,
    allocator: std.mem.Allocator,

    fn init(alloc: std.mem.Allocator) Self {
        return .{ .root = null, .allocator = alloc };
    }

    fn addRoot(self: *Self, elem: f32) !void {
        self.root = Node.create(self.allocator, elem);
    }
};
