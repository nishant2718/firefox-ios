// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

// As of Dec 2021
//  _____
// |     | PrimaryText
// | img |
// |_____| SecondaryText (subtitle formatting, tail truncating ...)
// __________________________________________________________________ divider
//

import UIKit

class LibraryPanelListSubtitleCell: UICollectionViewCell {
    
    // MARK: - Properties
    static let reuseIdentifier = "library-panel-list-subtitle-cell"
    
    // UI
    let faviconImageView: UIImageView = .build { imageView in }
    let primaryLabel: UILabel = .build { label in }
    let secondaryLabel: UILabel = .build { label in
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
        contentView.addSubviews(primaryLabel, secondaryLabel, faviconImageView, divider)
        
        NSLayoutConstraint.activate([
            faviconImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            faviconImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            faviconImageView.heightAnchor.constraint(equalToConstant: 24),
            faviconImageView.widthAnchor.constraint(equalToConstant: 24),
            
            primaryLabel.topAnchor.constraint(equalTo: topAnchor, constant: 4),
            primaryLabel.leadingAnchor.constraint(equalTo: faviconImageView.trailingAnchor, constant: 8),
            primaryLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            secondaryLabel.topAnchor.constraint(equalTo: primaryLabel.bottomAnchor),
            secondaryLabel.leadingAnchor.constraint(equalTo: primaryLabel.leadingAnchor),
            secondaryLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
            secondaryLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -4),
            
            divider.topAnchor.constraint(equalTo: secondaryLabel.bottomAnchor, constant: 8),
            divider.leadingAnchor.constraint(equalTo: faviconImageView.trailingAnchor, constant: 8),
            divider.trailingAnchor.constraint(equalTo: trailingAnchor),
            divider.heightAnchor.constraint(equalToConstant: 1)
        ])
    }
    
}
