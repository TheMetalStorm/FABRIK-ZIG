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
        const joint = Joint{ .position = rl.Vector2{ .x = @floatFromInt(screenWidth / 2 + i * 60), .y = @floatFromInt(screenHeight / 2) } };
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
        stepJoints(joints, dists, target);
        drawJoints(joints);
    }
}

fn computeJointDistances(alloc: std.mem.Allocator, joints: ArrayList(Joint)) !ArrayList(f32) {
    var dists = ArrayList(f32).init(alloc);
    errdefer dists.deinit();

    for (0..joints.items.len - 1) |index| {
        const a = joints.items[index];
        const b = joints.items[index + 1];

        try dists.append(a.position.distance(b.position));
    }

    return dists;
}

fn stepJoints(joints: ArrayList(Joint), dists: ArrayList(f32), target: rl.Vector2) void {
    const tolerance = 0.001;

    const distTarget = joints.items[0].position.distance(target);
    var allJointDistanceLength: f32 = 0;
    for (dists.items) |value| {
        allJointDistanceLength += value;
    }

    if (distTarget > allJointDistanceLength) {
        for (joints.items[0 .. joints.items.len - 1], 0..) |*joint, i| {
            const r: f32 = joint.position.distance(target);
            const lambda: f32 = dists.items[i] / r;
            joints.items[i + 1].position = joints.items[i].position
                .scale(1.0 - lambda)
                .add(target.scale(lambda));
        }
    } else {
        const b = joints.items[0].position;
        var difA = joints.items[joints.items.len - 1].position.distance(target);
        while (difA > tolerance) {

            // STAGE 1: FORWARD REACHING
            joints.items[joints.items.len - 1].position = target;
            var j = joints.items.len - 2;
            while (true) {
                const pi = joints.items[j];
                const pi1 = joints.items[j + 1];

                const r = pi.position.distance(pi1.position);
                const lambda = dists.items[j] / r;

                joints.items[j].position = pi1.position
                    .scale(1 - lambda)
                    .add(pi.position.scale(lambda));

                if (j == 0) break;
                j -= 1;
            }
            // STAGE 2: BACKWARD REACHING
            joints.items[0].position = b;
            for (joints.items[0 .. joints.items.len - 1], 0..) |_, i| {
                const pi = joints.items[i];
                const pi1 = joints.items[i + 1];
                const r = pi.position.distance(pi1.position);
                const lambda = dists.items[i] / r;
                joints.items[i + 1].position = pi.position
                    .scale(1 - lambda)
                    .add(pi1.position.scale(lambda));
            }
            difA = joints.items[joints.items.len - 1].position.distance(target);
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
