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
	from_cell : ^Check_Cell,
	cell : Cell,
	dist : f32
}

to_return : [dynamic]Check_Cell

to_check : [dynamic]Check_Cell
checked : [dynamic]Check_Cell

find_path :: proc(from_x : int, from_y : int, to_x : int, to_y : int) -> [dynamic]Check_Cell {
	clear(&to_return)
	clear(&to_check)
	clear(&to_check)

	log_error("from x ", from_x)
	log_error("from_y ", from_y)
	log_error("to_x x ", to_x)
	log_error("to_y x ", to_y)

	current_cell := game_state.arena[from_y * ARENA_WIDTH + from_x]

	c := Check_Cell {
		cell = current_cell
	}
	append(&to_check, c)

	log_error("to_check ", len(to_check))

	for {

		if len(to_check) <= 0 || (to_check[0].cell.x == to_x && to_check[0].cell.y == to_y) {
			break
		}

		log_error("tocheck")
		for t in to_check {
			log_error(t.cell.x, t.cell.y, t.dist, sep = ":")
			if t.from_cell != nil {
				log_error("from cell", t.from_cell.cell.x, t.from_cell.cell.y, sep=":")
			}
		}

		c = to_check[0]
		test_cell(&c, to_x, to_y)
		slice.sort_by(to_check[:], cell_check_order)
	}

	for z in checked {
		log_error("z.cell.x ", z.cell.x)
		log_error("z.cell.y ", z.cell.y)
		if z.from_cell != nil {
		log_error("z.from_cell.cell.x ", z.from_cell.cell.x)
		log_error("z.from_cell.cell.y ", z.from_cell.cell.y)
	}
	}

	cell := to_check[0]
	if cell.cell.x == to_x && cell.cell.y == to_y {
		/*log_error("cell.cell.x ", cell.cell.x)
		log_error("cell.cell.y ", cell.cell.y)
		append(&to_return, cell)
		for cell.from_cell != nil {
			log_error("bcell.cell.x ", cell.cell.x)
			log_error("bcell.cell.y ", cell.cell.y)
			append(&to_return, cell.from_cell^)
			cell_temp := cell.from_cell
			cell = cell.from_cell^
			log_error("cell.cell.x ", cell.cell.x)
			log_error("cell.cell.y ", cell.cell.y)

			log_error("cell_temp.cell.x ", cell_temp.cell.x)
			log_error("cell_temp.cell.y ", cell_temp.cell.y)
			log_error("cell_temp.from_cell.cell.x ", cell_temp.from_cell.cell.x)
			log_error("cell_temp.from_cell.cell.y ", cell_temp.from_cell.cell.y)
		}*/
		log_error(to_return)
	}

	return to_return
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

test_cell :: proc(cell_to_check : ^Check_Cell, to_x : int, to_y : int) {
	append(&checked, cell_to_check^)

	ordered_remove(&to_check, 0)

	log_error("test cell.cell.x ", cell_to_check.cell.x)
	log_error("terst cell.cell.y ", cell_to_check.cell.y)

	if cell_to_check.cell.x > 0 {
		log_error("left cell")
		cell := game_state.arena[cell_to_check.cell.y * ARENA_WIDTH + cell_to_check.cell.x - 1]
		if cell_to_check.from_cell == nil || cell != cell_to_check.from_cell.cell {
			dist := distance({f32(cell.x), f32(cell.y)}, {f32(to_x), f32(to_y)})
			check := to_check_has(cell)
			check2 := checked_has(cell)
			if check != nil {
				if cell_to_check.dist + dist < check.dist {
					check.from_cell = cell_to_check
					check.dist = cell_to_check.dist + dist
				}
			}
			else if check2 != nil {
				if cell_to_check.dist + dist < check2.dist {
					check2.from_cell = cell_to_check
					check2.dist = cell_to_check.dist + dist
				}
			}
			else {
				c := Check_Cell {
					cell = cell, 
					dist = distance({f32(cell.x), f32(cell.y)}, {f32(to_x), f32(to_y)}),
					from_cell = cell_to_check
				}
				append(&to_check, c)
			}
		}
	}
	if cell_to_check.cell.x < ARENA_WIDTH - 1 {
		log_error("right cell")
		cell := game_state.arena[cell_to_check.cell.y * ARENA_WIDTH + cell_to_check.cell.x + 1]
		if cell_to_check.from_cell == nil || cell != cell_to_check.from_cell.cell {
			dist := distance({f32(cell.x), f32(cell.y)}, {f32(to_x), f32(to_y)})
			check := to_check_has(cell)
			check2 := checked_has(cell)
			if check != nil {
				if cell_to_check.dist + dist < check.dist {
					check.from_cell = cell_to_check
					check.dist = cell_to_check.dist + dist
				}
			}
			else if check2 != nil {
				if cell_to_check.dist + dist < check2.dist {
					check2.from_cell = cell_to_check
					check2.dist = cell_to_check.dist + dist
				}
			}
			else {
				c := Check_Cell {
					cell = cell, 
					dist = distance({f32(cell.x), f32(cell.y)}, {f32(to_x), f32(to_y)}),
					from_cell = cell_to_check
				}
				append(&to_check, c)
			}
		}
	}
	if cell_to_check.cell.y > 0 {
		log_error("top cell")
		cell := game_state.arena[(cell_to_check.cell.y - 1) * ARENA_WIDTH + cell_to_check.cell.x]
		if cell_to_check.from_cell == nil || cell != cell_to_check.from_cell.cell {
			dist := distance({f32(cell.x), f32(cell.y)}, {f32(to_x), f32(to_y)})
			check := to_check_has(cell)
			check2 := checked_has(cell)
			log_error("top cell0")
			if check != nil {
				log_error("top cell1")
				if cell_to_check.dist + dist < check.dist {
					check.from_cell = cell_to_check
					check.dist = cell_to_check.dist + dist
				}
			}
			else if check2 != nil {
				log_error("top cell2")
				if cell_to_check.dist + dist < check2.dist {
					log_error("replace")
					check2.from_cell = cell_to_check
					check2.dist = cell_to_check.dist + dist
				}
			}
			else {
				log_error("top cell3")
				c := Check_Cell {
					cell = cell, 
					dist = distance({f32(cell.x), f32(cell.y)}, {f32(to_x), f32(to_y)}),
					from_cell = cell_to_check
				}
				append(&to_check, c)
			}
		}
	}
	if cell_to_check.cell.y < ARENA_HEIGHT - 1 {
		log_error("bottom cell")
		cell := game_state.arena[(cell_to_check.cell.y + 1) * ARENA_WIDTH + cell_to_check.cell.x]
		if cell_to_check.from_cell == nil || cell != cell_to_check.from_cell.cell {
			dist := distance({f32(cell.x), f32(cell.y)}, {f32(to_x), f32(to_y)})
			check := to_check_has(cell)
			check2 := checked_has(cell)
			if check != nil {
				if cell_to_check.dist + dist < check.dist {
					check.from_cell = cell_to_check
					check.dist = cell_to_check.dist + dist
				}
			}
			else if check2 != nil {
				if cell_to_check.dist + dist < check2.dist {
					check2.from_cell = cell_to_check
					check2.dist = cell_to_check.dist + dist
				}
			}
			else {
				log_error("lol3")
				log_error("cell_to_check.x",cell_to_check.cell.x)
				log_error("cell_to_check.y",cell_to_check.cell.y)
				c := Check_Cell {
					cell = cell, 
					dist = distance({f32(cell.x), f32(cell.y)}, {f32(to_x), f32(to_y)}),
					from_cell = cell_to_check
				}
				append(&to_check, c)
			}
		}
	}
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