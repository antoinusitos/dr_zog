package game

import "core:fmt"
import rl "vendor:raylib"

init_home_ui :: proc() {
	game_state.cloning_button = Button{
		x = WINDOW_WIDTH / 2 - 75,
		y = WINDOW_HEIGHT / 2 - 200,
		width = 150,
		height = 50,
		background_color = rl.RED,
		hover_color = rl.YELLOW,
		clicked_color = rl.GREEN,
		fill_color = rl.GREEN,
		text = "Generate\n Clone",
		fill_percent = 0,
		fill_max = 1.0,
		text_size = 20,
		text_offset = {30, 5},
		fill_auto_reset = true,
		active = true
	}
	setup_filling_button(&game_state.cloning_button)
	game_state.cloning_button.on_filled = proc(button : ^Button) {
		index := 0
		for &c in game_state.clones {
			if c == nil {
				c = entity_create(.player)
			    c.entity_stats = all_stats[rl.GetRandomValue(0, len(all_stats) - 1)]
			    if index == 0 {
			    	c.color = rl.BLUE
			    }
			    else if index == 1 {
			    	c.color = rl.RED
			    }
			    else if index == 2 {
			    	c.color = rl.GREEN
			    }
			    else if index == 3 {
			    	c.color = rl.YELLOW
			    }
			    c.name = names[rl.GetRandomValue(0, len(names) - 1)]
			    init_entity(c)
			    break
			}
			index += 1
		}

		for &c in game_state.clones {
			if c == nil {
				return
			}
		}

		game_state.all_clone_created = true
		game_state.all_clone_created_ready = false
		game_state.order_index = 0
	}

	game_state.ready_button = Button{
		x = WINDOW_WIDTH / 2 - 75,
		y = WINDOW_HEIGHT / 2 - 200,
		width = 150,
		height = 50,
		background_color = rl.RED,
		hover_color = rl.YELLOW,
		clicked_color = rl.GREEN,
		disabled_color = rl.GRAY,
		text = "Start",
		fill_percent = 0,
		fill_max = 1.0,
		text_size = 20,
		text_offset = {40, 15},
		active = true
	}
	setup_one_button(&game_state.ready_button)
	game_state.ready_button.on_click = proc(button : ^Button) {
		game_state.all_clone_created_ready = true
	}

	game_state.next_clone_button = Button{
		x = 0,
		y = 250,
		width = 150,
		height = 50,
		background_color = rl.RED,
		hover_color = rl.YELLOW,
		clicked_color = rl.GREEN,
		disabled_color = rl.GRAY,
		text = "Next Clone",
		fill_percent = 0,
		fill_max = 1.0,
		text_size = 20,
		text_offset = {20, 15},
		active = true
	}
	setup_one_button(&game_state.next_clone_button)
	game_state.next_clone_button.on_click = proc(button : ^Button) {
		game_state.order_index += 1
		if game_state.order_index >= 4 {
			game_state.order_index = 0
		}
	}

	game_state.remove_class_button = Button{
		x = 160,
		y = 250,
		width = 150,
		height = 50,
		background_color = rl.RED,
		hover_color = rl.YELLOW,
		clicked_color = rl.GREEN,
		disabled_color = rl.GRAY,
		text = "Remove Class",
		fill_percent = 0,
		fill_max = 1.0,
		text_size = 20,
		text_offset = {20, 15},
		active = true
	}
	setup_one_button(&game_state.remove_class_button)
	game_state.remove_class_button.on_click = proc(button : ^Button) {
		append(&game_state.possible_class, game_state.clones[game_state.order_index].class)
		remove_class(game_state.clones[game_state.order_index])
	}

	game_state.start_battle_button = Button {
		x = WINDOW_WIDTH / 2,
		y = WINDOW_HEIGHT / 2 - 200,
		width = 150,
		height = 50,
		background_color = rl.RED,
		hover_color = rl.YELLOW,
		clicked_color = rl.GREEN,
		disabled_color = rl.GRAY,
		text = "To Space Map",
		fill_percent = 0,
		fill_max = 1.0,
		text_size = 20,
		text_offset = {5, 15},
		active = true
	}
	setup_one_button(&game_state.start_battle_button)
	game_state.start_battle_button.on_click = proc(button : ^Button) {
		game_state.game_step = .mapping
	}

	game_state.class_1_button = Button {
		x = 300,
		y = 50,
		width = 150,
		height = 50,
		background_color = rl.RED,
		hover_color = rl.YELLOW,
		clicked_color = rl.GREEN,
		disabled_color = rl.GRAY,
		text = "Start",
		fill_percent = 0,
		fill_max = 1.0,
		text_size = 20,
		text_offset = {40, 15},
		active = true
	}
	setup_one_button(&game_state.class_1_button)
	game_state.class_1_button.on_click = proc(button : ^Button) {
		
	}

	game_state.class_2_button = Button {
		x = 300,
		y = 50,
		width = 150,
		height = 50,
		background_color = rl.RED,
		hover_color = rl.YELLOW,
		clicked_color = rl.GREEN,
		disabled_color = rl.GRAY,
		text = "Start",
		fill_percent = 0,
		fill_max = 1.0,
		text_size = 20,
		text_offset = {40, 15},
		active = true
	}
	setup_one_button(&game_state.class_2_button)
	game_state.class_2_button.on_click = proc(button : ^Button) {
		
	}

	game_state.class_3_button = Button {
		x = 300,
		y = 50,
		width = 150,
		height = 50,
		background_color = rl.RED,
		hover_color = rl.YELLOW,
		clicked_color = rl.GREEN,
		disabled_color = rl.GRAY,
		text = "Start",
		fill_percent = 0,
		fill_max = 1.0,
		text_size = 20,
		text_offset = {40, 15},
		active = true
	}
	setup_one_button(&game_state.class_3_button)
	game_state.class_3_button.on_click = proc(button : ^Button) {
		
	}

	game_state.class_4_button = Button {
		x = 300,
		y = 50,
		width = 150,
		height = 50,
		background_color = rl.RED,
		hover_color = rl.YELLOW,
		clicked_color = rl.GREEN,
		disabled_color = rl.GRAY,
		text = "Start",
		fill_percent = 0,
		fill_max = 1.0,
		text_size = 20,
		text_offset = {40, 15},
		active = true
	}
	setup_one_button(&game_state.class_4_button)
	game_state.class_4_button.on_click = proc(button : ^Button) {
		
	}
}

