package game

import rl "vendor:raylib"

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
	attack_size : int,
	ability : [2]^Class_ability,
}

Ability_type :: enum {
	damage,
	heal,
	passive,
	movement,
}

Class_ability :: struct {
	ability_type : Ability_type,
	value : int,
	value_2 : int,
	range : int,
	cost : int,
	name : string,
	id : string,
	tags : []string,
	add_tags : []string,
	element_to_add : Element_Active,
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
	description : string,
}

Object :: struct {
	name : string,
	stats : Entity_Stats,
	movement_size : int,
	attack_size : int,
}

ability_has_tag :: proc(ability : ^Class_ability, tag : string) -> bool {
	for t in ability.tags {
		if t == tag {
			return true
		}
	}

	return false
}

Map_Point_Type :: enum {
	home,
	battle,
	event,
	shop
}

Map_Point :: struct {
	type : Map_Point_Type,
	done : bool,
}

Element :: enum {
	none,
	fire
}

Element_Active :: struct {
	element : Element,
	turn : int,
	tag : string,
}

Element_Sprite :: struct {
	element : Element,
	sprite : rl.Texture2D
}

Cell :: struct {
	x : int,
	y : int,
	cell_active : bool,
	entity : ^Entity,
	tag_to_add : [dynamic]string,
	tags : [dynamic]string,
	elements : [dynamic]Element_Active,
}

Compare_Cell :: proc(lhs : Cell, rhs : Cell) -> bool {
	return lhs.x == rhs.x && lhs.y == rhs.y
}

cell_has_tag :: proc(cell : ^Cell, tag : string) -> bool {
	for t in cell.tags {
		if t == tag {
			return true
		}
	}

	return false
}

cell_remove_tag :: proc(cell : ^Cell, tag : string) {
	index := 0
	for t in cell.tags {
		if t == tag {
			ordered_remove(&cell.tags, index)
		}
		index += 1
	}
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

Game_Step :: enum {
	cloning,
	mapping,
	battle,
}

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
	ability_1 : bool,
	ability_2 : bool,
	enemies : [dynamic]^Entity,
	order : [dynamic]^Entity,
	order_index : int,
	ai_turn_time : f32,
	game_step : Game_Step,
	all_clone_created : bool,
	all_clone_created_ready : bool,
	possible_class : [dynamic]Class,
	game_finished : bool,
	gold : int,
	turn_number : int,

	damage_texts : [dynamic]Damage_Text,

	blocked : bool,
	applyed_dots : bool,

	cloning_button : Button,
	ready_button : Button,
	next_clone_button : Button,
	start_battle_button : Button,
	remove_class_button : Button,
	class_1_button : Button,
	class_2_button : Button,
	class_3_button : Button,
	class_4_button : Button,

	move_button : Button,
	attack_button : Button,
	ability_button : Button,
	ability_2_button : Button,
	end_combat_button : Button,
	end_turn_button : Button,

	map_elements : [dynamic]Map_Point,
	map_buttons : [dynamic]Button,
}

Entity :: struct {
	allocated: bool,
	handle: Entity_Handle,
	kind: Entity_Kind,

	// player
	current_sprite : rl.Texture,
	sprite : []rl.Texture,
	sprite_dead : rl.Texture,
	sprite_index : int,
	sprite_time : f32,
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
	attack_done : bool,
	class : Class,
	name : string,
	mutation : Mutation,
	mutation_stats : Mutation_stats,
	class_stats : Class_stats,

	tags : [dynamic]string,
	elements : [dynamic]Element_Active,

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
	path : [dynamic]Check_Cell,
	path_index : int,
	time_to_point : f32,
	time_to_attack : f32,
	moving : bool,
	attacking : bool,

	target : ^Entity,

	hit_state : int,
	hit_timer : f32,

	update : proc(^Entity),
	draw: proc(^Entity),
}

entity_has_tag :: proc(entity : ^Entity, tag : string) -> bool {
	for t in entity.tags {
		if t == tag {
			return true
		}
	}

	return false
}

entity_remove_tag :: proc(entity : ^Entity, tag : string) {
	index := 0
	for t in entity.tags {
		if t == tag {
			ordered_remove(&entity.tags, index)
		}
		index += 1
	}
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

Damage_Text :: struct {
	position : rl.Vector2,
	text : string,
	timer : f32,
	color : rl.Color
}