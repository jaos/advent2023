import Foundation

enum Pipe: Character {
    case vertical = "|"
    case horizontal = "-"
}

enum Bend: Character {
    case northeast = "L"
    case northwest = "J"
    case southeast = "F"
    case southwest = "7"
}

enum Position: Character {
    case ground = "."
    case start = "S"
}

struct Coord: Equatable {
    let x: Int
    let y: Int
}
extension Coord: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(x)
        hasher.combine(y)
    }
}

struct Connection: Equatable {
    let north: Coord?
    let south: Coord?
    let east: Coord?
    let west: Coord?
}

enum Tile: Equatable {
    case pipe(Pipe)
    case bend(Bend)
    case position(Position)

    var character: Character {
        return switch self {
        case .pipe(let p): p.rawValue
        case .bend(let b): b.rawValue
        case .position(let p): p.rawValue
        }
    }

    static func from(character c: Character) -> Self? {
        switch c {
        case "|", "-": return .pipe(Pipe(rawValue: c)!)
        case ".", "S": return .position(Position(rawValue: c)!)
        case "L", "J", "F", "7": return .bend(Bend(rawValue: c)!)
        default: return nil
        }
    }

    func connection() -> Connection {
        switch self {
        case .bend(Bend.northeast):
            return Connection(north: Coord(x: -1, y: 0), south: nil, east: Coord(x: 0, y: 1), west: nil)
        case .bend(Bend.northwest):
            return Connection(north: Coord(x: -1, y: 0), south: nil, east: nil, west: Coord(x: 0, y: -1))
        case .bend(Bend.southeast):
            return Connection(north: nil, south: Coord(x: 1, y: 0), east: Coord(x: 0, y: 1), west: nil)
        case .bend(Bend.southwest):
            return Connection(north: nil, south: Coord(x: 1, y: 0), east: nil, west: Coord(x: 0, y: -1))
        case .pipe(Pipe.vertical):
            return Connection(north: Coord(x: -1, y: 0), south: Coord(x: 1, y: 0), east: nil, west: nil)
        case .pipe(Pipe.horizontal):
            return Connection(north: nil, south: nil, east: Coord(x: 0, y: 1), west: Coord(x: 0, y: -1))
        case .position(Position.start):
            return Connection(
                north: Coord(x: -1, y: 0),
                south: Coord(x: 1, y: 0),
                east: Coord(x: 0, y: 1),
                west: Coord(x: 0, y: -1)
            )
        case .position(Position.ground):
            return Connection(north: nil, south: nil, east: nil, west: nil)
        }
    }
}

struct TilePosition {
    let tile: Tile
    let coord: Coord

    var character: Character {
        return tile.character
    }

    func connection() -> Connection {
        let c = self.tile.connection()
        return Connection(
            north: c.north != nil ? Coord(x: coord.x + c.north!.x, y: coord.y + c.north!.y) : nil,
            south: c.south != nil ? Coord(x: coord.x + c.south!.x, y: coord.y + c.south!.y) : nil,
            east: c.east != nil ? Coord(x: coord.x + c.east!.x, y: coord.y + c.east!.y) : nil,
            west: c.west != nil ? Coord(x: coord.x + c.west!.x, y: coord.y + c.west!.y) : nil
        )
    }
}

struct Path {
    var steps: [Coord]
    var seen: Set<Coord>

    var count: Int { steps.count }

    init() {
        steps = []
        seen = []
    }

    init(_ initial_steps: [Coord]) {
        self.init()
        for s in initial_steps {
            add(s)
        }
    }

    func contains(_ coord: Coord) -> Bool {
        return seen.contains(coord)
    }

    mutating func add(_ coord: Coord) {
        steps.append(coord)
        seen.insert(coord)
    }
}

struct Grid {
    let tilepositions: [TilePosition]
    let size: (Int, Int)
    let start: Coord

    static func from(_ data: [String]) -> Self? {
        let (sizeX, sizeY) = (data.count, data[0].count)
        var start = Coord(x: 0, y: 0)
        var tilepositions: [TilePosition] = []
        for (x, line) in data.enumerated() {
            for (y, c) in line.enumerated() {
                guard let tile = Tile.from(character: c) else {
                    print("invalid tile at \(x),\(y): \(c)")
                    return nil
                }
                if tile == .position(Position.start) {
                    start = Coord(x: x, y: y)
                }
                tilepositions.append(TilePosition(tile: tile, coord: Coord(x: x, y: y)))
            }
        }

        let g = Grid(tilepositions: tilepositions, size: (sizeX, sizeY), start: start)
        // update the start to be an actual tile type
        let start_connection = g.connection(position: g.get_start())
        let updated_start =
            switch start_connection {
            case let c where c.north != nil && c.south != nil && c.east == nil && c.west == nil:
                TilePosition(tile: .pipe(.vertical), coord: start)
            case let c where c.north == nil && c.south == nil && c.east != nil && c.west != nil:
                TilePosition(tile: .pipe(.horizontal), coord: start)
            case let c where c.north == nil && c.south != nil && c.east == nil && c.west != nil:
                TilePosition(tile: .bend(.southwest), coord: start)
            case let c where c.north != nil && c.south == nil && c.east == nil && c.west != nil:
                TilePosition(tile: .bend(.northwest), coord: start)
            case let c where c.north == nil && c.south != nil && c.east != nil && c.west == nil:
                TilePosition(tile: .bend(.southeast), coord: start)
            case let c where c.north != nil && c.south == nil && c.east != nil && c.west == nil:
                TilePosition(tile: .bend(.northeast), coord: start)
            default:
                TilePosition(tile: .position(.ground), coord: start)
            }
        tilepositions[(start.x * sizeY) + start.y] = updated_start

        return Grid(tilepositions: tilepositions, size: (sizeX, sizeY), start: start)
    }

