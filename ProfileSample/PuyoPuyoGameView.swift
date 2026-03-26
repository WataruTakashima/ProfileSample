//
//  PuyoPuyoGameView.swift
//  ProfileSample
//

import SwiftUI
import Combine

// MARK: - Models

enum PuyoColor: Int, CaseIterable, Equatable {
    case empty = 0
    case red, green, blue, yellow, purple

    var displayColor: Color {
        switch self {
        case .empty:  return .clear
        case .red:    return Color(red: 0.95, green: 0.25, blue: 0.25)
        case .green:  return Color(red: 0.2,  green: 0.85, blue: 0.35)
        case .blue:   return Color(red: 0.25, green: 0.55, blue: 1.0)
        case .yellow: return Color(red: 1.0,  green: 0.85, blue: 0.1)
        case .purple: return Color(red: 0.8,  green: 0.2,  blue: 1.0)
        }
    }

    static var gameColors: [PuyoColor] { [.red, .green, .blue, .yellow, .purple] }
}

struct BoardPos: Hashable {
    let row: Int
    let col: Int
}

struct FallingPair {
    var mainRow: Int
    var mainCol: Int
    var subRow: Int
    var subCol: Int
    var mainColor: PuyoColor
    var subColor: PuyoColor
}

// MARK: - Game Logic

class PuyoPuyoGame: ObservableObject {
    static let rows = 13
    static let cols = 6

    @Published var board: [[PuyoColor]] = Array(repeating: Array(repeating: PuyoColor.empty, count: 6), count: 13)
    @Published var fallingPair: FallingPair?
    @Published var nextMain: PuyoColor = .red
    @Published var nextSub: PuyoColor = .blue
    @Published var score: Int = 0
    @Published var chainCount: Int = 0
    @Published var gameOver: Bool = false
    @Published var flashPositions: Set<BoardPos> = []

    private var timer: Timer?
    private var isProcessing = false

    static func emptyBoard() -> [[PuyoColor]] {
        Array(repeating: Array(repeating: .empty, count: cols), count: rows)
    }

    func startGame() {
        timer?.invalidate()
        board = Self.emptyBoard()
        score = 0
        chainCount = 0
        gameOver = false
        isProcessing = false
        flashPositions = []
        nextMain = .gameColors.randomElement()!
        nextSub  = .gameColors.randomElement()!
        spawnPair()
        timer = Timer.scheduledTimer(withTimeInterval: 0.65, repeats: true) { [weak self] _ in
            DispatchQueue.main.async { self?.tick() }
        }
    }

    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    // MARK: Internal helpers

    private func tick() {
        guard !isProcessing, var pair = fallingPair else { return }
        if canMove(pair: pair, dRow: 1, dCol: 0) {
            pair.mainRow += 1
            pair.subRow  += 1
            fallingPair = pair
        } else {
            lockPair(pair)
        }
    }

    private func spawnPair() {
        let newPair = FallingPair(
            mainRow: 1, mainCol: 2,
            subRow: 0,  subCol: 2,
            mainColor: nextMain, subColor: nextSub
        )
        nextMain = PuyoColor.gameColors.randomElement()!
        nextSub  = PuyoColor.gameColors.randomElement()!

        guard isValidEmpty(row: newPair.mainRow, col: newPair.mainCol),
              isValidEmpty(row: newPair.subRow,  col: newPair.subCol) else {
            gameOver = true
            timer?.invalidate()
            return
        }
        fallingPair = newPair
    }

    private func lockPair(_ pair: FallingPair) {
        fallingPair = nil
        board[pair.mainRow][pair.mainCol] = pair.mainColor
        board[pair.subRow][pair.subCol]   = pair.subColor
        isProcessing = true
        chainCount = 0
        processMatches(chain: 1)
    }

