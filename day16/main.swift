import Foundation

enum MirrorDirection: Character {
    case left = "/"
    case right = "\\"
}

enum SplitterType: Character {
    case vertical = "|"
    case horizontal = "-"
}

enum GridType {
    case empty
    case mirror(MirrorDirection)
    case splitter(SplitterType)

    var value: Character {
        return switch self {
        case .empty: "."
        case .splitter(let s): s.rawValue
        case .mirror(let m): m.rawValue
        }
    }

    static func from(character c: Character) -> Self? {
        return switch c {
        case ".": .empty
        case SplitterType.vertical.rawValue: Self.splitter(.vertical)
        case SplitterType.horizontal.rawValue: Self.splitter(.horizontal)
        case MirrorDirection.left.rawValue: Self.mirror(.left)
        case MirrorDirection.right.rawValue: Self.mirror(.right)
        default: nil
        }
    }
}

struct Point {
    let x: Int
    let y: Int
}
extension Point: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(x)
        hasher.combine(y)
    }
}

enum Direction {
    case left
    case right
    case up
    case down

    func rotate(by mirrorDirection: MirrorDirection) -> Self {
        return switch (self, mirrorDirection) {
        case (.right, .left): .up
        case (.right, .right): .down
        case (.left, .left): .down
        case (.left, .right): .up
        case (.up, .left): .right
        case (.up, .right): .left
        case (.down, .left): .left
        case (.down, .right): .right
        }
    }

    func splits(from splitter: SplitterType) -> (Self, Self)? {
        return switch (self, splitter) {
        case (.up, .vertical),
            (.down, .vertical),
            (.left, .horizontal),
            (.right, .horizontal):
            nil
        case (.up, .horizontal), (.down, .horizontal): (.left, .right)
        case (.left, .vertical), (.right, .vertical): (.up, .down)
        }
    }
}

struct Grid {
    let layout: [GridType]
    let size: (Int, Int)

    func gridEntry(position coord: Point) -> GridType {
        return layout[(coord.x * size.1) + coord.y]
    }

    static func parse(from input: [String]) -> Self {
        var layout: [GridType] = []
        for line in input {
            let gridLine = line.compactMap { GridType.from(character: $0) }
            if gridLine.count != line.count {
                print("Invalid input line: \(line)")
                exit(1)
            }
            layout += gridLine
        }
        return Grid(layout: layout, size: (input.count, input[0].count))
    }

    func dump(_ highlight: Point? = nil) {
        for x in 0..<size.0 {
            for y in 0..<size.1 {
                let p = Point(x: x, y: y)
                let v =
                    highlight != nil && highlight! == p
                    ? "*"
                    : layout[(x * size.1) + y].value

                if let _ = visited[Point(x: x, y: y)] {
                    print("[\(v)]", terminator: "")
                } else {
                    print(" \(v) ", terminator: "")
                }
            }
            print()
        }
    }

    func move(from coord: Point, direction d: Direction) -> Point? {
        let next =
            switch d {
            case .up: Point(x: coord.x - 1, y: coord.y)
            case .down: Point(x: coord.x + 1, y: coord.y)
            case .left: Point(x: coord.x, y: coord.y - 1)
            case .right: Point(x: coord.x, y: coord.y + 1)
            }

        if (next.x < 0 || next.x >= size.0) || (next.y < 0 || next.y >= size.1) {
            return nil
        }
        return next
    }

    var visited: [Point: Set<Direction>] = [:]
    mutating func beamPath(start coord: Point, direction d: Direction, visualize vis: Bool = false) {
        var coord = coord
        var direction = d

        while true {

            if vis {
                homeTerm()
                dump(coord)
            }

            if let directions = visited[coord] {
                if directions.contains(direction) {
                    break
                }
            }
            visited[coord, default: []].insert(direction)

            let g = gridEntry(position: coord)
            switch g {
            case .empty:
                if let next = move(from: coord, direction: direction) {
                    //print("empty... moving \(direction) from \(coord) to \(next)")
                    coord = next
                    continue
                }

            case .mirror(let mirrorDirection):
                direction = direction.rotate(by: mirrorDirection)
                if let next = move(from: coord, direction: direction) {
                    //print("mirror... moving \(direction) from \(coord) to \(next)")
                    coord = next
                    continue
                }

            case .splitter(let splitter):
                if let (d1, d2) = direction.splits(from: splitter) {
                    if let next = move(from: coord, direction: d1) {
                        //print("split by \(splitter) at \(coord), going \(d1) to \(next)")
                        beamPath(start: next, direction: d1, visualize: vis)
                    }
                    if let next = move(from: coord, direction: d2) {
                        //print("split by \(splitter) at \(coord), going \(d2) to \(next)")
                        beamPath(start: next, direction: d2, visualize: vis)
                    }
                } else {
                    if let next = move(from: coord, direction: direction) {
                        //print("passed through \(splitter), moving \(direction) from \(coord) to \(next))")
                        coord = next
                        continue
                    }
                }
            }

            break
        }
    }

    var energized: Int {
        return visited.count
    }
}

func clearTerm() { print("\u{001B}[2J") }
func homeTerm() { print("\u{001B}[H") }

func part1() throws -> Int {
    if CommandLine.argc < 2 {
        print("\(CommandLine.arguments[0]) <input file>")
        exit(1)
    }
    let inputPath = CommandLine.arguments[1]
    let vis: Bool = CommandLine.argc >= 3

    let data = try String(contentsOfFile: inputPath)
        .trimmingCharacters(in: ["\n"])
        .components(separatedBy: "\n")

    var grid = Grid.parse(from: data)
    if vis { clearTerm() }
    grid.beamPath(start: Point(x: 0, y: 0), direction: Direction.right, visualize: vis)
    if vis {
        clearTerm()
        grid.dump()
    }

    return grid.energized
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

    let grid = Grid.parse(from: data)

    let edges: [(Direction, [Point])] = [
        // top row
        (Direction.down, (0..<grid.size.1).map { Point(x: 0, y: $0) }),
        // bottom row
        (Direction.up, (0..<grid.size.1).map { Point(x: grid.size.0 - 1, y: $0) }),
        // left column
        (Direction.right, (0..<grid.size.0).map { Point(x: $0, y: 0) }),
        // right column
        (Direction.left, (0..<grid.size.0).map { Point(x: $0, y: grid.size.1 - 1) }),
    ]

    var best = 0
    for (direction, coords) in edges {
        for start in coords {
            var grid = grid
            grid.beamPath(start: start, direction: direction)
            best = max(best, grid.energized)
        }
    }

    return best
}

print("Result part1: \(try part1())")
print("Result part2: \(try part2())")
