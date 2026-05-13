import SwiftUI
import AppKit
import ServiceManagement

enum DisplayMode: String, CaseIterable, Identifiable {
    case characters = "Characters"
    case charactersNoSpaces = "Characters (no spaces)"
    case words = "Words"
    case lines = "Lines"

    var id: String { rawValue }

    func value(from monitor: ClipboardMonitor) -> Int {
        switch self {
        case .characters: return monitor.characters
        case .charactersNoSpaces: return monitor.charactersNoSpaces
        case .words: return monitor.words
        case .lines: return monitor.lines
        }
    }

    func suffix(short: Bool, count: Int) -> String {
        if short {
            switch self {
            case .characters: return "c"
            case .charactersNoSpaces: return "c·"
            case .words: return "w"
            case .lines: return "l"
            }
        }
        switch self {
        case .characters, .charactersNoSpaces:
            return count == 1 ? "character" : "characters"
        case .words:
            return count == 1 ? "word" : "words"
        case .lines:
            return count == 1 ? "line" : "lines"
        }
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        Installer.promptIfNeeded()
    }
}

@main
struct TallyBarApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @StateObject private var monitor = ClipboardMonitor()
    @AppStorage("displayMode") private var displayModeRaw: String = DisplayMode.characters.rawValue
    @AppStorage("shortenLabel") private var shortenLabel: Bool = true

    private var displayMode: DisplayMode {
        DisplayMode(rawValue: displayModeRaw) ?? .characters
    }

    var body: some Scene {
        MenuBarExtra {
            MenuContent(
                monitor: monitor,
                displayModeRaw: $displayModeRaw,
                shortenLabel: $shortenLabel
            )
        } label: {
            let value = displayMode.value(from: monitor)
            Text("\(value) \(displayMode.suffix(short: shortenLabel, count: value))")
        }
        .menuBarExtraStyle(.menu)
    }
}

struct MenuContent: View {
    @ObservedObject var monitor: ClipboardMonitor
    @Binding var displayModeRaw: String
    @Binding var shortenLabel: Bool
    @State private var launchAtLogin: Bool = LoginItem.isEnabled
    @State private var loginItemError: String?

    var body: some View {
        Group {
            Text("Characters: \(monitor.characters)")
            Text("Characters (no spaces): \(monitor.charactersNoSpaces)")
            Text("Words: \(monitor.words)")
            Text("Lines: \(monitor.lines)")
        }

        Divider()

        Menu("Display in menu bar") {
            ForEach(DisplayMode.allCases) { mode in
                Button {
                    displayModeRaw = mode.rawValue
                } label: {
                    HStack {
                        Text(mode.rawValue)
                        if mode.rawValue == displayModeRaw {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        }

        Toggle("Shorten label (c / w / l)", isOn: $shortenLabel)

        Toggle("Launch at login", isOn: Binding(
            get: { launchAtLogin },
            set: { newValue in
                do {
                    try LoginItem.setEnabled(newValue)
                    launchAtLogin = LoginItem.isEnabled
                    loginItemError = nil
                } catch {
                    loginItemError = error.localizedDescription
                    launchAtLogin = LoginItem.isEnabled
                }
            }
        ))

        if let err = loginItemError {
            Text("Login item: \(err)")
        }

        Divider()

        Button("Quit TallyBar") {
            NSApp.terminate(nil)
        }
        .keyboardShortcut("q")
        .task {
            monitor.start()
        }
    }
}

enum LoginItem {
    static var isEnabled: Bool {
        SMAppService.mainApp.status == .enabled
    }

    static func setEnabled(_ enabled: Bool) throws {
        if enabled {
            if SMAppService.mainApp.status != .enabled {
                try SMAppService.mainApp.register()
            }
        } else {
            try SMAppService.mainApp.unregister()
        }
    }
}
