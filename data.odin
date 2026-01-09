package game

import rl "vendor:raylib"

class_stats := [6]Class_stats {
	{class = .tank, stats = {max_life = 2, psyche = -1, agility = -1}, attack_size = 1, ability = {&tank_ability_1, nil}},
	{class = .tech, stats = {technology = 2, speed = -1, max_life = -1}, attack_size = 1, ability = {&fire_flamme_ability, nil}},
	{class = .warrior, stats = {damage = 2, chance = -1, psyche = -1}, attack_size = 1, ability = {&fire_flamme_ability, nil}},
	{class = .healer, stats = {speed = 2, damage = -1, technology = -1}, attack_size = 1, ability = {&heal_ability, nil}},
	{class = .sniper, stats = {agility = 2, max_life = -1, psyche = -1}, attack_size = 3},
	{class = .spirit, stats = {psyche = 2, technology = -1, max_life = -1}, attack_size = 2},
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

objects := [3]Object {
	{name = "boot no grav", movement_size = 1},
	{name = "gloves ampli", stats = {technology = 1}},
	{name = "changing arms", attack_size = 1},
}

// ABILITIES

warrior_ability_1 := Class_ability {
	ability_type = .damage,
	value = 4, // dmg
	range = 3, // range
	cost = 4,
	name = "Dash & Cut",
	id = "Warrior_Ability"
}

tank_ability_1 := Class_ability {
	ability_type = .movement,
	range = 5, // range
	cost = 4,
	name = "TP",
	id = "Tank_Ability",
	tags = {"move_instant"}
}

heal_ability := Class_ability {
	ability_type = .heal,
	range = 4, // range
	value = 3, // heal
	cost = 2,
	name = "Heal",
	id = "Heal_Ability"
}

fire_flamme_ability := Class_ability {
	ability_type = .damage,
	value = 2, // dmg
	range = 3, // range
	cost = 4,
	name = "Fire Flamme",
	id = "Fire_Flamme_Ability",
	add_tags = {"fire"},
	tags = {"elemental"}
}

all_stats : [5]Entity_Stats = {
	Entity_Stats { entity_age = .baby, max_life = 1 },
	Entity_Stats { entity_age = .kid, chance = 1 },
	Entity_Stats { entity_age = .teen, speed = 1 },
	Entity_Stats { entity_age = .adult, damage = 1 },
	Entity_Stats { entity_age = .senior, psyche = 1 },
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