import Foundation

enum Direction: Int {
    case Left = 0
    case Right
}

struct Path {
    let directions: [Direction]
    let steps: [String: (String,String)]

    static func parse(_ input: [String]) -> Self? {
        let directions:[Direction] = input[0].compactMap {
            switch $0 {
                case "R": return Direction.Right
                case "L": return Direction.Left
                default: return nil;
            }
        }

        let omit:[Character] = [")", "(", ",", " "]

        let steps = input[1...]
        .compactMap {
            let split = $0.split(separator: " ")
            guard split.count == 4 else { return nil }

            let label = split[0].filter { !omit.contains($0) }
            let left = split[2].filter { !omit.contains($0) }
            let right = split[3].filter { !omit.contains($0) }
            return (label, left, right)
        }
        .reduce(into: [:]) {
            (steps, entry:(String,String,String)) in
            steps[entry.0] = (entry.1, entry.2)
        }

        return Self(directions: directions, steps: steps)
    }

    func part1() -> Int {
        var steps = 0
        guard var entry = self.steps["AAA"] else { return steps }
        repeat {
            for direction in self.directions {
                steps += 1
                let next = direction == .Left ? entry.0 : entry.1
                if next == "ZZZ" {
                    return steps
                }
                entry = self.steps[next]!
            }
        } while true
        return steps
    }

    func part2(_ start: String) -> Int {
        var steps = 0
        guard var entry = self.steps[start] else { return steps }
        repeat {
            for direction in self.directions {
                steps += 1
                let next = direction == .Left ? entry.0 : entry.1
                if next.hasSuffix("Z") {
                    return steps
                }
                entry = self.steps[next]!
            }
        } while true
        return steps
    }

}

func day8_part1() throws -> Int {
    if CommandLine.argc < 2 {
        print("\(CommandLine.arguments[0]) <input file>")
        exit(1)
    }
    let inputPath = CommandLine.arguments[1]

    let data = try String(contentsOfFile: inputPath)
        .trimmingCharacters(in: ["\n"])
        .components(separatedBy:"\n")

    let p = Path.parse(data)!
    return p.part1()
}

func day8_part2() throws -> Int {
    if CommandLine.argc < 2 {
        print("\(CommandLine.arguments[0]) <input file>")
        exit(1)
    }
    let inputPath = CommandLine.arguments[1]

    let data = try String(contentsOfFile: inputPath)
        .trimmingCharacters(in: ["\n"])
        .components(separatedBy:"\n")

    func gcd(_ n1: Int, _ n2: Int) -> Int { let m = n1 % n2; return m == 0 ? n2 : gcd(n2, m) }
    func lcm(_ n1: Int, _ n2: Int) -> Int { return n1 / gcd(n1, n2) * n2 }
    func xlcm(_ n: [Int]) -> Int { return n.reduce(1) { lcm($0, $1) } }

    let p = Path.parse(data)!
    let runs = p.steps.keys
        .filter { $0.hasSuffix("A") }
        .map { p.part2($0) }
    return xlcm(runs)
}

print("Result part1: \(try day8_part1())")
print("Result part2: \(try day8_part2())")
