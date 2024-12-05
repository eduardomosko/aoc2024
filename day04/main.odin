package day04

import "core:fmt"
import "core:os"
import "core:strings"

has_word_in_direction :: proc(input: []string, word: string, pos, dir: [2]int) -> bool {
	if word == "" do return true
	if pos.y < 0 || pos.y >= len(input) do return false
	if pos.x < 0 || pos.x >= len(input[pos.y]) do return false
	if input[pos.y][pos.x] != word[0] do return false
	return has_word_in_direction(input, word[1:], pos + dir, dir)
}

has_x_mas_in_direction :: proc(input: []string, pos, mdir, wdir: [2]int) -> bool {
	return(
		has_word_in_direction(input, "MAS", pos, wdir + mdir) &&
		has_word_in_direction(input, "MAS", pos + mdir * 2, wdir - mdir) \
	)
}


main :: proc() {
	data, ok := os.read_entire_file("day04/input")
	assert(ok)

	input, err := strings.split_lines(string(data))
	assert(err == nil)
	defer delete(input)

	if input[len(input) - 1] == "" {
		input = input[:len(input) - 1]
	}


	directions := [][2]int {
		{1, 0}, // right
		//{1, 1}, // right-down
		{0, 1}, // down
		//{-1, 1}, // left-down
		{-1, 0}, // left
		//{-1, -1}, // left-up
		{0, -1}, // up
		//{1, -1}, // right-up
	}

	total_xmas := 0

	for line, y in input {
		for char, x in line {
			if char != 'M' do continue

			pos := [2]int{x, y}
			for mdir in directions {
				for dir in directions {
					if mdir.x == dir.x || mdir.y == dir.y do continue // doesn't make sense to look at same axis

					if has_x_mas_in_direction(input, pos, mdir, dir) {
						total_xmas += 1
					}
				}
			}
		}
	}

	fmt.println(total_xmas / 2)
}
