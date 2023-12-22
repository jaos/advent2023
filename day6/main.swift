import Foundation

struct Race {
    let duration: Int
    let distance_record: Int

    /* quick part1
    func winning_charge_times() -> [Int] {
        return (1..<duration).map { $0 * (duration - $0)}.filter { $0 > distance_record }
    }
    */

    func winning_charges_range() -> ClosedRange<Int> {
        let r = 1..<duration
        let check = { (i:Int) -> Bool in (i * (duration - i)) > distance_record }
        return r.firstIndex(where: check)!...r.lastIndex(where: check)!
    }
}

func parse_races_part1(_ data: [String]) -> [Race] {
    return zip(
        data[0].split(separator:":")[1].split(separator:" ").map{Int($0)!},
        data[1].split(separator:":")[1].split(separator:" ").map{Int($0)!}
    ).map {
        Race(duration: $0, distance_record: $1)
    }
}

func parse_races_part2(_ data: [String]) -> Race {
    return Race(
        duration: Int(data[0].split(separator:":")[1].filter({ $0 != " "}))!,
        distance_record: Int(data[1].split(separator:":")[1].filter({ $0 != " "}))!
    )
}

func day6_part1() throws -> Int {
    if CommandLine.argc < 2 {
        print("\(CommandLine.arguments[0]) <input file>")
        exit(1)
    }
    let inputPath = CommandLine.arguments[1]

    let data = try String(contentsOfFile: inputPath)
        .trimmingCharacters(in: ["\n"])
        .components(separatedBy:"\n")

    return parse_races_part1(data).map { $0.winning_charges_range().count }.reduce(1, *)
}

func day6_part2() throws -> Int {
    if CommandLine.argc < 2 {
        print("\(CommandLine.arguments[0]) <input file>")
        exit(1)
    }
    let inputPath = CommandLine.arguments[1]

    let data = try String(contentsOfFile: inputPath)
        .trimmingCharacters(in: ["\n"])
        .components(separatedBy:"\n")

    return parse_races_part2(data).winning_charges_range().count
}

print("Result part1: \(try day6_part1())")
print("Result part2: \(try day6_part2())")
