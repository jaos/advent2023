import Foundation

struct Card {
    let id: Int
    let winners: [Int]
    let numbers: [Int]
    var part1points = 0
    var part2MatchingCards = 0

    init(id i: Int, winners w: [Int], numbers n: [Int]) {
        id = i
        winners = w
        numbers = n
        part2MatchingCards = numbers.filter { winners.contains($0) }.count

        for number in numbers {
            if winners.contains(number) {
                part1points = part1points == 0 ? 1 : part1points * 2
            }
        }
    }
}

func get_matching_card_counts(_ cards: [Card], _ card: Card) -> Int {
    var count = 1
    let last = card.id + card.part2MatchingCards
    if last == 0 || last > cards.count {
        return count
    }
    for idx in card.id..<last {
        count += get_matching_card_counts(cards, cards[idx])
    }
    return count
}

func parse_cards(_ lines: [String]) -> [Card] {
    var cards: [Card] = []
    for line in lines {
        let parts = line.split(separator:":")
        let cardId = Int(parts[0].split(separator:" ")[1])!
        let winners = parts[1].split(separator:"|")[0].split(separator:" ").map{ Int($0)! }
        let numbers = parts[1].split(separator:"|")[1].split(separator:" ").map{ Int($0)! }
        cards.append(Card(id: cardId, winners: winners, numbers: numbers))
    }
    return cards
}

func day4_part1() throws -> Int {
    if CommandLine.argc < 2 {
        print("\(CommandLine.arguments[0]) <input file>")
        exit(1)
    }
    let inputPath = CommandLine.arguments[1]

    let data = try String(contentsOfFile: inputPath)
        .trimmingCharacters(in: ["\n"])
        .components(separatedBy:"\n")

    let cards = parse_cards(data)
    return cards.map { $0.part1points }.reduce(0, +)
}

func day4_part2() throws -> Int {
    if CommandLine.argc < 2 {
        print("\(CommandLine.arguments[0]) <input file>")
        exit(1)
    }
    let inputPath = CommandLine.arguments[1]

    let data = try String(contentsOfFile: inputPath)
        .trimmingCharacters(in: ["\n"])
        .components(separatedBy:"\n")

    let cards = parse_cards(data)
    return cards.map { get_matching_card_counts(cards, $0) }.reduce(0,+)
}
print("Result part1: \(try day4_part1())")
print("Result part2: \(try day4_part2())")
