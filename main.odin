package game

import "."
import "core:log"
import "core:slice"
import "core:math"
import "core:math/rand"
import "core:fmt"
import rl "vendor:raylib"
import "core:strings"
import "core:strconv"

quick_test := false

main :: proc() {
	rl.InitWindow(WINDOW_WIDTH, WINDOW_HEIGHT, "Dr_Zog")
	//rl.ToggleBorderlessWindowed()

    camera.zoom = 2

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

	lines := read_map("LVL0.txt")

	game_state.level = read_level(lines)

    for y in 0..<ARENA_HEIGHT{
		for x in 0..<ARENA_WIDTH{
			game_state.arena[y * ARENA_WIDTH + x].x = x
			game_state.arena[y * ARENA_WIDTH + x].y = y
			game_state.arena[y * ARENA_WIDTH + x].type_loaded = game_state.level.cells[x][y]
		}
	}

	init_main_menu_ui()

	init_combat_ui()

	init_map_ui()

	init_event_ui()

	init_elements()

	init_main_menu()

	init_map()

	if quick_test {
		for i in 0..<4 {
			index := 0
			for &c in game_state.clones {
				if c == nil {
					c = entity_create(.player)
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

				    game_state.clones[index].class = game_state.possible_class[index]
				    //game_state.clones[index].class = game_state.possible_class[2]
					apply_class(game_state.clones[index])
				}
				index += 1
			}
		}
		game_state.all_clone_created = true
		game_state.all_clone_created_ready = true
		game_state.order_index = 0

		place_entity(game_state.clones[0], 0, 0, .mid)
	    place_entity(game_state.clones[1], 1, 0, .mid)
	    place_entity(game_state.clones[2], 2, 0, .mid)
	    place_entity(game_state.clones[3], 3, 0, .mid)

	    for e in 0..<3 {
	    	enemy := entity_create(.enemy)
		    enemy.entity_stats = fly_stats
		    if e == 0 {
		    	 enemy.name = "mother fucker"
		    }
		    else if e == 1 {
		    	enemy.name = "dummy"
		    }
		    else {
		    	enemy.name = "ass"
		    }
		    init_entity(enemy)
		    append(&game_state.enemies, enemy)
		    place_entity(enemy, 9 - e, 9, .mid)
		    enemy.target = game_state.clones[0]
	    }

	    for &e in game_state.entities {
	    	if !e.allocated do continue
	    	append(&game_state.order, &e)
	    }

	    game_state.order_index = 0
	    game_state.turn_number = 1
		slice.sort_by(game_state.order[:], entity_order)
		game_state.game_step = .battle
	}

    time_step : f32 = 1.0 / 60
    sub_steps : i32 = 4

	for !rl.WindowShouldClose() {
		rl.BeginDrawing()
		rl.ClearBackground(rl.BLACK)

		update()

        draw()
	}

	rl.CloseWindow()
}

log_error :: fmt.println

game_state: Game_State

camera : rl.Camera2D

player : ^Entity

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

pulled_movement : bool
pulled_attack : bool
pulled_ability : bool

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
	}

	return new_entity
}

entity_destroy :: proc(entity: ^Entity) {
	entity^ = {} // it's really that simple
}

