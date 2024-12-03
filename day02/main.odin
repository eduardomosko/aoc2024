package day02

import "core:fmt"
import "core:os"
import "core:strconv"
import "core:strings"

skip_space :: proc(str: string) -> string {
	str := str
	for len(str) > 0 && str[0] == ' ' do str = str[1:]
	return str
}

get_numbers :: proc(line: string) -> []int {
	nums := make([dynamic]int)
	line := line
	for line != "" {
		space := strings.index_byte(line, ' ')
		if space == -1 do space = len(line)

		num, ok := strconv.parse_int(line[:space])
		assert(ok)
		append(&nums, num)

		line = skip_space(line[space:])
	}
	return nums[:]
}

is_safe :: proc(nums: []int, problem_dampener: bool = false) -> bool {
	problem_dampener := problem_dampener // part 2
	dir := 0

	n1 := nums[0]
	for n2 in nums[1:] {

		if dir == 0 {
			// verify direction
			if n1 < n2 {
				dir = -1 // growing
			} else if n1 > n2 {
				dir = 1 // decreasing
			} else {
				if problem_dampener {
					problem_dampener = false
					continue
				} else {
					return false
				}
			}
		}

		diff := abs(n1 - n2)
		if diff > 3 || diff == 0 {
			if problem_dampener {
				problem_dampener = false
				continue
			} else {
				return false
			}
		}

		current_dir := (n1 - n2) / diff
		if current_dir != dir {
			if problem_dampener {
				problem_dampener = false
				continue
			} else {
				return false
			}
		}

		n1 = n2
	}
	return true
}

main :: proc() {
	data, ok := os.read_entire_file("./day02/input")
	assert(ok)
	input := string(data)
	defer delete(data)

	safe_count := 0

	lines: for line in strings.split_lines_iterator(&input) {
		nums := get_numbers(line)
		defer delete(nums)

		/*
		// part 1
		if is_safe(nums[:]) {
			safe_count += 1
		}
		*/

		// part 2
		if is_safe(nums[:], true) {
			safe_count += 1
			continue
		}

		nums2 := make([]int, len(nums) - 1)
		defer delete(nums2)

		// try removing each of the first 2 (they affect the direction)
		for i in 0 ..< 2 {
			copy(nums2[:i], nums[:i])
			copy(nums2[i:], nums[i+1:])

			if is_safe(nums2[:], false) {
				safe_count += 1
				continue lines
			}
		}
	}

	fmt.printfln("%v", safe_count)
}
