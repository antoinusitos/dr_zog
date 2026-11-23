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
		x = WINDOW_WIDTH / 2,
		y = 200,
		start_x = WINDOW_WIDTH / 2,
		start_y = 200,
		width = 64,
		height = 64,
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

	game_state.nobody_image = Reactive_Image {
		x = WINDOW_WIDTH / 2 + 100,
		y = 200,
		start_x = WINDOW_WIDTH / 2 + 100,
		start_y = 200,
		width = 64,
		height = 64,
		index = 1,
		background_color = rl.RED,
		hover_color = rl.YELLOW,
		disabled_color = rl.GRAY,
		active = true
	}
	setup_reactive_image(&game_state.nobody_image)
	game_state.nobody_image.on_click = proc(reactive_image : ^Reactive_Image) {
		game_state.current_image = &game_state.nobody_image
	}
	game_state.nobody_image.on_hover = proc(reactive_image : ^Reactive_Image) {
		game_state.cloning_hover_index = reactive_image.index
	}
	game_state.nobody_image.on_exit = proc(reactive_image : ^Reactive_Image) {
		game_state.cloning_hover_index = -1
	}
	game_state.nobody_image.on_release = proc(reactive_image : ^Reactive_Image) {
		game_state.current_image = nil
		game_state.nobody_image.x = game_state.nobody_image.start_x
		game_state.nobody_image.y = game_state.nobody_image.start_y
	}

	game_state.cloning_image_0 = Reactive_Image {
		x = f32(WINDOW_WIDTH / 4 * 0 + (WINDOW_WIDTH / 16)),
		y = f32(WINDOW_HEIGHT / 2),
		width = 200,
		height = 200,
		background_color = rl.RED,
		hover_color = rl.GREEN,
		disabled_color = rl.GRAY,
		active = true
	}
	setup_reactive_image(&game_state.cloning_image_0)
	game_state.cloning_image_0.on_release = proc(reactive_image : ^Reactive_Image) {
		if game_state.current_image != nil {
			game_state.clones[0] = entity_create(.player)
			game_state.cloning_image_0.active = false
			game_state.clones[0].entity_stats = Entity_Stats{agility = 1, chance = 1, endurance = 1, psyche = 1, speed = 1, strength = 1, vitality = 1, entity_retired = false}
	    	game_state.clones[0].color = rl.BLUE
		    game_state.clones[0].name = names[rl.GetRandomValue(0, len(names) - 1)]
		    init_entity(game_state.clones[0])
		}
	}

	game_state.cloning_image_1 = Reactive_Image {
		x = f32(WINDOW_WIDTH / 4 * 1 + (WINDOW_WIDTH / 16)),
		y = f32(WINDOW_HEIGHT / 2),
		width = 200,
		height = 200,
		background_color = rl.RED,
		hover_color = rl.GREEN,
		disabled_color = rl.GRAY,
		active = true
	}
	setup_reactive_image(&game_state.cloning_image_1)
	game_state.cloning_image_1.on_release = proc(reactive_image : ^Reactive_Image) {
		if game_state.current_image != nil {
			game_state.cloning_image_1.active = false
			game_state.clones[1] = entity_create(.player)
			game_state.clones[1].entity_stats = Entity_Stats{agility = 1, chance = 1, endurance = 1, psyche = 1, speed = 1, strength = 1, vitality = 1, entity_retired = false}
    		game_state.clones[1].color = rl.RED
		    game_state.clones[1].name = names[rl.GetRandomValue(0, len(names) - 1)]
		    init_entity(game_state.clones[1])
		}
	}

	game_state.cloning_image_2 = Reactive_Image {
		x = f32(WINDOW_WIDTH / 4 * 2 + (WINDOW_WIDTH / 16)),
		y = f32(WINDOW_HEIGHT / 2),
		width = 200,
		height = 200,
		background_color = rl.RED,
		hover_color = rl.GREEN,
		disabled_color = rl.GRAY,
		active = true
	}
	setup_reactive_image(&game_state.cloning_image_2)
	game_state.cloning_image_2.on_release = proc(reactive_image : ^Reactive_Image) {
		if game_state.current_image != nil {
			game_state.cloning_image_2.active = false
			game_state.clones[2] = entity_create(.player)
			game_state.clones[2].entity_stats = Entity_Stats{agility = 1, chance = 1, endurance = 1, psyche = 1, speed = 1, strength = 1, vitality = 1, entity_retired = false}
    		game_state.clones[2].color = rl.GREEN
		    game_state.clones[2].name = names[rl.GetRandomValue(0, len(names) - 1)]
		    init_entity(game_state.clones[2])
		}
	}

	game_state.cloning_image_3 = Reactive_Image {
		x = f32(WINDOW_WIDTH / 4 * 3 + (WINDOW_WIDTH / 16)),
		y = f32(WINDOW_HEIGHT / 2),
		width = 200,
		height = 200,
		background_color = rl.RED,
		hover_color = rl.GREEN,
		disabled_color = rl.GRAY,
		active = true
	}
	setup_reactive_image(&game_state.cloning_image_3)
	game_state.cloning_image_3.on_release = proc(reactive_image : ^Reactive_Image) {
		if game_state.current_image != nil {
			game_state.cloning_image_3.active = false
			game_state.clones[3] = entity_create(.player)
			game_state.clones[3].entity_stats = Entity_Stats{agility = 1, chance = 1, endurance = 1, psyche = 1, speed = 1, strength = 1, vitality = 1, entity_retired = false}
    		game_state.clones[3].color = rl.YELLOW
		    game_state.clones[3].name = names[rl.GetRandomValue(0, len(names) - 1)]
		    init_entity(game_state.clones[3])
		}
	}
}

