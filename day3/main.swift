import Foundation

enum SchematicSym: Equatable {
    case Number(UInt)
    case PartialNumber(UInt)
    case Symbol(Character)
    case Empty
}

struct Part {
    let id: Character
    let partNumbers: [UInt]
}

func add_found_numbers(_ line: inout [SchematicSym], _ sofar: inout String) {
    guard sofar.count > 0 else { return }
    let n = UInt(sofar)!
    line += Array<SchematicSym>(repeating: SchematicSym.PartialNumber(n), count: sofar.count)
    sofar = ""
}

func get_parts(_ schematic: [[SchematicSym]]) -> [Part] {
    var parts: [Part] = []

    func find_part_numbers(_ x: Int, _ y: Int) -> [UInt] {
        let positions = [
            "left": (x, y-1),
            "right": (x, y+1),
            "up": (x-1, y),
            "upleftdiag": (x-1, y-1),
            "uprightdiag": (x-1, y+1),
            "down": (x+1, y),
            "downleftdiag": (x+1, y-1),
            "downrightdiag": (x+1, y+1),
        ]
        var positionValues: [String: UInt] = [:]
        for (k, (x,y)) in positions {
            guard schematic.indices.contains(x) && schematic[x].indices.contains(y) else { continue }

            switch schematic[x][y] {
            case .Number(let n), .PartialNumber(let n):
                positionValues[k] = n
            default: continue
            }
        }

        // HACK: eliminate invalid dupes of our partials across the upper/lower diag
        if positionValues["upleftdiag"] == positionValues["up"] && positionValues["up"] == positionValues["uprightdiag"] {
            positionValues["up"] = nil
            positionValues["uprightdiag"] = nil
        } else if positionValues["upleftdiag"] == positionValues["up"] || positionValues["uprightdiag"] == positionValues["up"] {
            positionValues["up"] = nil
        }
        if positionValues["downleftdiag"] == positionValues["down"] && positionValues["down"] == positionValues["downrightdiag"] {
            positionValues["down"] = nil
            positionValues["downrightdiag"] = nil
        } else if positionValues["downleftdiag"] == positionValues["down"] || positionValues["downrightdiag"] == positionValues["down"] {
            positionValues["down"] = nil
        }

        return Array<UInt>(positionValues.values)
    }

    for (x, row) in schematic.enumerated() {
        for (y, val) in row.enumerated() {
            if case .Symbol(let c) = val {
                let partNos = find_part_numbers(x, y)
                parts.append(Part(id: c, partNumbers: partNos))
            }
        }
    }
    return parts
}

func parse_schematic(_ data: [String]) -> [[SchematicSym]] {
    var schematic: [[SchematicSym]] = []

    for line in data {
        var schematic_for_line: [SchematicSym] = []
        var numberBuffer = ""
        for c in line {
            switch c {
            case "0"..."9":
                numberBuffer.append(c)
            default:
                add_found_numbers(&schematic_for_line, &numberBuffer)
                if c == "." {
                    schematic_for_line.append(SchematicSym.Empty)
                } else {
                    schematic_for_line.append(SchematicSym.Symbol(c))
                }
            }
        }

        // end of line tricksy... spent about 30 minutes here until i added test case:
        // .......666
        // .......^..
        add_found_numbers(&schematic_for_line, &numberBuffer)

        schematic.append(schematic_for_line)
    }
    return schematic
}

func day3_part1() throws -> UInt {
    if CommandLine.argc < 2 {
        print("\(CommandLine.arguments[0]) <input file>")
        exit(1)
    }
    let inputPath = CommandLine.arguments[1]

    let data = try String(contentsOfFile: inputPath)
        .trimmingCharacters(in: ["\n"])
        .components(separatedBy:"\n")

    let schematic = parse_schematic(data)
    let parts = get_parts(schematic)

    return parts.map {p in p.partNumbers.reduce(0, +) }.reduce(0, +)
}

func day3_part2() throws -> UInt {
    if CommandLine.argc < 2 {
        print("\(CommandLine.arguments[0]) <input file>")
        exit(1)
    }
    let inputPath = CommandLine.arguments[1]

    let data = try String(contentsOfFile: inputPath)
        .trimmingCharacters(in: ["\n"])
        .components(separatedBy:"\n")

    let schematic = parse_schematic(data)
    let parts = get_parts(schematic)

    return parts
    .filter {p in p.partNumbers.count == 2 }
    .map { p in p.partNumbers[0] * p.partNumbers[1] }
    .reduce(0, +)
}

print("Result part1: \(try day3_part1())")
print("Result part2: \(try day3_part2())")
