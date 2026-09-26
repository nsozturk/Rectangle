/// ShortcutRecordingObserverTests.swift

import MASShortcut
import XCTest
@testable import Rectangle

class ShortcutRecordingObserverTests: XCTestCase {

    func testPostsRecordingChangesForObservedShortcutViews() {
        let observer = ShortcutRecordingObserver()
        let firstShortcutView = MASShortcutView()
        let secondShortcutView = MASShortcutView()
        var recordingChanges = [Bool]()
        let notificationObserver = NotificationCenter.default.addObserver(
            forName: .shortcutRecording,
            object: nil,
            queue: nil
        ) { notification in
            recordingChanges.append(notification.object as! Bool)
        }
        defer {
            NotificationCenter.default.removeObserver(notificationObserver)
            firstShortcutView.setValue(false, forKey: "recording")
            secondShortcutView.setValue(false, forKey: "recording")
        }

        observer.observe([firstShortcutView, secondShortcutView])

        firstShortcutView.setValue(true, forKey: "recording")
        firstShortcutView.setValue(false, forKey: "recording")
        secondShortcutView.setValue(true, forKey: "recording")
        secondShortcutView.setValue(false, forKey: "recording")

        XCTAssertEqual(recordingChanges, [true, false, true, false])
    }

    func testObservingSameShortcutViewTwiceDoesNotDuplicateNotifications() {
        let observer = ShortcutRecordingObserver()
        let shortcutView = MASShortcutView()
        var recordingChanges = [Bool]()
        let notificationObserver = NotificationCenter.default.addObserver(
            forName: .shortcutRecording,
            object: nil,
            queue: nil
        ) { notification in
            recordingChanges.append(notification.object as! Bool)
        }
        defer {
            NotificationCenter.default.removeObserver(notificationObserver)
            shortcutView.setValue(false, forKey: "recording")
        }

        observer.observe([shortcutView])
        observer.observe([shortcutView])

        shortcutView.setValue(true, forKey: "recording")
        shortcutView.setValue(false, forKey: "recording")

        XCTAssertEqual(recordingChanges, [true, false])
    }

    func testOverlappingShortcutRecordingsStayActiveUntilAllViewsStopRecording() {
        let observer = ShortcutRecordingObserver()
        let firstShortcutView = MASShortcutView()
        let secondShortcutView = MASShortcutView()
        var recordingChanges = [Bool]()
        let notificationObserver = NotificationCenter.default.addObserver(
            forName: .shortcutRecording,
            object: nil,
            queue: nil
        ) { notification in
            recordingChanges.append(notification.object as! Bool)
        }
        defer {
            NotificationCenter.default.removeObserver(notificationObserver)
        }

        observer.recordingChanged(for: firstShortcutView, isRecording: true)
        XCTAssertEqual(recordingChanges, [true])

        observer.recordingChanged(for: secondShortcutView, isRecording: true)
        XCTAssertEqual(recordingChanges, [true])

        observer.recordingChanged(for: firstShortcutView, isRecording: false)
        XCTAssertEqual(recordingChanges, [true])

        observer.recordingChanged(for: secondShortcutView, isRecording: false)
        XCTAssertEqual(recordingChanges, [true, false])
    }
}

class ColumnShortcutPopoverTests: XCTestCase {
    func testEveryColumnActionAppearsOnceInItsMenuGroup() throws {
        let menu = try XCTUnwrap(AppDelegate.instance.mainStatusMenu)
        func items(in menu: NSMenu) -> [NSMenuItem] {
            menu.items + menu.items.compactMap(\.submenu).flatMap { items(in: $0) }
        }
        let allItems = items(in: menu)
        for action in WindowAction.columnLayoutGroups.flatMap({ $0 }) {
            let matches = allItems.filter { ($0.representedObject as? WindowAction) == action }
            XCTAssertEqual(matches.count, 1, action.name)
            XCTAssertEqual(matches.first?.title, action.displayName)
            if !Defaults.showAllActionsInMenu.userEnabled {
                XCTAssertEqual(matches.first?.menu?.title, action.category?.displayName)
            }
        }
    }

    func testAllColumnShortcutsAreBoundAndReachableInScrollablePopover() throws {
        let originalWindows = Set(NSApp.windows.map(ObjectIdentifier.init))
        let host = NSWindow(contentRect: NSRect(x: 100, y: 100, width: 500, height: 300),
                            styleMask: [.titled], backing: .buffered, defer: false)
        host.isReleasedWhenClosed = false
        let button = NSButton(frame: NSRect(x: 40, y: 100, width: 120, height: 30))
        host.contentView!.addSubview(button)
        host.makeKeyAndOrderFront(nil)
        let controller = SettingsViewController()
        defer {
            for window in NSApp.windows where !originalWindows.contains(ObjectIdentifier(window)) {
                window.orderOut(nil)
            }
            host.close()
        }
        controller.showExtraSettings(button)

        func descendants(_ view: NSView) -> [NSView] {
            [view] + view.subviews.flatMap(descendants)
        }
        let testWindows = NSApp.windows.filter { !originalWindows.contains(ObjectIdentifier($0)) }
        let views = testWindows.compactMap(\.contentView).flatMap(descendants)
        let scroll = try XCTUnwrap(views.compactMap { $0 as? NSScrollView }.first)
        let document = try XCTUnwrap(scroll.documentView)
        document.layoutSubtreeIfNeeded()
        let controls = descendants(document).compactMap { $0 as? MASShortcutView }
        let labels = descendants(document).compactMap { $0 as? NSTextField }.map(\.stringValue)
        for action in WindowAction.columnLayoutGroups.flatMap({ $0 }) {
            XCTAssertEqual(controls.filter { $0.associatedUserDefaultsKey == action.name }.count, 1, action.name)
            XCTAssertTrue(labels.contains(try XCTUnwrap(action.displayName)), action.name)
        }
        XCTAssertTrue(document.isFlipped)
        XCTAssertLessThanOrEqual(scroll.frame.height, 680)
        XCTAssertGreaterThan(document.frame.height, scroll.contentView.bounds.height)
        XCTAssertEqual(scroll.contentView.bounds.minY, 0, accuracy: 1)
        let lastAction = try XCTUnwrap(WindowAction.columnLayoutGroups.last?.last)
        let lastControl = try XCTUnwrap(controls.first { $0.associatedUserDefaultsKey == lastAction.name })
        lastControl.scrollToVisible(lastControl.bounds)
        XCTAssertTrue(scroll.documentVisibleRect.intersects(lastControl.convert(lastControl.bounds, to: document)))
    }
}
