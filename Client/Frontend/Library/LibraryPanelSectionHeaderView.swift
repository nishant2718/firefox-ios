// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

// As of Dec 2021
//
// --------------------------------------
// PrimaryLabel      sectionActionButton
// --------------------------------------
//

import UIKit
import Shared

private struct LibraryPanelSectionHeaderUX {
    static let spacing: CGFloat = 8
}

class LibraryPanelSectionHeaderView: UICollectionReusableView, Themeable {
    
    // MARK: - Properties
    
    private typealias HeaderUX = LibraryPanelSectionHeaderUX
    static let reuseIdentifier = "library-panel-section-header-identifier"
    
    // UI
    let primaryLabel: UILabel = .build { label in
        label.font = DynamicFontHelper.defaultHelper.preferredBoldFont(withTextStyle: .headline, maxSize: 20)
        label.numberOfLines = 1
        label.adjustsFontSizeToFitWidth = true
    }
    lazy var sectionActionButton: UIButton = .build { [weak self] button in
        guard let self = self else { return }
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
        addSubviews(primaryLabel, sectionActionButton)
        backgroundColor = ThemeManager.shared.currentTheme.colours.controlBase
        
        NSLayoutConstraint.activate([
            primaryLabel.topAnchor.constraint(equalTo: topAnchor, constant: HeaderUX.spacing),
            primaryLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: HeaderUX.spacing * 2),
            primaryLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -HeaderUX.spacing),
            
            sectionActionButton.topAnchor.constraint(equalTo: topAnchor, constant: HeaderUX.spacing),
            sectionActionButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -HeaderUX.spacing * 2),
            sectionActionButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -HeaderUX.spacing),
            sectionActionButton.widthAnchor.constraint(equalToConstant: 50)
        ])
    }
    
}
