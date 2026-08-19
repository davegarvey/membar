import AppKit
import Foundation

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem?
    private var memoryMonitor: MemoryMonitor?
    private var usedMenuItem: NSMenuItem?
    private var pressureMenuItem: NSMenuItem?

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)

        let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusItem.button?.image = MemoryIcon.image(fillLevel: 0, pressure: .normal)
        statusItem.button?.imagePosition = .imageOnly
        statusItem.button?.imageScaling = .scaleProportionallyDown
        statusItem.button?.toolTip = "Memory"
        statusItem.menu = makeMenu()
        self.statusItem = statusItem

        let monitor = MemoryMonitor { [weak self] snapshot in
            DispatchQueue.main.async { [weak self] in
                self?.apply(snapshot)
            }
        }
        memoryMonitor = monitor
        monitor.start()
    }

    @objc private func quit() {
        memoryMonitor?.stop()
        NSApp.terminate(nil)
    }

    private func makeMenu() -> NSMenu {
        let menu = NSMenu()
        menu.autoenablesItems = false

        let heading = NSMenuItem(title: "Memory", action: nil, keyEquivalent: "")
        heading.isEnabled = false
        menu.addItem(heading)

        let usedItem = NSMenuItem(title: "Used: --", action: nil, keyEquivalent: "")
        usedItem.isEnabled = false
        menu.addItem(usedItem)
        self.usedMenuItem = usedItem

        let pressureItem = NSMenuItem(title: "Pressure: Normal", action: nil, keyEquivalent: "")
        pressureItem.isEnabled = false
        menu.addItem(pressureItem)
        self.pressureMenuItem = pressureItem

        menu.addItem(.separator())

        let quitItem = NSMenuItem(title: "Quit", action: #selector(quit), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)

        return menu
    }

    private func apply(_ snapshot: MemorySnapshot) {
        statusItem?.button?.image = MemoryIcon.image(
            fillLevel: snapshot.fillLevel,
            pressure: snapshot.pressure
        )
        usedMenuItem?.title = "Used: \(snapshot.percentage)%"
        pressureMenuItem?.title = "Pressure: \(snapshot.pressure.displayName)"
    }
}
