package game

import "core:fmt"
import rl "vendor:raylib"

init_home_ui :: proc() {
	game_state.next_clone_home_button = Button{
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
	setup_one_button(&game_state.next_clone_home_button)
	game_state.next_clone_home_button.on_click = proc(button : ^Button) {
		game_state.order_index += 1
		if game_state.order_index >= 4 {
			game_state.order_index = 0
		}
	}

	game_state.cloning_button = Button{
		x = WINDOW_WIDTH - 150,
		y = 250,
		width = 150,
		height = 50,
		background_color = rl.RED,
		hover_color = rl.YELLOW,
		clicked_color = rl.GREEN,
		disabled_color = rl.GRAY,
		text = "Cloning",
		fill_percent = 0,
		fill_max = 1.0,
		text_size = 20,
		text_offset = {20, 15},
		active = true
	}
	setup_one_button(&game_state.cloning_button)
	game_state.cloning_button.on_click = proc(button : ^Button) {
		game_state.game_step = .cloning
	}
}

init_home :: proc() {

}

update_home :: proc() {
	game_state.next_clone_home_button.update(&game_state.next_clone_home_button)
	game_state.cloning_button.update(&game_state.cloning_button)
}

draw_home :: proc() {
	rl.DrawText(fmt.ctprint("Home"), WINDOW_WIDTH / 2 - 100, 20, 75, rl.WHITE)

	rl.DrawText(fmt.ctprint("Gold : ", game_state.gold, sep = ""), WINDOW_WIDTH - 100, 10, 20, rl.WHITE)

	game_state.next_clone_home_button.draw(&game_state.next_clone_home_button)
	game_state.cloning_button.draw(&game_state.cloning_button)

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