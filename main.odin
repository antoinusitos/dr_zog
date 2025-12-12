package game

import "."
import "core:log"
import "core:slice"
import "core:math"
import "core:fmt"
import rl "vendor:raylib"
import "core:strings"
import "core:strconv"

quick_test := true

main :: proc() {
	rl.InitWindow(WINDOW_WIDTH, WINDOW_HEIGHT, "Dr_Zog")
	//rl.ToggleBorderlessWindowed()

    camera.zoom = 2

    for y in 0..<ARENA_HEIGHT{
		for x in 0..<ARENA_WIDTH{
			game_state.arena[y * ARENA_WIDTH + x].x = x
			game_state.arena[y * ARENA_WIDTH + x].y = y
		}
	}

	init_main_menu_ui()

	floor_sprite = rl.LoadTexture("Floor.png")
	bee_sprite = rl.LoadTexture("Bee.png")
	bee_dead_sprite = rl.LoadTexture("Bee_Dead.png")
	baby_player_sprite = rl.LoadTexture("Baby_Player.png")
	child_player_sprite = rl.LoadTexture("Child_Player.png")
	teen_player_sprite = rl.LoadTexture("Teen_Player.png")
	player_sprite = rl.LoadTexture("Player.png")
	old_player_sprite = rl.LoadTexture("Old_Player.png")

	init_main_menu()

	if quick_test {
		for i in 0..<4 {
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

				    game_state.clones[game_state.order_index].class = game_state.possible_class[i]
					apply_class(game_state.clones[game_state.order_index])
				}
				index += 1
			}
		}
		game_state.all_clone_created = true
		game_state.all_clone_created_ready = true
		game_state.order_index = 0

		place_entity(game_state.clones[0], 0, 0)
	    place_entity(game_state.clones[1], 1, 0)
	    place_entity(game_state.clones[2], 2, 0)
	    place_entity(game_state.clones[3], 3, 0)

	    enemy := entity_create(.enemy)
	    enemy.entity_stats = fly_stats
	    enemy.name = "ass"
	    init_entity(enemy)
	    append(&game_state.enemies, enemy)
	    place_entity(enemy, 9, 9)
		enemy = entity_create(.enemy)
	    enemy.entity_stats = fly_stats
	    enemy.name = "mother fucker"
	    init_entity(enemy)
	    append(&game_state.enemies, enemy)
	    place_entity(enemy, 8, 9)
	    enemy = entity_create(.enemy)
	    enemy.entity_stats = fly_stats
	    enemy.name = "dummy"
	    init_entity(enemy)
	    place_entity(enemy, 7, 9)
	    append(&game_state.enemies, enemy)

	    for &e in game_state.entities {
	    	if !e.allocated do continue
	    	append(&game_state.order, &e)
	    }

	    game_state.order_index = 0
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
bee_dead_sprite : rl.Texture2D
baby_player_sprite : rl.Texture2D
child_player_sprite : rl.Texture2D
teen_player_sprite : rl.Texture2D
player_sprite : rl.Texture2D
old_player_sprite : rl.Texture2D

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
	}

	return new_entity
}



entity_destroy :: proc(entity: ^Entity) {
	entity^ = {} // it's really that simple
}

default_draw_based_on_entity_data :: proc(entity: ^Entity) {
	rl.DrawTextureV(entity.sprite, {entity.position.x, -entity.position.y - 10}, entity.color)
}
 
setup_player :: proc(entity: ^Entity) {
	entity.sprite = rl.LoadTexture("Player.png")
	entity.kind = .player
	entity.sprite_size = 32
	entity.color = rl.WHITE
	entity.mutation = Mutation(int(rl.GetRandomValue(0, len(Mutation) - 1)))

	entity.update = proc(entity: ^Entity) {
	}
	entity.draw = proc(entity: ^Entity) {
		default_draw_based_on_entity_data(entity)
	}
}

setup_enemy :: proc(entity: ^Entity) {
	entity.sprite = bee_sprite
	entity.kind = .enemy
	entity.sprite_size = 32
	entity.color = rl.WHITE
	entity.class = .none
	entity.current_life = 2

	entity.update = proc(entity: ^Entity) {
	}
	entity.draw = proc(entity: ^Entity) {
		default_draw_based_on_entity_data(entity)
	}
}