entity_take_damage :: proc(entity : ^Entity, amount : int) {
	entity.current_life -= amount
	if entity.current_life <= -5 {
		entity.exploded = true
	}
	append(&game_state.damage_texts, Damage_Text{text = string(fmt.ctprint(amount)), position = {entity.position.x + 16, -entity.position.y - 20}, color = rl.RED})
	entity.hit_state = 1
	if entity.current_life <= 0 {
		if entity.kind == .enemy {
			if entity.current_life <= -5 {
				entity.current_sprite = blood_sprite
			}
			else {
				entity.current_sprite = bee_dead_sprite
			}
		}
	}
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

init_entity :: proc(entity: ^Entity) {
	if entity.kind == .player {

		entity.entity_stats.agility = int(5 + rl.GetRandomValue(-2, 2))
		entity.entity_stats.chance = int(5 + rl.GetRandomValue(-2, 2))
		entity.entity_stats.strength = int(5 + rl.GetRandomValue(-2, 2))
		entity.entity_stats.endurance = int(5 + rl.GetRandomValue(-2, 2))
		entity.entity_stats.vitality = int(5 + rl.GetRandomValue(-2, 2))
		entity.entity_stats.psyche = int(5 + rl.GetRandomValue(-2, 2))
		entity.entity_stats.speed = int(5 + rl.GetRandomValue(-2, 2))

		age := all_stats[rl.GetRandomValue(0, len(all_stats) - 1)]

		entity.entity_stats.entity_age = age.entity_age

		entity.entity_stats.agility += age.agility
		entity.entity_stats.chance += age.chance
		entity.entity_stats.strength += age.strength
		entity.entity_stats.endurance += age.endurance
		entity.entity_stats.vitality += age.vitality
		entity.entity_stats.psyche += age.psyche
		entity.entity_stats.speed += age.speed
		switch entity.entity_stats.entity_age {
			case .baby:
				entity.sprite = {baby_player_sprite}
			case .kid:
				entity.sprite = {child_player_sprite}
			case .teen:
				entity.sprite = {teen_player_sprite}
			case .adult:
				entity.sprite = {player_sprite}
			case .senior:
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

place_entity :: proc(entity: ^Entity, x : int, y : int, height : Cell_Height) {
	if entity.cell != nil {
		if entity.cell.entity_bottom == entity {
			entity.cell.entity_bottom = nil
		}
		else if entity.cell.entity == entity {
			entity.cell.entity = nil
		}
		else if entity.cell.entity_top == entity {
			entity.cell.entity_top = nil
		}
	}

	switch height {
		case .bottom:
			game_state.arena[y * ARENA_WIDTH + x].entity_bottom = entity
		case .mid:
			game_state.arena[y * ARENA_WIDTH + x].entity = entity
		case .top:
			game_state.arena[y * ARENA_WIDTH + x].entity_top = entity
	}

	entity.position = {f32(OFFSET_X + x * SPRITE_SIZE + int(entity.offset_sprite.x)), f32(-OFFSET_Y - y * SPRITE_SIZE+ int(entity.offset_sprite.y))}
	entity.cell = &game_state.arena[y * ARENA_WIDTH + x]


	if entity.kind == .player || entity.kind == .enemy {
		for t in entity.cell.tag_to_add {
			append(&entity.tags, t)
		}
		for e in entity.cell.elements {
			if !entity_has_tag(entity, e.tag) {
				append(&entity.tags, e.tag)
				append(&entity.elements, e)
				if e.stat_to_change != .none {
					#partial switch e.stat_to_change {
						case .evade :
							entity.current_evade += e.stat_to_change_value
					}
				}
			}
		}

		for t in entity.cell.tag_to_remove {
			index := 0
			for &e in entity.elements {
				if e.tag == t {
					if e.stat_to_change != .none {
						#partial switch e.stat_to_change {
							case .evade :
								entity.current_evade -= e.stat_to_change_value
						}
					}
					ordered_remove(&entity.tags, index)
					ordered_remove(&entity.elements, index)
				}
				index += 1
			}
		}
	}
}

all_units_have_played :: proc() {
	game_state.turn_number += 1
}

end_turn :: proc() {
	end_movement()
	end_attack()

	game_state.order_index += 1
	if game_state.order_index >= len(game_state.order) {
		all_units_have_played()
		game_state.order_index = 0
	}

	for y in 0..<ARENA_HEIGHT{
		for x in 0..<ARENA_WIDTH{
			index := 0
			for &e in game_state.arena[y * ARENA_WIDTH + x].elements {
				e.turn -= 1
				if e.turn <= 0 {
					ordered_remove(&game_state.arena[y * ARENA_WIDTH + x].elements, index)
					cell_remove_tag(&game_state.arena[y * ARENA_WIDTH + x], e.tag)
					entity_destroy(game_state.arena[y * ARENA_WIDTH + x].entity_top)
					game_state.arena[y * ARENA_WIDTH + x].entity_top = nil
				}
				else {
					index += 1
				}
			}
		}
	}

	for &entity in game_state.entities {
		if !entity.allocated do continue
		index := 0
		for &e in entity.elements {
			e.turn -= 1
			if e.turn <= 0 {
				ordered_remove(&entity.elements, index)
				entity_remove_tag(&entity, e.tag)
			}
			else {
				index += 1
			}
		}
	}

	game_state.move_button.disabled = false
	game_state.attack_button.disabled = false
	game_state.ability_button.disabled = false
	game_state.applyed_dots = false

	game_state.order[game_state.order_index].movement_done = false
	game_state.order[game_state.order_index].attack_done = false
	game_state.order[game_state.order_index].current_endurance += END_BY_TURN
}

end_movement :: proc() {
	game_state.want_to_move = false
	for y in 0..<ARENA_HEIGHT {
		for x in 0..<ARENA_WIDTH {
			game_state.arena[y * ARENA_WIDTH + x].cell_active = false
		}
	}
}

end_attack :: proc() {
	game_state.want_to_attack = false
	reset_active_cells()
}

check_inspected :: proc() {
	mouse_pos := rl.GetMousePosition() + camera.target * camera.zoom
	x := int(math.ceil_f32(mouse_pos.x / (SPRITE_SIZE * camera.zoom))) - 4
	y := int(math.ceil_f32(mouse_pos.y / (SPRITE_SIZE * camera.zoom))) - 4
	if x >= ARENA_WIDTH || x < 0 {
		game_state.info_entity = nil
		return
	}
	if y >= ARENA_HEIGHT || y < 0 {
		game_state.info_entity = nil
		return
	}
	if game_state.arena[y * ARENA_WIDTH + x].entity != nil {
		game_state.info_entity = game_state.arena[y * ARENA_WIDTH + x].entity
	}
	else {
		game_state.info_entity = nil
	}
}

reset_active_cells :: proc() {
	for y in 0..<ARENA_HEIGHT {
		for x in 0..<ARENA_WIDTH {
			game_state.arena[y * ARENA_WIDTH + x].cell_active = false
		}
	}
}

attack :: proc(damaged_entity : ^Entity, attacking_entity : ^Entity) {
	if damaged_entity == nil || attacking_entity.attack_done {
		return
	}

	rand := int(rl.GetRandomValue(0, 20))
	mult := 1
	if rand < attacking_entity.entity_stats.chance {
		mult = 2
	}

	touch := f32(100 / damaged_entity.current_evade)
	rand_touch := f32(rl.GetRandomValue(0, 100))

	if rand_touch <= touch {
		entity_take_damage(damaged_entity, attacking_entity.current_damage * mult)
	}
	else {
		append(&game_state.damage_texts, Damage_Text{text = string(fmt.ctprint("miss")), position = {damaged_entity.position.x + 16, -damaged_entity.position.y - 20}, color = rl.GREEN})
	}

	game_state.attack_button.disabled = true
	attacking_entity.current_endurance -= 2
	attacking_entity.attack_done = true
	check_all_dead()
	end_attack()
}

check_all_dead :: proc() {
	all_dead := true
	for &e in game_state.enemies {
		if e != nil && e.current_life > 0 {
			all_dead = false
			break
		}
	}

	if all_dead {
		game_state.game_finished = true
	}
}

ability :: proc(damaged_cell : ^Cell, attacking_entity : ^Entity, index : int) {
	#partial switch attacking_entity.class_stats.ability[index].ability_type {
		case .damage:
		{
			if damaged_cell.entity == nil {
				attacking_entity.current_endurance -= attacking_entity.class_stats.ability[index].cost
				if attacking_entity.current_endurance <= 0 {
					game_state.ability_button.disabled = true
				}
				if attacking_entity.class_stats.ability[index].element_to_add.element != .none {
					append(&damaged_cell.tags, attacking_entity.class_stats.ability[index].element_to_add.tag)
					append(&damaged_cell.elements, attacking_entity.class_stats.ability[index].element_to_add)
					element := entity_create(attacking_entity.class_stats.ability[index].element_to_add.element_to_spawn)
					place_entity(element, damaged_cell.x, damaged_cell.y, .top)
					damaged_cell.entity_top = element
				}
				game_state.ability_1 = false
				reset_active_cells()
				return
			}

			rand := int(rl.GetRandomValue(0, 20))
			mult := 1
			if rand < attacking_entity.entity_stats.chance {
				mult = 2
			}
			entity_take_damage(damaged_cell.entity, attacking_entity.class_stats.ability[index].value * mult)
			for t in attacking_entity.class_stats.ability[index].add_tags {
				append(&damaged_cell.entity.tags, t)
			}
			if attacking_entity.class_stats.ability[index].element_to_add.element != .none {
				append(&damaged_cell.entity.tags, attacking_entity.class_stats.ability[index].element_to_add.tag)
				append(&damaged_cell.entity.elements, attacking_entity.class_stats.ability[index].element_to_add)
				element := entity_create(attacking_entity.class_stats.ability[index].element_to_add.element_to_spawn)
				damaged_cell.entity_top = element
			}
			attacking_entity.current_endurance -= attacking_entity.class_stats.ability[index].cost
			if attacking_entity.current_endurance <= 0 {
				game_state.ability_button.disabled = true
			}
			check_all_dead()
		}
		case .movement:
		{
			if ability_has_tag(attacking_entity.class_stats.ability[index], "move_instant") {
				place_entity(attacking_entity, damaged_cell.x, damaged_cell.y, .top)
			}
			attacking_entity.current_endurance -= attacking_entity.class_stats.ability[index].cost
			game_state.ability_1 = false
			reset_active_cells()
			if attacking_entity.current_endurance <= 0 {
				game_state.ability_button.disabled = true
			}
		}
		case .heal:
		{
			if damaged_cell.entity == nil {
				attacking_entity.current_endurance -= attacking_entity.class_stats.ability[index].cost
				if attacking_entity.current_endurance <= 0 {
					game_state.ability_button.disabled = true
				}
				game_state.ability_1 = false
				reset_active_cells()
				return
			}
			append(&game_state.damage_texts, Damage_Text{text = string(fmt.ctprint(attacking_entity.class_stats.ability[index].value)), position = {damaged_cell.entity.position.x + 16, -damaged_cell.entity.position.y - 20}, color = rl.GREEN})
			damaged_cell.entity.current_life += attacking_entity.class_stats.ability[index].value
			for t in attacking_entity.class_stats.ability[index].add_tags {
				append(&damaged_cell.entity.tags, t)
			}
			attacking_entity.current_endurance -= attacking_entity.class_stats.ability[index].cost
			if attacking_entity.current_endurance <= 0 {
				game_state.ability_button.disabled = true
			}
			check_all_dead()
		}
	}
	game_state.ability_1 = false
	reset_active_cells()
}

update :: proc() {
	#partial switch game_state.game_step {
		case .cloning:
			update_main_menu()
		case .mapping:
			update_map()
		case .battle:
			update_battle()
		case .event:
			update_event()
	}
}

