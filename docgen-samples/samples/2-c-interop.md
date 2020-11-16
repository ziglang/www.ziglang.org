{#syntax#}
// build with `zig build-exe cimport.zig -lc -lraylib`
const ray = @cImport({
    @cInclude("raylib.h");
});

pub fn main() void {
    const screenWidth = 800;
    const screenHeight = 450;
    
    ray.InitWindow(screenWidth, screenHeight, "raylib [core] example - basic window");
    defer ray.CloseWindow();
    
    ray.SetTargetFPS(60);
    
    while(!ray.WindowShouldClose()) {
        ray.BeginDrawing();
        defer ray.EndDrawing();
        
        ray.ClearBackground(ray.RAYWHITE);
        ray.DrawText("Hello, World!", 190, 200, 20, ray.LIGHTGRAY);
    }
}
{#endsyntax#}
