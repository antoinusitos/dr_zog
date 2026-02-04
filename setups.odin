package game

import "core:fmt"
import rl "vendor:raylib"

floor_sprite : rl.Texture2D
bee_sprite : rl.Texture2D
bee_2_sprite : rl.Texture2D
bee_dead_sprite : rl.Texture2D
baby_player_sprite : rl.Texture2D
child_player_sprite : rl.Texture2D
teen_player_sprite : rl.Texture2D
player_sprite : rl.Texture2D
old_player_sprite : rl.Texture2D

fire_sprite : rl.Texture2D
fire_icon_sprite : rl.Texture2D

hover_cell_sprite : rl.Texture2D

blood_sprite : rl.Texture2D
blocker_sprite : rl.Texture2D
bush_sprite : rl.Texture2D
hidden_icon_sprite : rl.Texture2D

coin_sprite : rl.Texture2D

pulled_movement : bool
pulled_attack : bool
pulled_ability : bool

init_sprites :: proc() {
	floor_sprite = rl.LoadTexture("Floor.png")
	bee_sprite = rl.LoadTexture("Bee.png")
	bee_2_sprite = rl.LoadTexture("Bee_2.png")
	bee_dead_sprite = rl.LoadTexture("Bee_Dead.png")
	baby_player_sprite = rl.LoadTexture("Baby_Player.png")
	child_player_sprite = rl.LoadTexture("Child_Player.png")
	teen_player_sprite = rl.LoadTexture("Teen_Player.png")
	player_sprite = rl.LoadTexture("Player.png")
	old_player_sprite = rl.LoadTexture("Old_Player.png")

	fire_sprite = rl.LoadTexture("Fire.png")
	fire_icon_sprite = rl.LoadTexture("Fire_Icon.png")

	hover_cell_sprite = rl.LoadTexture("Hover_Cell.png")

	blood_sprite = rl.LoadTexture("Blood.png")
	blocker_sprite = rl.LoadTexture("Blocker.png")
	bush_sprite = rl.LoadTexture("Bush.png")
	hidden_icon_sprite = rl.LoadTexture("Hidden_Icon.png")

	coin_sprite = rl.LoadTexture("Coin.png")
}

entity_create :: proc(kind: Entity_Kind) -> ^Entity {
	new_index : int = -1
	new_entity: ^Entity = nil
	for &entity, index in game_state.entities {
		if !entity.allocated {
			new_entity = &entity
			new_index = int(index)
			break
		}
	}
	if new_index == -1 {
		log_error("out of entities, probably just double the MAX_ENTITIES")
		return nil
	}

	game_state.entity_top_count += 1
	
	// then set it up
	new_entity.allocated = true

	game_state.entity_id_gen += 1
	new_entity.handle.id = game_state.entity_id_gen
	new_entity.handle.index = u64(new_index)

	switch kind {
		case .nil: break
		case .player: setup_player(new_entity)
		case .enemy: setup_enemy(new_entity)
		case .element_fire: setup_element_fire(new_entity)
		case .blood: setup_blood(new_entity)
		case .bush: setup_bush(new_entity)
		case .item: setup_item(new_entity)
	}

	return new_entity
}

entity_destroy :: proc(entity: ^Entity) {
	entity^ = {} // it's really that simple
}

default_draw_based_on_entity_data :: proc(entity: ^Entity) {
	col := entity.color
	if entity.hit_state == 1 {
		col = rl.RED
	}
	else if entity.hit_state == 2 {
		col = rl.WHITE
	}

	if entity.hit_state != 0 {
		entity.hit_timer += rl.GetFrameTime()
		if entity.hit_timer >= 0.1 {
			entity.hit_timer = 0
			entity.hit_state += 1
			if entity.hit_state == 3 {
				entity.hit_state = 0
			}
		}
	}

	rl.DrawTextureV(entity.current_sprite, {entity.position.x, -entity.position.y - 10}, col)

	index := 0
	for e in entity.elements {
		if e.status_given != .none {
			for &temp_e in status_sprites {
				if temp_e.status == e.status_given {
					rl.DrawTextureV(temp_e.sprite, {entity.position.x, -entity.position.y - 10 + f32(index * -5)}, rl.WHITE)
					break
				}
			}
		}
		index += 1
	}
}
 
