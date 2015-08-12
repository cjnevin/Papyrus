//: Playground - noun: a place where people can play

import UIKit

var str = "Hello, playground"

func == (lhs: Square, rhs: Square) -> Bool {
    return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
}

enum Direction: CustomDebugStringConvertible {
    case Prev
    case Next
    var inverse: Direction {
        return self == .Prev ? .Next : .Prev
    }
    var debugDescription: String {
        return self == .Prev ? "Prev" : "Next"
    }
}

enum Axis: CustomDebugStringConvertible {
    case Row(Direction)
    case Column(Direction)
    func inverse(direction: Direction) -> Axis {
        switch self {
        case .Row(_): return .Column(direction)
        case .Column(_): return .Row(direction)
        }
    }
    var direction: Direction {
        switch self {
        case .Row(let dir): return dir
        case .Column(let dir): return dir
        }
    }
    var debugDescription: String {
        switch self {
        case .Row(let dir): return "Row-\(dir)"
        case .Column(let dir): return "Column-\(dir)"
        }
    }
}

struct Position: Equatable, Hashable {
    let axis: Axis
    let row: Int
    let col: Int
    var hashValue: Int {
        return "\(axis.debugDescription),\(row),\(col)".hashValue
    }
    var isInvalid: Bool {
        return invalid(row) || invalid(col)
    }
    private func invalid(z: Int) -> Bool {
        return z < 0 || z >= Dimensions
    }
    private func adjust(z: Int, dir: Direction) -> Int {
        let n = dir == .Next ? z + 1 : z - 1
        return invalid(n) ? z : n
    }
    func newPosition() -> Position {
        switch axis {
        case .Row(let dir):
            return Position(axis: axis, row: adjust(row, dir: dir), col: col)
        case .Column(let dir):
            return Position(axis: axis, row: row, col: adjust(col, dir: dir))
        }
    }
    func inversePosition(direction: Direction) -> Position {
        return Position(axis: axis.inverse(direction), row: row, col: col)
    }
    var isHorizontal: Bool {
        switch axis {
        case .Row(_): return true
        case .Column(_): return false
        }
    }
    var iterableValue: Int {
        return iterableValue(isHorizontal)
    }
    var fixedValue: Int {
        return fixedValue(isHorizontal)
    }
    func iterableValue(precomputedHorizontal: Bool) -> Int {
        return precomputedHorizontal ? row : col
    }
    func fixedValue(precomputedHorizontal: Bool) -> Int {
        return precomputedHorizontal ? col : row
    }
}

func == (lhs: Position, rhs: Position) -> Bool {
    return lhs.hashValue == rhs.hashValue
}

class Tile: CustomDebugStringConvertible {
    let letter: Character
    let value: Int
    init(_ letter: Character, _ value: Int) {
        self.letter = letter
        self.value = value
    }
    var debugDescription: String {
        return String(letter)
    }
}

class Square: CustomDebugStringConvertible, Equatable {
    enum Type {
        case None, Letterx2, Letterx3, Center, Wordx2, Wordx3
    }
    let type: Type
    var tile: Tile?
    init(_ type: Type) {
        self.type = type
    }
    var debugDescription: String {
        return String(tile?.letter ?? "_")
    }
}

let Dimensions = 15

typealias Lines = [Int: [Int: Square]]
typealias Line = [Int: Square]

var squares = [[Square]]()

for row in 1...Dimensions {
    var line = [Square]()
    for col in 1...Dimensions {
        line.append(Square(.None))
    }
    squares.append(line)
}

func loop(position: Position, fun: ((position: Position) -> ())? = nil) -> Position? {
    // Return nil if square is outside of range (should only occur first time)
    // Return nil if this square is empty (should only occur first time)
    if position.isInvalid || squares[position.row][position.col].tile == nil { return nil }
    // Check new position.
    let newPosition = position.newPosition()
    if newPosition.isInvalid || squares[newPosition.row][newPosition.col].tile == nil {
        fun?(position: position)
        return position
    } else {
        fun?(position: newPosition)
        return loop(newPosition, fun: fun)
    }
}

squares[7][5].tile = Tile("A", 1)
squares[7][6].tile = Tile("R", 1)
squares[7][7].tile = Tile("C", 3)

squares[8][7].tile = Tile("A", 1)
squares[9][7].tile = Tile("R", 1)
squares[10][7].tile = Tile("D", 2)

squares[10][6].tile = Tile("A", 1)
squares[10][5].tile = Tile("E", 1)
squares[10][4].tile = Tile("D", 2)

squares[8][5].tile = Tile("R", 1)
squares[9][5].tile = Tile("I", 1)

// When a word is played, lets just store the playable boundary, rather than trying to
// calculate it after the fact, it's going to take too much computing power.
//

for s in squares {
    print(s)
}

typealias Boundary = (start: Position, end: Position)
typealias Boundaries = [Boundary]
typealias PositionBoundaries = [Position: Boundary]

private func outOfBounds(z: Int) -> Bool {
    return z < 0 || z >= Dimensions
}

