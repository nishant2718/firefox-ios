// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

//
// --------------------------------------
// PrimaryLabel      sectionActionButton
// --------------------------------------
//

import UIKit

@available (iOS 14, *)
private struct LibraryPanelSectionHeaderUX {
    // General
    static let spacing: CGFloat = 8
    
    // Action Button
    static let actionButtonWidth: CGFloat = 50
}

@available (iOS 14, *)
class LibraryPanelSectionHeaderView: UICollectionReusableView, Themeable {
    
    // MARK: - Properties
    
    private typealias HeaderUX = LibraryPanelSectionHeaderUX
    static let reuseIdentifier = "library-panel-section-header-identifer"
    
    // UI
    
    let sectionTitleLabel: UILabel = .build { label in
        label.font = DynamicFontHelper.defaultHelper.preferredBoldFont(withTextStyle: .headline, maxSize: 20)
        label.numberOfLines = 1
        label.adjustsFontSizeToFitWidth = true
    }
    
    lazy var sectionActionButton: UIButton = .build { button in
        button.setTitle("Show All", for: .normal)
        button.titleLabel?.font = DynamicFontHelper.defaultHelper.preferredFont(withTextStyle: .callout, maxSize: 16)
        button.setTitleColor(self.themeSystem.currentTheme.colours.actionPrimary, for: .normal)
        button.titleLabel?.adjustsFontSizeToFitWidth = true
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
        
//        backgroundView?.backgroundColor = UIColor.theme.tableView.selectedBackground
        backgroundColor =  UIColor.theme.tableView.selectedBackground
        addSubviews(sectionTitleLabel, sectionActionButton)
        
        NSLayoutConstraint.activate([
            sectionTitleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 0),
            sectionTitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: HeaderUX.spacing * 2),
            
            sectionActionButton.topAnchor.constraint(equalTo: sectionTitleLabel.topAnchor),
            sectionActionButton.bottomAnchor.constraint(equalTo: sectionTitleLabel.bottomAnchor),
            sectionActionButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -HeaderUX.spacing * 2),
        ])
    }
    
}
