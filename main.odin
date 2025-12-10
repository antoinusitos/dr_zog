package game

import "core:log"
import "core:slice"
import "core:math"
import "core:fmt"
import rl "vendor:raylib"
import "core:strings"
import "core:strconv"

WINDOW_WIDTH :: 1920
WINDOW_HEIGHT :: 1080
SPRITE_SIZE :: 32
OFFSET_X :: 100
OFFSET_Y :: 100

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

	floor_sprite = rl.LoadTexture("Floor.png")
	bee_sprite = rl.LoadTexture("Bee.png")
	bee_dead_sprite = rl.LoadTexture("Bee_Dead.png")
	baby_player_sprite = rl.LoadTexture("Baby_Player.png")
	child_player_sprite = rl.LoadTexture("Child_Player.png")
	teen_player_sprite = rl.LoadTexture("Teen_Player.png")
	player_sprite = rl.LoadTexture("Player.png")
	old_player_sprite = rl.LoadTexture("Old_Player.png")

    game_state.clones[0] = entity_create(.player)
    game_state.clones[0].entity_stats = all_stats[rl.GetRandomValue(0, len(all_stats) - 1)]
    game_state.clones[0].color = rl.BLUE
    game_state.clones[0].name = names[rl.GetRandomValue(0, len(names) - 1)]
    game_state.clones[1] = entity_create(.player)
    game_state.clones[1].entity_stats = all_stats[rl.GetRandomValue(0, len(all_stats) - 1)]
    game_state.clones[1].color = rl.RED
    game_state.clones[1].name = names[rl.GetRandomValue(0, len(names) - 1)]
    game_state.clones[2] = entity_create(.player)
    game_state.clones[2].entity_stats = all_stats[rl.GetRandomValue(0, len(all_stats) - 1)]
    game_state.clones[2].color = rl.GREEN
    game_state.clones[2].name = names[rl.GetRandomValue(0, len(names) - 1)]
    game_state.clones[3] = entity_create(.player)
    game_state.clones[3].entity_stats = all_stats[rl.GetRandomValue(0, len(all_stats) - 1)]
    game_state.clones[3].color = rl.YELLOW
    game_state.clones[3].name = names[rl.GetRandomValue(0, len(names) - 1)]
    init_entity(game_state.clones[0])
    init_entity(game_state.clones[1])
    init_entity(game_state.clones[2])
    init_entity(game_state.clones[3])

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

	slice.sort_by(game_state.order[:], entity_order)

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

MAX_ENTITIES :: 1024
ARENA_WIDTH :: 10
ARENA_HEIGHT :: 10
END_BY_TURN :: 2

MOVEMENTS_1 :: [4][2]int {
	{1, 0},
	{-1, 0},
	{0, 1},
	{0, -1},
}
MOVEMENTS_2 :: [12][2]int {
	{1, 0},
	{2, 0},
	{1, 1},
	{1, -1},
	{-1, 0},
	{-2, 0},
	{-1, 1},
	{-1, -1},
	{0, 1},
	{0, 2},
	{0, -1},
	{0, -2},
}
MOVEMENTS_3 :: [24][2]int {
	{1, 0},
	{2, 0},
	{3, 0},
	{0, 1},
	{0, 2},
	{0, 3},
	{0, -1},
	{0, -2},
	{0, -3},
	{-1, 0},
	{-2, 0},
	{-3, 0},
	{1, 1},
	{1, -1},
	{-1, 1},
	{-1, -1},
	{1, 2},
	{-1, 2},
	{1, -2},
	{-1, -2},
	{-2, 1},
	{2, 1},
	{-2, -1},
	{2, -1},
}

names := [12]string {
	"Oliver",
	"Jake",
	"Noah",
	"James",
	"Jack",
	"Connor",
	"Liam",
	"John",
	"Harry",
	"Jacob",
	"Mason",
	"Robert"
}