    private func processMatches(chain: Int) {
        applyGravity()
        let matches = findMatches()
        guard !matches.isEmpty else {
            isProcessing = false
            chainCount = 0
            spawnPair()
            return
        }
        flashPositions = matches
        score += matches.count * 10 * chain
        chainCount = chain

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) { [weak self] in
            guard let self else { return }
            self.flashPositions = []
            for pos in matches { self.board[pos.row][pos.col] = .empty }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                self.processMatches(chain: chain + 1)
            }
        }
    }

    private func applyGravity() {
        for col in 0..<Self.cols {
            var writeRow = Self.rows - 1
            for row in stride(from: Self.rows - 1, through: 0, by: -1) {
                if board[row][col] != .empty {
                    board[writeRow][col] = board[row][col]
                    if writeRow != row { board[row][col] = .empty }
                    writeRow -= 1
                }
            }
        }
    }

    private func findMatches() -> Set<BoardPos> {
        var result  = Set<BoardPos>()
        var visited = Set<BoardPos>()
        for row in 0..<Self.rows {
            for col in 0..<Self.cols {
                let pos   = BoardPos(row: row, col: col)
                let color = board[row][col]
                guard color != .empty, !visited.contains(pos) else { continue }
                let group = floodFill(from: pos, color: color)
                visited.formUnion(group)
                if group.count >= 4 { result.formUnion(group) }
            }
        }
        return result
    }

    private func floodFill(from start: BoardPos, color: PuyoColor) -> Set<BoardPos> {
        var visited = Set<BoardPos>()
        var stack   = [start]
        while !stack.isEmpty {
            let pos = stack.removeLast()
            guard !visited.contains(pos) else { continue }
            guard pos.row >= 0, pos.row < Self.rows,
                  pos.col >= 0, pos.col < Self.cols else { continue }
            guard board[pos.row][pos.col] == color else { continue }
            visited.insert(pos)
            stack.append(BoardPos(row: pos.row - 1, col: pos.col))
            stack.append(BoardPos(row: pos.row + 1, col: pos.col))
            stack.append(BoardPos(row: pos.row, col: pos.col - 1))
            stack.append(BoardPos(row: pos.row, col: pos.col + 1))
        }
        return visited
    }

    private func canMove(pair: FallingPair, dRow: Int, dCol: Int) -> Bool {
        isValidEmpty(row: pair.mainRow + dRow, col: pair.mainCol + dCol) &&
        isValidEmpty(row: pair.subRow  + dRow, col: pair.subCol  + dCol)
    }

    private func isValidEmpty(row: Int, col: Int) -> Bool {
        row >= 0 && row < Self.rows &&
        col >= 0 && col < Self.cols &&
        board[row][col] == .empty
    }

    // MARK: - Controls

    func moveLeft() {
        guard !isProcessing, var pair = fallingPair else { return }
        if canMove(pair: pair, dRow: 0, dCol: -1) {
            pair.mainCol -= 1; pair.subCol -= 1; fallingPair = pair
        }
    }

    func moveRight() {
        guard !isProcessing, var pair = fallingPair else { return }
        if canMove(pair: pair, dRow: 0, dCol: 1) {
            pair.mainCol += 1; pair.subCol += 1; fallingPair = pair
        }
    }

    func rotateCW() {
        guard !isProcessing, var pair = fallingPair else { return }
        let dr = pair.subRow - pair.mainRow
        let dc = pair.subCol - pair.mainCol
        // (dr,dc) → (dc, -dr)
        let newSubRow = pair.mainRow + dc
        let newSubCol = pair.mainCol - dr
        if trySetSub(pair: &pair, row: newSubRow, col: newSubCol) { fallingPair = pair }
    }

    func rotateCCW() {
        guard !isProcessing, var pair = fallingPair else { return }
        let dr = pair.subRow - pair.mainRow
        let dc = pair.subCol - pair.mainCol
        // (dr,dc) → (-dc, dr)
        let newSubRow = pair.mainRow - dc
        let newSubCol = pair.mainCol + dr
        if trySetSub(pair: &pair, row: newSubRow, col: newSubCol) { fallingPair = pair }
    }

    private func trySetSub(pair: inout FallingPair, row: Int, col: Int) -> Bool {
        if isValidEmpty(row: row, col: col) {
            pair.subRow = row; pair.subCol = col; return true
        }
        // Wall kick
        let kickDC = col < 0 ? 1 : (col >= Self.cols ? -1 : 0)
        if kickDC != 0 {
            let km = pair.mainCol + kickDC
            let ks = col + kickDC
            if isValidEmpty(row: pair.mainRow, col: km) && isValidEmpty(row: row, col: ks) {
                pair.mainCol = km; pair.subRow = row; pair.subCol = ks; return true
            }
        }
        return false
    }

    func hardDrop() {
        guard !isProcessing, var pair = fallingPair else { return }
        while canMove(pair: pair, dRow: 1, dCol: 0) {
            pair.mainRow += 1; pair.subRow += 1
        }
        fallingPair = pair
        lockPair(pair)
    }

    // For display: overlay falling pair on board
    func colorAt(row: Int, col: Int) -> PuyoColor {
        if let p = fallingPair {
            if p.mainRow == row && p.mainCol == col { return p.mainColor }
            if p.subRow  == row && p.subCol  == col { return p.subColor }
        }
        return board[row][col]
    }
}

// MARK: - Cell View

struct PuyoCellView: View {
    let color: PuyoColor
    let size: CGFloat
    let flashing: Bool

    var body: some View {
        ZStack {
            if color != .empty {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [color.displayColor.opacity(0.75), color.displayColor],
                            center: UnitPoint(x: 0.35, y: 0.3),
                            startRadius: 0,
                            endRadius: size * 0.5
                        )
                    )
                    .shadow(color: color.displayColor.opacity(0.5), radius: 3)
                    .overlay(
                        Circle()
                            .fill(.white.opacity(0.35))
                            .scaleEffect(0.38)
                            .offset(x: -size * 0.09, y: -size * 0.09)
                    )
                    .opacity(flashing ? 0.25 : 1.0)
            }
        }
        .frame(width: size, height: size)
    }
}

// MARK: - Game View

struct PuyoPuyoGameView: View {
    @StateObject private var game = PuyoPuyoGame()

