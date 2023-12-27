import Foundation

enum Part {
    case operational
    case broken
    case unknown

    static func from(character c: Character) -> Self {
        switch c {
        case "#": .broken
        case "?": .unknown
        default: .operational
        }
    }
}

struct PartRow {
    let row: String
    let ranges: [Int]

    static var _parsedCache: [String: [Part]] = [:]
    var parsed: [Part] {
        if let cached = Self._parsedCache[row] {
            return cached
        }
        let v = row.map { Part.from(character: $0) }
        Self._parsedCache[row] = v
        return v
    }

    static func parse(from input: String) -> Self {
        let recordParts = input.split(separator: " ")
        guard recordParts.count == 2 else {
            print("Invalid record: \(input)")
            exit(1)
        }
        let ranges = recordParts[1].split(separator: ",").map { Int($0)! }

        return Self(row: String(recordParts[0]), ranges: ranges)
    }

    static func parse2(from input: String) -> Self {
        let recordParts = input.split(separator: " ")
        guard recordParts.count == 2 else {
            print("bad data for \(input)")
            exit(1)
        }
        let row = Array(repeating: recordParts[0], count: 5)
            .joined(separator: "?")
        let ranges = Array(repeating: recordParts[1], count: 5)
            .joined(separator: ",")
            .split(separator: ",").map { Int($0)! }

        return Self(row: row, ranges: ranges)
    }

    func calc() -> Int {
        return Self._calc(self)
    }

    static var _calcCache: [Self: Int] = [:]
    static func _calc(_ partRow: Self) -> Int {
        let parts = partRow.parsed

        guard let damagedCount = partRow.ranges.first else {
            return !parts.contains(.broken) ? 1 : 0
        }
        guard let part = parts.first else { return 0 }

        if let cached = Self._calcCache[partRow] {
            return cached
        }

        func scan() -> Int {
            guard parts.count >= damagedCount else { return 0 }

            let transformed = parts[0..<damagedCount].map { $0 == .unknown ? .broken : $0 }
            if transformed != Array(repeating: .broken, count: damagedCount) {
                return 0
            }

            if parts.count == damagedCount {
                return partRow.ranges.count == 1 ? 1 : 0
            }

            if [.unknown, .operational].contains(parts[damagedCount]) {
                let row = partRow.row.dropFirst(damagedCount + 1)
                let range = partRow.ranges[1...]
                let next = Self(row: String(row), ranges: Array(range))
                return _calc(next)
            }

            return 0
        }

        let next = Self(row: String(partRow.row.dropFirst()), ranges: partRow.ranges)
        let out =
            switch part {
            case .operational: _calc(next)
            case .broken: scan()
            case .unknown: _calc(next) + scan()
            }

        Self._calcCache[partRow] = out
        return out
    }
}
extension PartRow: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(row)
        for n in ranges {
            hasher.combine(n)
        }
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

    return data.map { PartRow.parse(from: $0) }
        .map { $0.calc() }
        .reduce(0, +)
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

    return data.map { PartRow.parse2(from: $0) }
        .map { $0.calc() }
        .reduce(0, +)
}

print("Result part1: \(try part1())")
print("Result part2: \(try part2())")
