import AppKit
import Combine
import Foundation

/// Polls NSPasteboard for changes and publishes counts.
/// Polling is the standard approach on macOS — there is no public push API for pasteboard changes.
final class ClipboardMonitor: ObservableObject {
    @Published private(set) var text: String = ""
    @Published private(set) var characters: Int = 0
    @Published private(set) var charactersNoSpaces: Int = 0
    @Published private(set) var words: Int = 0
    @Published private(set) var lines: Int = 0
    @Published private(set) var lastUpdated: Date = .init()

    private let pasteboard = NSPasteboard.general
    private var lastChangeCount: Int
    private var timer: Timer?

    init() {
        self.lastChangeCount = pasteboard.changeCount
        readClipboard(force: true)
    }

    func start(pollInterval: TimeInterval = 0.4) {
        stop()
        let t = Timer(timeInterval: pollInterval, repeats: true) { [weak self] _ in
            self?.tick()
        }
        RunLoop.main.add(t, forMode: .common)
        timer = t
    }

    func stop() {
        timer?.invalidate()
        timer = nil
    }

    private func tick() {
        let current = pasteboard.changeCount
        guard current != lastChangeCount else { return }
        lastChangeCount = current
        readClipboard(force: false)
    }

    private func readClipboard(force: Bool) {
        let value = pasteboard.string(forType: .string) ?? ""
        guard force || value != text else { return }
        let metrics = TextMetrics.compute(value)
        self.text = value
        self.characters = metrics.characters
        self.charactersNoSpaces = metrics.charactersNoSpaces
        self.words = metrics.words
        self.lines = metrics.lines
        self.lastUpdated = Date()
    }
}

struct TextMetrics {
    let characters: Int
    let charactersNoSpaces: Int
    let words: Int
    let lines: Int

    static func compute(_ s: String) -> TextMetrics {
        let characters = s.count
        let charactersNoSpaces = s.unicodeScalars.reduce(into: 0) { acc, scalar in
            if !CharacterSet.whitespacesAndNewlines.contains(scalar) { acc += 1 }
        }
        let words = s
            .split(whereSeparator: { $0.isWhitespace || $0.isNewline })
            .count
        let lines = s.isEmpty ? 0 : s.split(omittingEmptySubsequences: false, whereSeparator: { $0.isNewline }).count
        return TextMetrics(
            characters: characters,
            charactersNoSpaces: charactersNoSpaces,
            words: words,
            lines: lines
        )
    }
}