update_battle :: proc() {
	game_state.entity_animated = 0
	for &entity in game_state.entities {
		if !entity.allocated do continue

		animated := 0

		// call the update function
		entity.update(&entity)

		if entity.hit_state != 0 {
			animated = 1
		}

		if entity.moving {
			animated = 1
			game_state.end_turn_button.disabled = true
			if entity.time_to_point >= 0.25 {
				place_entity(&entity, entity.path[entity.path_index].cell.x, entity.path[entity.path_index].cell.y, .mid)
				entity.time_to_point = 0
				entity.path_index -= 1
				if entity.path_index < 0 {
					clear(&entity.path)
					entity.path_index = 0
					game_state.blocked = false
					entity.moving = false
					entity.movement_done = true
				}
			}
			else {
				entity.time_to_point += rl.GetFrameTime()
			}
		}
		else if entity.attacking {
			game_state.end_turn_button.disabled = true
			if entity.kind == .enemy {
				if entity.time_to_attack < 0.5 {
					entity.time_to_attack += rl.GetFrameTime()
				}
				else {
					attack(entity.target, &entity)
					entity.time_to_attack = 0
					entity.attack_done = true
					entity.attacking = false
					game_state.blocked = false
				}
			}
		}
		else {
			game_state.end_turn_button.disabled = false
		}

		game_state.entity_animated += animated
	}

	if game_state.game_finished {
		game_state.end_combat_button.active = true
		game_state.end_combat_button.update(&game_state.end_combat_button)
		return
	}

	if game_state.blocked {
		return
	}

	if !game_state.applyed_dots {
		game_state.applyed_dots = true
		if entity_has_tag(game_state.order[game_state.order_index], "fire") {
			game_state.order[game_state.order_index].current_life -= 1
			if game_state.order[game_state.order_index].current_life <= 0 {
				if game_state.order[game_state.order_index].kind == .enemy {
					game_state.order[game_state.order_index].current_sprite = bee_dead_sprite
				}
			}
		}
	}

	game_state.end_turn_button.active = true
	game_state.end_turn_button.update(&game_state.end_turn_button)

	if game_state.order[game_state.order_index].kind != .player {
		if game_state.order[game_state.order_index].current_life <= 0 {
			end_turn()
			return
		}
		if !game_state.order[game_state.order_index].moving && !game_state.order[game_state.order_index].attacking {
			x := game_state.order[game_state.order_index].cell.x
			y := game_state.order[game_state.order_index].cell.y
			target := game_state.order[game_state.order_index].target
			attack_size := 3
			movement := get_movement_cells(x, y, attack_size, false, false)

			target = game_state.clones[0]
			dist := distance({f32(x), f32(y)}, {f32(target.cell.x), f32(target.cell.y)})

			for &t in game_state.clones {
				temp_dist := distance({f32(x), f32(y)}, {f32(t.cell.x), f32(t.cell.y)})
				if temp_dist < dist {
					dist = temp_dist
					target = t
				}
			}

			game_state.order[game_state.order_index].target = target

			cell := movement[0]
			dist = distance({f32(x), f32(y)}, {f32(target.cell.x), f32(target.cell.y)})

			if dist != 1 && !game_state.order[game_state.order_index].movement_done {
				for c in movement {
					temp_dist := distance({f32(c.x), f32(c.y)}, {f32(target.cell.x), f32(target.cell.y)})
					if temp_dist < dist {
						dist = temp_dist
						cell = c
					}
				}

				clear(&game_state.order[game_state.order_index].path)
				
				game_state.order[game_state.order_index].path = find_path(x, y, cell.x, cell.y)
				game_state.order[game_state.order_index].path_index = len(game_state.order[game_state.order_index].path) - 1
				game_state.order[game_state.order_index].time_to_point = 0.25
				game_state.order[game_state.order_index].moving = true
				game_state.blocked = true
			}
			else if !game_state.order[game_state.order_index].attack_done && dist == 1 {
				game_state.order[game_state.order_index].attacking = true
				game_state.blocked = true
			}
			else {
				end_turn()
			}
		}
	}
	else {
		game_state.move_button.active = true
		game_state.move_button.update(&game_state.move_button)
		game_state.attack_button.active = true
		game_state.attack_button.update(&game_state.attack_button)
		game_state.ability_button.active = true
		game_state.ability_button.update(&game_state.ability_button)
		//game_state.ability_2_button.update(&game_state.ability_2_button)
	}

	if rl.IsKeyPressed(.SPACE) {
		end_turn()
	}

	if rl.IsKeyPressed(.F) {
		log_error(game_state.order[game_state.order_index].class_stats.ability)
	}

	if rl.IsKeyPressed(.G) {
		for i in 0..<4 {
			game_state.clones[i].entity_stats = all_stats[rl.GetRandomValue(0, len(all_stats) - 1)]
		    game_state.clones[i].name = names[rl.GetRandomValue(0, len(names) - 1)]
		    game_state.clones[i].class = Class(int(rl.GetRandomValue(1, len(Class) - 1)))
			game_state.clones[i].mutation = Mutation(int(rl.GetRandomValue(0, len(Mutation) - 1)))
			init_entity(game_state.clones[i])
		}
	}

	check_inspected()

	if game_state.want_to_move {
		x := game_state.order[game_state.order_index].cell.x
		y := game_state.order[game_state.order_index].cell.y
		movement_size := game_state.order[game_state.order_index].entity_stats.speed
		movement := get_movement_cells(x, y, movement_size, false, false)

		for &move in movement {
			game_state.arena[move.y * ARENA_WIDTH + move.x].cell_active = true
		}
	}
	else if game_state.want_to_attack {
		x := game_state.order[game_state.order_index].cell.x
		y := game_state.order[game_state.order_index].cell.y
		attack_size := game_state.order[game_state.order_index].base_attack.range
		if game_state.order[game_state.order_index].base_attack.damage_type == .range {
			attack_size = game_state.order[game_state.order_index].entity_stats.agility
		}
		movement := get_movement_cells(x, y, attack_size, true, false)

		for &move in movement {
			game_state.arena[move.y * ARENA_WIDTH + move.x].cell_active = true
		}
	}
	else if game_state.ability_1 && game_state.order[game_state.order_index].class_stats.ability[0] != nil {
		#partial switch (game_state.order[game_state.order_index].class_stats.ability[0].ability_type) {
			case .damage :
			{
				reset_active_cells()
				x := game_state.order[game_state.order_index].cell.x
				y := game_state.order[game_state.order_index].cell.y
				attack_size := game_state.order[game_state.order_index].class_stats.ability[0].range
				movement := get_movement_cells(x, y, attack_size, true, false)

				for &move in movement {
					game_state.arena[move.y * ARENA_WIDTH + move.x].cell_active = true
				}
			}
			case .movement :
			{
				reset_active_cells()
				x := game_state.order[game_state.order_index].cell.x
				y := game_state.order[game_state.order_index].cell.y
				attack_size := game_state.order[game_state.order_index].class_stats.ability[0].range
				movement := get_movement_cells(x, y, attack_size, false, false)

				for &move in movement {
					game_state.arena[move.y * ARENA_WIDTH + move.x].cell_active = true
				}
			}
			case .heal :
			{
				reset_active_cells()
				x := game_state.order[game_state.order_index].cell.x
				y := game_state.order[game_state.order_index].cell.y
				attack_size := game_state.order[game_state.order_index].class_stats.ability[0].range
				movement := get_movement_cells(x, y, attack_size, true, true)

				for &move in movement {
					game_state.arena[move.y * ARENA_WIDTH + move.x].cell_active = true
				}
			}
		}
	}

	if rl.IsMouseButtonPressed(.LEFT) && game_state.order[game_state.order_index].kind == .player && (game_state.want_to_move || game_state.want_to_attack || game_state.ability_1) {
		mouse_pos := rl.GetMousePosition() + camera.target * camera.zoom
		x := int(math.ceil_f32(mouse_pos.x / (SPRITE_SIZE * camera.zoom))) - 4
		y := int(math.ceil_f32(mouse_pos.y / (SPRITE_SIZE * camera.zoom))) - 4
		if x >= ARENA_WIDTH || x < 0 {
			return
		}
		if y >= ARENA_HEIGHT || y < 0 {
			return
		}

		if game_state.arena[y * ARENA_WIDTH + x].cell_active == true {
			reset_active_cells()
			if game_state.want_to_move {
				clear(&game_state.order[game_state.order_index].path)
				game_state.order[game_state.order_index].path = find_path(game_state.order[game_state.order_index].cell.x, game_state.order[game_state.order_index].cell.y, x, y)
				game_state.order[game_state.order_index].path_index = len(game_state.order[game_state.order_index].path) - 1
				game_state.order[game_state.order_index].time_to_point = 0.25
				game_state.order[game_state.order_index].moving = true
				game_state.blocked = true
				game_state.order[game_state.order_index].movement_done = true 
				game_state.move_button.disabled = true
				end_movement()
			}
			else if game_state.want_to_attack && game_state.arena[y * ARENA_WIDTH + x].entity != nil {
				attack(game_state.arena[y * ARENA_WIDTH + x].entity, game_state.order[game_state.order_index])
			}
			else if game_state.ability_1/* && game_state.arena[y * ARENA_WIDTH + x].entity != nil */{
				ability(&game_state.arena[y * ARENA_WIDTH + x], game_state.order[game_state.order_index], 0)
			}
		}
	}
}

