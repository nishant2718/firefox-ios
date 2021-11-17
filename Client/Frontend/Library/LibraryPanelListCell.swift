// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

// As of Dec 2021
//  _____
// |     |
// | img |  PrimaryText
// |_____|
// ____________________________________________________ divider
//

import UIKit
import SwiftUI

class LibraryPanelListCell: UICollectionViewCell {
    
    // MARK: - Properties
    
    static let reuseIdentifier = "library-panel-list-cell"
    
    // UI
    let imageView: UIImageView = .build { imageView in }
    let primaryLabel: UILabel = .build { label in }
    let divider: UIView = .build { divider in
        divider.backgroundColor = ThemeManager.shared.currentTheme.colours.borderDivider
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayout() {
        contentView.addSubviews(imageView, primaryLabel, divider)
        
        NSLayoutConstraint.activate([
            imageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            imageView.heightAnchor.constraint(equalToConstant: 24),
            imageView.widthAnchor.constraint(equalToConstant: 24),
            
            primaryLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            primaryLabel.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 8),
            primaryLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -4),
            
            divider.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8),
            divider.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 12),
            divider.trailingAnchor.constraint(equalTo: trailingAnchor),
            divider.heightAnchor.constraint(equalToConstant: 1),
        ])
    }
    
}