    func connection(position tp: TilePosition) -> Connection {
        let c = tp.connection()
        return Connection(
            north: {
                guard c.north != nil else { return nil }
                guard let tile = tile_at(c.north!) else { return nil }
                if tile.connection().south != nil { return c.north }
                return nil
            }(),
            south: {
                guard c.south != nil else { return nil }
                guard let tile = tile_at(c.south!) else { return nil }
                if tile.connection().north != nil { return c.south }
                return nil
            }(),
            east: {
                guard c.east != nil else { return nil }
                guard let tile = tile_at(c.east!) else { return nil }
                if tile.connection().west != nil { return c.east }
                return nil
            }(),
            west: {
                guard c.west != nil else { return nil }
                guard let tile = tile_at(c.west!) else { return nil }
                if tile.connection().east != nil { return c.west }
                return nil
            }()
        )
    }

    func tile_at(_ position: Coord) -> TilePosition? {
        let offset = (position.x * size.1) + position.y
        if offset < 0 || offset >= tilepositions.count {
            return nil
        }
        return tilepositions[offset]
    }

    func get_start() -> TilePosition {
        return tile_at(start)!
    }

    func walk(_ position: TilePosition, _ path_taken: Path) -> Path? {
        var path_taken = path_taken
        path_taken.add(position.coord)

        let c = connection(position: position)
        for case let direction_coord? in [c.north, c.south, c.east, c.west] {
            if direction_coord == start && path_taken.count != 2 {
                path_taken.add(direction_coord)
                return path_taken
            }

            guard let next = tile_at(direction_coord) else { continue }
            guard next.tile != .position(Position.ground) else { continue }

            guard !path_taken.contains(direction_coord) else { continue }
            if let found_path = walk(next, path_taken) {
                return found_path
            }

        }

        return nil
    }

    func get_loop() -> Path? {
        let start = get_start()
        let c = connection(position: start)
        let p = Path([start.coord])
        for case let direction? in [c.north, c.south, c.east, c.west] {
            if let tile = tile_at(direction) {
                if let path = walk(tile, p) {
                    return path
                }
            }
        }
        return nil
    }
}

func day10_part1() throws -> Int {
    if CommandLine.argc < 2 {
        print("\(CommandLine.arguments[0]) <input file>")
        exit(1)
    }
    let inputPath = CommandLine.arguments[1]

    let data = try String(contentsOfFile: inputPath)
        .trimmingCharacters(in: ["\n"])
        .components(separatedBy: "\n")

    guard let grid = Grid.from(data) else { return -1 }

    //let start = grid.get_start()
    //print("Start: \(start)")

    guard let loop = grid.get_loop() else { return -1 }
    //print("Loop steps: \(loop.steps.count)")
    return loop.steps.count / 2
}

func day10_part2() throws -> Int {
    if CommandLine.argc < 2 {
        print("\(CommandLine.arguments[0]) <input file>")
        exit(1)
    }
    let inputPath = CommandLine.arguments[1]

    let data = try String(contentsOfFile: inputPath)
        .trimmingCharacters(in: ["\n"])
        .components(separatedBy: "\n")

    guard let grid = Grid.from(data) else { return -1 }
    guard let loop = grid.get_loop() else { return -1 }

    var is_inside = false
    let inside = grid.tilepositions
        .map({
            switch $0.tile {
            case .pipe where loop.seen.contains($0.coord): return $0.tile
            case .bend where loop.seen.contains($0.coord): return $0.tile
            default: return .position(Position.ground)
            }
        })
        .filter({
            switch $0 {
            case .position(Position.ground): return is_inside
            case .pipe(Pipe.vertical), .bend(Bend.northwest), .bend(Bend.northeast):
                is_inside = !is_inside
                return false
            default: return false
            }

        }).count
    return inside
}

print("Result part1: \(try day10_part1())")
print("Result part2: \(try day10_part2())")
