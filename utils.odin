package game

import rl "vendor:raylib"

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