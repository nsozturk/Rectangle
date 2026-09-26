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
    private func descendants(of view: NSView) -> [NSView] {
        [view] + view.subviews.flatMap(descendants)
    }

    private func isHidden(_ view: NSView, by ancestor: NSView) -> Bool {
        var candidate: NSView? = view
        while let current = candidate {
            if current === ancestor { return current.isHidden }
            candidate = current.superview
        }
        return false
    }

    func testEveryDynamicActionAppearsOnceInItsMenuGroup() throws {
        let menu = try XCTUnwrap(AppDelegate.instance.mainStatusMenu)
        func items(in menu: NSMenu) -> [NSMenuItem] {
            menu.items + menu.items.compactMap(\.submenu).flatMap { items(in: $0) }
        }
        let allItems = items(in: menu)
        let fixedGridActions = WindowAction.gridLayoutGroups.flatMap { $0 }
        for action in (WindowAction.columnLayoutGroups + WindowAction.gridLayoutGroups).flatMap({ $0 }) {
            let matches = allItems.filter { ($0.representedObject as? WindowAction) == action }
            XCTAssertEqual(matches.count, 1, action.name)
            XCTAssertEqual(matches.first?.title, action.displayName)
            if !Defaults.showAllActionsInMenu.userEnabled {
                XCTAssertEqual(matches.first?.menu?.title, action.category?.displayName)
            }
        }
        let fixedGridCategories = Set(fixedGridActions.compactMap(\.category))
        XCTAssertEqual(fixedGridCategories, [.twoRowGrids, .threeRowGrids])
        XCTAssertEqual(menu.items.filter { item in
            item.submenu != nil && fixedGridCategories.contains { $0.displayName == item.title }
        }.count, 2)
        for (category, count) in [(WindowActionCategory.twoRowGrids, 8), (.threeRowGrids, 63)] {
            let submenu = try XCTUnwrap(menu.items.first { $0.title == category.displayName }?.submenu)
            XCTAssertEqual(submenu.items.compactMap { $0.representedObject as? WindowAction }.count, count)
        }
    }

    func testAllDynamicShortcutsAreBoundInsideScrollableShortcutsDisclosure() throws {
        let windowController = try XCTUnwrap(
            NSStoryboard(name: "Main", bundle: nil)
                .instantiateController(withIdentifier: "PrefsWindowController") as? NSWindowController
        )
        let tabController = try XCTUnwrap(windowController.contentViewController as? NSTabViewController)
        let controller = try XCTUnwrap(
            tabController.tabViewItems.compactMap(\.viewController)
                .compactMap { $0 as? PrefsViewController }
                .first
        )
        let window = try XCTUnwrap(windowController.window)
        windowController.showWindow(nil)
        defer { window.close() }

        let columnActions = WindowAction.columnLayoutGroups.flatMap { $0 }
        let fixedGridActions = WindowAction.gridLayoutGroups.flatMap { $0 }
        let actions = columnActions + fixedGridActions
        XCTAssertEqual(columnActions.count, 32)
        XCTAssertEqual(fixedGridActions.count, 71)
        XCTAssertEqual(actions.count, 103)
        XCTAssertTrue(controller.additionalShortcutsStackView.isHidden)

        let disclosureViews = descendants(of: controller.additionalShortcutsStackView)
        let disclosureControls = disclosureViews.compactMap { $0 as? MASShortcutView }
        let retainedActions: [WindowAction] = [
            .firstThird, .firstTwoThirds, .centerThird, .centerTwoThirds, .lastTwoThirds, .lastThird,
            .firstFourth, .secondFourth, .thirdFourth, .lastFourth,
            .firstThreeFourths, .centerThreeFourths, .lastThreeFourths
        ]
        for action in retainedActions {
            XCTAssertEqual(disclosureControls.filter { $0.associatedUserDefaultsKey == action.name }.count, 1, action.name)
        }
        for action in columnActions {
            let matches = disclosureControls.filter { $0.associatedUserDefaultsKey == action.name }
            XCTAssertEqual(matches.count, 1, action.name)
            XCTAssertEqual(matches.first?.identifier?.rawValue, "columnShortcut.\(action.name)")
            XCTAssertIdentical(controller.actionsToViews[action], matches.first)
            let control = try XCTUnwrap(matches.first)
            let row = try XCTUnwrap(control.superview)
            let icon = try XCTUnwrap(descendants(of: row).compactMap { $0 as? NSImageView }.first)
            XCTAssertEqual(
                control.convert(control.bounds, to: row).minX - icon.convert(icon.bounds, to: row).maxX,
                18,
                accuracy: 1,
                action.name
            )
        }
        for action in fixedGridActions {
            let matches = disclosureControls.filter { $0.associatedUserDefaultsKey == action.name }
            XCTAssertEqual(matches.count, 1, action.name)
            XCTAssertEqual(matches.first?.identifier?.rawValue, "fixedGridShortcut.\(action.name)")
            XCTAssertIdentical(controller.actionsToViews[action], matches.first)
            let control = try XCTUnwrap(matches.first)
            let row = try XCTUnwrap(control.superview)
            let icon = try XCTUnwrap(descendants(of: row).compactMap { $0 as? NSImageView }.first)
            XCTAssertEqual(
                control.convert(control.bounds, to: row).minX - icon.convert(icon.bounds, to: row).maxX,
                18,
                accuracy: 1,
                action.name
            )
        }
        XCTAssertEqual(
            disclosureControls.filter { actions.map(\.name).contains($0.associatedUserDefaultsKey) }.count,
            103
        )
        XCTAssertEqual(disclosureViews.filter { $0.identifier?.rawValue.hasPrefix("fixedGridShortcutHeader.") == true }.count, 2)
        XCTAssertEqual(disclosureViews.filter { $0.identifier?.rawValue.hasPrefix("fixedGridShortcutSubheader.") == true }.count, 4)
        XCTAssertTrue(disclosureViews.contains { $0 === controller.thirdFourthShortcutView })
        XCTAssertTrue(disclosureViews.contains { $0 === controller.lastFourthShortcutView })

        let collapsedWindowHeight = window.frame.height
        controller.toggleShowMore(controller.showMoreButton)
        XCTAssertFalse(controller.additionalShortcutsStackView.isHidden)
        window.contentView?.layoutSubtreeIfNeeded()
        XCTAssertGreaterThan(window.frame.height, collapsedWindowHeight)

        let scroll = try XCTUnwrap(descendants(of: controller.view).compactMap { $0 as? NSScrollView }.first)
        let document = try XCTUnwrap(scroll.documentView)
        document.layoutSubtreeIfNeeded()
        XCTAssertGreaterThan(document.frame.height, scroll.contentView.bounds.height)
        XCTAssertEqual(scroll.contentSize.height, min(document.frame.height, 686), accuracy: 1)
        for action in actions {
            let control = try XCTUnwrap(controller.actionsToViews[action])
            control.scrollToVisible(control.bounds)
            XCTAssertTrue(
                scroll.documentVisibleRect.contains(control.convert(control.bounds, to: document)),
                action.name
            )
        }

        controller.toggleShowMore(controller.showMoreButton)
        XCTAssertTrue(controller.additionalShortcutsStackView.isHidden)
        XCTAssertTrue(disclosureControls.allSatisfy {
            isHidden($0, by: controller.additionalShortcutsStackView)
        })
    }

    func testGeneralPopoverDoesNotDuplicateColumnShortcuts() throws {
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

        let testWindows = NSApp.windows.filter { !originalWindows.contains(ObjectIdentifier($0)) }
        let controls = testWindows.compactMap(\.contentView)
            .flatMap { descendants(of: $0) }
            .compactMap { $0 as? MASShortcutView }
        for action in (WindowAction.columnLayoutGroups + WindowAction.gridLayoutGroups).flatMap({ $0 }) {
            XCTAssertFalse(controls.contains { $0.associatedUserDefaultsKey == action.name }, action.name)
        }
    }

    func testEveryRecorderUsesSharedValidatorAndKeepsItAcrossLiveAllowAnyToggle() throws {
        let defaultsDomain = Bundle.main.bundleIdentifier.flatMap {
            UserDefaults.standard.persistentDomain(forName: $0)
        } ?? [:]
        let savedAllowAnyShortcut = Defaults.allowAnyShortcut.enabled
        let savedAllowAnyShortcutValue = defaultsDomain[Defaults.allowAnyShortcut.key]
        let savedTodoValues = Dictionary(uniqueKeysWithValues: TodoManager.defaultsKeys.map {
            ($0, defaultsDomain[$0])
        })
        defer {
            if let savedAllowAnyShortcutValue {
                UserDefaults.standard.set(savedAllowAnyShortcutValue,
                                          forKey: Defaults.allowAnyShortcut.key)
            } else {
                UserDefaults.standard.removeObject(forKey: Defaults.allowAnyShortcut.key)
            }
            Notification.Name.allowAnyShortcut.post(object: savedAllowAnyShortcut)
            for (key, value) in savedTodoValues {
                if let value {
                    UserDefaults.standard.set(value, forKey: key)
                } else {
                    UserDefaults.standard.removeObject(forKey: key)
                }
            }
        }
        Defaults.allowAnyShortcut.enabled = false

        let originalWindows = Set(NSApp.windows.map(ObjectIdentifier.init))
        let windowController = try XCTUnwrap(
            NSStoryboard(name: "Main", bundle: nil)
                .instantiateController(withIdentifier: "PrefsWindowController") as? NSWindowController
        )
        let tabController = try XCTUnwrap(windowController.contentViewController as? NSTabViewController)
        let prefsController = try XCTUnwrap(
            tabController.tabViewItems.compactMap(\.viewController)
                .compactMap { $0 as? PrefsViewController }
                .first
        )
        let settingsController = try XCTUnwrap(
            tabController.tabViewItems.compactMap(\.viewController)
                .compactMap { $0 as? SettingsViewController }
                .first
        )
        let window = try XCTUnwrap(windowController.window)
        windowController.showWindow(nil)
        defer {
            for candidate in NSApp.windows where !originalWindows.contains(ObjectIdentifier(candidate)) {
                candidate.orderOut(nil)
            }
            window.close()
        }

        let popoverHost = NSButton(frame: NSRect(x: 40, y: 40, width: 120, height: 30))
        window.contentView?.addSubview(popoverHost)
        let windowsBeforePopover = Set(NSApp.windows.map(ObjectIdentifier.init))
        settingsController.showExtraSettings(popoverHost)
        let popoverControls = NSApp.windows
            .filter { !windowsBeforePopover.contains(ObjectIdentifier($0)) }
            .compactMap(\.contentView)
            .flatMap { descendants(of: $0) }
            .compactMap { $0 as? MASShortcutView }

        let mainControls = Array(prefsController.actionsToViews.values)
        let todoControls = [settingsController.toggleTodoShortcutView,
                            settingsController.reflowTodoShortcutView].compactMap { $0 }
        XCTAssertGreaterThanOrEqual(mainControls.count, 141)
        XCTAssertEqual(popoverControls.count, 18)
        XCTAssertEqual(todoControls.count, 2)
        XCTAssertTrue(mainControls.allSatisfy { $0.shortcutValidator is AppShortcutValidator })
        XCTAssertTrue(popoverControls.allSatisfy { $0.shortcutValidator is AppShortcutValidator })
        XCTAssertTrue(todoControls.allSatisfy { $0.shortcutValidator is AppShortcutValidator })

        let allControls = mainControls + popoverControls + todoControls
        let originalValidators = try allControls.map {
            ObjectIdentifier(try XCTUnwrap($0.shortcutValidator))
        }

        Defaults.allowAnyShortcut.enabled = true
        Notification.Name.allowAnyShortcut.post(object: true)
        XCTAssertEqual(try allControls.map { ObjectIdentifier(try XCTUnwrap($0.shortcutValidator)) },
                       originalValidators)

        Defaults.allowAnyShortcut.enabled = false
        Notification.Name.allowAnyShortcut.post(object: false)
        XCTAssertEqual(try allControls.map { ObjectIdentifier(try XCTUnwrap($0.shortcutValidator)) },
                       originalValidators)
    }
}
