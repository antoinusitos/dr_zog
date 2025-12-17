package game

import rl "vendor:raylib"
import "core:math"
import "core:slice"

Button_Type :: enum {
	once,
	filling,
}

Button :: struct {
	x : f32,
	y : f32,
	width : f32,
	height : f32,
	background_color : rl.Color,
	hover_color : rl.Color,
	clicked_color : rl.Color,
	fill_color : rl.Color,
	button_type : Button_Type,
	is_hover : bool,
	is_clicked : bool,

	filled_done : bool,
	fill_percent : f32,
	fill_max : f32,
	fill_auto_reset : bool,

	text : string,
	text_size : i32,
	text_offset : rl.Vector2,

	update : proc(^Button),
	draw : proc(^Button),
	on_click : proc(^Button),
	on_down : proc(^Button),
	on_release : proc(^Button),
	on_filled : proc(^Button),
}

Check_Cell :: struct {
	id : int,
	//from_cell : ^Check_Cell,
	cell : Cell,
	dist : f32,
	from_id : int,
}

id_cumul := 0
to_return : [dynamic]Check_Cell

to_check : [dynamic]Check_Cell
checked : [dynamic]Check_Cell

find_path :: proc(from_x : int, from_y : int, to_x : int, to_y : int) -> [dynamic]Check_Cell {
	clear(&to_return)
	clear(&to_check)
	clear(&to_check)

	current_cell := game_state.arena[from_y * ARENA_WIDTH + from_x]

	append(&to_check, Check_Cell {
		cell = current_cell,
		id = id_cumul,
		from_id = -1
	})
	id_cumul += 1

	for {

		if len(to_check) <= 0 || (to_check[0].cell.x == to_x && to_check[0].cell.y == to_y) {
			if len(to_check) > 0 && to_check[0].cell.x == to_x && to_check[0].cell.y == to_y {
				log_error("found0")
			}
			else {
				log_error("found1")
			}
			break
		}

		c := to_check[0]
		if test_cell(&c, to_x, to_y) {
			break
		}
		slice.sort_by(to_check[:], cell_check_order)
	}
	if len(to_check) > 0 {
		cell := to_check[0]
		if cell.cell.x == to_x && cell.cell.y == to_y {
			append(&to_return, cell)
			for cell.from_id != -1 {
				c := get_cell_check(cell.from_id)
				append(&to_return, c)
				cell = c
			}
		}
	}

	for t in to_return {
		log_error("node x", t.cell.x, " : ", t.cell.y)
	}

	return to_return
}

get_cell_check :: proc(from_id : int) -> Check_Cell{
	for &c in checked {
		if c.id == from_id {
			return c
		}
	}

	return Check_Cell{
		id = -1
	}
}

to_check_has :: proc(cell : Cell) -> ^Check_Cell {
	for &c in to_check {
		if c.cell == cell {
			return &c
		}
	}

	return nil
}

checked_has :: proc(cell : Cell) -> ^Check_Cell {
	for &c in checked {
		if c.cell == cell {
			return &c
		}
	}

	return nil
}