init_home :: proc() {
	append(&game_state.possible_class, Class.tank)
	append(&game_state.possible_class, Class.spirit)
	append(&game_state.possible_class, Class.warrior)
	append(&game_state.possible_class, Class.healer)
}

update_home :: proc() {
	if game_state.all_clone_created_ready {
		if len(game_state.possible_class) == 0 {
			game_state.start_battle_button.update(&game_state.start_battle_button)
		}

		game_state.next_clone_button.update(&game_state.next_clone_button)

		if game_state.clones[game_state.order_index].class != .none {
			game_state.remove_class_button.disabled = false	
		}
		else
		{
			game_state.remove_class_button.disabled = true
		}
		game_state.remove_class_button.update(&game_state.remove_class_button)

		game_state.class_1_button.update(&game_state.class_1_button)
		game_state.class_2_button.update(&game_state.class_2_button)
		game_state.class_3_button.update(&game_state.class_3_button)
		game_state.class_4_button.update(&game_state.class_4_button)
	}
	else {
		if game_state.all_clone_created && !game_state.all_clone_created_ready {
			game_state.ready_button.update(&game_state.ready_button)
		}
		else {
			game_state.cloning_button.update(&game_state.cloning_button)
		}
	}
}

draw_home :: proc() {
	if game_state.all_clone_created_ready {
		rl.DrawText(fmt.ctprint("Gold : ", game_state.gold, sep = ""), WINDOW_WIDTH - 100, 10, 20, rl.WHITE)

		if len(game_state.possible_class) == 0 {
			game_state.start_battle_button.draw(&game_state.start_battle_button)
		}

		game_state.next_clone_button.draw(&game_state.next_clone_button)

		/*if rl.GuiButton(rl.Rectangle{0, 350, 150, 50}, "Recycle Clone") {
			game_state.clones[game_state.order_index].entity_stats = all_stats[rl.GetRandomValue(0, len(all_stats) - 1)]
		    game_state.clones[game_state.order_index].name = names[rl.GetRandomValue(0, len(names) - 1)]
		    game_state.clones[game_state.order_index].mutation = Mutation(int(rl.GetRandomValue(0, len(Mutation) - 1)))
		    init_entity(game_state.clones[game_state.order_index])
		}*/

		game_state.remove_class_button.draw(&game_state.remove_class_button)

		rl.DrawText(fmt.ctprint("Assign a class to each clone"), WINDOW_WIDTH / 2 - 150, 20, 20, rl.WHITE)

		offset_class_x := 0
		index := 0

		game_state.class_1_button.active = false
		game_state.class_2_button.active = false
		game_state.class_3_button.active = false
		game_state.class_4_button.active = false

		for c in game_state.possible_class {
			button : ^Button
			if index == 0 {
				button = &game_state.class_1_button
			}
			else if index == 1 {
				button = &game_state.class_2_button
			}
			else if index == 2 {
				button = &game_state.class_3_button
			}
			else if index == 3 {
				button = &game_state.class_4_button
			}
			button.x = f32(400 + offset_class_x)
			button.text = string(fmt.ctprint(c))
			button.class = c
			button.index = index
			button.active = true
			button.on_click = proc(button : ^Button) {
				if game_state.clones[game_state.order_index].class != .none {
					append(&game_state.possible_class, game_state.clones[game_state.order_index].class)
					remove_class(game_state.clones[game_state.order_index])
				}
				game_state.clones[game_state.order_index].class = button.class
				apply_class(game_state.clones[game_state.order_index])
				ordered_remove(&game_state.possible_class, button.index)
			}
			button.draw(button)
			index += 1
			offset_class_x += 160
		}

		rl.DrawText(fmt.ctprint(game_state.clones[game_state.order_index].name), 0, 0, 20, game_state.clones[game_state.order_index].color)
		rl.DrawText(fmt.ctprint("HP:", game_state.clones[game_state.order_index].current_life), 0, 20, 20, rl.WHITE)
		rl.DrawText(fmt.ctprint("VIT:", game_state.clones[game_state.order_index].entity_stats.vitality), 0, 40, 20, rl.WHITE)
		rl.DrawText(fmt.ctprint("STR:", game_state.clones[game_state.order_index].entity_stats.strength), 0, 60, 20, rl.WHITE)
		rl.DrawText(fmt.ctprint("SPEED:", game_state.clones[game_state.order_index].entity_stats.speed), 0, 80, 20, rl.WHITE)
		rl.DrawText(fmt.ctprint("PSY:", game_state.clones[game_state.order_index].entity_stats.psyche), 0, 100, 20, rl.WHITE)
		rl.DrawText(fmt.ctprint("CHANCE:", game_state.clones[game_state.order_index].entity_stats.chance), 0, 120, 20, rl.WHITE)
		rl.DrawText(fmt.ctprint("END:", game_state.clones[game_state.order_index].current_endurance), 0, 140, 20, rl.WHITE)
		rl.DrawText(fmt.ctprint("AGI:", game_state.clones[game_state.order_index].entity_stats.agility), 0, 160, 20, rl.WHITE)
		rl.DrawText(fmt.ctprint("age:", game_state.clones[game_state.order_index].entity_stats.entity_age), 0, 180, 20, rl.WHITE)
		rl.DrawText(fmt.ctprint("mutation:", game_state.clones[game_state.order_index].mutation_stats.description), 0, 200, 20, game_state.clones[game_state.order_index].mutation == .none ? rl.WHITE : game_state.clones[game_state.order_index].mutation_stats.good ? rl.GREEN : rl.RED)
		rl.DrawText(fmt.ctprint("class:", game_state.clones[game_state.order_index].class), 0, 220, 20, rl.WHITE)

		rl.DrawText(fmt.ctprint("base attack:", game_state.clones[game_state.order_index].base_attack.name), 0, 300, 20, rl.WHITE)
		rl.DrawText(fmt.ctprint("(", game_state.clones[game_state.order_index].base_attack.description, ")"), 0, 320, 20, rl.WHITE)

		if game_state.clones[game_state.order_index].abilities[0] != nil {
			rl.DrawText(fmt.ctprint("ability:", game_state.clones[game_state.order_index].abilities[0].name), 0, 380, 20, rl.WHITE)
			rl.DrawText(fmt.ctprint("(", game_state.clones[game_state.order_index].abilities[0].description, ")"), 0, 400, 20, rl.WHITE)
		}

		if game_state.clones[game_state.order_index].mutation_ability.ability_type != .none {
			rl.DrawText(fmt.ctprint("mutation:", game_state.clones[game_state.order_index].mutation_ability.name), 0, 340, 20, game_state.clones[game_state.order_index].mutation_ability.value > 0 ? rl.GREEN : rl.RED)
			rl.DrawText(fmt.ctprint("(", game_state.clones[game_state.order_index].mutation_ability.description, ")"), 0, 360, 20, game_state.clones[game_state.order_index].mutation_ability.value > 0 ? rl.GREEN : rl.RED)
		}

		rl.DrawTextureEx(game_state.clones[game_state.order_index].current_sprite, {f32(WINDOW_WIDTH / 2), f32(WINDOW_HEIGHT / 2)}, 0, 5, game_state.clones[game_state.order_index].color)

		rl.DrawText(fmt.ctprint("Chance - Slightly affects all actions"), 0, WINDOW_HEIGHT - 20, 20, rl.WHITE)
		rl.DrawText(fmt.ctprint("Agility - damage at long range"), 0, WINDOW_HEIGHT - 40, 20, rl.WHITE)
		rl.DrawText(fmt.ctprint("Speed - Initiative"), 0, WINDOW_HEIGHT - 80, 20, rl.WHITE)
		rl.DrawText(fmt.ctprint("Psyche - Mental/psychic power"), 0, WINDOW_HEIGHT - 100, 20, rl.WHITE)
		rl.DrawText(fmt.ctprint("Strength - Physical attack power "), 0, WINDOW_HEIGHT - 120, 20, rl.WHITE)
		rl.DrawText(fmt.ctprint("Endurance - Points of actions per turn "), 0, WINDOW_HEIGHT - 140, 20, rl.WHITE)
		rl.DrawText(fmt.ctprint("Vitality - Total life "), 0, WINDOW_HEIGHT - 160, 20, rl.WHITE)
	
	}
	else {
		rl.DrawText(fmt.ctprint("Home"), WINDOW_WIDTH / 2 - 100, 20, 75, rl.WHITE)

		if game_state.all_clone_created && !game_state.all_clone_created_ready {
			game_state.ready_button.draw(&game_state.ready_button)
		}
		else {
			game_state.cloning_button.draw(&game_state.cloning_button)
		}
		offset_clone_x := 0
		for &c in game_state.clones {
			if c == nil {
				return
			}

			rl.DrawTextureEx(c.current_sprite, {f32(WINDOW_WIDTH / 4 * offset_clone_x + (WINDOW_WIDTH / 16)), f32(WINDOW_HEIGHT / 2)}, 0, 5, c.color)
			rl.DrawText(fmt.ctprint(c.name), i32(WINDOW_WIDTH / 4 * offset_clone_x + (WINDOW_WIDTH / 16) + 32), WINDOW_HEIGHT / 2 + 175, 30, rl.WHITE)
			offset_clone_x += 1
		}
	}
}