var playedBoundaries = Boundaries()
// ARC
playedBoundaries.append(Boundary(start: Position(axis: .Column(.Prev), row: 7, col: 5), end: Position(axis: .Column(.Next), row: 7, col: 7)))
// DEAD
playedBoundaries.append(Boundary(start: Position(axis: .Column(.Prev), row: 10, col: 4), end: Position(axis: .Column(.Next), row: 10, col: 7)))
// CARD
playedBoundaries.append(Boundary(start: Position(axis: .Row(.Prev), row: 7, col: 7), end: Position(axis: .Row(.Next), row: 10, col: 7)))
// ARIE
playedBoundaries.append(Boundary(start: Position(axis: .Row(.Prev), row: 7, col: 5), end: Position(axis: .Row(.Next), row: 10, col: 5)))


func positionBoundaries(horizontal: Bool, row: Int, col: Int) -> PositionBoundaries {
    // Collect valid places to play
    var collected = PositionBoundaries()
    func collector(position: Position) {
        // Wrap collector when it needs to be moved, use another function to pass in an array
        if collected[position] == nil {
            let a = position.inversePosition(.Prev)
            let b = position.inversePosition(.Next)
            if let first = loop(a), last = loop(b) {
                // Add/update boundary
                collected[position] = (start: first, end: last)
            }
        }
    }
    
    // Find boundaries of this word
    let a = Position(axis: horizontal ? .Column(.Prev) : .Row(.Prev), row: row, col: col)
    let b = Position(axis: horizontal ? .Column(.Next) : .Row(.Next), row: row, col: col)
    if let first = loop(a, fun: collector), last = loop(b, fun: collector) {
        // Print start and end of word
        print(first)
        print(last)
        // And any squares that are filled around this word (non-recursive)
        print(collected)
    }
    return collected
}

func readable(boundary: Boundary) -> String? {
    func letter(row: Int, _ col: Int) -> Character? {
        return squares[row][col].tile?.letter
    }
    let start = boundary.start, end = boundary.end
    if start.isHorizontal {
        if start.row >= end.row { return nil }
        return String((start.row...end.row).map({letter($0, start.col)}).filter({$0 != nil}).map({$0!}))
    } else {
        if start.col >= end.col { return nil }
        return String((start.col...end.col).map({letter(start.row, $0)}).filter({$0 != nil}).map({$0!}))
    }
}

func readable(positionBoundaries: PositionBoundaries) -> [String] {
    var output = [String]()
    for (position, range) in positionBoundaries {
        if position != range.start || position != range.end {
            if let word = readable(range) {
                output.append(word)
            }
        }
    }
    var sorted = positionBoundaries.keys.sort { (lhs, rhs) -> Bool in
        if lhs.isHorizontal {
            return lhs.row < rhs.row
        } else {
            return lhs.col < rhs.col
        }
    }
    if let first = sorted.first, last = sorted.last where first != last {
        if let word = readable(Boundary(start: first, end: last)) {
            output.append(word)
        }
    }
    return output
}

func validate(words: [String]) -> Bool {
    for word in words {
        if word.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) < 4 {
            return false
        }
    }
    return true
}

// Determine boundaries of words on the board (hard coded positions)

positionBoundaries(true, row: 8, col: 6)

let arcWords = readable(positionBoundaries(true, row: 7, col: 7))

let arieWords = readable(positionBoundaries(true, row: 10, col: 4))

let deadWords = readable(positionBoundaries(false, row: 10, col: 7))

validate(deadWords)

validate(arieWords)



// Now determine playable boundaries

let rackCount = 7

var playableBoundaries = [Boundary]()
for boundary in playedBoundaries {
    //
    // This code deals with the direction the word was played
    // TODO: Opposite direction and adjacent/parallel tiles
    //
    // Return row/col
    let h = boundary.start.isHorizontal
    let startIter = boundary.start.iterableValue(h)
    let endIter = boundary.end.iterableValue(h)
    let startFixed = boundary.start.fixedValue(h)
    let endFixed = boundary.end.fixedValue(h)
    
    func positionFor(axis: Axis, iterable: Int, fixed: Int) -> Position {
        return Position(axis: axis, row: h ? iterable : fixed, col: h ? fixed : iterable)
    }
    
    // For each boundary, we can move 7 characters either way minus the length of the word
    let remainder = rackCount - (endIter - startIter)
    
    // Need to call loop while tiles outside of boundary are EMPTY, then if we hit a tile, we go back two squares for this iteration.
    // Then also include the next tiles in the iteration until we hit the end of the board or run out of tiles.
    var currentBoundaries = [Boundary]()
    for i in startIter-remainder...endIter+remainder where !outOfBounds(i) {
        let start = i > startIter ? startIter : i
        let end = i < endIter ? endIter : i
        let startPosition = positionFor(boundary.start.axis, iterable: start, fixed: startFixed)
        let endPosition = positionFor(boundary.end.axis, iterable: end, fixed: endFixed)
        let boundary = Boundary(start: startPosition, end: endPosition)
        if currentBoundaries.filter({$0.start == startPosition && $0.end == endPosition}).count == 0 {
            currentBoundaries.append(boundary)
        }
    }
    playableBoundaries.extend(currentBoundaries)
}

print(playableBoundaries.count)
