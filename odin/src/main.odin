package main

import rl "vendor:raylib"

MAX_BUNNIES :: 80000
MAX_BATCH_ELEMENTS :: 8192

Bunny :: struct {
	position: rl.Vector2,
	speed:    rl.Vector2,
	color:    rl.Color,
}

main :: proc() {
	SCREEN_WIDTH :: i32(800)
	SCREEN_HEIGHT :: i32(450)

	rl.InitWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "raylib [textures] example - bunnymark")
	defer rl.CloseWindow()

	tex_bunny := rl.LoadTexture("resources/raybunny.png")
	defer rl.UnloadTexture(tex_bunny)

	bunnies := make([]Bunny, MAX_BUNNIES)
	defer delete(bunnies)

	bunnies_count: i32 = 0
	paused := false

	for !rl.WindowShouldClose() {
		// Update
		if rl.IsMouseButtonDown(.LEFT) {
			for _ in 0 ..< 100 {
				if bunnies_count < MAX_BUNNIES {
					b := &bunnies[bunnies_count]
					b.position = rl.GetMousePosition()
					b.speed = {
						f32(rl.GetRandomValue(-250, 250)),
						f32(rl.GetRandomValue(-250, 250)),
					}
					b.color = {
						u8(rl.GetRandomValue(50, 240)),
						u8(rl.GetRandomValue(80, 240)),
						u8(rl.GetRandomValue(100, 240)),
						255,
					}
					bunnies_count += 1
				}
			}
		}

		if rl.IsKeyPressed(.P) do paused = !paused

		if !paused {
			hw := f32(tex_bunny.width) / 2
			hh := f32(tex_bunny.height) / 2
			sw := f32(rl.GetScreenWidth())
			sh := f32(rl.GetScreenHeight())

			for i in 0 ..< bunnies_count {
				b := &bunnies[i]
				b.position += b.speed * rl.GetFrameTime()

				if b.position.x + hw > sw || b.position.x + hw < 0 do b.speed.x *= -1
				if b.position.y + hh > sh || b.position.y + hh - 40 < 0 do b.speed.y *= -1
			}
		}

		// Draw
		rl.BeginDrawing()
		defer rl.EndDrawing()

		rl.ClearBackground(rl.RAYWHITE)

		for i in 0 ..< bunnies_count {
			b := bunnies[i]
			rl.DrawTexture(tex_bunny, i32(b.position.x), i32(b.position.y), b.color)
		}

		rl.DrawRectangle(0, 0, SCREEN_WIDTH, 40, rl.BLACK)
		rl.DrawText(rl.TextFormat("bunnies: %i", bunnies_count), 120, 10, 20, rl.GREEN)
		rl.DrawText(
			rl.TextFormat("batched draw calls: %i", 1 + bunnies_count / MAX_BATCH_ELEMENTS),
			320,
			10,
			20,
			rl.MAROON,
		)
		rl.DrawFPS(10, 10)
	}
}
