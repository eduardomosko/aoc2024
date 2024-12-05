package day05

import "core:fmt"
import "core:os"
import "core:strconv"
import "core:strings"
import "core:slice"


main :: proc() {
	data, ok := os.read_entire_file("./day05/input")
	assert(ok)
	defer delete(data)
	input := string(data)

	sep := strings.index(input, "\n\n")
	assert(sep != -1)

	orderings_input := input[:sep]
	updates_input := input[sep + 2:]

	orderings := make(map[int][dynamic]int)
	for ordering in strings.split_lines_iterator(&orderings_input) {
		sep := strings.index(ordering, "|")
		assert(sep != -1)

		ok: bool
		page_before, page_after: int
		page_before, ok = strconv.parse_int(ordering[:sep])
		assert(ok)
		page_after, ok = strconv.parse_int(ordering[sep + 1:])
		assert(ok)

		orderings[page_before] = orderings[page_before] or_else make([dynamic]int)
		_, err := append(&orderings[page_before], page_after)
		assert(err == nil)
	}

	fmt.println("orderings:", orderings)

	total := 0

	updates: for update_input in strings.split_lines_iterator(&updates_input) {
		update := make([dynamic]int)
		defer delete(update)

		update_input := update_input
		for num in strings.split_by_byte_iterator(&update_input, ',') {
			num, ok := strconv.parse_int(num)
			assert(ok)

			_, err := append(&update, num)
			assert(err == nil)
		}
		fmt.println(update)

		for num, i in update {
			for before in update[:i] {
				if slice.contains(orderings[num][:], before) {
					// broken rule
					//fmt.printfln("broken rule: %v|%v", num, before)
					continue updates
				}
			}
		}

		assert(len(update) % 2 == 1)
		midpoint := len(update) / 2
		fmt.println(update[midpoint])
		total += update[midpoint]
	}

	fmt.println(total)
}