game_state: Game_State
Game_State :: struct {
	initialized: bool,
	entities: [MAX_ENTITIES]Entity,
	entity_id_gen: u64,
	entity_top_count: u64,
	world_name: string,
	player_handle: Entity_Handle,
	arena: [ARENA_WIDTH * ARENA_HEIGHT]Cell,
	clones: [4]^Entity,
	info_entity: ^Entity,
	want_to_move : bool,
	want_to_attack : bool,
	enemies : [dynamic]^Entity,
	order : [dynamic]^Entity,
	order_index : int,
	ai_turn_time : f32,
}

Entity_Handle :: struct {
	index: u64,
	id: u64,
}

Entity_Kind :: enum {
	nil,
	player,
	enemy,
}

Entity_Age :: enum {
	baby,
	kid,
	teen,
	adult,
	senior,
}

Entity_Stats :: struct {
	entity_age : Entity_Age,
	max_life : int, // Vitalité, vie totale 
	fatigue : int, // Vitalité, vie totale
	damage : int, // Puissance d’attaque physique
	psyche : int, // Puissance mentale/psychique 
	speed : int, // Vitesse, initiative, esquive
	technology : int, // Maîtrise des gadgets et objets
	agility : int, // Chance d'esquive et dégâts sur les longue distance
	chance : int, // Affecte légèrement toutes les actions
}

all_stats : [5]Entity_Stats = {
	Entity_Stats { entity_age = .baby, max_life = 2, fatigue = 2, damage = 1, psyche = 3, speed = 5, technology = 2, chance = 5 },
	Entity_Stats { entity_age = .kid, max_life = 3, fatigue = 2, damage = 2, psyche = 2, speed = 4, technology = 3, chance = 3 },
	Entity_Stats { entity_age = .teen, max_life = 3, fatigue = 2, damage = 3, psyche = 4, speed = 3, technology = 1, chance = 1 },
	Entity_Stats { entity_age = .adult, max_life = 4, fatigue = 2, damage = 4, psyche = 3, speed = 2, technology = 4, chance = 2 },
	Entity_Stats { entity_age = .senior, max_life = 2, fatigue = 2, damage = 3, psyche = 5, speed = 1, technology = 3, chance = 4 },
}

fly_stats := Entity_Stats { max_life = 2, fatigue = 2, damage = 1, psyche = 3, speed = 5, technology = 2, chance = 5 }

Entity :: struct {
	allocated: bool,
	handle: Entity_Handle,
	kind: Entity_Kind,

	// player
	sprite : rl.Texture,
	position : rl.Vector2,
	sprite_size: f32,
	color : rl.Color,

	//stats
	entity_stats : Entity_Stats,

	//details
	current_level : int,
	current_life : int,
	current_endurance : int,
	action_per_turn : int, // 1-3
	current_stress : int,
	movement_done : bool,
	class : Class,
	name : string,
	mutation : Mutation,
	mutation_stats : Mutation_stats,
	class_stats : Class_stats,

	//effects
	burned : bool,
	acided : bool,
	electrified : bool,
	paradoxed : bool,
	iced : bool,
	bleed : bool,
	stuned : bool,
	lighted : bool,

	//inventory
	alien_objects : [2]Object,
	zog_objects : [3]Object,
	artefact : Object,

	cell : ^Cell,

	update : proc(^Entity),
	draw: proc(^Entity),
}

Object :: struct {
	name : string,
	stats : Entity_Stats,
	movement_size : int,
	attack_size : int,
}

objects := [3]Object {
	{name = "boot no grav", movement_size = 1},
	{name = "gloves ampli", stats = {technology = 1}},
	{name = "changing arms", attack_size = 1},
}

Class :: enum {
	none,
	tank,
	tech,
	warrior,
	healer,
	sniper,
	spirit
}

Class_stats :: struct {
	class : Class,
	stats : Entity_Stats,
	movement_size : int,
	attack_size : int,
}

