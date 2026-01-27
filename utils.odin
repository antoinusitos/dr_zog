package game

import rl "vendor:raylib"
import "core:math"
import "core:slice"
import "core:fmt"
import "core:os"
import "core:strings"
import "core:strconv"

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
	disabled_color : rl.Color,
	button_type : Button_Type,
	is_hover : bool,
	is_clicked : bool,
	disabled : bool,
	active : bool, // don't update or draw

	filled_done : bool,
	fill_percent : f32,
	fill_max : f32,
	fill_auto_reset : bool,

	text : string,
	text_size : i32,
	text_offset : rl.Vector2,

	// Class Buttons
	class : Class,
	index : int,

	update : proc(^Button),
	draw : proc(^Button),
	on_click : proc(button : ^Button),
	on_down : proc(^Button),
	on_release : proc(^Button),
	on_filled : proc(^Button),
	on_hover : proc(^Button),
	on_exit : proc(^Button),
}

setup_one_button :: proc(button : ^Button) {
	button.button_type = .once
	button.update = proc(button : ^Button) {
		if !button.active {
			return
		}

		if button.disabled {
			button.is_clicked = false
			return
		}

		mouse_pos := rl.GetMousePosition()

		if mouse_pos.x >= button.x && mouse_pos.x <= button.x + button.width &&
			mouse_pos.y >= button.y && mouse_pos.y <= button.y + button.height {
				button.is_hover = true
				button.on_hover(button)

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
			if rl.IsMouseButtonReleased(.LEFT) {
				if button.is_clicked {
					button.on_release(button)
				}
				button.is_clicked = false
			}

			if button.is_hover {
				button.on_exit(button)
			}
			button.is_hover = false
		}
	}
	button.draw = proc(button : ^Button) {
		if !button.active {
			return
		}

		if button.disabled {
			rl.DrawRectangleRec(rl.Rectangle{button.x, button.y, button.width, button.height}, button.disabled_color)
			rl.DrawText(fmt.ctprint(button.text), i32(button.x + button.text_offset.x), i32(button.y + button.text_offset.y), button.text_size, rl.BLACK)
			return
		}
		if button.is_clicked {
			rl.DrawRectangleRec(rl.Rectangle{button.x, button.y, button.width, button.height}, button.clicked_color)
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
	button.on_hover = proc(button : ^Button) {
		
	}

	button.on_exit = proc(button : ^Button) {
		
	}
}

setup_filling_button :: proc(button : ^Button) {
	button.button_type = .filling
	button.update = proc(button : ^Button) {
		if !button.active {
			return
		}

		if button.disabled {
			return
		}

		mouse_pos := rl.GetMousePosition()

		if mouse_pos.x >= button.x && mouse_pos.x <= button.x + button.width &&
			mouse_pos.y >= button.y && mouse_pos.y <= button.y + button.height {
				button.is_hover = true
				button.on_hover(button)
				
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
			if button.is_hover {
				button.on_exit(button)
			}
			button.is_hover = false
		}
	}
	button.draw = proc(button : ^Button) {
		if !button.active {
			return
		}
		
		if button.disabled {
			rl.DrawRectangleRec(rl.Rectangle{button.x, button.y, button.width, button.height}, button.disabled_color)
			rl.DrawText(fmt.ctprint(button.text), i32(button.x + button.text_offset.x), i32(button.y + button.text_offset.y), button.text_size, rl.BLACK)
			return
		}
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
	button.on_hover = proc(button : ^Button) {
		
	}
	button.on_exit = proc(button : ^Button) {
		
	}
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
	clear(&checked)

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
				//log_error("found objective cell")
			}
			else {
				//log_error("found1 no node to check")
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
    log_error("to check has")
	for &c in to_check {
		if Compare_Cell(c.cell, cell) {
			return &c
		}
	}

	return nil
}

checked_has :: proc(cell : Cell) -> ^Check_Cell {
    log_error("checked has")
	for &c in checked {
		if Compare_Cell(c.cell, cell) {
			return &c
		}
	}

	return nil
}

test_cell :: proc(cell_to_check : ^Check_Cell, to_x : int, to_y : int) -> bool {
	append(&checked, cell_to_check^)

    log_error("test cell")

	if cell_to_check.cell.x == to_x && cell_to_check.cell.y == to_y {
		return true
	}

	ordered_remove(&to_check, 0)

	from := get_cell_check(cell_to_check.from_id)

	if cell_to_check.cell.x > 0 {
		cell := game_state.arena[cell_to_check.cell.y * ARENA_WIDTH + cell_to_check.cell.x - 1]
		if (from.id == -1 || !Compare_Cell(cell, from.cell)) && cell.entity == nil && !cell.blocked {
			dist := distance({f32(cell.x), f32(cell.y)}, {f32(to_x), f32(to_y)})
			check := to_check_has(cell)
			check2 := checked_has(cell)
			if check != nil {
				//log_error("nope0")
				/*if cell_to_check.dist + dist < check.dist {
					check.from_cell = cell_to_check
					check.dist = cell_to_check.dist + dist
				}*/
			}
			else if check2 != nil {
				//log_error("nope1")
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
		if (from.id == -1 || !Compare_Cell(cell, from.cell)) && cell.entity == nil && !cell.blocked {
			dist := distance({f32(cell.x), f32(cell.y)}, {f32(to_x), f32(to_y)})
			check := to_check_has(cell)
			check2 := checked_has(cell)
			if check != nil {
				//log_error("nope0")
				/*if cell_to_check.dist + dist < check.dist {
					check.from_cell = cell_to_check
					check.dist = cell_to_check.dist + dist
				}*/
			}
			else if check2 != nil {
				//log_error("nope1")
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
		if (from.id == -1 || !Compare_Cell(cell, from.cell)) && cell.entity == nil && !cell.blocked {
			dist := distance({f32(cell.x), f32(cell.y)}, {f32(to_x), f32(to_y)})
			check := to_check_has(cell)
			check2 := checked_has(cell)
			if check != nil {
				//log_error("nope0")
				/*log_error("top cell1")
				if cell_to_check.dist + dist < check.dist {
					check.from_cell = cell_to_check
					check.dist = cell_to_check.dist + dist
				}*/
			}
			else if check2 != nil {
				//log_error("nope1")
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
		if (from.id == -1 || !Compare_Cell(cell, from.cell)) && cell.entity == nil && !cell.blocked {
			dist := distance({f32(cell.x), f32(cell.y)}, {f32(to_x), f32(to_y)})
			check := to_check_has(cell)
			check2 := checked_has(cell)
			if check != nil {
				//log_error("nope0")
				/*if cell_to_check.dist + dist < check.dist {
					check.from_cell = cell_to_check
					check.dist = cell_to_check.dist + dist
				}*/
			}
			else if check2 != nil {
				//log_error("nope1")
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

movement_cells : [dynamic]Cell
movement_cells_to_check : [dynamic]Movement_Cell
movement_cells_checked : [dynamic]Cell

Movement_Cell :: struct {
	cell : Cell,
	range : int,
}

get_movement_cells :: proc(x_start : int, y_start : int, max : int, can_go_through : bool, including_self : bool) -> [dynamic]Cell {
	clear(&movement_cells)
	clear(&movement_cells_to_check)
	clear(&movement_cells_checked)

	start_cell := Movement_Cell {range = 0, cell = game_state.arena[y_start * ARENA_WIDTH + x_start]}
	append(&movement_cells_to_check, start_cell)

	if including_self {
		append(&movement_cells, start_cell.cell)
	}

	for len(movement_cells_to_check) > 0 {
		current := movement_cells_to_check[0]
		append(&movement_cells_checked, current.cell)

		if current.range > 0 {
			append(&movement_cells, current.cell)
		}

		if (current.range == max) {
			ordered_remove(&movement_cells_to_check, 0)
			continue
		}

		if current.cell.x > 0 && !movement_cells_already_checked(game_state.arena[current.cell.y * ARENA_WIDTH + current.cell.x - 1]) {
			if !game_state.arena[current.cell.y * ARENA_WIDTH + current.cell.x - 1].blocked && ( (!can_go_through && game_state.arena[current.cell.y * ARENA_WIDTH + current.cell.x - 1].entity == nil) || can_go_through ) {
				added_cell := Movement_Cell {range = current.range + 1, cell = game_state.arena[current.cell.y * ARENA_WIDTH + current.cell.x - 1]}
				append(&movement_cells_to_check, added_cell)
			}
		}

		if current.cell.x < ARENA_WIDTH - 1 && !movement_cells_already_checked(game_state.arena[current.cell.y * ARENA_WIDTH + current.cell.x + 1]) {
			if !game_state.arena[current.cell.y * ARENA_WIDTH + current.cell.x + 1].blocked && ( (!can_go_through && game_state.arena[current.cell.y * ARENA_WIDTH + current.cell.x + 1].entity == nil) || can_go_through ) {
				added_cell := Movement_Cell {range = current.range + 1, cell = game_state.arena[current.cell.y * ARENA_WIDTH + current.cell.x + 1]}
				append(&movement_cells_to_check, added_cell)
			}
		}

		if current.cell.y > 0 && !movement_cells_already_checked(game_state.arena[(current.cell.y - 1) * ARENA_WIDTH + current.cell.x]) {
			if !game_state.arena[(current.cell.y - 1) * ARENA_WIDTH + current.cell.x].blocked && ( (!can_go_through && game_state.arena[(current.cell.y - 1) * ARENA_WIDTH + current.cell.x].entity == nil) || can_go_through ) {
				added_cell := Movement_Cell {range = current.range + 1, cell = game_state.arena[(current.cell.y - 1) * ARENA_WIDTH + current.cell.x]}
				append(&movement_cells_to_check, added_cell)
			}
		}

		if current.cell.y < ARENA_HEIGHT - 1 && !movement_cells_already_checked(game_state.arena[(current.cell.y + 1) * ARENA_WIDTH + current.cell.x]) {
			if !game_state.arena[(current.cell.y + 1) * ARENA_WIDTH + current.cell.x].blocked && ( (!can_go_through && game_state.arena[(current.cell.y + 1) * ARENA_WIDTH + current.cell.x].entity == nil) || can_go_through ) {
				added_cell := Movement_Cell {range = current.range + 1, cell = game_state.arena[(current.cell.y + 1) * ARENA_WIDTH + current.cell.x]}
				append(&movement_cells_to_check, added_cell)
			}
		}

		ordered_remove(&movement_cells_to_check, 0)

	}

	return movement_cells
}

movement_cells_already_checked :: proc(cell : Cell) -> bool {
	for move in movement_cells_checked {
		if Compare_Cell(move, cell) {
			return true
		}
	}
	return false
}

read_map :: proc(map_name : string) -> [dynamic]string {
	return_lines : [dynamic]string
	if map_data, ok := os.read_entire_file(map_name, context.temp_allocator); ok {
		it := string(map_data)
		for line in strings.split_lines_iterator(&it) {
			if strings.contains(line, "//") {

			}
			else {
				append(&return_lines, line)
			}
			// process line
		}
    } else {
        log_error("Failed to read map_data")
    }

    return return_lines
}

read_level :: proc(map_info : [dynamic]string) -> Level {
	to_return : Level

	line : int = 0
	for y in 0..<10 {
		for x in 0..<10 {
			n, ok := strconv.parse_int(strings.cut(map_info[line],x, 1))
			to_return.cells[x][y] = n
		}
		line += 1
	}

	it := 0

	for str in strings.split_iterator(&map_info[line], "-") {
		if it == 0 {
			n, ok := strconv.parse_int(str)
			to_return.block_min = n
		}
		else {
			n, ok := strconv.parse_int(str)
			to_return.block_max = n
		}
		it += 1
	}

	line += 1

	it = 0
	for str in strings.split_iterator(&map_info[line], "-") {
		if it == 0 {
			n, ok := strconv.parse_int(str)
			to_return.bush_min = n
		}
		else {
			n, ok := strconv.parse_int(str)
			to_return.bush_max = n
		}
		it += 1
	}

	line += 1

	it = 0
	for str in strings.split_iterator(&map_info[line], "-") {
		if it == 0 {
			n, ok := strconv.parse_int(str)
			to_return.item_min = n
		}
		else {
			n, ok := strconv.parse_int(str)
			to_return.item_max = n
		}
		it += 1
	}

	line += 1

	it = 0
	for str in strings.split_iterator(&map_info[line], "-") {
		if it == 0 {
			n, ok := strconv.parse_int(str)
			to_return.enemies_min = n
		}
		else {
			n, ok := strconv.parse_int(str)
			to_return.enemies_max = n
		}
		it += 1
	}

	return to_return
}
