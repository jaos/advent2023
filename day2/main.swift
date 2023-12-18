import Foundation

enum Color: String {
    case red   = "red"
    case green = "green"
    case blue  = "blue"
}

struct Game {
    let id:       UInt
    var maxRed:   UInt
    var maxGreen: UInt
    var maxBlue:  UInt

    static func parse(_ input: String) -> Self? {
        let parts =
            input
            .replacingOccurrences(of: ": ", with: "\n")
            .replacingOccurrences(of: "; ", with: "\n")
            .split(separator: "\n")

        guard parts.count > 1
        else { return nil }

        guard let gameId = UInt(parts[0].replacingOccurrences(of: "Game ", with: ""))
        else { return nil }

        var game = Game(
            id: gameId,
            maxRed:   0,
            maxGreen: 0,
            maxBlue:  0
        )

        parts[1...].forEach { set in
            set.split(separator: ",").forEach { pair in
                let count_and_color = pair.split(separator: " ", maxSplits: 2)
                if count_and_color.count == 2, let count = UInt(count_and_color[0]) {
                    switch count_and_color[1] {
                    case Color.red.rawValue:
                        game.maxRed = max(count, game.maxRed)
                    case Color.green.rawValue:
                        game.maxGreen = max(count, game.maxGreen)
                    case Color.blue.rawValue:
                        game.maxBlue = max(count, game.maxBlue)
                    default: break
                    }
                }
            }
        }
        return game
    }
}

func day2_part1() throws -> UInt {
    if CommandLine.argc < 2 {
        print("\(CommandLine.arguments[0]) <input file>")
        exit(1)
    }
    let inputPath = CommandLine.arguments[1]

    let data = try String(contentsOfFile: inputPath)
        .trimmingCharacters(in: ["\n"])
        .components(separatedBy:"\n")

    let maxRed   = 12
    let maxGreen = 13
    let maxBlue  = 14

    var sum: UInt = 0
    for line in data {
        if let game = Game.parse(line) {
            if game.maxRed <= maxRed && game.maxGreen <= maxGreen && game.maxBlue <= maxBlue {
                sum += game.id
            }
        } else {
            print("ERROR invalid line: \(line)")
        }
    }

    return sum
}



func day2_part2() throws -> UInt {
    if CommandLine.argc < 2 {
        print("\(CommandLine.arguments[0]) <input file>")
        exit(1)
    }
    let inputPath = CommandLine.arguments[1]

    let data = try String(contentsOfFile: inputPath)
        .trimmingCharacters(in: ["\n"])
        .components(separatedBy:"\n")

    var sum: UInt = 0
    for line in data {
        if let game = Game.parse(line) {
            sum += game.maxRed * game.maxGreen * game.maxBlue
        } else {
            print("ERROR invalid line: \(line)")
        }
    }

    return sum
}

print("Result: \(try day2_part1())")
print("Result: \(try day2_part2())")
