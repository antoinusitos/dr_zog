package game

import rl "vendor:raylib"

class_stats := [5]Class_stats {
	{class = .tank, stats = {vitality = 2, psyche = -1, agility = -1}, attack_size = 1, ability = {&push_ability, nil}},
	{class = .warrior, stats = {strength = 2, chance = -1, psyche = -1}, attack_size = 1, ability = {&patator_ability, nil}},
	{class = .healer, stats = {speed = 2, strength = -1, agility = -1}, attack_size = 1, ability = {&heal_ability, nil}},
	{class = .sniper, stats = {agility = 2, vitality = -1, psyche = -1}, attack_size = 3},
	{class = .spirit, stats = {psyche = 2, strength = -1, vitality = -1}, attack_size = 2, ability = {&fire_flamme_ability, nil}},
}

mutation_stats := [8]Mutation_stats {
	{mutation = .cortex, stats = {psyche = 1, chance = 1}, good = true, description = "Big Brain (+1 psyche, +1 chance)"},
	{mutation = .reflex, stats = {agility = 1}, good = true, description = "Strong Reflex (+1 agility)"},
	{mutation = .lucky, stats = {chance = 1}, good = true, description = "Strong Luck (+1 chance)"},
	{mutation = .dna, stats = {vitality = 1}, good = true, description = "Strong DNA (+1 HP)"},
	{mutation = .shaking, stats = {agility = -1}, description = "Bad Shake (-1 agility)"},
	{mutation = .microwave, stats = {psyche = -1}, description = "Radiated (-1 psyche)"},
	{mutation = .bad_luck, stats = {chance = -1}, description = "Bad Luck (-1 chance)"},
	{mutation = .bad_body, stats = {vitality = -1}, description = "Bad Body (-1 HP)"},
}

mutations := [9]Class_ability {
	Class_ability{ability_type = .none},
	cortex_ability,
	reflex_ability,
	lucky_ability,
	dna_ability,
	shaking_ability,
	microwave_ability,
	bad_luck_ability,
	bad_body_ability
}

objects := [2]Object {
	{name = "boot no grav", movement_size = 1},
	{name = "changing arms", attack_size = 1},
}

// EVENTS

// IDEAS
// - reroll shop to give you character level 1 (event)

events := [1]Event {
	chest_event,
}

chest_event := Event {
	id = "event_test", 
	description = "You found a chest in the street, what do you do ?", 
	choice = 
	{
		open_chest
	}
}

open_chest := Event_Choice {
	id = "open_chest",
	text = "open the chest",
	outcome = {
		open_chest_crit_success,
		open_chest_success,
		open_chest_fail,
		open_chest_crit_fail
	}
}

open_chest_crit_success := Event_Outcome {
	id = "open_chest_crit_success",
	text = "%clone open the chest and see a big pile of money.\nyou earn 10 gold",
	tag = "add-gold-10"
}

open_chest_success := Event_Outcome {
	id = "open_chest_success",
	text = "%clone open the chest and see some coins.\nyou earn 5 gold",
	tag = "add-gold-5"
}

open_chest_fail := Event_Outcome {
	id = "open_chest_fail",
	text = "%clone fail to open the chest as the lock was too hard."
}

open_chest_crit_fail := Event_Outcome {
	id = "open_chest_crit_fail",
	text = "while trying to open, %clone cut himself and lost some health.",
	tag = "remove-life-5"
}

// BASIC ATTACK

close_attack_ability := Class_ability {
	ability_type = .damage,
	damage_type = .close,
	range = 1, // range
	cost = 0,
	number_of_use = 1,
	name = "close attack",
	id = "close_attack_ability",
	description = "basic attack (stat : strength)",
	base_stat = .damage,
	stat_calculation = 1,
}

range_attack_ability := Class_ability {
	ability_type = .damage,
	damage_type = .range,
	cost = 0,
	number_of_use = 1,
	name = "range attack",
	id = "range_attack_ability",
	description = "basic attack (stat : strength)",
	base_stat = .damage,
	stat_calculation = 1,
}

// ACTIVE ABILITIES

// IDEAS
// -kick the baby (shoot an adjacent baby to a choosen cell)