init_combat_ui :: proc() {
	game_state.move_button = Button{
		x = 0,
		y = 1005,
		width = 150,
		height = 75,
		background_color = rl.RED,
		hover_color = rl.YELLOW,
		clicked_color = rl.GREEN,
		disabled_color = rl.GRAY,
		text = "Move",
		fill_percent = 0,
		fill_max = 1.0,
		text_size = 20,
		text_offset = {40, 15}
	}
	setup_one_button(&game_state.move_button)
	game_state.move_button.on_click = proc(button : ^Button) {
		if button.disabled {
			return
		}
		end_attack()
		game_state.want_to_move = true
	}
	game_state.move_button.on_hover = proc(button : ^Button) {
		if game_state.order[game_state.order_index].kind != .player {
			return
		}

		mouse_pos := rl.GetMousePosition() + camera.target * camera.zoom
		x := mouse_pos.x
		y := mouse_pos.y
		if !pulled_movement {
			reset_active_cells()
			x := game_state.order[game_state.order_index].cell.x
			y := game_state.order[game_state.order_index].cell.y
			movement_size := game_state.order[game_state.order_index].entity_stats.speed

			movement := get_movement_cells(x, y, movement_size, false, false)

			pulled_movement = true

			for &move in movement {
				game_state.arena[move.y * ARENA_WIDTH + move.x].cell_active = true
			}
		}
	}
	game_state.move_button.on_exit = proc(button : ^Button) {
		if pulled_movement {
			reset_active_cells()
		}
		pulled_movement = false
	}

	game_state.attack_button = Button{
		x = 160,
		y = 1005,
		width = 150,
		height = 75,
		background_color = rl.RED,
		hover_color = rl.YELLOW,
		clicked_color = rl.GREEN,
		disabled_color = rl.GRAY,
		text = "Attack",
		fill_percent = 0,
		fill_max = 1.0,
		text_size = 20,
		text_offset = {7, 15}
	}
	setup_one_button(&game_state.attack_button)
	game_state.attack_button.on_click = proc(button : ^Button) {
		if button.disabled {
			return
		}
		end_movement()
		game_state.want_to_attack = true
	}
	game_state.attack_button.on_hover = proc(button : ^Button) {
		if game_state.order[game_state.order_index].kind != .player {
			return
		}

		mouse_pos := rl.GetMousePosition() + camera.target * camera.zoom
		x := mouse_pos.x
		y := mouse_pos.y
		if !pulled_attack {
			pulled_attack = true
			reset_active_cells()
			x := game_state.order[game_state.order_index].cell.x
			y := game_state.order[game_state.order_index].cell.y
			attack_size := game_state.order[game_state.order_index].base_attack.range
			if game_state.order[game_state.order_index].base_attack.damage_type == .range {
				attack_size = game_state.order[game_state.order_index].entity_stats.agility
			}
			movement := get_movement_cells(x, y, attack_size, true, false)

			for &move in movement {
				game_state.arena[move.y * ARENA_WIDTH + move.x].cell_active = true
			}
		}
	}
	game_state.attack_button.on_exit = proc(button : ^Button) {
		if pulled_attack {
			reset_active_cells()
		}
		pulled_attack = false
	}

	game_state.ability_button = Button{
		x = 160,
		y = 1005,
		width = 150,
		height = 75,
		background_color = rl.RED,
		hover_color = rl.YELLOW,
		clicked_color = rl.GREEN,
		disabled_color = rl.GRAY,
		text = "Ability",
		fill_percent = 0,
		fill_max = 1.0,
		text_size = 20,
		text_offset = {7, 15}
	}
	setup_one_button(&game_state.ability_button)
	game_state.ability_button.on_click = proc(button : ^Button) {
		if button.disabled {
			return
		}

		game_state.ability_1 = true
	}
	game_state.ability_button.on_hover = proc(button : ^Button) {
		if game_state.order[game_state.order_index].kind != .player {
			return
		}

		a := game_state.order[game_state.order_index].class_stats.ability[0]
		if a != nil && !pulled_ability {
			pulled_ability = true
			#partial switch a.ability_type {
				case .damage :
				{
					reset_active_cells()
					x := game_state.order[game_state.order_index].cell.x
					y := game_state.order[game_state.order_index].cell.y
					attack_size := a.range
					movement := get_movement_cells(x, y, attack_size, true, false)

					for &move in movement {
						game_state.arena[move.y * ARENA_WIDTH + move.x].cell_active = true
					}
				}
				case .movement :
				{
					reset_active_cells()
					x := game_state.order[game_state.order_index].cell.x
					y := game_state.order[game_state.order_index].cell.y
					attack_size := a.range
					movement := get_movement_cells(x, y, attack_size, false, false)

					for &move in movement {
						game_state.arena[move.y * ARENA_WIDTH + move.x].cell_active = true
					}
				}
				case .heal :
				{
					reset_active_cells()
					x := game_state.order[game_state.order_index].cell.x
					y := game_state.order[game_state.order_index].cell.y
					attack_size := a.range
					movement := get_movement_cells(x, y, attack_size, true, true)

					for &move in movement {
						game_state.arena[move.y * ARENA_WIDTH + move.x].cell_active = true
					}
				}
			}
		}
	}
	game_state.ability_button.on_exit = proc(button : ^Button) {
		if pulled_ability {
			reset_active_cells()
		}
		pulled_ability = false
	}

	game_state.end_combat_button = Button{
		x = WINDOW_WIDTH / 2 - 25,
		y = WINDOW_HEIGHT / 2 + 100,
		width = 150,
		height = 75,
		background_color = rl.RED,
		hover_color = rl.YELLOW,
		clicked_color = rl.GREEN,
		disabled_color = rl.GRAY,
		text = "End Combat",
		fill_percent = 0,
		fill_max = 1.0,
		text_size = 20,
		text_offset = {7, 15}
	}
	setup_one_button(&game_state.end_combat_button)
	game_state.end_combat_button.on_click = proc(button : ^Button) {
		game_state.game_step = .mapping

		game_state.game_finished = false

		for &e in game_state.enemies {
			entity_destroy(e)
		}
		clear(&game_state.enemies)
	}

	game_state.end_turn_button = Button{
		x = WINDOW_WIDTH - 150,
		y = 0,
		width = 150,
		height = 75,
		background_color = rl.RED,
		hover_color = rl.YELLOW,
		clicked_color = rl.GREEN,
		disabled_color = rl.GRAY,
		text = "End Turn",
		fill_percent = 0,
		fill_max = 1.0,
		text_size = 20,
		text_offset = {20, 25}
	}
	setup_one_button(&game_state.end_turn_button)
	game_state.end_turn_button.on_click = proc(button : ^Button) {
		end_turn()
	}
}

