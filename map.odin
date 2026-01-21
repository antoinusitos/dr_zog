package game

import "core:fmt"
import rl "vendor:raylib"

init_map_ui :: proc() {

}

init_map :: proc() {
	append(&game_state.map_elements, Map_Point { type = .home, done = true})
	append(&game_state.map_elements, Map_Point { type = .battle})
	append(&game_state.map_elements, Map_Point { type = .event})
	append(&game_state.map_elements, Map_Point { type = .battle})
	append(&game_state.map_elements, Map_Point { type = .event})
	append(&game_state.map_elements, Map_Point { type = .home})

	game_state.current_map_point = 1

	index := 0
	for &e in game_state.map_elements {
		button := Button {
			x = WINDOW_WIDTH / 2 - 75,
			y = f32(200 + 150 * index),
			width = 150,
			height = 50,
			background_color = rl.RED,
			hover_color = rl.YELLOW,
			clicked_color = rl.GREEN,
			disabled_color = rl.GRAY,
			text = string(fmt.ctprint(e.type)),
			fill_percent = 0,
			fill_max = 1.0,
			text_size = 20,
			text_offset = {40, 15},
			active = true
		}
		append(&game_state.map_buttons, button)
		setup_one_button(&game_state.map_buttons[index])
		if e.done || index != game_state.current_map_point {
			game_state.map_buttons[index].disabled = true
		}
		switch e.type {
			case .home: {
				game_state.map_buttons[index].on_click = proc(button : ^Button) {
					on_home_back()
				}
			}
			case .battle: {
				game_state.map_buttons[index].on_click = proc(button : ^Button) {
					game_state.game_step = .battle
					game_state.map_elements[game_state.current_map_point].done = true
					game_state.current_map_point += 1
				}
			}
			case .event: {
				game_state.map_buttons[index].on_click = proc(button : ^Button) {
					init_event()
					game_state.game_step = .event
					game_state.map_elements[game_state.current_map_point].done = true
					game_state.current_map_point += 1
				}
			}
			case .shop: {
				game_state.map_buttons[index].on_click = proc(button : ^Button) {
					game_state.game_step = .shop
					game_state.map_elements[game_state.current_map_point].done = true
					game_state.current_map_point += 1
				}
			}
		}
		index += 1
	}
}

update_map :: proc() {
	//index := 0
	index := 0
	for &e in game_state.map_elements {
		if e.done || index != game_state.current_map_point {
			game_state.map_buttons[index].disabled = true
		}
		else {
			game_state.map_buttons[index].disabled = false
		}
		switch e.type {
			case .home: {
				
			}
			case .battle: {
				game_state.map_buttons[index].on_click = proc(button : ^Button) {
					game_state.game_step = .battle
					game_state.map_elements[game_state.current_map_point].done = true
					game_state.current_map_point += 1
					on_battle_enter()
				}
			}
			case .event: {
				
			}
			case .shop: {
				
			}
		}
		index += 1
	}

	for &e in game_state.map_buttons {
		e.update(&e)
	}
}

draw_map :: proc() {
	rl.DrawText(fmt.ctprint("World Map"), WINDOW_WIDTH / 2 - 100, 20, 50, rl.WHITE)
//todo : draw clones info here
	index := 0
	for &e in game_state.map_buttons {
		e.draw(&e)
	}
}

on_home_enter :: proc() {
	if game_state.clones[0] != nil
	{
		for &c in game_state.clones {
    		c.current_life = c.entity_stats.vitality * 4
    	}
	}
}

on_home_back :: proc() {
	game_state.game_step = .cloning
    for &e in game_state.entities {
    	#partial switch e.entity_stats.entity_age {
    		case .baby:
    			e.entity_stats.entity_age = .kid
			case .kid:
    			e.entity_stats.entity_age = .teen
    		case .teen:
    			e.entity_stats.entity_age = .adult
    		case .adult:
    			e.entity_stats.entity_age = .senior
    		case .senior:
    			e.entity_stats.entity_age = .retired
    	}
    }
}
