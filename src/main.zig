const std = @import("std");
const rl = @import("raylib");
pub fn main() void {
    const screenWidth = 800;
    const screenHeight = 450;

    rl.initWindow(screenWidth, screenHeight, "FABRIK");
    defer rl.closeWindow();
    while (!rl.windowShouldClose()) {
        rl.beginDrawing();
        defer rl.endDrawing();
        rl.clearBackground(rl.Color.dark_gray); // Set background color (framebuffer clear color)
    }
}
