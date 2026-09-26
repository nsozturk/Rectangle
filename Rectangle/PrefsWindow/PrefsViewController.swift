/// PrefsViewController.swift

import Cocoa
import MASShortcut
import ServiceManagement

class PrefsViewController: NSViewController {
    
    var actionsToViews = [WindowAction: MASShortcutView]()
    private let shortcutRecordingObserver = ShortcutRecordingObserver()
    
    @IBOutlet weak var leftHalfShortcutView: MASShortcutView!
    @IBOutlet weak var rightHalfShortcutView: MASShortcutView!
    @IBOutlet weak var centerHalfShortcutView: MASShortcutView!
    @IBOutlet weak var topHalfShortcutView: MASShortcutView!
    @IBOutlet weak var bottomHalfShortcutView: MASShortcutView!
    
    @IBOutlet weak var topLeftShortcutView: MASShortcutView!
    @IBOutlet weak var topRightShortcutView: MASShortcutView!
    @IBOutlet weak var bottomLeftShortcutView: MASShortcutView!
    @IBOutlet weak var bottomRightShortcutView: MASShortcutView!
    
    @IBOutlet weak var nextDisplayShortcutView: MASShortcutView!
    @IBOutlet weak var previousDisplayShortcutView: MASShortcutView!
    
    @IBOutlet weak var makeLargerShortcutView: MASShortcutView!
    @IBOutlet weak var makeSmallerShortcutView: MASShortcutView!
    
    @IBOutlet weak var maximizeShortcutView: MASShortcutView!
    @IBOutlet weak var almostMaximizeShortcutView: MASShortcutView!
    @IBOutlet weak var maximizeHeightShortcutView: MASShortcutView!
    @IBOutlet weak var centerShortcutView: MASShortcutView!
    @IBOutlet weak var restoreShortcutView: MASShortcutView!
    
    // Additional
    @IBOutlet weak var firstThirdShortcutView: MASShortcutView!
    @IBOutlet weak var firstTwoThirdsShortcutView: MASShortcutView!
    @IBOutlet weak var centerThirdShortcutView: MASShortcutView!
    @IBOutlet weak var centerTwoThirdsShortcutView: MASShortcutView!
    @IBOutlet weak var lastTwoThirdsShortcutView: MASShortcutView!
    @IBOutlet weak var lastThirdShortcutView: MASShortcutView!
    
    @IBOutlet weak var moveLeftShortcutView: MASShortcutView!
    @IBOutlet weak var moveRightShortcutView: MASShortcutView!
    @IBOutlet weak var moveUpShortcutView: MASShortcutView!
    @IBOutlet weak var moveDownShortcutView: MASShortcutView!
    
    @IBOutlet weak var firstFourthShortcutView: MASShortcutView!
    @IBOutlet weak var secondFourthShortcutView: MASShortcutView!
    @IBOutlet weak var thirdFourthShortcutView: MASShortcutView!
    @IBOutlet weak var lastFourthShortcutView: MASShortcutView!
    @IBOutlet weak var firstThreeFourthsShortcutView: MASShortcutView!
    @IBOutlet weak var centerThreeFourthsShortcutView: MASShortcutView!
    @IBOutlet weak var lastThreeFourthsShortcutView: MASShortcutView!
    
    @IBOutlet weak var topLeftSixthShortcutView: MASShortcutView!
    @IBOutlet weak var topCenterSixthShortcutView: MASShortcutView!
    @IBOutlet weak var topRightSixthShortcutView: MASShortcutView!
    @IBOutlet weak var bottomLeftSixthShortcutView: MASShortcutView!
    @IBOutlet weak var bottomCenterSixthShortcutView: MASShortcutView!
    @IBOutlet weak var bottomRightSixthShortcutView: MASShortcutView!

    
    @IBOutlet weak var showMoreButton: NSButton!
    @IBOutlet weak var additionalShortcutsStackView: NSStackView!

    private var shortcutsScrollView: NSScrollView?
    private weak var shortcutsContentView: NSStackView?
    private var documentWidthConstraint: NSLayoutConstraint?
    private var documentHeightConstraint: NSLayoutConstraint?
    private var expandedShortcutWidth: CGFloat = 850
    private var collapsedShortcutHeight: CGFloat = 0
    private var didInitialize = false
    
