const std = @import("std");
const ArrayList = std.ArrayList;
const Vector2 = @import("raylib").Vector2;

pub const IKSolver = struct {
    const Self = @This();
    joints: ArrayList(Joint),
    alloc: std.mem.Allocator,
    dists: ArrayList(f32),

    pub const Joint = struct { position: Vector2 };
    pub fn init(alloc: std.mem.Allocator, joints: ArrayList(Joint)) !Self {
        return .{ .alloc = alloc, .joints = joints, .dists = try computeJointDistances(alloc, joints) };
    }

    pub fn stepJoints(self: *Self, target: Vector2) void {
        const tolerance = 0.001;

        const distTarget = self.joints.items[0].position.distance(target);
        var allJointDistanceLength: f32 = 0;
        for (self.dists.items) |value| {
            allJointDistanceLength += value;
        }

        if (distTarget > allJointDistanceLength) {
            for (self.joints.items[0 .. self.joints.items.len - 1], 0..) |*joint, i| {
                const r: f32 = joint.position.distance(target);
                const lambda: f32 = self.dists.items[i] / r;
                self.joints.items[i + 1].position = self.joints.items[i].position
                    .scale(1.0 - lambda)
                    .add(target.scale(lambda));
            }
        } else {
            const b = self.joints.items[0].position;
            var difA = self.joints.items[self.joints.items.len - 1].position.distance(target);
            while (difA > tolerance) {

                // STAGE 1: FORWARD REACHING
                self.joints.items[self.joints.items.len - 1].position = target;
                var j = self.joints.items.len - 2;
                while (true) {
                    const pi = self.joints.items[j];
                    const pi1 = self.joints.items[j + 1];

                    const r = pi.position.distance(pi1.position);
                    const lambda = self.dists.items[j] / r;
                    self.joints.items[j].position = pi1.position
                        .scale(1.0 - lambda)
                        .add(pi.position.scale(lambda));

                    if (j == 0) break;
                    j -= 1;
                }
                // STAGE 2: BACKWARD REACHING
                self.joints.items[0].position = b;
                for (self.joints.items[0 .. self.joints.items.len - 1], 0..) |_, i| {
                    const pi = self.joints.items[i];
                    const pi1 = self.joints.items[i + 1];
                    const r = pi.position.distance(pi1.position);
                    const lambda = self.dists.items[i] / r;
                    self.joints.items[i + 1].position = pi.position
                        .scale(1 - lambda)
                        .add(pi1.position.scale(lambda));
                }
                difA = self.joints.items[self.joints.items.len - 1].position.distance(target);
            }
        }
    }

    pub fn computeJointDistances(alloc: std.mem.Allocator, joints: ArrayList(Joint)) !ArrayList(f32) {
        var dists = ArrayList(f32).init(alloc);

        for (0..joints.items.len - 1) |index| {
            const a = joints.items[index];
            const b = joints.items[index + 1];

            try dists.append(a.position.distance(b.position));
        }

        return dists;
    }

    pub fn getJoints(self: *Self) !ArrayList(Joint) {
        return try self.joints.clone();
    }
};