patator_ability := Class_ability {
	ability_type = .damage,
	damage_type = .close,
	value = 4, // dmg
	range = 1, // range
	cost = 4,
	name = "Patator",
	id = "Patator_Ability",
	description = "Shoot a big potato ! (stat : strength)",
	base_stat = .damage,
	stat_calculation = 1,
}

tp_ability := Class_ability {
	ability_type = .movement,
	range = 5, // range
	cost = 4,
	name = "TP",
	id = "TP_Ability",
	tags = {"move_instant"},
	description = "TP on an empty cell"
}

heal_ability := Class_ability {
	ability_type = .heal,
	range = 4, // range
	value = 3, // heal
	cost = 2,
	name = "Heal",
	id = "Heal_Ability",
	description = "heal any one ! (stat : psyche)",
	base_stat = .psyche,
	stat_calculation = 1,
}

push_ability := Class_ability {
	ability_type = .movement,
	range = 1, // range
	value = 2, // push length
	cost = 2,
	name = "push",
	id = "Push_Ability",
	description = "Push any one in the direction ! (stat : speed)",
	base_stat = .speed,
	stat_calculation = 1,
}

fire_flamme_ability := Class_ability {
	ability_type = .damage,
	damage_type = .range,
	value = 2, // dmg
	range = 3, // range
	cost = 4,
	name = "Fire Flamme",
	id = "Fire_Flamme_Ability",
	element_to_add = fire_element,
	tags = {"elemental"},
	description = "Shoot a big potato ! (stat : psyche)",
	base_stat = .psyche,
	stat_calculation = 1,
}

// PASSIVE ABILITIES

cortex_ability := Class_ability {
	ability_type = .passive,
	value = 1,
	name = "Big Brain",
	id = "cortex_ability",
	description = "Passive (+1 psyche, +1 chance)",
	stats = {psyche = 1, chance = 1}
}

reflex_ability := Class_ability {
	ability_type = .passive,
	value = 1,
	name = "Strong Reflex",
	id = "reflex_ability",
	description = "Passive (+1 agility)",
	stats = {agility = 1}
}

lucky_ability := Class_ability {
	ability_type = .passive,
	value = 1,
	name = "Strong Luck",
	id = "lucky_ability",
	description = "Passive (+1 chance)",
	stats = {chance = 1}
}

dna_ability := Class_ability {
	ability_type = .passive,
	value = 1,
	name = "Strong DNA",
	id = "dna_ability",
	description = "Passive (+1 vitality)",
	stats = {vitality = 1}
}

shaking_ability := Class_ability {
	ability_type = .passive,
	value = -1,
	name = "Bad Shake",
	id = "shaking_ability",
	description = "Passive (-1 agility)",
	stats = {agility = -1}
}

microwave_ability := Class_ability {
	ability_type = .passive,
	value = -1,
	name = "Radiated",
	id = "microwave_ability",
	description = "Passive (-1 psyche)",
	stats = {psyche = -1}
}

bad_luck_ability := Class_ability {
	ability_type = .passive,
	value = -1,
	name = "Bad Luck",
	id = "bad_luck_ability",
	description = "Passive (-1 chance)",
	stats = {chance = -1}
}

bad_body_ability := Class_ability {
	ability_type = .passive,
	value = -1,
	name = "Bad Body",
	id = "bad_body_ability",
	description = "Passive (-1 vitality)",
	stats = {vitality = -1}
}

all_stats : [5]Entity_Stats = {
	Entity_Stats { entity_age = .baby, vitality = 1 },
	Entity_Stats { entity_age = .kid, chance = 1 },
	Entity_Stats { entity_age = .teen, speed = 1 },
	Entity_Stats { entity_age = .adult, strength = 1 },
	Entity_Stats { entity_age = .senior, psyche = 1 },
}

element_sprites := []Element_Sprite {
	{element = .fire}
}

fire_element := Element_Active {tag = "fire", turn = 4, element = .fire, element_to_spawn = .element_fire}

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

fly_stats := Entity_Stats { vitality = 2, endurance = 2, strength = 1, psyche = 3, speed = 5, chance = 5 }


WINDOW_WIDTH :: 1920
WINDOW_HEIGHT :: 1080
SPRITE_SIZE :: 32
OFFSET_X :: 100
OFFSET_Y :: 100

MAX_ENTITIES :: 1024
ARENA_WIDTH :: 10
ARENA_HEIGHT :: 10
END_BY_TURN :: 2