setup_player :: proc(entity: ^Entity) {
	entity.sprite = {player_sprite}
	entity.current_sprite = entity.sprite[0]
	entity.kind = .player
	entity.sprite_size = 32
	entity.color = rl.WHITE
	entity.offset_sprite = 0
	entity.mutation_ability = &mutations[(int(rl.GetRandomValue(0, len(mutations) - 1)))]

	entity.update = proc(entity: ^Entity) {
	}
	entity.draw = proc(entity: ^Entity) {
		default_draw_based_on_entity_data(entity)
	}
}

setup_enemy :: proc(entity: ^Entity) {
	entity.sprite = {bee_sprite, bee_2_sprite}
	entity.sprite_dead = bee_dead_sprite
	entity.current_sprite = entity.sprite[0]
	entity.kind = .enemy
	entity.sprite_size = 32
	entity.color = rl.WHITE
	entity.offset_sprite = 0
	entity.class = .none
	entity.current_life = 2
	entity.sprite_index = int(rl.GetRandomValue(0, i32(len(entity.sprite) - 1)))

	entity.update = proc(entity: ^Entity) {
		entity.sprite = {bee_sprite, bee_2_sprite}
		if len(entity.sprite) > 1 && entity.current_life > 0 {
			entity.sprite_time += rl.GetFrameTime()
			if entity.sprite_time >= 0.2 {
				entity.sprite_time = 0
				entity.sprite_index += 1
				if entity.sprite_index >= len(entity.sprite) {
					entity.sprite_index = 0
				}
				entity.current_sprite = entity.sprite[entity.sprite_index]
			}
		}
	}
	entity.draw = proc(entity: ^Entity) {
		default_draw_based_on_entity_data(entity)
	}
}

setup_element_fire :: proc(entity: ^Entity) {
	entity.sprite = {fire_sprite}
	entity.current_sprite = entity.sprite[0]
	entity.kind = .element_fire
	entity.sprite_size = 32
	entity.offset_sprite = {0, -10}
	entity.color = rl.WHITE
	entity.update = proc(entity: ^Entity) {
	}
	entity.draw = proc(entity: ^Entity) {
		default_draw_based_on_entity_data(entity)
	}
}

setup_blood :: proc(entity: ^Entity) {
	entity.sprite = {blood_sprite}
	entity.current_sprite = entity.sprite[0]
	entity.kind = .blood
	entity.sprite_size = 32
	entity.offset_sprite = {0 , -10}
	entity.color = rl.WHITE
	entity.update = proc(entity: ^Entity) {
	}
	entity.draw = proc(entity: ^Entity) {
		default_draw_based_on_entity_data(entity)
	}
}

setup_bush :: proc(entity: ^Entity) {
	entity.sprite = {bush_sprite}
	entity.current_sprite = entity.sprite[0]
	entity.kind = .bush
	entity.sprite_size = 32
	entity.offset_sprite = {0 , -10}
	entity.color = rl.WHITE
	entity.update = proc(entity: ^Entity) {
	}
	entity.draw = proc(entity: ^Entity) {
		default_draw_based_on_entity_data(entity)
	}
}

setup_item :: proc(entity: ^Entity) {
	entity.sprite = {coin_sprite}
	entity.current_sprite = entity.sprite[0]
	entity.kind = .item
	entity.item_type = .coin
	entity.sprite_size = 32
	entity.offset_sprite = {0 , -10}
	entity.color = rl.WHITE
	entity.update = proc(entity: ^Entity) {
	}
	entity.draw = proc(entity: ^Entity) {
		default_draw_based_on_entity_data(entity)
	}
}