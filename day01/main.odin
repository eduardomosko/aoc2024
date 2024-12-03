package day01

import "core:fmt"
import "core:os"
import "core:strings"
import "core:strconv"
import "core:slice"

main :: proc() {
	input_data, ok := os.read_entire_file("./day01/input")
	//input_data, ok := os.read_entire_file("./day01/example")
	assert(ok)
	defer delete(input_data)

	input := string(input_data)

	l1 := make([dynamic]int)
	l2 := make([dynamic]int)


	for line in strings.split_lines_iterator(&input) {
		space := strings.index_byte(line, ' ')

		str, line := line[:space], line[space:]
		val, ok := strconv.parse_int(str)
		assert(ok)
		append(&l1, val)

		for line[0] == ' ' {
			line = line[1:]
		}

		val, ok = strconv.parse_int(line)
		assert(ok)
		append(&l2, val)
	}

	/* 
	// puzzle 1
	slice.sort(l1[:])
	slice.sort(l2[:])

	total_distance := 0

	for v1, i in l1 {
		v2 := l2[i]

		total_distance += abs(v1 - v2)
	}
	*/

	// puzzle 2

	similarity_score := 0

	for num in l1 {
		mult := slice.count(l2[:], num)

		similarity_score += num * mult
	}

	fmt.printfln("%v", similarity_score)
}
