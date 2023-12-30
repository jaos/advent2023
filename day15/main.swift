import Foundation

func hashString(_ input: Substring) -> Int {
    var sum = 0
    input.forEach {
        sum += Int($0.asciiValue!)
        sum *= 17
        sum = sum % 256
    }
    return sum
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

    return data.map {
        $0.split(separator: ",")
            .map { hashString($0) }
            .reduce(0, +)
    }
    .reduce(0, +)
}

enum Op: Character {
    case addOrReplace = "="
    case remove = "-"

    var description: String {
        switch self {
        case .addOrReplace: return "addOrReplace"
        case .remove: return "remove"
        }
    }
}

struct Step {
    let label: String
    let box: Int
    let op: Op
    let focalLength: Int?

    var description: String {
        if let f = focalLength {
            return "\(label) \(f)"
        } else {
            return "\(label)"
        }
    }

    static func parse(from input: Substring) -> Self {
        if input.contains(Op.addOrReplace.rawValue) {
            let parts = input.split(separator: Op.addOrReplace.rawValue)
            return Self(
                label: String(parts[0]),
                box: hashString(parts[0]),
                op: Op.addOrReplace,
                focalLength: Int(parts[1])!
            )
        } else if input.contains(Op.remove.rawValue) {
            let parts = input.split(separator: Op.remove.rawValue)
            return Self(
                label: String(parts[0]),
                box: hashString(parts[0]),
                op: Op.remove,
                focalLength: nil
            )
        } else {
            print("Unknown input \(input)")
            exit(1)
        }
    }
}

struct BoxMap {
    var boxmap: [[Step]] = Array(repeating: [], count: 256)

    mutating func step(_ step: Step) {
        switch step.op {
        case .addOrReplace:
            if let idx = boxmap[step.box].firstIndex(where: { $0.label == step.label }) {
                let r = idx...idx
                boxmap[step.box].replaceSubrange(r, with: [step])
            } else {
                boxmap[step.box].append(step)
            }
        case .remove:
            if let idx = boxmap[step.box].firstIndex(where: { $0.label == step.label }) {
                let r = idx...idx
                boxmap[step.box].replaceSubrange(r, with: [])
            }
        }
    }

    func focusPower() -> Int {
        var power = 0
        for (boxIdx, steps) in boxmap.enumerated() {
            for (stepIdx, step) in steps.enumerated() {
                power += (1 + boxIdx) * (stepIdx + 1) * (step.focalLength ?? 0)
            }
        }
        return power
    }

    func dump() {
        for (idx, steps) in boxmap.enumerated() {
            if steps.count > 0 {
                print("Box \(idx): \(steps.map { $0.description})")
            }
        }
    }
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

    let steps: [Step] = data.flatMap {
        $0.split(separator: ",")
            .map { Step.parse(from: $0) }
    }

    var boxMap = BoxMap()
    for step in steps {
        boxMap.step(step)
    }
    return boxMap.focusPower()
}

print("Result part1: \(try part1())")
print("Result part2: \(try part2())")
