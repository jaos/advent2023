import Foundation

enum ReflectionType {
    case vertical
    case horizontal
}

struct Reflection {
    let type: ReflectionType
    let offset: Int

    var value: Int {
        return switch self.type {
        case .vertical: offset + 1
        case .horizontal: (offset + 1) * 100
        }
    }
}

struct Pattern {
    let input: [Character]
    let size: (Int, Int)

    func dump() {
        for x in 0..<size.0 {
            for y in 0..<size.1 {
                print(input[(x * size.1) + y], terminator: "")
            }
            print()
        }
    }

    static func _findReflectionOffset(_ lines: [String], smudge smudgeCount: Int = 0) -> Int? {
        let count = lines.count
        let range = 0..<count

        for offset in range {
            let next = offset + 1

            let linePairs: [(Int, Int)] =
                (next..<count)
                .map { ($0, next - ($0 - offset)) }
                .filter({ range.contains($0.0) && range.contains($0.1) })

            let delta: Int = linePairs.map {
                zip(lines[$0.0], lines[$0.1])
                    .map({ $0 == $1 ? 0 : 1 })
                    .reduce(0, +)
            }.reduce(0, +)

            if linePairs.count > 0 && delta == smudgeCount {
                return offset
            }
        }

        return nil
    }

    func reflection(smudge smudgeCount: Int = 0) -> Reflection? {
        let xCount = size.0
        let yCount = size.1

        let rows: [String] = (0..<xCount).map {
            let x = $0
            let xoffset = x * yCount
            return input[xoffset..<(xoffset + yCount)].map { String($0) }.joined(separator: "")
        }
        if let offset = Self._findReflectionOffset(rows, smudge: smudgeCount) {
            return Reflection(type: .horizontal, offset: offset)
        }

        let cols: [String] = (0..<yCount).map {
            let y = $0
            return (0..<xCount).map { String(input[($0 * yCount) + y]) }.joined(separator: "")
        }
        if let offset = Self._findReflectionOffset(cols, smudge: smudgeCount) {
            return Reflection(type: .vertical, offset: offset)
        }

        return nil
    }
}

func parsePatterns(input data: [String]) -> [Pattern] {
    var patterns: [Pattern] = []
    var scratch: [Character] = []
    var (lastX, lastY) = (0, 0)
    for line in data {
        scratch += line.map { Character(extendedGraphemeClusterLiteral: $0) }
        if line.count == 0 {
            patterns.append(Pattern(input: scratch, size: (lastX, lastY)))
            scratch = []
            lastX = 0
            lastY = 0
        } else {
            lastX += 1
            lastY = line.count
        }
    }
    patterns.append(Pattern(input: scratch, size: (lastX, lastY)))
    return patterns
}

func part1() throws -> Int {
    if CommandLine.argc < 2 {
        print("\(CommandLine.arguments[0]) <input file>")
        exit(1)
    }
    let inputPath = CommandLine.arguments[1]

    let data = try String(contentsOfFile: inputPath)
        .trimmingCharacters(in: ["\n"])
        .components(separatedBy: "\n")

    let patterns = parsePatterns(input: data)
    var sum = 0
    for p in patterns {
        if let r = p.reflection() {
            sum += r.value
        } else {
            print("No reflection!")
            p.dump()
            print()
        }
    }

    return sum
}

func part2() throws -> Int {
    if CommandLine.argc < 2 {
        print("\(CommandLine.arguments[0]) <input file>")
        exit(1)
    }
    let inputPath = CommandLine.arguments[1]

    let data = try String(contentsOfFile: inputPath)
        .trimmingCharacters(in: ["\n"])
        .components(separatedBy: "\n")

    let patterns = parsePatterns(input: data)
    var sum = 0
    for p in patterns {
        if let r = p.reflection(smudge: 1) {
            sum += r.value
        } else {
            print("No reflection!")
            p.dump()
            print()
        }
    }
    return sum
}

print("Result part1: \(try part1())")
print("Result part2: \(try part2())")