draw :: proc() {
	#partial switch game_state.game_step {
		case .cloning:
			draw_main_menu()
		case .mapping:
			draw_map()
		case .battle:
			draw_battle()
		case .event:
			draw_event()
	}

	rl.EndDrawing()	
}

draw_battle :: proc() {
	rl.BeginMode2D(camera)

	for y in 0..<ARENA_HEIGHT{
		for x in 0..<ARENA_WIDTH{
			col := rl.WHITE
			if game_state.arena[y * ARENA_WIDTH + x].cell_active {
				col = rl.PURPLE
			}
			else if x == game_state.order[game_state.order_index].cell.x && y == game_state.order[game_state.order_index].cell.y {
				col = rl.GREEN
			}
			rl.DrawTextureV(floor_sprite, {f32(OFFSET_X + x * SPRITE_SIZE), f32(OFFSET_Y + y * SPRITE_SIZE)}, col)

			if game_state.arena[y * ARENA_WIDTH + x].blocked {
				rl.DrawTextureV(blocker_sprite, {f32(OFFSET_X + x * SPRITE_SIZE), f32(OFFSET_Y + y * SPRITE_SIZE)}, col)
			}
		}
	}

	check_mouse_hover_cell()

	for y in 0..<ARENA_HEIGHT {
		for x in 0..<ARENA_WIDTH {
			if game_state.arena[y * ARENA_WIDTH + x].entity_bottom != nil {
				game_state.arena[y * ARENA_WIDTH + x].entity_bottom.draw(game_state.arena[y * ARENA_WIDTH + x].entity_bottom)
			}
			if game_state.arena[y * ARENA_WIDTH + x].entity != nil {
				game_state.arena[y * ARENA_WIDTH + x].entity.draw(game_state.arena[y * ARENA_WIDTH + x].entity)
			}
			if game_state.arena[y * ARENA_WIDTH + x].entity_top != nil {
				game_state.arena[y * ARENA_WIDTH + x].entity_top.draw(game_state.arena[y * ARENA_WIDTH + x].entity_top)
			}
		}
	}

	index := 0
	for &dt in game_state.damage_texts {
		dt.color = dt.color
		dt.timer += rl.GetFrameTime()
		lerp := math.lerp(f32(255), f32(0), dt.timer)
		dt.color.a = u8(lerp)
		dt.position.y -= rl.GetFrameTime() * 10
		rl.DrawText(fmt.ctprint(dt.text), i32(dt.position.x), i32(dt.position.y), 20, dt.color)
		if dt.timer >= 0.5 {
			ordered_remove(&game_state.damage_texts, index)
		}
		else {
			index += 1
		}
	}

	/*for &entity in game_state.entities {
		if !entity.allocated do continue

		// call the update function
		entity.draw(&entity)
	}*/

	rl.EndMode2D()

	if game_state.order[game_state.order_index].kind == .player {
		rl.DrawText(fmt.ctprint(game_state.order[game_state.order_index].name, " (", game_state.order[game_state.order_index].class, ")", sep= ""), 0, 0, 20, game_state.order[game_state.order_index].color)
		rl.DrawText(fmt.ctprint("HP:", game_state.order[game_state.order_index].current_life), 0, 20, 20, rl.WHITE)
		rl.DrawText(fmt.ctprint("END:", game_state.order[game_state.order_index].current_endurance), 0, 40, 20, rl.WHITE)
		index := 0
		for t in game_state.order[game_state.order_index].tags {
			rl.DrawText(fmt.ctprint("tag :", t), 0, i32(60 + index), 20, rl.WHITE)
			index += 20
		}

		/*rl.DrawText(fmt.ctprint("DMG:", game_state.order[game_state.order_index].entity_stats.damage), 0, 40, 20, rl.WHITE)
		rl.DrawText(fmt.ctprint("SPEED:", game_state.order[game_state.order_index].entity_stats.speed), 0, 60, 20, rl.WHITE)
		rl.DrawText(fmt.ctprint("PSY:", game_state.order[game_state.order_index].entity_stats.psyche), 0, 80, 20, rl.WHITE)
		rl.DrawText(fmt.ctprint("TECH:", game_state.order[game_state.order_index].entity_stats.technology), 0, 100, 20, rl.WHITE)
		rl.DrawText(fmt.ctprint("CHANCE:", game_state.order[game_state.order_index].entity_stats.chance), 0, 120, 20, rl.WHITE)
		rl.DrawText(fmt.ctprint("END:", game_state.order[game_state.order_index].current_endurance), 0, 140, 20, rl.WHITE)
		rl.DrawText(fmt.ctprint("AGI:", game_state.order[game_state.order_index].entity_stats.agility), 0, 160, 20, rl.WHITE)
		rl.DrawText(fmt.ctprint(game_state.order[game_state.order_index].name), 0, 180, 20, rl.WHITE)
		rl.DrawText(fmt.ctprint("mutation:", game_state.order[game_state.order_index].mutation), 0, 200, 20, game_state.order[game_state.order_index].mutation == .none ? rl.WHITE : game_state.order[game_state.order_index].mutation_stats.good ? rl.GREEN : rl.RED)*/
	}

	if game_state.info_entity != nil {
		rl.DrawText(fmt.ctprint(game_state.info_entity.kind), 1300, 0, 20, rl.WHITE)
		rl.DrawText(fmt.ctprint("HP:", game_state.info_entity.current_life), 1300, 20, 20, rl.WHITE)
		if game_state.info_entity.kind == .player {
			rl.DrawText(fmt.ctprint(game_state.info_entity.entity_stats.entity_age), 1300, 40, 20, rl.WHITE)
		}
		rl.DrawText(fmt.ctprint("SPEED:", game_state.info_entity.entity_stats.speed), 1300, 60, 20, rl.WHITE)
		rl.DrawText(fmt.ctprint("PSY:", game_state.info_entity.entity_stats.psyche), 1300, 80, 20, rl.WHITE)
		rl.DrawText(fmt.ctprint("VIT:", game_state.info_entity.entity_stats.vitality), 1300, 100, 20, rl.WHITE)
		rl.DrawText(fmt.ctprint("CHANCE:", game_state.info_entity.entity_stats.chance), 1300, 120, 20, rl.WHITE)
		rl.DrawText(fmt.ctprint("AGI:", game_state.info_entity.entity_stats.agility), 1300, 140, 20, rl.WHITE)
		rl.DrawText(fmt.ctprint("STR:", game_state.info_entity.entity_stats.strength), 1300, 160, 20, rl.WHITE)
		rl.DrawText(fmt.ctprint("NAME:", game_state.info_entity.name), 1300, 180, 20, rl.WHITE)
		rl.DrawText(fmt.ctprint("mutation", game_state.info_entity.mutation), 1300, 200, 20, rl.WHITE)
		rl.DrawText(fmt.ctprint("class", game_state.info_entity.class), 1300, 220, 20, rl.WHITE)
		rl.DrawText(fmt.ctprint("cell", game_state.info_entity.cell.x, " : ", game_state.info_entity.cell.y), 1300, 240, 20, rl.WHITE)
		rl.DrawText(fmt.ctprint("evade", game_state.info_entity.current_evade), 1300, 260, 20, rl.WHITE)
		index := 0
		for t in game_state.info_entity.tags {
			rl.DrawText(fmt.ctprint("tag :", t,), 1300, i32(280 + index), 20, rl.WHITE)
			index += 20
		}
	}

	x_offset := 0
	index = 0
	rl.DrawText(fmt.ctprint(game_state.turn_number), i32(1470), 5, 30, rl.WHITE)
	for &e in game_state.order {
		rl.DrawTexturePro(e.current_sprite, rl.Rectangle{0, 0, 32, 32}, rl.Rectangle{f32(1500 + x_offset), 5, 32, 32}, {0, 0}, 0, e.color)
		if index == game_state.order_index {
			rl.DrawText(fmt.ctprint("^"), i32(1500 + x_offset + 10), 45, 30, rl.WHITE)
		}
		x_offset += 32
		index += 1
	}

	if game_state.order[game_state.order_index].kind == .player {

		game_state.end_turn_button.draw(&game_state.end_turn_button)

		move_text := fmt.ctprint("Move\n(", game_state.order[game_state.order_index].entity_stats.speed, ")", sep = "")
		game_state.move_button.text = string(move_text)
		game_state.move_button.draw(&game_state.move_button)

		attack_text := fmt.ctprint(game_state.order[game_state.order_index].base_attack.name, "\n(dmg:", game_state.order[game_state.order_index].current_damage, " | rng:", game_state.order[game_state.order_index].base_attack.range, ")", sep = "")
		if game_state.order[game_state.order_index].base_attack.damage_type == .range {
			attack_text = fmt.ctprint(game_state.order[game_state.order_index].base_attack.name, "\n(dmg:", game_state.order[game_state.order_index].current_damage, " | rng:", game_state.order[game_state.order_index].entity_stats.agility, ")", sep = "")
		}
		game_state.attack_button.text = string(attack_text)
		game_state.attack_button.draw(&game_state.attack_button)

		offset_ability := 0
		for a in game_state.order[game_state.order_index].class_stats.ability {
			if a != nil {
				ability_text := fmt.ctprint()
				if a.ability_type == .damage {
					ability_text = fmt.ctprint(a.name, "\n(dmg:", a.value, " | rng:", a.range, ")", sep = "")
				}
				else if a.ability_type == .movement {
					ability_text = fmt.ctprint(a.name, "\n(rng:", a.range, ")", sep = "")
				}
				else if a.ability_type == .heal {
					ability_text = fmt.ctprint(a.name, "\n(heal:", a.value, " | rng:", a.range, ")", sep = "")
				}
				game_state.ability_button.text = string(ability_text)
				game_state.ability_button.x = f32(320 + offset_ability)
				if a.cost > game_state.order[game_state.order_index].current_endurance {
					game_state.ability_button.disabled = true
				}
				game_state.ability_button.draw(&game_state.ability_button)
				offset_ability += 160
			}
		}
	}

	if game_state.game_finished && game_state.entity_animated == 0 {
		rl.DrawRectangleRec(rl.Rectangle{(WINDOW_WIDTH - 1000) / 2, (WINDOW_HEIGHT - 1000) / 2, 1000, 1000}, rl.GRAY)
		rl.DrawText(fmt.ctprint("YOU WIN !"), WINDOW_WIDTH / 2 - 50, WINDOW_HEIGHT / 2 - 150, 50, rl.WHITE)
		rl.DrawText(fmt.ctprint("Rewards : "), WINDOW_WIDTH / 2 - 50, WINDOW_HEIGHT / 2 - 100, 40, rl.WHITE)
		rl.DrawText(fmt.ctprint("10 interstellar coins "), WINDOW_WIDTH / 2 - 50, WINDOW_HEIGHT / 2 - 50, 25, rl.WHITE)
		game_state.end_combat_button.draw(&game_state.end_combat_button)
	}
}

