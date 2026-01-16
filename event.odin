package game

import "core:fmt"
import rl "vendor:raylib"

init_event :: proc() {
	index := 0
	for o in events[0].outcome {
		y := WINDOW_HEIGHT / 2 + 100 * index
		if index == 0 {
			game_state.outcome_1_button.active = true
			game_state.outcome_1_button.text = o.text
			game_state.outcome_1_button.y = f32(y)
			game_state.outcome_1_button.on_click = proc(button : ^Button) {
				game_state.game_step = .mapping
			}
		}
		else if index == 1 {
			game_state.outcome_2_button.active = true
			game_state.outcome_2_button.text = o.text
			game_state.outcome_2_button.y = f32(y)
			game_state.outcome_2_button.on_click = proc(button : ^Button) {
				game_state.game_step = .mapping
			}
		}
		else if index == 2 {
			game_state.outcome_3_button.active = true
			game_state.outcome_3_button.text = o.text
			game_state.outcome_3_button.y = f32(y)
			game_state.outcome_3_button.on_click = proc(button : ^Button) {
				game_state.game_step = .mapping
			}
		}
		else if index == 3 {
			game_state.outcome_4_button.active = true
			game_state.outcome_4_button.text = o.text
			game_state.outcome_4_button.y = f32(y)
			game_state.outcome_4_button.on_click = proc(button : ^Button) {
				game_state.game_step = .mapping
			}
		}
		index += 1
	}
}

update_event :: proc() {
	game_state.outcome_1_button.update(&game_state.outcome_1_button)
	game_state.outcome_2_button.update(&game_state.outcome_2_button)
	game_state.outcome_3_button.update(&game_state.outcome_3_button)
	game_state.outcome_4_button.update(&game_state.outcome_4_button)
}

draw_event :: proc() {
	rl.DrawText(fmt.ctprint(events[0].description), WINDOW_WIDTH / 2 - 50, WINDOW_HEIGHT / 2 - 100, 40, rl.WHITE)
	game_state.outcome_1_button.draw(&game_state.outcome_1_button)
	game_state.outcome_2_button.draw(&game_state.outcome_2_button)
	game_state.outcome_3_button.draw(&game_state.outcome_3_button)
	game_state.outcome_4_button.draw(&game_state.outcome_4_button)
}