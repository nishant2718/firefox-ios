// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import UIKit
import Storage
import Shared

/// Target-Action helper. #selector can now refer to closures. MOVE LATER
@available (iOS 14, *)
final class Action: NSObject {

    private let _action: () -> ()

    init(action: @escaping () -> ()) {
        _action = action
        super.init()
    }

    @objc func action() {
        _action()
    }
}

// MARK: - Generalized List Cell & associated items

/// A generalized list cell. Create new list cells based on this abstraction.
@available (iOS 14, *)
private extension UIConfigurationStateCustomKey {
    static let historyActionableItem = UIConfigurationStateCustomKey("org.mozilla.ios.historyActionableItem")
    static let historySiteItem = UIConfigurationStateCustomKey("org.mozilla.ios.historySiteItem")
}

@available (iOS 14, *)
private extension UICellConfigurationState {
    var historyActionableItem: HistoryActionables? {
        get { return self[.historyActionableItem] as? HistoryActionables }
        set { self[.historyActionableItem] = newValue }
    }
    var historySiteItem: Site? {
        get { return self[.historySiteItem] as? Site }
        set { self[.historySiteItem] = newValue }
    }
}

/// A generalized list cell for use throughout LibraryPanel. Create new list cells from this abstraction.
@available (iOS 14, *)
class LibraryPanelGeneralizedListCell: UICollectionViewListCell {
    
    // MARK: - Properties
    /// When handling a new type, add it below.
    
    private var historyActionableItem: HistoryActionables? = nil
    private var historySiteItem: Site? = nil
    @objc var tapAction: Action?
    
    // MARK: - Helpers
    /// Type specific updates of list cells.
    
    func updateWithItem(_ newItem: HistoryActionables) {
        guard historyActionableItem != newItem else { return }
        historyActionableItem = newItem
        setNeedsUpdateConfiguration()
    }
    
    func updateWithItem(_ newItem: Site) {
        guard historySiteItem != newItem else { return }
        historySiteItem = newItem
        setNeedsUpdateConfiguration()
    }
    
    override var configurationState: UICellConfigurationState {
        var state = super.configurationState
        state.historyActionableItem = self.historyActionableItem
        state.historySiteItem = self.historySiteItem
        
        return state
    }
    
}

// MARK: - LibraryPanelListCell: Plain and subtitle support.

/// A list cell that can hold an image, a title and a subtitle. MOVE SOON
@available (iOS 14, *)
class LibraryPanelCustomListCell: LibraryPanelGeneralizedListCell {
    
    private func defaultListContentConfiguration() -> UIListContentConfiguration { return .subtitleCell() }
    private lazy var listContentView = UIListContentView(configuration: defaultListContentConfiguration())
    
    private func setupViewsIfNeeded() {
        contentView.addSubview(listContentView)
        listContentView.translatesAutoresizingMaskIntoConstraints = false
        
        let defaultHorizontalCompressionResistance = listContentView.contentCompressionResistancePriority(for: .horizontal)
        listContentView.setContentCompressionResistancePriority(defaultHorizontalCompressionResistance - 1, for: .horizontal)
        
        NSLayoutConstraint.activate([
            listContentView.topAnchor.constraint(equalTo: contentView.topAnchor),
            listContentView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            listContentView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            listContentView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            contentView.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    override func updateConfiguration(using state: UICellConfigurationState) {
        setupViewsIfNeeded()
        
        var content = defaultListContentConfiguration().updated(for: state)
        
        if let historyActionableState = state.historyActionableItem {
            setHistoryActionableCellProperties(content: &content, historyActionableState)
        } else if let historySiteState = state.historySiteItem {
            setHistorySiteCellProperties(content: &content, historySiteState)
        }
        
        listContentView.configuration = content
    }
    
    private func setHistoryActionableCellProperties(content: inout UIListContentConfiguration, _ historyActionableContent: HistoryActionables) {
        content.image = historyActionableContent.itemImage
        content.text = historyActionableContent.itemTitle
        content.textProperties.font = UIFont.systemFont(ofSize: 16, weight: .medium)
    }
    
    private func setHistorySiteCellProperties(content: inout UIListContentConfiguration, _ historySiteContent: Site) {
        content.image = historySiteContent.faviconImage
        content.imageProperties.maximumSize = CGSize(width: 32, height: 32)
        content.imageProperties.cornerRadius = 8
        content.text = historySiteContent.title
        content.textProperties.numberOfLines = 1
        content.textProperties.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        content.secondaryText = historySiteContent.url
        content.secondaryTextProperties.numberOfLines = 1
    }
    
}
