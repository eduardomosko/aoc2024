package day06

import "core:bytes"
import "core:fmt"
import "core:math"
import "core:math/linalg"
import "core:os"
import "core:slice"
import "core:strings"

main :: proc() {
	input, ok := os.read_entire_file("./day06/input")
	assert(ok)
	defer delete(input)

	m := bytes.split(input, []byte{'\n'})
	if len(m[len(m) - 1]) == 0 do m = m[:len(m) - 1]


	guard_ang := linalg.to_radians(-90.)
	guard_dir := [2]int{0, -1}
	guard_pos := [2]int{-1, -1}
	for line, y in m {
		for char, x in line {
			if char == '^' {
				guard_pos = {x, y}
			}
		}
	}
	assert(guard_pos != {-1, -1})
	total := 0

	for in_bounds(m, guard_pos) {
		if m[guard_pos.y][guard_pos.x] != 'X' {
			total += 1
			m[guard_pos.y][guard_pos.x] = 'X'
		}

		next := [2]int{guard_pos.x + int(guard_dir.x), guard_pos.y + int(guard_dir.y)}

		for in_bounds(m, next) && m[next.y][next.x] == '#' {
			// rotate 90deg
			guard_ang += linalg.to_radians(90.)
			guard_dir = [2]int{int(math.cos(guard_ang)), int(math.sin(guard_ang))}
			fmt.printfln("ang: %v new_dir: %v", linalg.to_degrees(guard_ang), guard_dir)

			next = [2]int{guard_pos.x + int(guard_dir.x), guard_pos.y + int(guard_dir.y)}
		}
		guard_pos = next
	}

	/*
	for line, y in m {
		fmt.printfln("%s", line)
	}
	*/

	fmt.println(total)
}

in_bounds :: proc(m: [][]u8, crd: [2]int) -> bool {
	return crd.y >= 0 && crd.y < len(m) && crd.x >= 0 && crd.x < len(m[crd.y])
}
