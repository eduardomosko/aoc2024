package day03

import "core:fmt"
import "core:os"
import "core:strconv"
import "core:unicode"
import "core:unicode/utf8"

ParseState :: union #no_nil {
	MulState,
	NumState,
	CommaState,
	EndState,
}

mul_ref :: "mul("
MulState :: struct {
	mul_pos: int, // where in the ref we are
}

NumState :: struct {
	start:  int, // index of where digits start
	target: ^int, // where to store the data
}

CommaState :: struct {}

EndState :: struct {}


main :: proc() {
	data, ok := os.read_entire_file("day03/example2")
	assert(ok)
	defer delete(data)
	input := string(data)

	n1, n2, total := 0, 0, 0

	state: ParseState = MulState{}
	for v, i in input {
		reprocess := true

		for reprocess {
			//fmt.printfln("%v %v   %v", i, v, state)
			reprocess = false

			#partial switch &s in state {
			case MulState:
				if utf8.rune_at(mul_ref, s.mul_pos) == v {
					s.mul_pos += 1
				} else {
					s.mul_pos = 0
				}

				if s.mul_pos == len(mul_ref) {
					// next state
					state = NumState {
						start  = i + 1,
						target = &n1,
					}
				}
			case NumState:
				if !unicode.is_digit(v) {
					digits := input[s.start:i]

					num, ok := strconv.parse_int(digits)
					if ok {
						s.target^ = num

						// next state
						state = CommaState{} if s.target == &n1 else EndState{}
						reprocess = true
					} else {
						// failed, restart
						state = MulState{}
						reprocess = true
					}
				}
			case CommaState:
				if v == ',' {
					// next state
					state = NumState {
						start  = i + 1,
						target = &n2,
					}
				} else {
					// failed, restart
					state = MulState{}
					reprocess = true
				}
			case EndState:
				if v == ')' {
					total += n1 * n2

					// next mul
					state = MulState{}
				} else {
					// failed, restart
					state = MulState{}
					reprocess = true
				}
			}
		}
	}

	fmt.println(total)
}