test_cell :: proc(cell_to_check : ^Check_Cell, to_x : int, to_y : int) -> bool {
	append(&checked, cell_to_check^)

	log_error("test_cell x", cell_to_check.cell.x, " : ", cell_to_check.cell.y)

	if cell_to_check.cell.x == to_x && cell_to_check.cell.y == to_y {
		log_error("found")
		return true
	}

	ordered_remove(&to_check, 0)

	from := get_cell_check(cell_to_check.from_id)

	if cell_to_check.cell.x > 0 {
		cell := game_state.arena[cell_to_check.cell.y * ARENA_WIDTH + cell_to_check.cell.x - 1]
		if (from.id == -1 || cell != from.cell) && cell.entity == nil {
			dist := distance({f32(cell.x), f32(cell.y)}, {f32(to_x), f32(to_y)})
			check := to_check_has(cell)
			check2 := checked_has(cell)
			if check != nil {
				/*if cell_to_check.dist + dist < check.dist {
					check.from_cell = cell_to_check
					check.dist = cell_to_check.dist + dist
				}*/
			}
			else if check2 != nil {
				/*if cell_to_check.dist + dist < check2.dist {
					check2.from_cell = cell_to_check
					check2.dist = cell_to_check.dist + dist
				}*/
			}
			else {
				c := Check_Cell {
					cell = cell, 
					dist = distance({f32(cell.x), f32(cell.y)}, {f32(to_x), f32(to_y)}),
					//from_cell = cell_to_check,
					id = id_cumul,
					from_id = cell_to_check.id
				}
				id_cumul += 1
				append(&to_check, c)
			}
		}
	}
	if cell_to_check.cell.x < ARENA_WIDTH - 1 {
		cell := game_state.arena[cell_to_check.cell.y * ARENA_WIDTH + cell_to_check.cell.x + 1]
		if (from.id == -1 || cell != from.cell) && cell.entity == nil {
			dist := distance({f32(cell.x), f32(cell.y)}, {f32(to_x), f32(to_y)})
			check := to_check_has(cell)
			check2 := checked_has(cell)
			if check != nil {
				/*if cell_to_check.dist + dist < check.dist {
					check.from_cell = cell_to_check
					check.dist = cell_to_check.dist + dist
				}*/
			}
			else if check2 != nil {
				/*if cell_to_check.dist + dist < check2.dist {
					check2.from_cell = cell_to_check
					check2.dist = cell_to_check.dist + dist
				}*/
			}
			else {
				c := Check_Cell {
					cell = cell, 
					dist = distance({f32(cell.x), f32(cell.y)}, {f32(to_x), f32(to_y)}),
					//from_cell = cell_to_check,
					id = id_cumul,
					from_id = cell_to_check.id
				}
				id_cumul += 1
				append(&to_check, c)
			}
		}
	}
	if cell_to_check.cell.y > 0 {
		cell := game_state.arena[(cell_to_check.cell.y - 1) * ARENA_WIDTH + cell_to_check.cell.x]
		if (from.id == -1 || cell != from.cell) && cell.entity == nil {
			dist := distance({f32(cell.x), f32(cell.y)}, {f32(to_x), f32(to_y)})
			check := to_check_has(cell)
			check2 := checked_has(cell)
			if check != nil {
				/*log_error("top cell1")
				if cell_to_check.dist + dist < check.dist {
					check.from_cell = cell_to_check
					check.dist = cell_to_check.dist + dist
				}*/
			}
			else if check2 != nil {
				/*log_error("top cell2")
				if cell_to_check.dist + dist < check2.dist {
					log_error("replace")
					check2.from_cell = cell_to_check
					check2.dist = cell_to_check.dist + dist
				}*/
			}
			else {
				c := Check_Cell {
					cell = cell, 
					dist = distance({f32(cell.x), f32(cell.y)}, {f32(to_x), f32(to_y)}),
					/*from_cell = cell_to_check,
					from_x = cell_to_check.cell.x,
					from_y = cell_to_check.cell.y - 1,*/
					id = id_cumul,
					from_id = cell_to_check.id
				}
				id_cumul += 1
				append(&to_check, c)
			}
		}
	}
	if cell_to_check.cell.y < ARENA_HEIGHT - 1 {
		cell := game_state.arena[(cell_to_check.cell.y + 1) * ARENA_WIDTH + cell_to_check.cell.x]
		if (from.id == -1 || cell != from.cell) && cell.entity == nil {
			dist := distance({f32(cell.x), f32(cell.y)}, {f32(to_x), f32(to_y)})
			check := to_check_has(cell)
			check2 := checked_has(cell)
			if check != nil {
				/*if cell_to_check.dist + dist < check.dist {
					check.from_cell = cell_to_check
					check.dist = cell_to_check.dist + dist
				}*/
			}
			else if check2 != nil {
				/*if cell_to_check.dist + dist < check2.dist {
					check2.from_cell = cell_to_check
					check2.dist = cell_to_check.dist + dist
				}*/
			}
			else {
				c := Check_Cell {
					cell = cell, 
					dist = distance({f32(cell.x), f32(cell.y)}, {f32(to_x), f32(to_y)}),
					/*from_cell = cell_to_check,
					from_x = cell_to_check.cell.x,
					from_y = cell_to_check.cell.y + 1,*/
					id = id_cumul,
					from_id = cell_to_check.id
				}
				id_cumul += 1
				append(&to_check, c)
			}
		}
	}
	return false
}

distance :: proc(v1 : rl.Vector2, v2 : rl.Vector2) -> f32{
    first :f32 = math.pow_f32(v2.x-v1.x,2)
    second :f32 = math.pow_f32(v2.y-v1.y,2)
    return (first+second)
}

cell_check_order :: proc(lhs, rhs: Check_Cell) -> bool {
    return lhs.dist < rhs.dist
}

entity_order :: proc(lhs, rhs: ^Entity) -> bool {
    return lhs.entity_stats.speed > rhs.entity_stats.speed || (lhs.entity_stats.speed == rhs.entity_stats.speed && lhs.kind == .player)
}