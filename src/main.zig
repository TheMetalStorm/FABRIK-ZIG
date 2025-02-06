const std = @import("std");
const rl = @import("raylib");
const ArrayList = std.ArrayList;

const Joint = struct { position: rl.Vector2 };
pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const alloc = gpa.allocator();

    const screenWidth = 800;
    const screenHeight = 450;

    var joints = ArrayList(Joint).init(alloc);
    defer joints.deinit();

    for (0..5) |i| {
        const joint = Joint{ .position = rl.Vector2{ .x = @floatFromInt(screenWidth / 2 + i * 20), .y = @floatFromInt(screenHeight / 2) } };
        try joints.append(joint);
    }

    rl.initWindow(screenWidth, screenHeight, "FABRIK");

    defer rl.closeWindow();

    while (!rl.windowShouldClose()) {
        rl.beginDrawing();
        defer rl.endDrawing();
        rl.clearBackground(rl.Color.dark_gray); // Set background color (framebuffer clear color)

        const dists = try computeJointDistances(alloc, joints);
        const target = rl.getMousePosition();
        std.debug.print("{any}\n", .{target});
        stepJoints(joints, dists, target);
        drawJoints(joints);
    }
}

fn computeJointDistances(alloc: std.mem.Allocator, joints: ArrayList(Joint)) !ArrayList(f32) {
    var dists = ArrayList(f32).init(alloc);
    errdefer dists.deinit();

    for (1..joints.items.len) |index| {
        const a = joints.items[index - 1];
        const b = joints.items[index];

        try dists.append(a.position.distance(b.position));
    }

    return dists;
}

fn stepJoints(joints: ArrayList(Joint), dists: ArrayList(f32), target: rl.Vector2) void {
    const dTarget = joints.items[0].position.distance(target);
    var allJointDistanceLength: f32 = 0;
    for (dists.items) |value| {
        allJointDistanceLength += value;
    }

    if (dTarget > allJointDistanceLength) {
        for (joints.items[0 .. joints.items.len - 1], 0..) |*joint, i| {
            const r = joint.position.distance(target);
            const lambda = dists.items[i] / r;
            const oldPos = joints.items[i + 1].position;
            joints.items[i + 1].position = oldPos
                .multiply(rl.Vector2{ .x = 1.0 - lambda, .y = 1.0 - lambda })
                .add(target.multiply(rl.Vector2{ .x = lambda, .y = lambda }));
        }
    } 
    else {
        const b = joints.items[0].position;
        const difA = joints.items[joints.items.len - 1].position.distance(target);
        var i = joints.items.len - 2;
        while(i >= 0){
            const pi = joints.items[i];
            const pi1 = joints.items[i+1];

            const r = pi.position.distance(pi1.position);

            i--;
        }
    }
}

fn drawJoints(joints: ArrayList(Joint)) void {
    for (1..joints.items.len) |index| {
        const a = joints.items[index - 1];
        const b = joints.items[index];

        rl.drawLineEx(a.position, b.position, 2, rl.Color.ray_white);
    }

    for (joints.items) |joint| {
        rl.drawCircle(@intFromFloat(joint.position.x), @intFromFloat(joint.position.y), 5, rl.Color.red);
    }
}
