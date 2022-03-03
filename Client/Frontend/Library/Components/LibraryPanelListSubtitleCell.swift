// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

//  _____
// |     | title text
// | img |
// |_____| detail text (subtitle formatting, tail truncating ...)
// __________________________________________________________________ divider
//

// DEPRECATE in favor of GeneralizedListCell

import UIKit
import SwiftUI

@available (iOS 14, *)
class LibraryPanelListSubtitleCell: UICollectionViewListCell {
    
    // MARK: - Properties
    
    static let reuseIdentifier = "library-panel-list-cell"
    
    private func defaultListContentConfiguration() -> UIListContentConfiguration { return .subtitleCell() }
    private lazy var listContentView = UIListContentView(configuration: defaultListContentConfiguration())
    
    // UI
    let iconImageView: UIImageView = .build { imageView in }
    let itemTitleLabel: UILabel = .build { label in }
    let itemDetailLabel: UILabel = .build { label in
        label.font = DynamicFontHelper.defaultHelper.preferredBoldFont(withTextStyle: .footnote, maxSize: 14)
        label.textColor = ThemeManager.shared.currentTheme.colours.textSecondary
    }
    let divider: UIView = .build { divider in
        divider.backgroundColor = ThemeManager.shared.currentTheme.colours.borderDivider
    }
    
    // MARK: - Inits
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Helpers
    
    private func setupLayout() {
        contentView.addSubviews(itemTitleLabel, itemDetailLabel, iconImageView, divider)
        
        NSLayoutConstraint.activate([
            iconImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            iconImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            iconImageView.heightAnchor.constraint(equalToConstant: 24),
            iconImageView.widthAnchor.constraint(equalToConstant: 24),
            
            itemTitleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 4),
            itemTitleLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 8),
            itemTitleLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            itemDetailLabel.topAnchor.constraint(equalTo: itemTitleLabel.bottomAnchor),
            itemDetailLabel.leadingAnchor.constraint(equalTo: itemTitleLabel.leadingAnchor),
            itemDetailLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
            itemDetailLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -4),
            
            divider.topAnchor.constraint(equalTo: itemDetailLabel.bottomAnchor, constant: 8),
            divider.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 8),
            divider.trailingAnchor.constraint(equalTo: trailingAnchor),
            divider.heightAnchor.constraint(equalToConstant: 1)
        ])
    }
    
//    private func setupLayout2() {
//        // add divider later
//        contentView.addSubview(listContentView)
//        listContentView.translatesAutoresizingMaskIntoConstraints = false
//        
//        NSLayoutConstraint.activate([
//            listContentView.topAnchor.constraint(equalTo: contentView.topAnchor),
//            listContentView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
//            listContentView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
//            listContentView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
//
//            // add divider later
//        ])
//    }
////
////    override func updateConfiguration(using state: UICellConfigurationState) {
////        setupViewsIfNeeded()
////
////        var content = defaultListContentConfiguration().updated(for: state)
////
////        if let categoryState = state.categoryItem {
////            setCategoryCellProperties(content: &content, categoryContent: categoryState)
////        } else if let settingState = state.settingItem {
////            setSettingCellProperties(&content, settingState)
////        }
////
////        content.imageProperties.preferredSymbolConfiguration = .init(font: content.textProperties.font, scale: .large)
////        content.imageProperties.tintColor = UIColor.brandPurple
////        content.secondaryTextProperties.font = UIFont.systemFont(ofSize: 12)
////        content.axesPreservingSuperviewLayoutMargins = []
////
////        listContentView.configuration = content
////    }
//
//    override func updateConfiguration(using state: UICellConfigurationState) {
//        setupLayout()
//
//        var content = defaultListContentConfiguration().updated(for: state)
//
//        if let
//    }
    
    
}