    private let cols = PuyoPuyoGame.cols
    private let rows = PuyoPuyoGame.rows

    var body: some View {
        ZStack {
            Color(red: 0.06, green: 0.06, blue: 0.18).ignoresSafeArea()

            VStack(spacing: 12) {
                header
                boardArea
                controls
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)

            if game.gameOver { gameOverOverlay }
        }
        .navigationTitle("ぷよぷよ")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear  { game.startGame() }
        .onDisappear { game.stopTimer() }
    }

    // MARK: Header

    private var header: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 2) {
                Text("SCORE").font(.caption2).foregroundStyle(.white.opacity(0.5))
                Text("\(game.score)")
                    .font(.title2.bold().monospacedDigit())
                    .foregroundStyle(.white)
            }

            Spacer()

            if game.chainCount > 1 {
                Text("\(game.chainCount) CHAIN!")
                    .font(.headline.bold())
                    .foregroundStyle(.yellow)
                    .transition(.scale.combined(with: .opacity))
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text("NEXT").font(.caption2).foregroundStyle(.white.opacity(0.5))
                VStack(spacing: 2) {
                    Circle().fill(game.nextSub.displayColor)
                        .frame(width: 22, height: 22)
                    Circle().fill(game.nextMain.displayColor)
                        .frame(width: 22, height: 22)
                }
            }
        }
        .animation(.easeInOut(duration: 0.2), value: game.chainCount)
    }

    // MARK: Board

    private var boardArea: some View {
        GeometryReader { geo in
            let cellW = geo.size.width  / CGFloat(cols)
            let cellH = geo.size.height / CGFloat(rows)
            let cell  = min(cellW, cellH)
            let bw    = cell * CGFloat(cols)
            let bh    = cell * CGFloat(rows)

            ZStack(alignment: .topLeading) {
                // Background
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(red: 0.1, green: 0.1, blue: 0.22))
                    .frame(width: bw, height: bh)

                // Grid lines
                Canvas { ctx, size in
                    var path = Path()
                    for c in 0...cols {
                        let x = CGFloat(c) * cell
                        path.move(to: CGPoint(x: x, y: 0))
                        path.addLine(to: CGPoint(x: x, y: bh))
                    }
                    for r in 0...rows {
                        let y = CGFloat(r) * cell
                        path.move(to: CGPoint(x: 0, y: y))
                        path.addLine(to: CGPoint(x: bw, y: y))
                    }
                    ctx.stroke(path, with: .color(.white.opacity(0.06)), lineWidth: 1)
                }
                .frame(width: bw, height: bh)

                // Cells
                ForEach(0..<rows, id: \.self) { row in
                    ForEach(0..<cols, id: \.self) { col in
                        let color   = game.colorAt(row: row, col: col)
                        let pos     = BoardPos(row: row, col: col)
                        let flash   = game.flashPositions.contains(pos)
                        PuyoCellView(color: color, size: cell - 3, flashing: flash)
                            .position(
                                x: CGFloat(col) * cell + cell / 2,
                                y: CGFloat(row) * cell + cell / 2
                            )
                    }
                }
            }
            .frame(width: bw, height: bh)
            .position(x: geo.size.width / 2, y: geo.size.height / 2)
        }
        .aspectRatio(CGFloat(cols) / CGFloat(rows), contentMode: .fit)
    }

    // MARK: Controls

    private var controls: some View {
        HStack(spacing: 14) {
            ctrlBtn(icon: "arrow.left",         label: "左",    action: game.moveLeft)
            ctrlBtn(icon: "arrow.counterclockwise", label: "反転", action: game.rotateCCW)
            ctrlBtn(icon: "arrow.down.to.line", label: "落下",  action: game.hardDrop)
            ctrlBtn(icon: "arrow.clockwise",    label: "回転",  action: game.rotateCW)
            ctrlBtn(icon: "arrow.right",        label: "右",    action: game.moveRight)
        }
    }

    @ViewBuilder
    private func ctrlBtn(icon: String, label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 3) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                Text(label)
                    .font(.system(size: 9))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 60)
            .background(Color.white.opacity(0.12))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    // MARK: Game Over

    private var gameOverOverlay: some View {
        ZStack {
            Color.black.opacity(0.75).ignoresSafeArea()
            VStack(spacing: 20) {
                Text("GAME OVER")
                    .font(.system(size: 36, weight: .black))
                    .foregroundStyle(.white)
                Text("スコア: \(game.score)")
                    .font(.title2.bold())
                    .foregroundStyle(.yellow)
                Button("もう一度プレイ") {
                    game.startGame()
                }
                .font(.headline)
                .foregroundStyle(.white)
                .padding(.horizontal, 36)
                .padding(.vertical, 14)
                .background(
                    LinearGradient(colors: [.blue, .purple], startPoint: .leading, endPoint: .trailing)
                )
                .clipShape(RoundedRectangle(cornerRadius: 14))
            }
        }
    }
}

#Preview {
    NavigationStack {
        PuyoPuyoGameView()
    }
}
