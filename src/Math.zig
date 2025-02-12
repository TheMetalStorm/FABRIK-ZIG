const std = @import("std");

pub const Vector2 = extern struct {
    const Self = @This();
    data: @Vector(2, f32),

    pub fn init(xx: f32, yy: f32) Self {
        return Self{ .data = @Vector(2, f32){ xx, yy } };
    }

    pub fn scalarOf(xx: f32) Self {
        return Self{ .data = @Vector(2, f32){ xx, xx } };
    }

    pub fn add(self: Self, other: Self) Self {
        return Self{ .data = self.data + other.data };
    }

    pub fn mul(self: Self, other: Self) Self {
        return Self{ .data = self.data * other.data };
    }

    pub fn scale(self: Self, other: f32) Self {
        return Self{ .data = self.data * Self.scalarOf(other).data };
    }

    pub fn distance(a: Self, b: Self) f32 {
        const xd = a.x() - b.x();
        const yd = a.y() - b.y();

        return @sqrt((xd * xd) + (yd * yd));
    }

    pub fn x(self: Self) f32 {
        return self.data[0];
    }

    pub fn y(self: Self) f32 {
        return self.data[1];
    }
};