    // Settings
    override func awakeFromNib() {
        guard !didInitialize else { return }
        didInitialize = true
        
        actionsToViews = [
            .leftHalf: leftHalfShortcutView,
            .rightHalf: rightHalfShortcutView,
            .centerHalf: centerHalfShortcutView,
            .topHalf: topHalfShortcutView,
            .bottomHalf: bottomHalfShortcutView,
            .topLeft: topLeftShortcutView,
            .topRight: topRightShortcutView,
            .bottomLeft: bottomLeftShortcutView,
            .bottomRight: bottomRightShortcutView,
            .nextDisplay: nextDisplayShortcutView,
            .previousDisplay: previousDisplayShortcutView,
            .maximize: maximizeShortcutView,
            .almostMaximize: almostMaximizeShortcutView,
            .maximizeHeight: maximizeHeightShortcutView,
            .center: centerShortcutView,
            .larger: makeLargerShortcutView,
            .smaller: makeSmallerShortcutView,
            .restore: restoreShortcutView,
            .firstThird: firstThirdShortcutView,
            .firstTwoThirds: firstTwoThirdsShortcutView,
            .centerThird: centerThirdShortcutView,
            .centerTwoThirds: centerTwoThirdsShortcutView,
            .lastTwoThirds: lastTwoThirdsShortcutView,
            .lastThird: lastThirdShortcutView,
            .moveLeft: moveLeftShortcutView,
            .moveRight: moveRightShortcutView,
            .moveUp: moveUpShortcutView,
            .moveDown: moveDownShortcutView,
            .firstFourth: firstFourthShortcutView,
            .secondFourth: secondFourthShortcutView,
            .thirdFourth: thirdFourthShortcutView,
            .lastFourth: lastFourthShortcutView,
            .firstThreeFourths: firstThreeFourthsShortcutView,
            .centerThreeFourths: centerThreeFourthsShortcutView,
            .lastThreeFourths: lastThreeFourthsShortcutView,
            .topLeftSixth: topLeftSixthShortcutView,
            .topCenterSixth: topCenterSixthShortcutView,
            .topRightSixth: topRightSixthShortcutView,
            .bottomLeftSixth: bottomLeftSixthShortcutView,
            .bottomCenterSixth: bottomCenterSixthShortcutView,
            .bottomRightSixth: bottomRightSixthShortcutView
        ]
        appendDynamicShortcuts()
        
        for (action, view) in actionsToViews {
            view.setAssociatedUserDefaultsKey(action.name, withTransformerName: MASDictionaryTransformerName)
        }
        shortcutRecordingObserver.observe(Array(actionsToViews.values))
        
        if Defaults.allowAnyShortcut.enabled {
            let passThroughValidator = PassthroughShortcutValidator()
            actionsToViews.values.forEach { $0.shortcutValidator = passThroughValidator }
        }
        
        subscribeToAllowAnyShortcutToggle()
        
        additionalShortcutsStackView.isHidden = true
        installShortcutScrollView()
        updateShortcutViewport()
    }
    
    @IBAction func toggleShowMore(_ sender: NSButton) {
        if additionalShortcutsStackView.isHidden {
            let expandedHeight = collapsedShortcutHeight + ceil(additionalShortcutsStackView.fittingSize.height) + 8
            documentHeightConstraint?.constant = expandedHeight
            shortcutsContentView?.frame.size.height = expandedHeight
        }
        additionalShortcutsStackView.isHidden = !additionalShortcutsStackView.isHidden
        showMoreButton.title = additionalShortcutsStackView.isHidden
            ? "▶︎ ⋯" : "▼"
        updateShortcutViewport()
    }

    private func appendDynamicShortcuts() {
        let existingColumns = additionalShortcutsStackView.arrangedSubviews
        guard existingColumns.count == 2 else { return }

        existingColumns.forEach {
            additionalShortcutsStackView.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }

        additionalShortcutsStackView.orientation = .vertical
        additionalShortcutsStackView.distribution = .fill
        additionalShortcutsStackView.alignment = .leading
        additionalShortcutsStackView.spacing = 9

        let existingGrid = makeTwoColumnGrid(existingColumns)
        additionalShortcutsStackView.addArrangedSubview(existingGrid)
        existingGrid.widthAnchor.constraint(equalTo: additionalShortcutsStackView.widthAnchor).isActive = true

        var widestGrid = existingGrid.fittingSize.width
        for actions in WindowAction.columnLayoutGroups {
            guard let category = actions.first?.category else { continue }

            appendHeader(category.displayName, identifier: "columnShortcutHeader.\(category.menuOrder)")
            widestGrid = max(widestGrid, appendGrid(actions, identifierPrefix: "columnShortcut").fittingSize.width)
        }

        if let twoRowActions = WindowAction.gridLayoutGroups.first,
           let category = twoRowActions.first?.category {
            appendHeader(category.displayName, identifier: "fixedGridShortcutHeader.\(category.menuOrder)")
            widestGrid = max(widestGrid, appendGrid(twoRowActions, identifierPrefix: "fixedGridShortcut").fittingSize.width)
        }

        let threeRowGroups = WindowAction.gridLayoutGroups.dropFirst()
        if let category = threeRowGroups.first?.first?.category {
            appendHeader(category.displayName, identifier: "fixedGridShortcutHeader.\(category.menuOrder)")
            for actions in threeRowGroups {
                let columnCount = actions.count / 3
                appendHeader(fixedGridColumnsTitle(columnCount), identifier: "fixedGridShortcutSubheader.\(columnCount)")
                widestGrid = max(widestGrid, appendGrid(actions, identifierPrefix: "fixedGridShortcut").fittingSize.width)
            }
        }

        let horizontalPadding = view.frame.width - additionalShortcutsStackView.frame.width
        expandedShortcutWidth = ceil(max(view.frame.width, widestGrid + horizontalPadding))
        if let content = view.subviews.first as? NSStackView,
           let widthConstraint = content.constraints.first(where: {
               $0.firstAttribute == .width && $0.secondItem == nil
           }) {
            widthConstraint.constant = expandedShortcutWidth
        }
    }