init_entity :: proc(entity: ^Entity) {
	if entity.kind == .player {
        entity.character = character_ryan
		entity.entity_stats.agility = int(i32( rl.GetRandomValue(i32(entity.character.stat_min.agility), i32(entity.character.stat_max.agility))) + rl.GetRandomValue(-2, 2))
		entity.entity_stats.chance = int(i32( rl.GetRandomValue(i32(entity.character.stat_min.chance), i32(entity.character.stat_max.chance))) + rl.GetRandomValue(-2, 2))
		entity.entity_stats.strength = int(i32( rl.GetRandomValue(i32(entity.character.stat_min.strength), i32(entity.character.stat_max.strength))) + rl.GetRandomValue(-2, 2))
		entity.entity_stats.endurance = int(i32( rl.GetRandomValue(i32(entity.character.stat_min.endurance), i32(entity.character.stat_max.endurance))) + rl.GetRandomValue(-2, 2))
		entity.entity_stats.vitality = int(i32( rl.GetRandomValue(i32(entity.character.stat_min.vitality), i32(entity.character.stat_max.vitality)))+ rl.GetRandomValue(-2, 2))
		entity.entity_stats.psyche = int(i32( rl.GetRandomValue(i32(entity.character.stat_min.psyche), i32(entity.character.stat_max.psyche))) + rl.GetRandomValue(-2, 2))
		entity.entity_stats.speed = int(i32( rl.GetRandomValue(i32(entity.character.stat_min.speed), i32(entity.character.stat_max.speed))) + rl.GetRandomValue(-2, 2))

		age := all_stats[rl.GetRandomValue(0, len(all_stats) - 1)]

		entity.entity_stats.entity_age = age.entity_age

		entity.entity_stats.agility += age.agility
		entity.entity_stats.chance += age.chance
		entity.entity_stats.strength += age.strength
		entity.entity_stats.endurance += age.endurance
		entity.entity_stats.vitality += age.vitality
		entity.entity_stats.psyche += age.psyche
		entity.entity_stats.speed += age.speed
		#partial switch entity.entity_stats.entity_age {
			case .stage1:
				entity.sprite = {baby_player_sprite}
			case .stage2:
				entity.sprite = {child_player_sprite}
			case .stage3:
				entity.sprite = {teen_player_sprite}
			case .stage4:
				entity.sprite = {player_sprite}
			case .stage5:
				entity.sprite = {old_player_sprite}
		}
		entity.current_sprite = entity.sprite[0]
	}

	entity.current_evade = 1

	if entity.mutation_ability != nil {
		entity.entity_stats.agility += entity.mutation_ability.stats.agility
		entity.entity_stats.chance += entity.mutation_ability.stats.chance
		entity.entity_stats.strength += entity.mutation_ability.stats.strength
		entity.entity_stats.endurance += entity.mutation_ability.stats.endurance
		entity.entity_stats.vitality += entity.mutation_ability.stats.vitality
		entity.entity_stats.psyche += entity.mutation_ability.stats.psyche
		entity.entity_stats.speed += entity.mutation_ability.stats.speed
	}

	resolve_stats(entity)

	random_attack := rl.GetRandomValue(0, 1)
	if random_attack == 0 {
		entity.base_attack = close_attack_ability
	}
	else {
		entity.base_attack = range_attack_ability
	}
}

