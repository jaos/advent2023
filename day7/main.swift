import Foundation

enum FaceCard: Int {
    case A = 14
    case K = 13
    case Q = 12
    case J = 11
    case T = 10
    case Joker = 1

    var letter: Character { String(describing: self).first! }
    var value: Int { self.rawValue }

    static func from(character: Character) -> Self? {
        switch character {
        case "A": return Self.A
        case "K": return Self.K
        case "Q": return Self.Q
        case "J": return Self.J
        case "T": return Self.T
        default: return nil
        }
    }
}
extension FaceCard: Comparable {
    static func <(lhs: Self, rhs: Self) -> Bool {
        return lhs.value < rhs.value
    }
    static func ==(lhs: Self, rhs: Self) -> Bool {
        return lhs.value == rhs.value
    }
}

enum Card {
    case Face(FaceCard)
    case Number(Int)

    var value: Int {
        switch self {
        case .Face(let f): return f.value
        case .Number(let n): return n
        }
    }
    var letter: Character {
        switch self {
        case .Face(let f): return f.letter
        case .Number(let n): return Character(String(n))
        }
    }

    static func from(number: Int) -> Self? {
        switch number {
        case 2...9:
            return .Number(number)
        // tricksy needs to be a valid range from lowest to highest
        case FaceCard.T.value...FaceCard.A.value:
            guard let f = FaceCard(rawValue: number) else { return nil}
            return .Face(f)
        default: return nil
        }
    }

    static func from(character: Character) -> Self? {
        switch character {
        case "2"..."9":
            return .Number(character.wholeNumberValue!)
        // tricksy needs to be a valid range from lowest to highest
        case FaceCard.A.letter...FaceCard.T.letter:
            guard let f = FaceCard.from(character: character) else { return nil }
            return .Face(f)
        default: return nil
        }
    }

}
extension Card: Comparable {
    static func <(lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case (.Number(let l), .Number(let r)): return l < r
        case (.Face(let l), .Number(let r)): return l.value < r
        case (.Number(let l), .Face(let r)): return l < r.value
        case (.Face(let l), .Face(let r)): return l.value < r.value
        }
    }

    static func ==(lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case (.Number(let l), .Number(let r)): return l == r
        case (.Face(_), .Number(_)): return false //l.value == r // not for part 2
        case (.Number(_), .Face(_)): return false //l == r.value // not for part 2
        case (.Face(let l), .Face(let r)): return l.value == r.value
        }
    }
}
extension Card: Hashable {
    func hash(into hasher: inout Hasher) {
        switch self {
        case .Number(let n): return hasher.combine(n)
        case .Face(let f): return hasher.combine(f.value)
        }
    }
}

enum HandType: Comparable {
    case HighCard //(Card)
    case OnePair //(Card)
    case TwoPair //(Card, Card)
    case ThreeOfAKind //(Card)
    case FullHouse //(Card, Card)
    case FourOfAKind //(Card)
    case FiveOfAKind //(Card)
}

struct Hand {
    let cards: [Card]
    let type: HandType
    let bid: Int

    static func parse(_ input: String) -> Self? {
        let parts = input.split(separator: " ")
        guard parts.count == 2 else { return nil }

        let cards = parts[0].map { Card.from(character: $0)! }
        let cardtypes = cards.reduce(into: [:]) { count, item in count[item, default: 0] += 1 }
        guard cardtypes.count <= 5 else { return nil }

        var hand_type: HandType
        switch cardtypes.count {
            case 1:
                hand_type = .FiveOfAKind //(cards.sorted(by: {$0.value > $1.value}).first!)
            case 2:
                hand_type = cardtypes.values.sorted().first! == 1 ? .FourOfAKind : .FullHouse
            case 3:
                hand_type = cardtypes.values.sorted().last! == 3 ? .ThreeOfAKind : .TwoPair
            case 4:
                hand_type = .OnePair //(Array(cardtypes).sorted(by: { $0.1 > $1.1 }).first!.0)
            case 5:
                hand_type = .HighCard //(cards.sorted(by: {$0.value > $1.value}).first!)
            default: print("impossible!"); exit(1)
        }

        return Self(cards: cards, type: hand_type, bid: Int(parts[1])!)
    }

    static func parse2(_ input: String) -> Self? {
        guard let original_card = parse(input) else { return nil }

        let cards = original_card.cards
            .map { $0 == .Face(FaceCard.J) ? .Face(FaceCard.Joker) : $0 }
        let cardtypes = cards.reduce(into: [:]) { count, item in count[item, default: 0] += 1 }
        let has_joker = cardtypes[.Face(FaceCard.Joker)] != nil
        guard has_joker else { return original_card }

        var hand_type = original_card.type
        let non_jokers = cardtypes.filter { $0.0 != .Face(FaceCard.Joker) }
        switch non_jokers.count {
            // JJJJJ, JJJJA
            case 0, 1:
                hand_type = .FiveOfAKind
            // JJJAK, JJAAK, JAAAK, JAAKK
            case 2:
                hand_type = non_jokers.values.sorted().first! == 1 ? .FourOfAKind : .FullHouse
            // JJAKQ, JAAKQ
            case 3:
                hand_type = .ThreeOfAKind
            // JAKQT
            case 4:
                hand_type = .OnePair
            default: print("impossible card composition \(cardtypes)"); exit(1)
        }

        return Self(cards: cards, type: hand_type, bid: original_card.bid)
    }

}
extension Hand: Comparable {
    static func <(lhs: Self, rhs: Self) -> Bool {
        guard lhs.type == rhs.type else { return lhs.type < rhs.type }
        for (idx, card) in lhs.cards.enumerated() {
            let other = rhs.cards[rhs.cards.index(rhs.cards.startIndex, offsetBy: idx)]
            if card.value == other.value { continue }
            return card.value < other.value
        }
        return false
    }

    static func ==(lhs: Self, rhs: Self) -> Bool {
        guard lhs.type == rhs.type else { return false }
        for (idx, card) in lhs.cards.enumerated() {
            let other = rhs.cards[rhs.cards.index(rhs.cards.startIndex, offsetBy: idx)]
            if card.value == other.value { continue }
            return false
        }
        return true
    }
}

func day7_part1() throws -> Int {
    if CommandLine.argc < 2 {
        print("\(CommandLine.arguments[0]) <input file>")
        exit(1)
    }
    let inputPath = CommandLine.arguments[1]

    let data = try String(contentsOfFile: inputPath)
        .trimmingCharacters(in: ["\n"])
        .components(separatedBy:"\n")

    let hands = data.compactMap { Hand.parse($0) }.sorted()
    return hands.enumerated().map {(rank, hand) in hand.bid * (rank + 1)}.reduce(0, +)
}

func day7_part2() throws -> Int {
    if CommandLine.argc < 2 {
        print("\(CommandLine.arguments[0]) <input file>")
        exit(1)
    }
    let inputPath = CommandLine.arguments[1]

    let data = try String(contentsOfFile: inputPath)
        .trimmingCharacters(in: ["\n"])
        .components(separatedBy:"\n")

    let hands = data.compactMap { Hand.parse2($0) }.sorted()
    return hands.enumerated().map {(rank, hand) in hand.bid * (rank + 1)}.reduce(0, +)
}

print("Result part1: \(try day7_part1())")
print("Result part2: \(try day7_part2())")
