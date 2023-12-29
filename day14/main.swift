import Foundation

let roundRock: Character = "O"
let cubeRock: Character = "#"

struct Platform {
    var columns: [Character]
    let size: (Int, Int)

    mutating func tiltNorth() {
        for y in 0..<size.1 {
            let col = (0..<size.0)
                .map { columns[($0 * size.1) + y] }
                .split(separator: cubeRock, omittingEmptySubsequences: false)
                .map { $0.sorted().reversed() }
                .joined(separator: [cubeRock])

            for (idx, c) in col.enumerated() {
                columns[(idx * size.1) + y] = c
            }
        }
    }

    mutating func tiltSouth() {
        for y in 0..<size.1 {
            let col = (0..<size.0)
                .map { columns[($0 * size.1) + y] }
                .split(separator: cubeRock, omittingEmptySubsequences: false)
                .map { $0.sorted() }
                .joined(separator: [cubeRock])

            for (x, c) in col.enumerated() {
                columns[(x * size.1) + y] = c
            }
        }
    }

    mutating func tiltWest() {
        for x in 0..<size.0 {
            let row = (0..<size.1)
                .map { columns[(x * size.1) + $0] }
                .split(separator: cubeRock, omittingEmptySubsequences: false)
                .map { $0.sorted().reversed() }
                .joined(separator: [cubeRock])

            for (y, c) in row.enumerated() {
                columns[(x * size.1) + y] = c
            }
        }
    }

    mutating func tiltEast() {
        for x in 0..<size.0 {
            let row = (0..<size.1)
                .map { columns[(x * size.1) + $0] }
                .split(separator: cubeRock, omittingEmptySubsequences: false)
                .map { $0.sorted() }
                .joined(separator: [cubeRock])

            for (y, c) in row.enumerated() {
                columns[(x * size.1) + y] = c
            }
        }
    }

    mutating func cycle(count cycles: Int) {
        for _ in 0..<cycles {
            tiltNorth()
            tiltWest()
            tiltSouth()
            tiltEast()
        }
    }

    func northLoad() -> Int {
        var sum = 0
        for y in 0..<size.1 {
            for x in 0..<size.0 {
                if columns[(x * size.1) + y] == roundRock {
                    sum += size.1 - x
                }
            }
        }
        return sum
    }

    static func parse(from input: [String]) -> Self {
        var columns: [Character] = []
        for line in input {
            columns += line.map { Character(extendedGraphemeClusterLiteral: $0) }
        }
        return Platform(columns: columns, size: (input.count, input[0].count))
    }

    func dump() {
        for x in 0..<size.0 {
            for y in 0..<size.1 {
                print(columns[(x * size.1) + y], terminator: "")
            }
            print()
        }
        print()
    }
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

    var platform = Platform.parse(from: data)
    platform.tiltNorth()
    return platform.northLoad()
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

    var platform = Platform.parse(from: data)
    //platform.cycle(count: 1_000_000_000)
    platform.cycle(count: 1_000)
    return platform.northLoad()
}

print("Result part1: \(try part1())")
print("Result part2: \(try part2())")