init_elements :: proc() {
	for &e in element_sprites {
		#partial switch e.element {
			case .fire:
				e.sprite = fire_icon_sprite
		}
	}

	for &e in status_sprites {
		#partial switch e.status {
			case .burning:
				e.sprite = fire_icon_sprite
			case .hidden:
				e.sprite = hidden_icon_sprite
		}
	}
}

remove_class :: proc (entity : ^Entity) {
	for c in class_stats {
		if c.class == entity.class {
			entity.class = .none
			entity.entity_stats.agility -= c.stats.agility
			entity.entity_stats.chance -= c.stats.chance
			entity.entity_stats.strength -= c.stats.strength
			entity.entity_stats.endurance -= c.stats.endurance
			entity.entity_stats.vitality -= c.stats.vitality
			entity.entity_stats.psyche -= c.stats.psyche
			entity.entity_stats.speed -= c.stats.speed

			entity.abilities[0] = nil
		}
	}

	resolve_stats(entity)
}

apply_class :: proc (entity : ^Entity) {
	for c in class_stats {
		if c.class == entity.class {
			entity.class_stats = c
			entity.entity_stats.agility += c.stats.agility
			entity.entity_stats.chance += c.stats.chance
			entity.entity_stats.strength += c.stats.strength
			entity.entity_stats.endurance += c.stats.endurance
			entity.entity_stats.vitality += c.stats.vitality
			entity.entity_stats.psyche += c.stats.psyche
			entity.entity_stats.speed += c.stats.speed

			entity.abilities[0] = c.ability[rl.GetRandomValue(0, i32(len(c.ability) - 1))]
		}
	}

	resolve_stats(entity)
}

resolve_stats  :: proc(entity: ^Entity) {
	if entity.entity_stats.agility <= 0 {
		entity.entity_stats.agility = 1
	}
	if entity.entity_stats.chance <= 0 {
		entity.entity_stats.chance = 1
	}
	if entity.entity_stats.strength <= 0 {
		entity.entity_stats.strength = 1
	}
	if entity.entity_stats.endurance <= 0 {
		entity.entity_stats.endurance = 1
	}
	if entity.entity_stats.vitality <= 0 {
		entity.entity_stats.vitality = 1
	}
	if entity.entity_stats.psyche <= 0 {
		entity.entity_stats.psyche = 1
	}
	if entity.entity_stats.speed <= 0 {
		entity.entity_stats.speed = 1
	}

	entity.current_life = entity.entity_stats.vitality * 4
	entity.current_level = 1
	entity.current_stress = 0
	entity.current_endurance = entity.entity_stats.endurance
	entity.current_damage = entity.entity_stats.strength
}