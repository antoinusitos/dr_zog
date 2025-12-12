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
	movement_size : int,
	attack_size : int,
	ability : [2]^Class_ability,
}

Ability_type :: enum {
	damage,
	heal,

}

Class_ability :: struct {
	ability_type : Ability_type,
	value : int,
	value_2 : int,
	cost : int,
	name : string,
	id : string,
}

class_stats := [6]Class_stats {
	{class = .tank, stats = {max_life = 3, psyche = 1, agility = -1}, movement_size = 3, attack_size = 1},
	{class = .tech, stats = {technology = 3, chance = 1, max_life = -1}, movement_size = 4, attack_size = 2},
	{class = .warrior, stats = {max_life = 2, agility = 1, psyche = -1}, movement_size = 4, attack_size = 1, ability = {&warrior_ability_1, nil}},
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
	description : string,
}

mutation_stats := [8]Mutation_stats {
	{mutation = .cortex, stats = {psyche = 1, technology = 1}, good = true, description = "Big Brain (+1 psyche, +1 tech)"},
	{mutation = .reflex, stats = {agility = 1}, good = true, description = "Strong Reflex (+1 agility)"},
	{mutation = .lucky, stats = {chance = 1}, good = true, description = "Strong Luck (+1 chance)"},
	{mutation = .dna, stats = {max_life = 1}, good = true, description = "Strong DNA (+1 HP)"},
	{mutation = .shaking, stats = {agility = -1}, description = "Bad Shake (-1 agility)"},
	{mutation = .microwave, stats = {psyche = -1}, description = "Radiated (-1 psyche)"},
	{mutation = .bad_luck, stats = {chance = -1}, description = "Bad Luck (-1 chance)"},
	{mutation = .bad_body, stats = {max_life = -1}, description = "Bad Body (-1 HP)"},
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


warrior_ability_1 := Class_ability {
	ability_type = .damage,
	value = 2,
	value_2 = 3,
	cost = 2,
	name = "Warrior Ability",
	id = "Warrior_Ability"
}

Cell :: struct {
	x : int,
	y : int,
	cell_active : bool,
	entity : ^Entity,
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

Game_Step :: enum {
	cloning,
	battle,
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

	cloning_button : Button,
	ready_button : Button,
	next_clone_button : Button,
}

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

Entity_Handle :: struct {
	index: u64,
	id: u64,
}

Entity_Kind :: enum {
	nil,
	player,
	enemy,
}

fly_stats := Entity_Stats { max_life = 2, fatigue = 2, damage = 1, psyche = 3, speed = 5, technology = 2, chance = 5 }


WINDOW_WIDTH :: 1920
WINDOW_HEIGHT :: 1080
SPRITE_SIZE :: 32
OFFSET_X :: 100
OFFSET_Y :: 100

MAX_ENTITIES :: 1024
ARENA_WIDTH :: 10
ARENA_HEIGHT :: 10
END_BY_TURN :: 2