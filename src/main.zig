const std = @import("std");
const ArrayList = std.ArrayList;
const NaryTree = @import("NaryTree.zig");
const IKSolver = @import("IKSolver.zig").IKSolver;
const rl = @import("raylib");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const alloc = gpa.allocator();

    const screenWidth = 800;
    const screenHeight = 450;

    var a = ArrayList(IKSolver.Joint).init(alloc);
    for (0..10) |i| {
        const joint = IKSolver.Joint{ .position = rl.Vector2.init(@floatFromInt(screenWidth / 2 + i * 20), @floatFromInt(screenHeight / 2)) };
        try a.append(joint);
    }

    //Build NaryTree

    var solver = try IKSolver.init(alloc, a);
    rl.initWindow(screenWidth, screenHeight, "FABRIK");
    defer rl.closeWindow();

    while (!rl.windowShouldClose()) {
        rl.beginDrawing();
        defer rl.endDrawing();
        rl.clearBackground(rl.Color.dark_gray); // Set background color (framebuffer clear color)
        const target = rl.getMousePosition();
        solver.stepJoints(target);

        const joints = try solver.getJoints();
        defer joints.deinit();

        drawJoints(joints);
    }
}

fn drawJoints(joints: ArrayList(IKSolver.Joint)) void {
    for (1..joints.items.len) |index| {
        const a = joints.items[index - 1];
        const b = joints.items[index];

        rl.drawLineEx(a.position, b.position, 2, rl.Color.ray_white);
    }

    for (joints.items) |joint| {
        rl.drawCircle(@intFromFloat(joint.position.x), @intFromFloat(joint.position.y), 5, rl.Color.red);
    }
}