setup_one_button :: proc(button : ^Button) {
	button.button_type = .once
	button.update = proc(button : ^Button) {
		mouse_pos := rl.GetMousePosition()

		if mouse_pos.x >= button.x && mouse_pos.x <= button.x + button.width &&
			mouse_pos.y >= button.y && mouse_pos.y <= button.y + button.height {
				button.is_hover = true
				
				if rl.IsMouseButtonPressed(.LEFT) {
					button.is_clicked = true
					button.on_click(button)
				}
				else if rl.IsMouseButtonReleased(.LEFT) {
					button.is_clicked = false
					button.on_release(button)
				}
		}
		else {
			button.is_hover = false
		}
	}
	button.draw = proc(button : ^Button) {
		if button.is_clicked {
			rl.DrawRectangleRec(rl.Rectangle{button.x, button.y, button.width, button.height}, button.clicked_color)
		}
		else {
			rl.DrawRectangleRec(rl.Rectangle{button.x, button.y, button.width, button.height}, button.is_hover ? button.hover_color : button.background_color)
		}
		rl.DrawText(fmt.ctprint(button.text), i32(button.x + button.text_offset.x), i32(button.y + + button.text_offset.y), button.text_size, rl.BLACK)
	}

	button.on_click = proc(button : ^Button) {

	}
	button.on_down = proc(button : ^Button) {
		
	}
	button.on_release = proc(button : ^Button) {
		
	}
	button.on_filled = proc(button : ^Button) {
		
	}
}

setup_filling_button :: proc(button : ^Button) {
	button.button_type = .filling
	button.update = proc(button : ^Button) {
		mouse_pos := rl.GetMousePosition()

		if mouse_pos.x >= button.x && mouse_pos.x <= button.x + button.width &&
			mouse_pos.y >= button.y && mouse_pos.y <= button.y + button.height {
				button.is_hover = true
				
				if rl.IsMouseButtonDown(.LEFT) {
					button.is_clicked = true
					button.fill_percent += rl.GetFrameTime()
					if button.fill_percent >= button.fill_max {
						button.fill_percent = button.fill_max
						if !button.fill_auto_reset {
							if !button.filled_done {
								button.filled_done = true
								button.on_filled(button)
							}
						}
						else {
							button.fill_percent = 0
							button.on_filled(button)
						}
					}
				}
				else if rl.IsMouseButtonReleased(.LEFT) {
					button.is_clicked = false
					button.fill_percent = 0
					button.filled_done = false
				}
		}
		else {
			button.is_hover = false
		}
	}
	button.draw = proc(button : ^Button) {
		if button.is_clicked {
			rl.DrawRectangleRec(rl.Rectangle{button.x, button.y, button.width, button.height}, button.background_color)
			rl.DrawRectangleRec(rl.Rectangle{button.x, button.y, f32(button.width * (button.fill_percent / button.fill_max)) , button.height}, button.fill_color)
		}
		else {
			rl.DrawRectangleRec(rl.Rectangle{button.x, button.y, button.width, button.height}, button.is_hover ? button.hover_color : button.background_color)
		}
		rl.DrawText(fmt.ctprint(button.text), i32(button.x + button.text_offset.x), i32(button.y + button.text_offset.y), button.text_size, rl.BLACK)
	}

	button.on_click = proc(button : ^Button) {

	}
	button.on_down = proc(button : ^Button) {
		
	}
	button.on_release = proc(button : ^Button) {
		
	}
	button.on_filled = proc(button : ^Button) {
		
	}
}


init_entity :: proc(entity: ^Entity) {
	if entity.kind == .player {
		switch entity.entity_stats.entity_age {
			case .baby:
				entity.sprite = baby_player_sprite
			case .kid:
				entity.sprite = child_player_sprite
			case .teen:
				entity.sprite = teen_player_sprite
			case .adult:
				entity.sprite = player_sprite
			case .senior:
				entity.sprite = old_player_sprite
		}
	}

	for m in mutation_stats {
		if m.mutation == entity.mutation {
			entity.mutation_stats = m
			entity.entity_stats.agility += m.stats.agility
			entity.entity_stats.chance += m.stats.chance
			entity.entity_stats.damage += m.stats.damage
			entity.entity_stats.fatigue += m.stats.fatigue
			entity.entity_stats.max_life += m.stats.max_life
			entity.entity_stats.psyche += m.stats.psyche
			entity.entity_stats.speed += m.stats.speed
			entity.entity_stats.technology += m.stats.technology
		}
	}

	resolve_stats(entity)
}