check_mouse_hover_cell :: proc() {
	mouse_pos := rl.GetMousePosition() + camera.target * camera.zoom
	x := int(math.ceil_f32(mouse_pos.x / (SPRITE_SIZE * camera.zoom))) - 4
	y := int(math.ceil_f32(mouse_pos.y / (SPRITE_SIZE * camera.zoom))) - 4
	if x >= ARENA_WIDTH || x < 0 {
		return
	}
	if y >= ARENA_HEIGHT || y < 0 {
		return
	}

	rl.DrawTextureV(hover_cell_sprite, {f32(OFFSET_X + x * SPRITE_SIZE), f32(OFFSET_Y + y * SPRITE_SIZE)}, rl.RED)
}

on_battle_enter :: proc() {
	player_spawned : [dynamic]^Cell
	enemy_spawned : [dynamic]^Cell
	other_spawned : [dynamic]^Cell

	for y in 0..<ARENA_HEIGHT{
		for x in 0..<ARENA_WIDTH{
			if game_state.arena[y * ARENA_WIDTH + x].type_loaded == 1 {
				append(&player_spawned, &game_state.arena[y * ARENA_WIDTH + x])
			}
			else if game_state.arena[y * ARENA_WIDTH + x].type_loaded == 2 {
				append(&enemy_spawned, &game_state.arena[y * ARENA_WIDTH + x])
			}
			else {
				append(&other_spawned, &game_state.arena[y * ARENA_WIDTH + x])
			}
		}
	} 

	rand.shuffle(player_spawned[:])
	rand.shuffle(enemy_spawned[:])
	rand.shuffle(other_spawned[:])

	block := int(rl.GetRandomValue(i32(game_state.level.block_min), i32(game_state.level.block_max)))

	for b in 0..<block {
		other_spawned[b].blocked = true
		ordered_remove(&other_spawned, b)
	}

	bush := int(rl.GetRandomValue(i32(game_state.level.bush_min), i32(game_state.level.bush_max)))

	for b in 0..<bush {
		bush_entity := entity_create(.bush)
		place_entity(bush_entity, other_spawned[b].x, other_spawned[b].y, .top)
		append(&other_spawned[b].elements, hidden_element)
		ordered_remove(&other_spawned, b)
	}

	for &b in other_spawned {
		append(&b.tag_to_remove, "bush")
	}

	for c in 0..<4 {
		place_entity(game_state.clones[c], player_spawned[c].x, player_spawned[c].y, .mid)
	}

    for &c in game_state.clones {
    	c.current_endurance = c.entity_stats.endurance
		c.current_damage = c.entity_stats.strength
    }

    clear(&game_state.enemies)

    for e in 0..<3 {
    	enemy := entity_create(.enemy)
	    enemy.entity_stats = fly_stats
	    if e == 0 {
	    	 enemy.name = "mother fucker"
	    }
	    else if e == 1 {
	    	enemy.name = "dummy"
	    }
	    else {
	    	enemy.name = "ass"
	    }
	    init_entity(enemy)
	    append(&game_state.enemies, enemy)
	    place_entity(enemy, enemy_spawned[e].x, enemy_spawned[e].y, .mid)
	    enemy.target = game_state.clones[0]
    }

    clear(&game_state.order)

    for &e in game_state.entities {
    	if !e.allocated do continue
    	if e.kind == .player || e.kind == .enemy {
	    	append(&game_state.order, &e)
    	}
    }

    game_state.order_index = 0
    game_state.turn_number = 1
	slice.sort_by(game_state.order[:], entity_order)
}