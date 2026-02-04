package game

import "core:fmt"
import rl "vendor:raylib"

init_main_menu_ui :: proc() {
	game_state.play_button = Button{
		x = WINDOW_WIDTH / 2 - 75,
		y = 250,
		width = 150,
		height = 50,
		background_color = rl.RED,
		hover_color = rl.YELLOW,
		clicked_color = rl.GREEN,
		disabled_color = rl.GRAY,
		text = "Play",
		fill_percent = 0,
		fill_max = 1.0,
		text_size = 20,
		text_offset = {20, 15},
		active = true
	}
	setup_one_button(&game_state.play_button)
	game_state.play_button.on_click = proc(button : ^Button) {
		game_state.game_step = .home
	}

	game_state.quit_button = Button{
		x = WINDOW_WIDTH / 2 - 75,
		y = 350,
		width = 150,
		height = 50,
		background_color = rl.RED,
		hover_color = rl.YELLOW,
		clicked_color = rl.GREEN,
		disabled_color = rl.GRAY,
		text = "Quit",
		fill_percent = 0,
		fill_max = 1.0,
		text_size = 20,
		text_offset = {20, 15},
		active = true
	}
	setup_one_button(&game_state.quit_button)
	game_state.quit_button.on_click = proc(button : ^Button) {
		game_state.want_to_quit = true
	}
}

init_main_menu :: proc() {
	game_state.game_step = .main_menu
}

update_main_menu :: proc() {
	game_state.play_button.update(&game_state.play_button)
	game_state.quit_button.update(&game_state.quit_button)
}

draw_main_menu :: proc() {
	rl.DrawText(fmt.ctprint("Dr. Zog - A Revenge Story"), WINDOW_WIDTH / 2 - 500, 20, 75, rl.WHITE)

	game_state.play_button.draw(&game_state.play_button)
	game_state.quit_button.draw(&game_state.quit_button)
}