    private func appendHeader(_ title: String, identifier: String) {
        let header = NSTextField(labelWithString: title)
        header.font = NSFont.boldSystemFont(ofSize: NSFont.systemFontSize)
        header.alignment = .center
        header.translatesAutoresizingMaskIntoConstraints = false
        header.setContentCompressionResistancePriority(.required, for: .vertical)
        header.heightAnchor.constraint(equalToConstant: 16).isActive = true
        header.identifier = NSUserInterfaceItemIdentifier(identifier)
        additionalShortcutsStackView.setCustomSpacing(14, after: additionalShortcutsStackView.arrangedSubviews.last!)
        additionalShortcutsStackView.addArrangedSubview(header)
        header.widthAnchor.constraint(equalTo: additionalShortcutsStackView.widthAnchor).isActive = true
    }

    private func appendGrid(_ actions: [WindowAction], identifierPrefix: String) -> NSStackView {
        let midpoint = (actions.count + 1) / 2
        let columns = [Array(actions[..<midpoint]), Array(actions[midpoint...])].map {
            makeColumn($0, identifierPrefix: identifierPrefix)
        }
        let grid = makeTwoColumnGrid(columns)
        let gridHeight = CGFloat(midpoint * 19 + max(0, midpoint - 1) * 9)
        grid.heightAnchor.constraint(equalToConstant: gridHeight).isActive = true
        additionalShortcutsStackView.addArrangedSubview(grid)
        grid.widthAnchor.constraint(equalTo: additionalShortcutsStackView.widthAnchor).isActive = true
        return grid
    }

    private func fixedGridColumnsTitle(_ count: Int) -> String {
        switch count {
        case 3: return NSLocalizedString("3 Columns", tableName: "Main", value: "3 Columns", comment: "Fixed grid shortcut subgroup")
        case 4: return NSLocalizedString("4 Columns", tableName: "Main", value: "4 Columns", comment: "Fixed grid shortcut subgroup")
        case 6: return NSLocalizedString("6 Columns", tableName: "Main", value: "6 Columns", comment: "Fixed grid shortcut subgroup")
        default: return NSLocalizedString("8 Columns", tableName: "Main", value: "8 Columns", comment: "Fixed grid shortcut subgroup")
        }
    }

    private func makeColumn(_ actions: [WindowAction], identifierPrefix: String) -> NSStackView {
        let column = NSStackView()
        column.orientation = .vertical
        column.alignment = .trailing
        column.distribution = .fill
        column.spacing = 9
        column.translatesAutoresizingMaskIntoConstraints = false

        for action in actions {
            let label = NSTextField(labelWithString: action.displayName ?? action.name)
            label.alignment = .right
            label.translatesAutoresizingMaskIntoConstraints = false
            label.setContentCompressionResistancePriority(.required, for: .horizontal)

            let icon = NSImageView(frame: NSRect(x: 0, y: 0, width: 21, height: 14))
            icon.image = action.image
            icon.imageScaling = .scaleProportionallyDown
            icon.setAccessibilityLabel(action.displayName ?? action.name)
            icon.translatesAutoresizingMaskIntoConstraints = false
            icon.widthAnchor.constraint(equalToConstant: 21).isActive = true
            icon.heightAnchor.constraint(equalToConstant: 14).isActive = true

            let labelAndIcon = NSStackView(views: [label, icon])
            labelAndIcon.orientation = .horizontal
            labelAndIcon.alignment = .centerY
            labelAndIcon.distribution = .fill
            labelAndIcon.spacing = 8
            labelAndIcon.translatesAutoresizingMaskIntoConstraints = false

            let shortcutView = MASShortcutView(frame: NSRect(x: 0, y: 0, width: 160, height: 19))
            shortcutView.identifier = NSUserInterfaceItemIdentifier("\(identifierPrefix).\(action.name)")
            shortcutView.translatesAutoresizingMaskIntoConstraints = false
            shortcutView.widthAnchor.constraint(equalToConstant: 160).isActive = true
            shortcutView.heightAnchor.constraint(equalToConstant: 19).isActive = true
            actionsToViews[action] = shortcutView

            let row = NSStackView(views: [labelAndIcon, shortcutView])
            row.orientation = .horizontal
            row.alignment = .centerY
            row.distribution = .fill
            row.spacing = 18
            row.translatesAutoresizingMaskIntoConstraints = false
            row.setContentHuggingPriority(.required, for: .horizontal)
            labelAndIcon.trailingAnchor.constraint(equalTo: shortcutView.leadingAnchor, constant: -18).isActive = true
            column.addArrangedSubview(row)
        }
        return column
    }

