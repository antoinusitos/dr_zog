package game

import "core:fmt"
import rl "vendor:raylib"
import "core:math/rand"

init_leveling_ui :: proc() {
	game_state.leveling_1_button = Button{
		x = WINDOW_WIDTH / 2 - 450,
		y = 150,
		width = 150,
		height = 75,
		background_color = rl.RED,
		hover_color = rl.YELLOW,
		clicked_color = rl.GREEN,
		disabled_color = rl.GRAY,
		text = "leveling 1",
		fill_percent = 0,
		fill_max = 1.0,
		text_size = 20,
		text_offset = {20, 25}
	}
	setup_one_button(&game_state.leveling_1_button)
	game_state.leveling_1_button.active = true
	game_state.leveling_1_button.on_click = proc(button : ^Button) {
		game_state.game_step = .mapping
		for &a in game_state.event_clone.abilities {
			if a == nil {
				a = game_state.event_clone.class_stats.ability[0]
				break
			}
		}
	}

	game_state.leveling_2_button = Button{
		x = WINDOW_WIDTH / 2 - 150,
		y = 150,
		width = 150,
		height = 75,
		background_color = rl.RED,
		hover_color = rl.YELLOW,
		clicked_color = rl.GREEN,
		disabled_color = rl.GRAY,
		text = "leveling 2",
		fill_percent = 0,
		fill_max = 1.0,
		text_size = 20,
		text_offset = {20, 25}
	}
	setup_one_button(&game_state.leveling_2_button)
	game_state.leveling_2_button.active = true
	game_state.leveling_2_button.on_click = proc(button : ^Button) {
		game_state.game_step = .mapping
		for &a in game_state.event_clone.abilities {
			if a == nil {
				a = game_state.event_clone.class_stats.ability[0]
				break
			}
		}
	}

	game_state.leveling_3_button = Button{
		x = WINDOW_WIDTH / 2 + 150,
		y = 150,
		width = 150,
		height = 75,
		background_color = rl.RED,
		hover_color = rl.YELLOW,
		clicked_color = rl.GREEN,
		disabled_color = rl.GRAY,
		text = "leveling 3",
		fill_percent = 0,
		fill_max = 1.0,
		text_size = 20,
		text_offset = {20, 25}
	}
	setup_one_button(&game_state.leveling_3_button)
	game_state.leveling_3_button.active = true
	game_state.leveling_3_button.on_click = proc(button : ^Button) {
		game_state.game_step = .mapping
		for &a in game_state.event_clone.abilities {
			if a == nil {
				a = game_state.event_clone.class_stats.ability[0]
				break
			}
		}
	}

	game_state.leveling_4_button = Button{
		x = WINDOW_WIDTH / 2 + 450,
		y = 150,
		width = 150,
		height = 75,
		background_color = rl.RED,
		hover_color = rl.YELLOW,
		clicked_color = rl.GREEN,
		disabled_color = rl.GRAY,
		text = "leveling 4",
		fill_percent = 0,
		fill_max = 1.0,
		text_size = 20,
		text_offset = {20, 25}
	}
	setup_one_button(&game_state.leveling_4_button)
	game_state.leveling_4_button.active = true
	game_state.leveling_4_button.on_click = proc(button : ^Button) {
		game_state.game_step = .mapping
		for &a in game_state.event_clone.abilities {
			if a == nil {
				a = game_state.event_clone.class_stats.ability[0]
				break
			}
		}
	}
}

init_leveling :: proc() {

	lowest_level := 99
	clones : [dynamic]^Entity

	for &c in game_state.clones {
		if c.current_level < lowest_level {
			clear(&clones)
			append(&clones, c)
			lowest_level = c.current_level
		}
		else if c.current_level == lowest_level {
			append(&clones, c)
		}
	}

	rand.shuffle(clones[:])

	game_state.event_clone = clones[0]

	game_state.event_clone.current_level += 1
}

update_leveling :: proc() {
	game_state.leveling_1_button.update(&game_state.leveling_1_button)
	game_state.leveling_2_button.update(&game_state.leveling_2_button)
	game_state.leveling_3_button.update(&game_state.leveling_3_button)
	game_state.leveling_4_button.update(&game_state.leveling_4_button)
}

draw_leveling :: proc() {
	rl.DrawText(fmt.ctprint("Level Up !"), WINDOW_WIDTH / 2 - 100, 20, 50, rl.WHITE)

	rl.DrawText(fmt.ctprint(game_state.event_clone.name, " reached level ", game_state.event_clone.current_level), WINDOW_WIDTH / 2 - 100, 70, 30, rl.WHITE)

	game_state.leveling_1_button.draw(&game_state.leveling_1_button)
	game_state.leveling_2_button.draw(&game_state.leveling_2_button)
	game_state.leveling_3_button.draw(&game_state.leveling_3_button)
	game_state.leveling_4_button.draw(&game_state.leveling_4_button)
}