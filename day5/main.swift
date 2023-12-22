import Foundation

enum ParseState {
    case none
    case inSeedToSoil
    case inSoil2Fertilizer
    case inFertilizer2Water
    case inWater2Light
    case inLight2Temperature
    case inTemperature2Humidity
    case inHumidity2Location
}

struct RangePair {
    let source: Range<Int>
    let destination: Range<Int>

    func source2destination(_ idx: Int) -> Int? {
        if source.contains(idx) {
            let offset = source.distance(from: source.startIndex, to:source.firstIndex(of: idx)!)
            return destination.index(destination.startIndex, offsetBy: offset)
        }
        return nil
    }

    func destination2source(_ idx: Int) -> Int? {
        if destination.contains(idx) {
            let offset = destination.distance(from: destination.startIndex, to:destination.firstIndex(of: idx)!)
            return source.index(source.startIndex, offsetBy: offset)
        }
        return nil
    }
}

struct Almanac {
    var seedIds: [Int] = []
    var seedRanges: [Range<Int>] = []
    var seed2Soil: [RangePair] = []
    var soil2Fertilizer: [RangePair] = []
    var fertilizer2Water: [RangePair] = []
    var water2Light: [RangePair] = []
    var light2Temperature: [RangePair] = []
    var temperature2Humidity: [RangePair] = []
    var humidity2Location: [RangePair] = []

    func get_mapped_id(_ id: Int, _ mapping: [RangePair], _ reverse: Bool = false) -> Int {
        for rp in mapping {
            if !reverse {
                if let dest_id = rp.source2destination(id) { return dest_id }
            } else {
                if let dest_id = rp.destination2source(id) { return dest_id }
            }
        }
        return id
    }

    // egads
    func seed_to_location(_ seed: Int) -> Int {
        return self.get_mapped_id(
            self.get_mapped_id(
                self.get_mapped_id(
                    self.get_mapped_id(
                        self.get_mapped_id(
                            self.get_mapped_id(
                                self.get_mapped_id(
                                    seed,
                                    self.seed2Soil
                                ),
                                self.soil2Fertilizer
                            ),
                            self.fertilizer2Water
                        ),
                        self.water2Light
                    ),
                    self.light2Temperature
                ),
                self.temperature2Humidity
            ),
            self.humidity2Location
        )
    }

    static func parse(_ data: [String]) -> Self {
        var a = Almanac()
        var state = ParseState.none

        for line in data {
            guard line != "" else { continue }

            switch line {
            case let x where x.starts(with: "seeds: "):
                a.seedIds = line.split(separator:":")[1].split(separator:" ").map { Int($0)! }

                let seed_pairs = sequence(
                    state: a.seedIds.makeIterator(),
                    next: { i in i.next().map{first in (first, i.next()!)} }
                )
                for (start, length) in seed_pairs {
                    a.seedRanges.append(start..<(start+length))
                }
            case let x where x.starts(with: "seed-to-soil map:"):
                state = .inSeedToSoil
            case let x where x.starts(with: "soil-to-fertilizer map:"):
                state = .inSoil2Fertilizer
            case let x where x.starts(with: "fertilizer-to-water map:"):
                state = .inFertilizer2Water
            case let x where x.starts(with: "water-to-light map:"):
                state = .inWater2Light
            case let x where x.starts(with: "light-to-temperature map:"):
                state = .inLight2Temperature
            case let x where x.starts(with: "temperature-to-humidity map:"):
                state = .inTemperature2Humidity
            case let x where x.starts(with: "humidity-to-location map"):
                state = .inHumidity2Location
            default:
                // the destination range start, the source range start, and the range length
                let counters = line.split(separator:" ").map { Int($0)! }
                guard counters.count == 3 else { continue }
                let r = RangePair(
                    source: counters[1]..<(counters[1]+counters[2]),
                    destination: counters[0]..<(counters[0]+counters[2])
                )

                switch state {
                case .inSeedToSoil:
                    a.seed2Soil.append(r)
                case .inSoil2Fertilizer:
                    a.soil2Fertilizer.append(r)
                case .inFertilizer2Water:
                    a.fertilizer2Water.append(r)
                case .inWater2Light:
                    a.water2Light.append(r)
                case .inLight2Temperature:
                    a.light2Temperature.append(r)
                case .inTemperature2Humidity:
                    a.temperature2Humidity.append(r)
                case .inHumidity2Location:
                    a.humidity2Location.append(r)
                case .none: continue
                }
            }
        }

        return a
    }
}

func day5_part1() throws -> Int {
    if CommandLine.argc < 2 {
        print("\(CommandLine.arguments[0]) <input file>")
        exit(1)
    }
    let inputPath = CommandLine.arguments[1]

    let data = try String(contentsOfFile: inputPath)
        .trimmingCharacters(in: ["\n"])
        .components(separatedBy:"\n")

    let a = Almanac.parse(data)
    return a.seedIds.map { seed_id in a.seed_to_location(seed_id) }.min()!
}

func day5_part2() throws -> Int {
    if CommandLine.argc < 2 {
        print("\(CommandLine.arguments[0]) <input file>")
        exit(1)
    }
    let inputPath = CommandLine.arguments[1]

    let data = try String(contentsOfFile: inputPath)
        .trimmingCharacters(in: ["\n"])
        .components(separatedBy:"\n")

    let a = Almanac.parse(data)

    return a.seedRanges.joined().map { a.seed_to_location($0) }.min()!
}

print("Result part1: \(try day5_part1())")
print("Result part2: \(try day5_part2())")
