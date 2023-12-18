import Foundation

let namesOfNumbers = [
    ("zero", "0"),
    ("one", "1"),
    ("two", "2"),
    ("three", "3"),
    ("four", "4"),
    ("five", "5"),
    ("six", "6"),
    ("seven", "7"),
    ("eight", "8"),
    ("nine", "9"),
]

func day1_part1() throws -> Int {
    if CommandLine.argc < 2 {
        print("\(CommandLine.arguments[0]) <input file>")
        exit(1)
    }
    let inputPath = CommandLine.arguments[1]

    let data = try String(contentsOfFile: inputPath).trimmingCharacters(in: ["\n"]).components(separatedBy:"\n")
    var sum = 0
    for line in data {
        let sub = line.filter {s in s.isNumber}
        let pair = (sub[sub.startIndex].wholeNumberValue! * 10, sub[sub.index(before: sub.endIndex)].wholeNumberValue!)
        sum += (pair.0 + pair.1)
    }
    return sum
}

func r(_ input: String) -> String {
    var updated = ""
    var walk = input[input.startIndex...]
    while walk.count > 0 {
        var found = false;
        for (k,v) in namesOfNumbers {
            if walk.starts(with: k) {
                updated.append(v)
                walk = walk[walk.index(after: walk.startIndex)...]
                found = true
                break
            }
        }
        if !found {
            let r = walk.index(after: walk.startIndex)
            updated.append(String(walk[..<r]))
            walk = walk[r...]
        }
    }
    return updated
}


func day1_part2() throws -> Int {
    if CommandLine.argc < 2 {
        print("\(CommandLine.arguments[0]) <input file>")
        exit(1)
    }
    let inputPath = CommandLine.arguments[1]

    let data = try String(contentsOfFile: inputPath).trimmingCharacters(in: ["\n"]).components(separatedBy:"\n")
    var sum = 0
    for var line in data {
        line = r(line)
        let sub = line.filter {s in s.isNumber}
        let pair = (sub[sub.startIndex].wholeNumberValue! * 10, sub[sub.index(before: sub.endIndex)].wholeNumberValue!)
        sum += (pair.0 + pair.1)
    }
    return sum
}

print(try day1_part1())
print(try day1_part2())
