import Foundation

struct Point {
    let x: Int
    let y: Int
}

enum PointType: Character {
    case empty = "."
    case galaxy = "#"
}

struct Galaxy {
    let id: Int
    let coord: Point

    func distance(to galaxy: Self) -> Int {
        return abs(coord.x - galaxy.coord.x) + abs(coord.y - galaxy.coord.y)
    }
}
extension Galaxy: Equatable {
    static func == (rhs: Self, lhs: Self) -> Bool {
        return rhs.coord.x == lhs.coord.x && rhs.coord.y == lhs.coord.y
    }
}

struct GalaxyMap {
    let galaxies: [Galaxy]

    static func from(input data: [String], factor addForEmpty: Int = 2) -> Self {
        // book keeping... observe empty rows and columns as we go
        let colcount = data[0].count
        var colCount: [Int: Int] = Dictionary(uniqueKeysWithValues: (0..<colcount).map { ($0, 0) })
        var emptyRows: [Int] = []

        // parse our our galaxies
        var origGalaxies: [Galaxy] = []
        for (lineNumber, line) in data.enumerated() {

            let p: [PointType] = line.map {
                switch $0 {
                case "#": .galaxy
                default: .empty
                }
            }

            var found = false
            for (colNumber, col) in p.enumerated() {
                if case .galaxy = col {
                    found = true
                    colCount[colNumber]! += 1
                    origGalaxies.append(Galaxy(id: origGalaxies.count + 1, coord: Point(x: lineNumber, y: colNumber)))
                }
            }

            // note empty rows for expansion
            if !found {
                emptyRows.append(lineNumber)
            }
        }

        // figure out which columns were empty... we need these for expansion
        let emptyColumns = colCount.filter({ $0.1 == 0 }).keys.sorted()

        return Self(
            galaxies: origGalaxies.map { g in
                // scale x and y by empty factor
                let x = g.coord.x + emptyRows.map { g.coord.x > $0 ? (addForEmpty - 1) : 0 }.reduce(0, +)
                let y = g.coord.y + emptyColumns.map { g.coord.y > $0 ? (addForEmpty - 1) : 0 }.reduce(0, +)
                return Galaxy(id: g.id, coord: Point(x: x, y: y))
            }
        )
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

    let galaxyMap = GalaxyMap.from(input: data)

    var sum = 0
    for (i, galaxy) in galaxyMap.galaxies.enumerated() {
        for other in galaxyMap.galaxies[i...] {
            guard galaxy != other else { continue }
            let d = galaxy.distance(to: other)
            sum += d
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

    let galaxyMap = GalaxyMap.from(input: data, factor: 1_000_000)

    var sum = 0
    for (i, galaxy) in galaxyMap.galaxies.enumerated() {
        for other in galaxyMap.galaxies[i...] {
            guard galaxy != other else { continue }
            let d = galaxy.distance(to: other)
            sum += d
        }
    }

    return sum
}

print("Result part1: \(try part1())")
print("Result part2: \(try part2())")
