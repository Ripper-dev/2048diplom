import SwiftUI

struct ContentView: View {
    @StateObject private var game = Game2048()

    var body: some View {
        VStack(spacing: 16) {
            Text("2048")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundColor(.black)

            Text("Score: \(game.score)")
                .font(.system(size: 24, weight: .medium, design: .rounded))
                .foregroundColor(.black)

            BoardView(game: game)
                .gesture(DragGesture().onEnded { gesture in
                    let horizontal = gesture.translation.width
                    let vertical = gesture.translation.height

                    if abs(horizontal) > abs(vertical) {
                        if horizontal > 0 {
                            game.move(.right)
                        } else {
                            game.move(.left)
                        }
                    } else {
                        if vertical > 0 {
                            game.move(.down)
                        } else {
                            game.move(.up)
                        }
                    }
                })

            Button("New Game") {
                game.reset()
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .padding()
    }
}

struct BoardView: View {
    @ObservedObject var game: Game2048

    var body: some View {
        VStack(spacing: 8) {
            ForEach(0..<4, id: \.self) { row in
                HStack(spacing: 8) {
                    ForEach(0..<4, id: \.self) { col in
                        CellView(value: game.board[row][col])
                    }
                }
            }
        }
        .background(Color.gray.opacity(0.2))
        .cornerRadius(8)
        .padding()
    }
}

struct CellView: View {
    let value: Int

    var body: some View {
        ZStack {
            Rectangle()
                .fill(colorForTile(value: value))
                .cornerRadius(4)

            if value != 0 {
                Text("\(value)")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            }
        }
        .frame(width: 80, height: 80)
    }

    func colorForTile(value: Int) -> Color {
        switch value {
        case 2: return Color(red: 0.9, green: 0.9, blue: 0.8)
        case 4: return Color(red: 0.9, green: 0.8, blue: 0.6)
        case 8: return Color(red: 0.9, green: 0.6, blue: 0.4)
        case 16: return Color(red: 0.9, green: 0.4, blue: 0.2)
        case 32: return Color(red: 0.8, green: 0.2, blue: 0.1)
        case 64: return Color(red: 0.7, green: 0.1, blue: 0.1)
        case 128: return Color(red: 0.6, green: 0.1, blue: 0.1)
        case 256: return Color(red: 0.5, green: 0.1, blue: 0.1)
        case 512: return Color(red: 0.4, green: 0.1, blue: 0.1)
        case 1024: return Color(red: 0.3, green: 0.1, blue: 0.1)
        case 2048: return Color(red: 0.2, green: 0.1, blue: 0.1)
        default: return Color.gray.opacity(0.2)
        }
    }
}

class Game2048: ObservableObject {
    @Published var board: [[Int]] = Array(repeating: Array(repeating: 0, count: 4), count: 4)
    @Published var score: Int = 0

    init() {
        reset()
    }

    func reset() {
        board = Array(repeating: Array(repeating: 0, count: 4), count: 4)
        score = 0
        addRandomTile()
        addRandomTile()
    }

    func addRandomTile() {
        var emptyTiles = [(Int, Int)]()
        for i in 0..<4 {
            for j in 0..<4 {
                if board[i][j] == 0 {
                    emptyTiles.append((i, j))
                }
            }
        }
        if let randomTile = emptyTiles.randomElement() {
            board[randomTile.0][randomTile.1] = [2, 4].randomElement()!
        }
    }

    func move(_ direction: Direction) {
        var newBoard = board
        switch direction {
        case .left:
            for i in 0..<4 {
                var row = board[i].filter { $0 != 0 }
                while row.count < 4 { row.append(0) }
                for j in 0..<3 {
                    if row[j] == row[j+1] {
                        row[j] *= 2
                        score += row[j]
                        row[j+1] = 0
                    }
                }
                row = row.filter { $0 != 0 }
                while row.count < 4 { row.append(0) }
                newBoard[i] = row
            }
        case .right:
            for i in 0..<4 {
                var row = board[i].filter { $0 != 0 }
                while row.count < 4 { row.insert(0, at: 0) }
                for j in (1..<4).reversed() {
                    if row[j] == row[j-1] {
                        row[j] *= 2
                        score += row[j]
                        row[j-1] = 0
                    }
                }
                row = row.filter { $0 != 0 }
                while row.count < 4 { row.insert(0, at: 0) }
                newBoard[i] = row
            }
        case .up:
            for j in 0..<4 {
                var column = (0..<4).map { board[$0][j] }.filter { $0 != 0 }
                while column.count < 4 { column.append(0) }
                for i in 0..<3 {
                    if column[i] == column[i+1] {
                        column[i] *= 2
                        score += column[i]
                        column[i+1] = 0
                    }
                }
                column = column.filter { $0 != 0 }
                while column.count < 4 { column.append(0) }
                for i in 0..<4 {
                    newBoard[i][j] = column[i]
                }
            }
        case .down:
            for j in 0..<4 {
                var column = (0..<4).map { board[$0][j] }.filter { $0 != 0 }
                while column.count < 4 { column.insert(0, at: 0) }
                for i in (1..<4).reversed() {
                    if column[i] == column[i-1] {
                        column[i] *= 2
                        score += column[i]
                        column[i-1] = 0
                    }
                }
                column = column.filter { $0 != 0 }
                while column.count < 4 { column.insert(0, at: 0) }
                for i in 0..<4 {
                    newBoard[i][j] = column[i]
                }
            }
        }
        if newBoard != board {
            board = newBoard
            addRandomTile()
        }
    }

    enum Direction {
        case left, right, up, down
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
