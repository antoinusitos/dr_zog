package game

import "."
import "core:log"
import "core:slice"
import "core:math"
import "core:math/rand"
import "core:fmt"
import rl "vendor:raylib"
import "core:strings"
import "core:strconv"

quick_test := false

main :: proc() {
	rl.InitWindow(WINDOW_WIDTH, WINDOW_HEIGHT, "Dr_Zog")
	//rl.ToggleBorderlessWindowed()

    camera.zoom = 2

    init_sprites()

	lines := read_map("LVL0.txt")

	game_state.level = read_level(lines)

    for y in 0..<ARENA_HEIGHT{
		for x in 0..<ARENA_WIDTH{
			game_state.arena[y * ARENA_WIDTH + x].x = x
			game_state.arena[y * ARENA_WIDTH + x].y = y
			game_state.arena[y * ARENA_WIDTH + x].type_loaded = game_state.level.cells[x][y]
		}
	}

	init_elements()

	init_main_menu()

	init_main_menu_ui()

	init_event_ui()

	init_leveling_ui()

	init_home()

	init_home_ui()

	init_map()

	init_map_ui()

	init_battle()

	init_battle_ui()

	//init and init ui for events and leveling when needed only

	game_state.game_step = .main_menu

    time_step : f32 = 1.0 / 60
    sub_steps : i32 = 4

    log_error("init done.")

	for !game_state.want_to_quit && !rl.WindowShouldClose() {
		rl.BeginDrawing()
		rl.ClearBackground(rl.BLACK)

		update()

        draw()
	}

	rl.CloseWindow()
}

log_error :: fmt.println

game_state: Game_State

camera : rl.Camera2D

player : ^Entity

update :: proc() {
	//log_error("update")
	#partial switch game_state.game_step {
		case .main_menu:
			update_main_menu()
		case .home :
			update_home()
		case .mapping:
			update_map()
		case .battle:
			update_battle()
		case .event:
			update_event()
		case .leveling:
			update_leveling()
	}
}

draw :: proc() {
	//log_error("draw")

	#partial switch game_state.game_step {
		case .main_menu:
			draw_main_menu()
		case .home:
			draw_home()
		case .mapping:
			draw_map()
		case .battle:
			draw_battle()
		case .event:
			draw_event()
		case .leveling:
			draw_leveling()
	}

	rl.EndDrawing()	
}

collect_item :: proc(item : ^Entity) {
	#partial switch item.item_type {
		case .coin:
		game_state.gold += 3
	}
}