init_cloning :: proc() {
	game_state.cloning_hover_index = -1
}

update_cloning :: proc() {
	game_state.back_home_button.update(&game_state.back_home_button)
	game_state.cloning_image_0.update(&game_state.cloning_image_0)
	game_state.cloning_image_1.update(&game_state.cloning_image_1)
	game_state.cloning_image_2.update(&game_state.cloning_image_2)
	game_state.cloning_image_3.update(&game_state.cloning_image_3)
	game_state.ryan_image.update(&game_state.ryan_image)
	game_state.ryan_image.update(&game_state.nobody_image)
}

draw_cloning :: proc() {
	rl.DrawText(fmt.ctprint("Cloning"), WINDOW_WIDTH / 2 - 100, 20, 75, rl.WHITE)
	rl.DrawText(fmt.ctprint("Characters Available (drag&drop in cloning zones)"), WINDOW_WIDTH / 2 - 100, 150, 30, rl.WHITE)

	rl.DrawText(fmt.ctprint("Gold : ", game_state.gold, sep = ""), WINDOW_WIDTH - 100, 10, 20, rl.WHITE)

	game_state.back_home_button.draw(&game_state.back_home_button)

	game_state.cloning_image_0.draw(&game_state.cloning_image_0)
	game_state.cloning_image_1.draw(&game_state.cloning_image_1)
	game_state.cloning_image_2.draw(&game_state.cloning_image_2)
	game_state.cloning_image_3.draw(&game_state.cloning_image_3)
	game_state.ryan_image.draw(&game_state.ryan_image)
	game_state.ryan_image.draw(&game_state.nobody_image)

	if game_state.current_image != nil {
		mouse_pos := rl.GetMousePosition()
		game_state.current_image.x = mouse_pos.x - game_state.current_image.width / 2
		game_state.current_image.y = mouse_pos.y - game_state.current_image.height / 2
	}

	if game_state.cloning_hover_index != -1 {
		rl.DrawText(fmt.ctprint(characters[game_state.cloning_hover_index].name, "\n Random stats in range (", characters[game_state.cloning_hover_index].stat_min.vitality, " - ", characters[game_state.cloning_hover_index].stat_max.vitality, ")", sep = ""), WINDOW_WIDTH / 2, 300, 20, rl.WHITE)
	}

	offset_clone_x := 0
	for &c in game_state.clones {
		if c == nil {
			rl.DrawText(fmt.ctprint("Cloning zone"), i32(WINDOW_WIDTH / 4 * offset_clone_x + (WINDOW_WIDTH / 16)), WINDOW_HEIGHT / 2 + 75, 30, rl.WHITE)
			offset_clone_x += 1
			continue
		}

		rl.DrawTextureEx(c.current_sprite, {f32(WINDOW_WIDTH / 4 * offset_clone_x + (WINDOW_WIDTH / 16)), f32(WINDOW_HEIGHT / 2)}, 0, 5, c.color)
		rl.DrawText(fmt.ctprint(c.name), i32(WINDOW_WIDTH / 4 * offset_clone_x + (WINDOW_WIDTH / 16) + 32), WINDOW_HEIGHT / 2 + 175, 30, rl.WHITE)
		offset_clone_x += 1
	}
}