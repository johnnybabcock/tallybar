import AppKit
import Foundation

/// Detects when the app is running from outside the Applications folder and
/// offers to move itself there. Mirrors the well-worn "LetsMove" pattern.
enum Installer {
    private static let declinedKey = "installerDeclined"

    static func promptIfNeeded() {
        guard !isInApplicationsFolder() else { return }
        if UserDefaults.standard.bool(forKey: declinedKey) { return }

        let alert = NSAlert()
        alert.messageText = "Move TallyBar to your Applications folder?"
        alert.informativeText = """
        TallyBar is running from \(Bundle.main.bundlePath).

        For Launch at Login to work reliably and to keep the app available after \
        rebuilds or moves, install it into your Applications folder.
        """
        alert.addButton(withTitle: "Move to Applications")
        alert.addButton(withTitle: "Not Now")
        alert.addButton(withTitle: "Don't Ask Again")

        NSApp.activate(ignoringOtherApps: true)
        let response = alert.runModal()
        switch response {
        case .alertFirstButtonReturn:
            moveAndRelaunch()
        case .alertThirdButtonReturn:
            UserDefaults.standard.set(true, forKey: declinedKey)
        default:
            break
        }
    }

    private static func isInApplicationsFolder() -> Bool {
        let path = Bundle.main.bundlePath
        let userApps = (NSHomeDirectory() as NSString).appendingPathComponent("Applications") + "/"
        return path.hasPrefix("/Applications/") || path.hasPrefix(userApps)
    }

    private static func moveAndRelaunch() {
        let fm = FileManager.default
        let source = URL(fileURLWithPath: Bundle.main.bundlePath)
        let fileName = source.lastPathComponent

        let candidates: [URL] = [
            URL(fileURLWithPath: "/Applications"),
            URL(fileURLWithPath: (NSHomeDirectory() as NSString).appendingPathComponent("Applications"))
        ]

        for dir in candidates {
            do {
                try fm.createDirectory(at: dir, withIntermediateDirectories: true)
                let destination = dir.appendingPathComponent(fileName)
                if fm.fileExists(atPath: destination.path) {
                    try fm.removeItem(at: destination)
                }
                try fm.copyItem(at: source, to: destination)
                relaunch(at: destination)
                return
            } catch {
                continue
            }
        }

        let err = NSAlert()
        err.messageText = "Could not move TallyBar"
        err.informativeText = "Drag the app into your Applications folder manually."
        err.runModal()
    }

    private static func relaunch(at destination: URL) {
        // Detach a shell that waits for this process to exit, then opens the new copy.
        // Using `open` ensures macOS launches the freshly-installed bundle cleanly.
        let pid = ProcessInfo.processInfo.processIdentifier
        let script = """
        while kill -0 \(pid) 2>/dev/null; do sleep 0.1; done
        /usr/bin/open "\(destination.path)"
        """
        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/bin/sh")
        task.arguments = ["-c", script]
        try? task.run()
        NSApp.terminate(nil)
    }
}