    private func makeTwoColumnGrid(_ columns: [NSView]) -> NSStackView {
        let grid = NSStackView(views: columns)
        grid.orientation = .horizontal
        grid.alignment = .top
        grid.distribution = .fillEqually
        grid.spacing = 43
        grid.translatesAutoresizingMaskIntoConstraints = false
        return grid
    }

    private func installShortcutScrollView() {
        guard shortcutsScrollView == nil,
              let content = view.subviews.first as? NSStackView else { return }

        let containingConstraints = view.constraints.filter {
            ($0.firstItem as? NSView) === content || ($0.secondItem as? NSView) === content
        }
        NSLayoutConstraint.deactivate(containingConstraints)
        content.removeFromSuperview()
        content.translatesAutoresizingMaskIntoConstraints = false

        let scrollView = NSScrollView(frame: view.bounds)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.hasVerticalScroller = true
        scrollView.autohidesScrollers = true
        scrollView.borderType = .noBorder
        scrollView.drawsBackground = false
        scrollView.documentView = content
        view.addSubview(scrollView)
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        collapsedShortcutHeight = ceil(content.fittingSize.height)
        let widthConstraint = content.widthAnchor.constraint(equalToConstant: expandedShortcutWidth)
        let heightConstraint = content.heightAnchor.constraint(equalToConstant: collapsedShortcutHeight)
        NSLayoutConstraint.activate([widthConstraint, heightConstraint])

        shortcutsContentView = content
        shortcutsScrollView = scrollView
        documentWidthConstraint = widthConstraint
        documentHeightConstraint = heightConstraint
    }

    private func updateShortcutViewport() {
        guard let content = shortcutsContentView, shortcutsScrollView != nil else { return }

        additionalShortcutsStackView.needsLayout = true
        additionalShortcutsStackView.layoutSubtreeIfNeeded()

        let documentHeight = additionalShortcutsStackView.isHidden
            ? collapsedShortcutHeight
            : collapsedShortcutHeight + ceil(additionalShortcutsStackView.fittingSize.height) + 8
        let contentSize = NSSize(width: expandedShortcutWidth, height: documentHeight)
        documentWidthConstraint?.constant = contentSize.width
        documentHeightConstraint?.constant = contentSize.height
        content.frame = NSRect(origin: .zero, size: contentSize)
        content.layoutSubtreeIfNeeded()

        let viewportHeight = additionalShortcutsStackView.isHidden
            ? contentSize.height
            : min(contentSize.height, 686)
        let viewportSize = NSSize(width: contentSize.width, height: viewportHeight)
        preferredContentSize = viewportSize
        view.frame.size = viewportSize
        view.window?.setContentSize(viewportSize)

        DispatchQueue.main.async { [weak self] in
            guard let self = self, let content = self.shortcutsContentView,
                  let scrollView = self.shortcutsScrollView else { return }
            let top = content.isFlipped ? CGFloat.zero : max(0, content.bounds.height - scrollView.contentSize.height)
            scrollView.contentView.scroll(to: NSPoint(x: 0, y: top))
            scrollView.reflectScrolledClipView(scrollView.contentView)
        }
    }
    
    private func subscribeToAllowAnyShortcutToggle() {
        Notification.Name.allowAnyShortcut.onPost { notification in
            guard let enabled = notification.object as? Bool else { return }
            let validator = enabled ? PassthroughShortcutValidator() : MASShortcutValidator()
            self.actionsToViews.values.forEach { $0.shortcutValidator = validator }
        }
    }
    
}

class PassthroughShortcutValidator: MASShortcutValidator {
    
    override func isShortcutValid(_ shortcut: MASShortcut!) -> Bool {
        return true
    }
    
    override func isShortcutAlreadyTaken(bySystem shortcut: MASShortcut!, explanation: AutoreleasingUnsafeMutablePointer<NSString?>!) -> Bool {
        return false
    }
    
    override func isShortcut(_ shortcut: MASShortcut!, alreadyTakenIn menu: NSMenu!, explanation: AutoreleasingUnsafeMutablePointer<NSString?>!) -> Bool {
        return false
    }
    
}
