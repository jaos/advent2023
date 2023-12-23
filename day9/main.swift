import Foundation

func to_seq(_ input: String) -> [Int] {
    return input.split(separator: " ").map { Int($0)! }
}

func predict_next(_ values: [Int]) -> Int {
    var values = values
    var to_sum:[Int] = []

    while values.filter({ $0 != 0}).count > 0 {
        to_sum.append(values.last!)
        values = values.enumerated()
        .compactMap { idx, v in
            return idx == 0 ? nil : v - values[idx - 1]
        }
    }
    return to_sum.reduce(0, +)
}

func predict_previous(_ values: [Int]) -> Int {
    var values = values
    var to_subtract:[Int] = []

    while values.filter({ $0 != 0}).count > 0 {
        to_subtract.append(values.first!)
        values = values.enumerated()
        .compactMap { idx, v in
            return idx == 0 ? nil : v - values[idx - 1]
        }
    }
    return to_subtract.reversed().reduce(0) { $1 - $0}
}

func day9_part1() throws -> Int {
    if CommandLine.argc < 2 {
        print("\(CommandLine.arguments[0]) <input file>")
        exit(1)
    }
    let inputPath = CommandLine.arguments[1]

    let data = try String(contentsOfFile: inputPath)
        .trimmingCharacters(in: ["\n"])
        .components(separatedBy:"\n")

    return data.map { predict_next(to_seq($0)) }.reduce(0, +)
}

func day9_part2() throws -> Int {
    if CommandLine.argc < 2 {
        print("\(CommandLine.arguments[0]) <input file>")
        exit(1)
    }
    let inputPath = CommandLine.arguments[1]

    let data = try String(contentsOfFile: inputPath)
        .trimmingCharacters(in: ["\n"])
        .components(separatedBy:"\n")

    return data.map { predict_previous(to_seq($0)) }.reduce(0, +)
}

print("Result part1: \(try day9_part1())")
print("Result part2: \(try day9_part2())")