remove_class :: proc (entity : ^Entity) {
	for c in class_stats {
		if c.class == entity.class {
			entity.class = .none
			entity.entity_stats.agility -= c.stats.agility
			entity.entity_stats.chance -= c.stats.chance
			entity.entity_stats.damage -= c.stats.damage
			entity.entity_stats.fatigue -= c.stats.fatigue
			entity.entity_stats.max_life -= c.stats.max_life
			entity.entity_stats.psyche -= c.stats.psyche
			entity.entity_stats.speed -= c.stats.speed
			entity.entity_stats.technology -= c.stats.technology
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
			entity.entity_stats.damage += c.stats.damage
			entity.entity_stats.fatigue += c.stats.fatigue
			entity.entity_stats.max_life += c.stats.max_life
			entity.entity_stats.psyche += c.stats.psyche
			entity.entity_stats.speed += c.stats.speed
			entity.entity_stats.technology += c.stats.technology
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
	if entity.entity_stats.damage <= 0 {
		entity.entity_stats.damage = 1
	}
	if entity.entity_stats.fatigue <= 0 {
		entity.entity_stats.fatigue = 1
	}
	if entity.entity_stats.max_life <= 0 {
		entity.entity_stats.max_life = 1
	}
	if entity.entity_stats.psyche <= 0 {
		entity.entity_stats.psyche = 1
	}
	if entity.entity_stats.speed <= 0 {
		entity.entity_stats.speed = 1
	}
	if entity.entity_stats.technology <= 0 {
		entity.entity_stats.technology = 1
	}

	entity.current_life = entity.entity_stats.max_life
	entity.current_level = 1
	entity.action_per_turn = 1
	entity.current_stress = 0
	entity.current_endurance = entity.entity_stats.fatigue
}

place_entity :: proc(entity: ^Entity, x : int, y : int) {
	if entity.cell != nil {
		entity.cell.entity = nil
	}
	game_state.arena[y * ARENA_WIDTH + x].entity = entity
	game_state.arena[y * ARENA_WIDTH + x].entity.position = {f32(OFFSET_X + x * SPRITE_SIZE), f32(-OFFSET_Y - y * SPRITE_SIZE)}
	entity.cell = &game_state.arena[y * ARENA_WIDTH + x]
}

end_turn :: proc() {
	end_movement()
	end_attack()

	game_state.order_index += 1
	if game_state.order_index >= len(game_state.order) {
		game_state.order_index = 0
	}

	game_state.order[game_state.order_index].movement_done = false
	game_state.order[game_state.order_index].current_endurance += END_BY_TURN
}

init_main_menu :: proc() {
	game_state.game_step = .cloning

	append(&game_state.possible_class, Class.tank)
	append(&game_state.possible_class, Class.tech)
	append(&game_state.possible_class, Class.warrior)
	append(&game_state.possible_class, Class.healer)
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

check_move :: proc() {
	if game_state.order[game_state.order_index].kind != .player {
		return
	}

	mouse_pos := rl.GetMousePosition() + camera.target * camera.zoom
	x := mouse_pos.x
	y := mouse_pos.y
	if x >= 0 && x <= 150 && y >= 1000 && y <= 1080 {
		reset_active_cells()
		x := game_state.order[game_state.order_index].cell.x
		y := game_state.order[game_state.order_index].cell.y
		movement_size := game_state.order[game_state.order_index].class_stats.movement_size
		array : [dynamic]rl.Vector2
		for dx := -movement_size; dx <= movement_size; dx += 1 {
	        for dy := -movement_size; dy <= movement_size; dy += 1 {
	            if abs(dx) + abs(dy) <= movement_size {
	            	append(&array, rl.Vector2{f32(dx), f32(dy)})
	            }
	        }
	    }

		for move in array {
			move_x := int(move[0])
			move_y := int(move[1])

			if x + move_x < 0 || y + move_y < 0 do continue
			if x + move_x >= ARENA_WIDTH || y + move_y >= ARENA_HEIGHT do continue
			if game_state.arena[(y + move_y) * ARENA_WIDTH + x + move_x].entity != nil do continue

			game_state.arena[(y + move_y) * ARENA_WIDTH + x + move_x].cell_active = true
		}
	}
}

check_attack :: proc() {
	if game_state.order[game_state.order_index].kind != .player {
		return
	}

	mouse_pos := rl.GetMousePosition() + camera.target * camera.zoom
	x := mouse_pos.x
	y := mouse_pos.y
	if x >= 160 && x <= 310 && y >= 1000 && y <= 1080 {
		reset_active_cells()
		x := game_state.order[game_state.order_index].cell.x
		y := game_state.order[game_state.order_index].cell.y
		attack_size := game_state.order[game_state.order_index].class_stats.attack_size
		for move in -attack_size..=attack_size {
			if x + move < 0 || y  < 0 do continue
			if x + move == x do continue
			if x + move >= ARENA_WIDTH || y >= ARENA_HEIGHT do continue

			game_state.arena[y * ARENA_WIDTH + x + move].cell_active = true
		}
		for move in -attack_size..=attack_size {
			if x < 0 || y + move < 0 do continue
			if y + move == y do continue
			if x >= ARENA_WIDTH || y + move >= ARENA_HEIGHT do continue

			game_state.arena[(y + move) * ARENA_WIDTH + x].cell_active = true
		}
	}
}

check_abilities :: proc() {
	if game_state.order[game_state.order_index].kind != .player {
		return
	}

	mouse_pos := rl.GetMousePosition() + camera.target * camera.zoom
	x := mouse_pos.x
	y := mouse_pos.y

	offset_ability := 0
	for a in game_state.order[game_state.order_index].class_stats.ability {
		if a != nil {
			if x >= f32(320 + offset_ability) && x <= f32(320 + offset_ability + 160) && y >= 1000 && y <= 1080 {
				#partial switch a.ability_type {
					case .damage :
					{
						reset_active_cells()
						x := game_state.order[game_state.order_index].cell.x
						y := game_state.order[game_state.order_index].cell.y
						attack_size := a.value_2
						for move in -attack_size..=attack_size {
							if x + move < 0 || y  < 0 do continue
							if x + move == x do continue
							if x + move >= ARENA_WIDTH || y >= ARENA_HEIGHT do continue

							game_state.arena[y * ARENA_WIDTH + x + move].cell_active = true
						}
						for move in -attack_size..=attack_size {
							if x < 0 || y + move < 0 do continue
							if y + move == y do continue
							if x >= ARENA_WIDTH || y + move >= ARENA_HEIGHT do continue

							game_state.arena[(y + move) * ARENA_WIDTH + x].cell_active = true
						}
					}
				}
			}
			offset_ability += 160
		}
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
	damaged_entity.current_life -= attacking_entity.entity_stats.damage
	if damaged_entity.current_life <= 0 {
		if damaged_entity.kind == .enemy {
			damaged_entity.sprite = bee_dead_sprite
		}
	}
	attacking_entity.current_endurance -= 2
	check_all_dead()
	end_attack()
}

check_all_dead :: proc() {
	all_dead := true
	for e in game_state.enemies {
		if e != nil && e.current_life >= 0 {
			all_dead = false
			break
		}
	}

	if all_dead {
		game_state.game_finished = true
		// return to main menu
	}
}

ability :: proc(damaged_entity : ^Entity, attacking_entity : ^Entity, index : int) {
	#partial switch attacking_entity.class_stats.ability[index].ability_type {
		case .damage:
		{
			damaged_entity.current_life -= attacking_entity.class_stats.ability[index].value
			if damaged_entity.current_life <= 0 {
				if damaged_entity.kind == .enemy {
					damaged_entity.sprite = bee_dead_sprite
				}
			}
			attacking_entity.current_endurance -= attacking_entity.class_stats.ability[index].cost
		}
	}
	game_state.ability_1 = false
	reset_active_cells()
}

update :: proc() {
	
	switch game_state.game_step {
		case .cloning:
			update_main_menu()
		case .battle:
			update_battle()
	}
}

update_main_menu :: proc() {
	if game_state.all_clone_created_ready {
		game_state.next_clone_button.update(&game_state.next_clone_button)
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

update_battle :: proc() {
	for &entity in game_state.entities {
		if !entity.allocated do continue

		// call the update function
		entity.update(&entity)
	}

	if game_state.game_finished {
		return
	}

	if game_state.order[game_state.order_index].kind != .player {
		if game_state.order[game_state.order_index].current_life <= 0 {
			end_turn()
			return
		}
		game_state.ai_turn_time += rl.GetFrameTime()
		if game_state.ai_turn_time >= 0.5 {
			game_state.ai_turn_time = 0
			end_turn()
		}
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

	reset_active_cells()

	if game_state.want_to_move {
		x := game_state.order[game_state.order_index].cell.x
		y := game_state.order[game_state.order_index].cell.y
		movement_size := game_state.order[game_state.order_index].class_stats.movement_size
		array : [dynamic]rl.Vector2
		for dx := -movement_size; dx <= movement_size; dx += 1 {
	        for dy := -movement_size; dy <= movement_size; dy += 1 {
	            if abs(dx) + abs(dy) <= movement_size {
	            	append(&array, rl.Vector2{f32(dx), f32(dy)})
	            }
	        }
	    }

	    for move in array {
			move_x := int(move[0])
			move_y := int(move[1])

			if x + move_x < 0 || y + move_y < 0 do continue
			if x + move_x >= ARENA_WIDTH || y + move_y >= ARENA_HEIGHT do continue
			if game_state.arena[(y + move_y) * ARENA_WIDTH + x + move_x].entity != nil do continue

			game_state.arena[(y + move_y) * ARENA_WIDTH + x + move_x].cell_active = true
		}
	}
	else if game_state.want_to_attack {
		x := game_state.order[game_state.order_index].cell.x
		y := game_state.order[game_state.order_index].cell.y
		attack_size := game_state.order[game_state.order_index].class_stats.attack_size
		for move in -attack_size..=attack_size {
			if x + move < 0 || y  < 0 do continue
			if x + move == x do continue
			if x + move >= ARENA_WIDTH || y >= ARENA_HEIGHT do continue

			game_state.arena[y * ARENA_WIDTH + x + move].cell_active = true
		}
		for move in -attack_size..=attack_size {
			if x < 0 || y + move < 0 do continue
			if y + move == y do continue
			if x >= ARENA_WIDTH || y + move >= ARENA_HEIGHT do continue

			game_state.arena[(y + move) * ARENA_WIDTH + x].cell_active = true
		}
	}
	else if game_state.ability_1 && game_state.order[game_state.order_index].class_stats.ability[0] != nil {
		#partial switch (game_state.order[game_state.order_index].class_stats.ability[0].ability_type) {
			case .damage :
			{
				reset_active_cells()
				x := game_state.order[game_state.order_index].cell.x
				y := game_state.order[game_state.order_index].cell.y
				attack_size := game_state.order[game_state.order_index].class_stats.ability[0].value_2
				for move in -attack_size..=attack_size {
					if x + move < 0 || y  < 0 do continue
					if x + move == x do continue
					if x + move >= ARENA_WIDTH || y >= ARENA_HEIGHT do continue

					game_state.arena[y * ARENA_WIDTH + x + move].cell_active = true
				}
				for move in -attack_size..=attack_size {
					if x < 0 || y + move < 0 do continue
					if y + move == y do continue
					if x >= ARENA_WIDTH || y + move >= ARENA_HEIGHT do continue

					game_state.arena[(y + move) * ARENA_WIDTH + x].cell_active = true
				}
			}
		}
	}

	check_move()

	check_attack()

	check_abilities()

	if rl.IsMouseButtonPressed(.LEFT) && game_state.order[game_state.order_index].kind == .player && (game_state.want_to_move || game_state.want_to_attack) {
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
				find_path(game_state.order[game_state.order_index].cell.x, game_state.order[game_state.order_index].cell.y, x, y)
				place_entity(game_state.order[game_state.order_index], x, y)
				game_state.order[game_state.order_index].movement_done = true 
				end_movement()
			}
			else if game_state.want_to_attack && game_state.arena[y * ARENA_WIDTH + x].entity != nil {
				attack(game_state.arena[y * ARENA_WIDTH + x].entity, game_state.order[game_state.order_index])
			}
			else if game_state.ability_1 && game_state.arena[y * ARENA_WIDTH + x].entity != nil {
				attack(game_state.arena[y * ARENA_WIDTH + x].entity, game_state.order[game_state.order_index])
			}
		}
	}
}

init_main_menu_ui :: proc() {
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
		fill_auto_reset = true
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
		text = "Start",
		fill_percent = 0,
		fill_max = 1.0,
		text_size = 20,
		text_offset = {40, 15}
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
		text = "Next Clone",
		fill_percent = 0,
		fill_max = 1.0,
		text_size = 20,
		text_offset = {20, 15}
	}
	setup_one_button(&game_state.next_clone_button)
	game_state.next_clone_button.on_click = proc(button : ^Button) {
		game_state.order_index += 1
		if game_state.order_index >= 4 {
			game_state.order_index = 0
		}
	}
}

draw :: proc() {
	switch game_state.game_step {
		case .cloning:
			draw_main_menu()
		case .battle:
			draw_battle()
	}

	rl.EndDrawing()	
}

draw_main_menu :: proc() {
	if game_state.all_clone_created_ready {
		rl.DrawText(fmt.ctprint("Gold : ", game_state.gold, sep = ""), WINDOW_WIDTH - 100, 10, 20, rl.WHITE)

		if len(game_state.possible_class) == 0 {
			if rl.GuiButton(rl.Rectangle{WINDOW_WIDTH / 2, WINDOW_HEIGHT / 2 - 200, 150, 50}, "Start Battle") {
				place_entity(game_state.clones[0], 0, 0)
			    place_entity(game_state.clones[1], 1, 0)
			    place_entity(game_state.clones[2], 2, 0)
			    place_entity(game_state.clones[3], 3, 0)

			    enemy := entity_create(.enemy)
			    enemy.entity_stats = fly_stats
			    enemy.name = "ass"
			    init_entity(enemy)
			    append(&game_state.enemies, enemy)
			    place_entity(enemy, 9, 9)
				enemy = entity_create(.enemy)
			    enemy.entity_stats = fly_stats
			    enemy.name = "mother fucker"
			    init_entity(enemy)
			    append(&game_state.enemies, enemy)
			    place_entity(enemy, 8, 9)
			    enemy = entity_create(.enemy)
			    enemy.entity_stats = fly_stats
			    enemy.name = "dummy"
			    init_entity(enemy)
			    place_entity(enemy, 7, 9)
			    append(&game_state.enemies, enemy)

			    for &e in game_state.entities {
			    	if !e.allocated do continue
			    	append(&game_state.order, &e)
			    }

			    game_state.order_index = 0
				slice.sort_by(game_state.order[:], entity_order)
				game_state.game_step = .battle
			}
		}

		game_state.next_clone_button.draw(&game_state.next_clone_button)

		/*if rl.GuiButton(rl.Rectangle{0, 350, 150, 50}, "Recycle Clone") {
			game_state.clones[game_state.order_index].entity_stats = all_stats[rl.GetRandomValue(0, len(all_stats) - 1)]
		    game_state.clones[game_state.order_index].name = names[rl.GetRandomValue(0, len(names) - 1)]
		    game_state.clones[game_state.order_index].mutation = Mutation(int(rl.GetRandomValue(0, len(Mutation) - 1)))
		    init_entity(game_state.clones[game_state.order_index])
		}*/

		if game_state.clones[game_state.order_index].class != .none {
			if rl.GuiButton(rl.Rectangle{160, 250, 150, 50}, "Remove Class") {
				append(&game_state.possible_class, game_state.clones[game_state.order_index].class)
				remove_class(game_state.clones[game_state.order_index])
			}
		}

		rl.DrawText(fmt.ctprint("Assign a class to each clone"), WINDOW_WIDTH / 2 - 150, 20, 20, rl.WHITE)

		offset_class_x := 0
		index := 0
		for c in game_state.possible_class {
			if rl.GuiButton(rl.Rectangle{f32(300 + offset_class_x), 50, 150, 50}, fmt.ctprint(c)) {
				if game_state.clones[game_state.order_index].class != .none {
					append(&game_state.possible_class, game_state.clones[game_state.order_index].class)
					remove_class(game_state.clones[game_state.order_index])
				}
				game_state.clones[game_state.order_index].class = c
				apply_class(game_state.clones[game_state.order_index])
				ordered_remove(&game_state.possible_class, index)

			}
			index += 1
			offset_class_x += 160
		}

		rl.DrawText(fmt.ctprint(game_state.clones[game_state.order_index].entity_stats.entity_age), 0, 0, 20, game_state.clones[game_state.order_index].color)
		rl.DrawText(fmt.ctprint("HP:", game_state.clones[game_state.order_index].current_life), 0, 20, 20, rl.WHITE)
		rl.DrawText(fmt.ctprint("DMG:", game_state.clones[game_state.order_index].entity_stats.damage), 0, 40, 20, rl.WHITE)
		rl.DrawText(fmt.ctprint("SPEED:", game_state.clones[game_state.order_index].entity_stats.speed), 0, 60, 20, rl.WHITE)
		rl.DrawText(fmt.ctprint("PSY:", game_state.clones[game_state.order_index].entity_stats.psyche), 0, 80, 20, rl.WHITE)
		rl.DrawText(fmt.ctprint("TECH:", game_state.clones[game_state.order_index].entity_stats.technology), 0, 100, 20, rl.WHITE)
		rl.DrawText(fmt.ctprint("CHANCE:", game_state.clones[game_state.order_index].entity_stats.chance), 0, 120, 20, rl.WHITE)
		rl.DrawText(fmt.ctprint("END:", game_state.clones[game_state.order_index].current_endurance), 0, 140, 20, rl.WHITE)
		rl.DrawText(fmt.ctprint("AGI:", game_state.clones[game_state.order_index].entity_stats.agility), 0, 160, 20, rl.WHITE)
		rl.DrawText(fmt.ctprint(game_state.clones[game_state.order_index].name), 0, 180, 20, rl.WHITE)
		rl.DrawText(fmt.ctprint("mutation:", game_state.clones[game_state.order_index].mutation_stats.description), 0, 200, 20, game_state.clones[game_state.order_index].mutation == .none ? rl.WHITE : game_state.clones[game_state.order_index].mutation_stats.good ? rl.GREEN : rl.RED)
		rl.DrawText(fmt.ctprint("class:", game_state.clones[game_state.order_index].class), 0, 220, 20, rl.WHITE)

		rl.DrawTextureEx(game_state.clones[game_state.order_index].sprite, {f32(WINDOW_WIDTH / 2), f32(WINDOW_HEIGHT / 2)}, 0, 5, game_state.clones[game_state.order_index].color)

		rl.DrawText(fmt.ctprint("Chance - Slightly affects all actions"), 0, WINDOW_HEIGHT - 20, 20, rl.WHITE)
		rl.DrawText(fmt.ctprint("Agility - Dodge chance and damage at long range"), 0, WINDOW_HEIGHT - 40, 20, rl.WHITE)
		rl.DrawText(fmt.ctprint("Technology - Mastery of gadgets and objects"), 0, WINDOW_HEIGHT - 60, 20, rl.WHITE)
		rl.DrawText(fmt.ctprint("Speed - Initiative"), 0, WINDOW_HEIGHT - 80, 20, rl.WHITE)
		rl.DrawText(fmt.ctprint("Psyche - Mental/psychic power"), 0, WINDOW_HEIGHT - 100, 20, rl.WHITE)
		rl.DrawText(fmt.ctprint("Damage - Physical attack power "), 0, WINDOW_HEIGHT - 120, 20, rl.WHITE)
		rl.DrawText(fmt.ctprint("Fatigue - Number of actions per turn "), 0, WINDOW_HEIGHT - 140, 20, rl.WHITE)
		rl.DrawText(fmt.ctprint("Heal Point - Total life "), 0, WINDOW_HEIGHT - 160, 20, rl.WHITE)
	}
	else {
		rl.DrawText(fmt.ctprint("Dr. Zog - A Revenge Story"), WINDOW_WIDTH / 2 - 500, 20, 75, rl.WHITE)

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

			rl.DrawTextureEx(c.sprite, {f32(WINDOW_WIDTH / 4 * offset_clone_x + (WINDOW_WIDTH / 16)), f32(WINDOW_HEIGHT / 2)}, 0, 5, c.color)
			rl.DrawText(fmt.ctprint(c.name), i32(WINDOW_WIDTH / 4 * offset_clone_x + (WINDOW_WIDTH / 16) + 32), WINDOW_HEIGHT / 2 + 175, 30, rl.WHITE)
			offset_clone_x += 1
		}
	}
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

			if game_state.arena[y * ARENA_WIDTH + x].entity != nil {
				game_state.arena[y * ARENA_WIDTH + x].entity.draw(game_state.arena[y * ARENA_WIDTH + x].entity)
			}
		}
	}

	/*for &entity in game_state.entities {
		if !entity.allocated do continue

		// call the update function
		entity.draw(&entity)
	}*/

	rl.EndMode2D()

	if game_state.order[game_state.order_index].kind == .player {
		rl.DrawText(fmt.ctprint(game_state.order[game_state.order_index].entity_stats.entity_age, " (", game_state.order[game_state.order_index].class, ")", sep= ""), 0, 0, 20, game_state.order[game_state.order_index].color)
		rl.DrawText(fmt.ctprint("HP:", game_state.order[game_state.order_index].current_life), 0, 20, 20, rl.WHITE)
		rl.DrawText(fmt.ctprint("DMG:", game_state.order[game_state.order_index].entity_stats.damage), 0, 40, 20, rl.WHITE)
		rl.DrawText(fmt.ctprint("SPEED:", game_state.order[game_state.order_index].entity_stats.speed), 0, 60, 20, rl.WHITE)
		rl.DrawText(fmt.ctprint("PSY:", game_state.order[game_state.order_index].entity_stats.psyche), 0, 80, 20, rl.WHITE)
		rl.DrawText(fmt.ctprint("TECH:", game_state.order[game_state.order_index].entity_stats.technology), 0, 100, 20, rl.WHITE)
		rl.DrawText(fmt.ctprint("CHANCE:", game_state.order[game_state.order_index].entity_stats.chance), 0, 120, 20, rl.WHITE)
		rl.DrawText(fmt.ctprint("END:", game_state.order[game_state.order_index].current_endurance), 0, 140, 20, rl.WHITE)
		rl.DrawText(fmt.ctprint("AGI:", game_state.order[game_state.order_index].entity_stats.agility), 0, 160, 20, rl.WHITE)
		rl.DrawText(fmt.ctprint(game_state.order[game_state.order_index].name), 0, 180, 20, rl.WHITE)
		rl.DrawText(fmt.ctprint("mutation:", game_state.order[game_state.order_index].mutation), 0, 200, 20, game_state.order[game_state.order_index].mutation == .none ? rl.WHITE : game_state.order[game_state.order_index].mutation_stats.good ? rl.GREEN : rl.RED)
	}

	if game_state.info_entity != nil {
		rl.DrawText(fmt.ctprint(game_state.info_entity.kind), 1300, 0, 20, rl.WHITE)
		rl.DrawText(fmt.ctprint("HP:", game_state.info_entity.current_life), 1300, 20, 20, rl.WHITE)
		if game_state.info_entity.kind == .player {
			rl.DrawText(fmt.ctprint(game_state.info_entity.entity_stats.entity_age), 1300, 40, 20, rl.WHITE)
		}
		rl.DrawText(fmt.ctprint("SPEED:", game_state.info_entity.entity_stats.speed), 1300, 60, 20, rl.WHITE)
		rl.DrawText(fmt.ctprint("PSY:", game_state.info_entity.entity_stats.psyche), 1300, 80, 20, rl.WHITE)
		rl.DrawText(fmt.ctprint("TECH:", game_state.info_entity.entity_stats.technology), 1300, 100, 20, rl.WHITE)
		rl.DrawText(fmt.ctprint("CHANCE:", game_state.info_entity.entity_stats.chance), 1300, 120, 20, rl.WHITE)
		rl.DrawText(fmt.ctprint("AGI:", game_state.info_entity.entity_stats.agility), 1300, 140, 20, rl.WHITE)
		rl.DrawText(fmt.ctprint("DMG:", game_state.info_entity.entity_stats.damage), 1300, 160, 20, rl.WHITE)
		rl.DrawText(fmt.ctprint("NAME:", game_state.info_entity.name), 1300, 180, 20, rl.WHITE)
		rl.DrawText(fmt.ctprint("mutation", game_state.info_entity.mutation), 1300, 200, 20, rl.WHITE)
		rl.DrawText(fmt.ctprint("class", game_state.info_entity.class), 1300, 220, 20, rl.WHITE)
	}

	x_offset := 0
	index := 0
	for &e in game_state.order {
		rl.DrawTexturePro(e.sprite, rl.Rectangle{0, 0, 32, 32}, rl.Rectangle{f32(1500 + x_offset), 5, 32, 32}, {0, 0}, 0, e.color)
		if index == game_state.order_index {
			rl.DrawText(fmt.ctprint("^"), i32(1500 + x_offset + 10), 45, 30, rl.WHITE)
		}
		x_offset += 32
		index += 1
	}

	if game_state.order[game_state.order_index].kind == .player {

		if rl.GuiButton(rl.Rectangle{WINDOW_WIDTH - 150, 0, 150, 50}, "End Turn") && !game_state.game_finished {
			end_turn()
		}

		move_text := fmt.ctprint("Move (", game_state.order[game_state.order_index].class_stats.movement_size, ")", sep = "")
		if rl.GuiButton(rl.Rectangle{0, 1000, 150, 50}, move_text) && game_state.order[game_state.order_index].kind == .player && !game_state.order[game_state.order_index].movement_done && !game_state.game_finished {
			end_attack()
			game_state.want_to_move = true
		}
		attack_text := fmt.ctprint("Attack (dmg:", game_state.order[game_state.order_index].entity_stats.damage, " | rng:", game_state.order[game_state.order_index].class_stats.attack_size, ")", sep = "")
		if rl.GuiButton(rl.Rectangle{160, 1000, 150, 50}, attack_text) && game_state.order[game_state.order_index].kind == .player && game_state.order[game_state.order_index].current_endurance > 0 && !game_state.game_finished {
			end_movement()
			game_state.want_to_attack = true
		}

		offset_ability := 0
		for a in game_state.order[game_state.order_index].class_stats.ability {
			if a != nil {
				if rl.GuiButton(rl.Rectangle{f32(320 + offset_ability), 1000, 150, 50}, fmt.ctprint(a.name)) && game_state.order[game_state.order_index].kind == .player && game_state.order[game_state.order_index].current_endurance > 0 {
					game_state.ability_1 = true
				}
				offset_ability += 160
			}
		}
	}

	if game_state.game_finished {
		rl.DrawRectangleRec(rl.Rectangle{(WINDOW_WIDTH - 1000) / 2, (WINDOW_HEIGHT - 1000) / 2, 1000, 1000}, rl.GRAY)
		rl.DrawText(fmt.ctprint("YOU WIN !"), WINDOW_WIDTH / 2 - 50, WINDOW_HEIGHT / 2 - 150, 50, rl.WHITE)
		rl.DrawText(fmt.ctprint("Rewards : "), WINDOW_WIDTH / 2 - 50, WINDOW_HEIGHT / 2 - 100, 40, rl.WHITE)
		rl.DrawText(fmt.ctprint("10 interstellar coins "), WINDOW_WIDTH / 2 - 50, WINDOW_HEIGHT / 2 - 50, 25, rl.WHITE)
		if rl.GuiButton(rl.Rectangle{WINDOW_WIDTH / 2 - 25, WINDOW_HEIGHT / 2 + 100, 150, 50}, "End Combat") {
			game_state.game_step = .cloning
			for &c in game_state.clones {
				entity_destroy(c)
				c = nil
			}
			for &e in game_state.enemies {
				entity_destroy(e)
			}
			clear(&game_state.enemies)
			game_state.order_index = 0
			game_state.all_clone_created = false
			game_state.all_clone_created_ready = false
			game_state.gold += 10
			init_main_menu()
		}
	}
}