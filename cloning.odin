package game

import "core:fmt"
import rl "vendor:raylib"

init_cloning_ui :: proc() {
	game_state.back_home_button = Button{
		x = 0,
		y = 0,
		width = 150,
		height = 50,
		background_color = rl.RED,
		hover_color = rl.YELLOW,
		clicked_color = rl.GREEN,
		disabled_color = rl.GRAY,
		text = "Back",
		fill_percent = 0,
		fill_max = 1.0,
		text_size = 20,
		text_offset = {20, 15},
		active = true
	}
	setup_one_button(&game_state.back_home_button)
	game_state.back_home_button.on_click = proc(button : ^Button) {
		game_state.game_step = .home
	}

	game_state.ryan_image = Reactive_Image {
		x = WINDOW_WIDTH - 32,
		y = 100,
		start_x = WINDOW_WIDTH - 32,
		start_y = 100,
		width = 32,
		height = 32,
		index = 0,
		background_color = rl.RED,
		hover_color = rl.YELLOW,
		disabled_color = rl.GRAY,
		active = true
	}
	setup_reactive_image(&game_state.ryan_image)
	game_state.ryan_image.on_click = proc(reactive_image : ^Reactive_Image) {
		game_state.current_image = &game_state.ryan_image
	}
	game_state.ryan_image.on_hover = proc(reactive_image : ^Reactive_Image) {
		game_state.cloning_hover_index = reactive_image.index
	}
	game_state.ryan_image.on_exit = proc(reactive_image : ^Reactive_Image) {
		game_state.cloning_hover_index = -1
	}
	game_state.ryan_image.on_release = proc(reactive_image : ^Reactive_Image) {
		game_state.current_image = nil
		game_state.ryan_image.x = game_state.ryan_image.start_x
		game_state.ryan_image.y = game_state.ryan_image.start_y
	}

	game_state.cloning_image = Reactive_Image {
		x = WINDOW_WIDTH - 200,
		y = 150,
		start_x = WINDOW_WIDTH - 200,
		start_y = 150,
		width = 200,
		height = 200,
		background_color = rl.RED,
		hover_color = rl.GREEN,
		disabled_color = rl.GRAY,
		active = true
	}
	setup_reactive_image(&game_state.cloning_image)
	game_state.cloning_image.on_click = proc(reactive_image : ^Reactive_Image) {
		game_state.current_image = &game_state.cloning_image
	}
	game_state.cloning_image.on_release = proc(reactive_image : ^Reactive_Image) {
		if game_state.current_image != nil {
			log_error("clone", game_state.current_image.index)
		}
	}
}

init_cloning :: proc() {
	game_state.cloning_hover_index = -1
}

update_cloning :: proc() {
	game_state.back_home_button.update(&game_state.back_home_button)
	game_state.cloning_image.update(&game_state.cloning_image)
	game_state.ryan_image.update(&game_state.ryan_image)
}

draw_cloning :: proc() {
	rl.DrawText(fmt.ctprint("Cloning"), WINDOW_WIDTH / 2 - 100, 20, 75, rl.WHITE)

	rl.DrawText(fmt.ctprint("Gold : ", game_state.gold, sep = ""), WINDOW_WIDTH - 100, 10, 20, rl.WHITE)

	game_state.back_home_button.draw(&game_state.back_home_button)

	game_state.cloning_image.draw(&game_state.cloning_image)
	game_state.ryan_image.draw(&game_state.ryan_image)

	if game_state.current_image != nil {
		mouse_pos := rl.GetMousePosition()
		game_state.current_image.x = mouse_pos.x - game_state.current_image.width / 2
		game_state.current_image.y = mouse_pos.y - game_state.current_image.height / 2
	}

	if game_state.cloning_hover_index != -1 {
		rl.DrawText(fmt.ctprint(characters[game_state.cloning_hover_index].name, sep = ""), WINDOW_WIDTH / 2, WINDOW_HEIGHT / 2, 20, rl.WHITE)
	}
}