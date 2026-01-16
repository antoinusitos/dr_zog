package game

import "core:fmt"
import rl "vendor:raylib"
import "core:strings"
import "core:strconv"

outcome : Event_Outcome
event_state : Event_state = .choice

init_event_ui :: proc() {
		game_state.outcome_1_button = Button{
		x = WINDOW_WIDTH / 2,
		y = 0,
		width = 150,
		height = 75,
		background_color = rl.RED,
		hover_color = rl.YELLOW,
		clicked_color = rl.GREEN,
		disabled_color = rl.GRAY,
		text = "",
		fill_percent = 0,
		fill_max = 1.0,
		text_size = 20,
		text_offset = {20, 25}
	}
	setup_one_button(&game_state.outcome_1_button)
	game_state.outcome_1_button.active = false

	game_state.outcome_2_button = Button{
		x = WINDOW_WIDTH / 2,
		y = 0,
		width = 150,
		height = 75,
		background_color = rl.RED,
		hover_color = rl.YELLOW,
		clicked_color = rl.GREEN,
		disabled_color = rl.GRAY,
		text = "",
		fill_percent = 0,
		fill_max = 1.0,
		text_size = 20,
		text_offset = {20, 25}
	}
	setup_one_button(&game_state.outcome_2_button)
	game_state.outcome_2_button.active = false

	game_state.outcome_3_button = Button{
		x = WINDOW_WIDTH / 2,
		y = 0,
		width = 150,
		height = 75,
		background_color = rl.RED,
		hover_color = rl.YELLOW,
		clicked_color = rl.GREEN,
		disabled_color = rl.GRAY,
		text = "",
		fill_percent = 0,
		fill_max = 1.0,
		text_size = 20,
		text_offset = {20, 25}
	}
	setup_one_button(&game_state.outcome_3_button)
	game_state.outcome_3_button.active = false

	game_state.outcome_4_button = Button{
		x = WINDOW_WIDTH / 2,
		y = 0,
		width = 150,
		height = 75,
		background_color = rl.RED,
		hover_color = rl.YELLOW,
		clicked_color = rl.GREEN,
		disabled_color = rl.GRAY,
		text = "",
		fill_percent = 0,
		fill_max = 1.0,
		text_size = 20,
		text_offset = {20, 25}
	}
	setup_one_button(&game_state.outcome_4_button)
	game_state.outcome_4_button.active = false

	game_state.end_event_button = Button{
		x = WINDOW_WIDTH / 2,
		y = WINDOW_HEIGHT / 2 + 200,
		width = 150,
		height = 75,
		background_color = rl.RED,
		hover_color = rl.YELLOW,
		clicked_color = rl.GREEN,
		disabled_color = rl.GRAY,
		text = "OK",
		fill_percent = 0,
		fill_max = 1.0,
		text_size = 20,
		text_offset = {20, 25}
	}
	setup_one_button(&game_state.end_event_button)
	game_state.end_event_button.on_click = proc(button : ^Button) {
		game_state.game_step = .mapping
	}
	game_state.end_event_button.active = false
}

init_event :: proc() {
	index := 0

	game_state.event_clone = game_state.clones[int(rl.GetRandomValue(0, len(game_state.clones) - 1))]

	for o in events[0].choice {
		y := WINDOW_HEIGHT / 2 + 100 * index
		if index == 0 {
			game_state.outcome_1_button.active = true
			game_state.outcome_1_button.text = o.text
			game_state.outcome_1_button.y = f32(y)
			game_state.outcome_1_button.on_click = proc(button : ^Button) {
				process_choice(0)
			}
		}
		else if index == 1 {
			game_state.outcome_2_button.active = true
			game_state.outcome_2_button.text = o.text
			game_state.outcome_2_button.y = f32(y)
			game_state.outcome_2_button.on_click = proc(button : ^Button) {
				process_choice(1)
			}
		}
		else if index == 2 {
			game_state.outcome_3_button.active = true
			game_state.outcome_3_button.text = o.text
			game_state.outcome_3_button.y = f32(y)
			game_state.outcome_3_button.on_click = proc(button : ^Button) {
				process_choice(2)
			}
		}
		else if index == 3 {
			game_state.outcome_4_button.active = true
			game_state.outcome_4_button.text = o.text
			game_state.outcome_4_button.y = f32(y)
			game_state.outcome_4_button.on_click = proc(button : ^Button) {
				process_choice(3)
			}
		}
		index += 1
	}
}

process_choice :: proc(index : int) {
	rand := int(rl.GetRandomValue(0, 20))

	if rand == 20 {
		outcome = events[0].choice[index].outcome[0]
	}
	else if rand == 0 {
		outcome = events[0].choice[index].outcome[3]
	}
	else if rand > game_state.event_clone.entity_stats.chance {
		outcome = events[0].choice[index].outcome[1]
	}
	else {
		outcome = events[0].choice[index].outcome[2]
	}

	s, ok := strings.replace(outcome.text, "%clone", game_state.event_clone.name, 1) 
	outcome.text = s

	event_state = .outcome

	analyse_tags(outcome.tag)

	game_state.end_event_button.active = true
}

analyse_tags :: proc(tag : string) {
	tags := strings.split_after(tag, "-")
	
	if tags[0] == "add" {
		add_tag(tags)
	}
	else if tags[0] == "remove" {
		add_tag(tags)
	}
}

add_tag :: proc(tags : []string) {
	if tags[1] == "gold" {
		n, ok := strconv.parse_int(tags[2])
		game_state.gold += n
	}
}

remove_tag :: proc(tags : []string) {
	if tags[1] == "life" {
		n, ok := strconv.parse_int(tags[2])
		game_state.event_clone.current_life -= n
	}
}

update_event :: proc() {
	game_state.outcome_1_button.update(&game_state.outcome_1_button)
	game_state.outcome_2_button.update(&game_state.outcome_2_button)
	game_state.outcome_3_button.update(&game_state.outcome_3_button)
	game_state.outcome_4_button.update(&game_state.outcome_4_button)
	game_state.end_event_button.update(&game_state.end_event_button)
}

draw_event :: proc() {
	if event_state == .choice {
		text := fmt.ctprint(events[0].description)
		size := rl.MeasureTextEx(rl.GetFontDefault(), text, 40, 0) 
		rl.DrawText(text, i32(WINDOW_WIDTH / 2 - size.x / 2), WINDOW_HEIGHT / 2 - 100, 40, rl.WHITE)
		game_state.outcome_1_button.draw(&game_state.outcome_1_button)
		game_state.outcome_2_button.draw(&game_state.outcome_2_button)
		game_state.outcome_3_button.draw(&game_state.outcome_3_button)
		game_state.outcome_4_button.draw(&game_state.outcome_4_button)
	}
	else {
		text := fmt.ctprint(outcome.text)
		size := rl.MeasureTextEx(rl.GetFontDefault(), text, 40, 0) 
		rl.DrawText(text, i32(WINDOW_WIDTH / 2 - size.x / 2), WINDOW_HEIGHT / 2 - 100, 40, rl.WHITE)
		game_state.end_event_button.draw(&game_state.end_event_button)
	}
}