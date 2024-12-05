package day03

import "core:fmt"
import "core:mem"
import "core:os"
import "core:strconv"
import "core:unicode"
import "core:unicode/utf8"

ParseState :: union #no_nil {
	InstructionState,
	NumState,
	CommaState,
	EndState,
}


InstructionState :: struct {
	start: int,
	tree:  ^InstructionTree,
}

NumState :: struct {
	start:  int, // index of where digits start
	target: ^int, // where to store the data
}

CommaState :: struct {}

EndState :: struct {}


instructions := (map[string]Instruction) {
	"mul("   = Instruction.Mul,
	"don't(" = Instruction.Dont,
	"do("    = Instruction.Do,
}

Instruction :: enum {
	Mul,
	Dont,
	Do,
}

InstructionNode :: struct {
	r:    rune,
	tree: ^InstructionTree,
}
InstructionTree :: struct {
	nodes: []InstructionNode,
}

build_tree :: proc(instructions: []string) -> ^InstructionTree {
	region := make([]byte, 1024 * 2)
	defer delete(region)

	arena: mem.Arena
	mem.arena_init(&arena, region)
	temp_allocator := mem.arena_allocator(&arena)

	runes := make(map[rune][dynamic]string, allocator = temp_allocator)

	instructions_left := len(instructions)
	for &instruction, i in instructions {
		if instruction == "" do continue

		first := utf8.rune_at(instruction, 0)
		instruction = instruction[utf8.rune_size(first):]

		if len(runes[first]) == 0 {
			runes[first] = make([dynamic]string, 0, temp_allocator)
		}

		if instruction == "" do continue
		_, err := append(&runes[first], instruction)
		assert(err == nil, fmt.tprintf("unable to allocate: %v", err))
	}

	nodes := make([]InstructionNode, len(runes))

	i := 0
	for r, instructions in runes {
		node := InstructionNode {
			r = r,
		}

		//fmt.println(r, instructions)
		if len(instructions) > 0 {
			node.tree = build_tree(instructions[:])
		}

		nodes[i] = node
		i += 1
	}

	clear(&runes)

	tree := new(InstructionTree)
	tree.nodes = nodes[:]
	return tree
}

print_tree_possibilities :: proc(tree: ^InstructionTree, accumulated: string = "") {
	for node in tree.nodes {
		str := fmt.tprintf("%v%v", accumulated, node.r)
		if node.tree != nil {
			print_tree_possibilities(node.tree, str)
		} else {
			fmt.println(str)
		}
	}
}

main :: proc() {
	instruction_tree: ^InstructionTree
	tree_region := make([]byte, 1024 * 20)
	defer delete(tree_region)

	{
		arena: mem.Arena
		mem.arena_init(&arena, tree_region)
		context.allocator = mem.arena_allocator(&arena)

		instruction_tree = build_tree([]string{"mul(", "do(", "don't("})

		//fmt.println(arena.peak_used)
	}

	//print_tree_possibilities(instruction_tree)

	data, ok := os.read_entire_file("day03/input")
	assert(ok)
	defer delete(data)
	input := string(data)

	instruction := Instruction.Mul
	enabled := true
	n1, n2, total := 0, 0, 0

	state: ParseState = InstructionState {
		start = 0,
		tree  = instruction_tree,
	}
	chars: for v, i in input {
		reprocess := true

		for reprocess {
			fmt.printfln(
				"%v %v - (%v * %v = %v) %v %v -  %v",
				i,
				v,
				n1,
				n2,
				total,
				instruction,
				enabled,
				state,
			)
			reprocess = false

			#partial switch &s in state {
			case InstructionState:
				if s.tree == nil { 	// found one instruction
					value := input[s.start:i]
					instruction = instructions[value]

					// next state
					state =
						NumState{start = i, target = &n1} if instruction == .Mul else EndState{}
					reprocess = true
					continue
				}
				for node in s.tree.nodes {
					if node.r == v {
						s.tree = node.tree
						continue chars
					}
				}

				// failed, restart
				state = InstructionState {
					start = i + utf8.rune_size(v),
					tree  = instruction_tree,
				}
			//reprocess = true
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
						state = InstructionState {
							start = i + utf8.rune_size(v),
							tree  = instruction_tree,
						}
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
					state = InstructionState {
						start = i + utf8.rune_size(v),
						tree  = instruction_tree,
					}
					reprocess = true
				}
			case EndState:
				if v == ')' {
					switch instruction {
					case .Mul:
						if enabled do total += n1 * n2
					case .Dont:
						enabled = false
					case .Do:
						enabled = true
					}

					// next instruction
					state = InstructionState {
						start = i + utf8.rune_size(v),
						tree  = instruction_tree,
					}
				} else {
					// failed, restart
					state = InstructionState {
						start = i + utf8.rune_size(v),
						tree  = instruction_tree,
					}
					reprocess = true
				}
			}
		}
	}

	fmt.println(total)
}