class_stats := [6]Class_stats {
	{class = .tank, stats = {max_life = 3, psyche = 1, agility = -1}, movement_size = 3, attack_size = 1},
	{class = .tech, stats = {technology = 3, chance = 1, max_life = -1}, movement_size = 4, attack_size = 2},
	{class = .warrior, stats = {max_life = 2, agility = 1, psyche = -1}, movement_size = 4, attack_size = 1},
	{class = .healer, stats = {psyche = 3, chance = 3, max_life = -1}, movement_size = 4, attack_size = 1},
	{class = .sniper, stats = {agility = 3, max_life = -1, psyche = -1}, movement_size = 5, attack_size = 4},
	{class = .spirit, stats = {psyche = 3, technology = -1, max_life = -1}, movement_size = 4, attack_size = 2},
}

Mutation :: enum {
	none,
	cortex,
	reflex,
	lucky,
	dna,
	shaking,
	microwave,
	bad_luck,
	bad_body
}

Mutation_stats :: struct {
	mutation : Mutation,
	stats : Entity_Stats,
	good : bool,
}

mutation_stats := [8]Mutation_stats {
	{mutation = .cortex, stats = {psyche = 1, technology = 1}, good = true},
	{mutation = .reflex, stats = {agility = 1}, good = true},
	{mutation = .lucky, stats = {chance = 1}, good = true},
	{mutation = .dna, stats = {max_life = 1}, good = true},
	{mutation = .shaking, stats = {agility = -1}},
	{mutation = .microwave, stats = {psyche = -1}},
	{mutation = .bad_luck, stats = {chance = -1}},
	{mutation = .bad_body, stats = {max_life = -1}},
}

Cell :: struct {
	x : int,
	y : int,
	cell_active : bool,
	entity : ^Entity,
}

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

entity_order :: proc(lhs, rhs: ^Entity) -> bool {
    return lhs.entity_stats.speed > rhs.entity_stats.speed || (lhs.entity_stats.speed == rhs.entity_stats.speed && lhs.kind == .player)
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
	entity.class = Class(int(rl.GetRandomValue(1, len(Class) - 1)))
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
	attacking_entity.current_endurance -= 1
	end_attack()
}

update :: proc() {
	for &entity in game_state.entities {
		if !entity.allocated do continue

		// call the update function
		entity.update(&entity)
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

	check_move()

	check_attack()

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
				place_entity(game_state.order[game_state.order_index], x, y)
				game_state.order[game_state.order_index].movement_done = true 
				end_movement()
			}
			else if game_state.arena[y * ARENA_WIDTH + x].entity != nil {
				attack(game_state.arena[y * ARENA_WIDTH + x].entity, game_state.order[game_state.order_index])
			}
		}
	}
}

draw :: proc() {
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

		if rl.GuiButton(rl.Rectangle{WINDOW_WIDTH - 150, 0, 150, 50}, "End Turn") {
			end_turn()
		}

		move_text := fmt.ctprint("Move (", game_state.order[game_state.order_index].class_stats.movement_size, ")", sep = "")
		if rl.GuiButton(rl.Rectangle{0, 1000, 150, 50}, move_text) && game_state.order[game_state.order_index].kind == .player && !game_state.order[game_state.order_index].movement_done {
			end_attack()
			game_state.want_to_move = true

			x := game_state.order[game_state.order_index].cell.x
			y := game_state.order[game_state.order_index].cell.y
			for move in MOVEMENTS_2 {
				if x + move[0] < 0 || y + move[1] < 0 do continue
				if x + move[0] >= ARENA_WIDTH || y + move[1] >= ARENA_HEIGHT do continue
				if game_state.arena[(y + move[1]) * ARENA_WIDTH + x + move[0]].entity != nil do continue

				game_state.arena[(y + move[1]) * ARENA_WIDTH + x + move[0]].cell_active = true
			}
		}
		attack_text := fmt.ctprint("Attack (", game_state.order[game_state.order_index].entity_stats.damage, ")", sep = "")
		if rl.GuiButton(rl.Rectangle{160, 1000, 150, 50}, attack_text) && game_state.order[game_state.order_index].kind == .player && game_state.order[game_state.order_index].current_endurance > 0 {
			end_movement()
			game_state.want_to_attack = true
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

	rl.EndDrawing()	
}