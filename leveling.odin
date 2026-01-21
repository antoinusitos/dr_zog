package game

import "core:fmt"
import rl "vendor:raylib"

init_leveling_ui :: proc() {

}

init_leveling :: proc() {

}

update_leveling :: proc() {

}

draw_leveling :: proc() {
	rl.DrawText(fmt.ctprint("Level Up !"), WINDOW_WIDTH / 2 - 100, 20, 50, rl.WHITE)
}