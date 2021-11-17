// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Foundation

/**
    History has fixed actionables in its first section (which is always present). In that case, we only need some properties of that to serve
    as a model.
 */
struct HistoryActionables {
    
    // MARK: - Properties
    
    let actionImage: UIImage?
    let primaryLabel: String
    let identifier = UUID()
    
    init(imageName: String?, primaryLabel: String) {
        self.primaryLabel = primaryLabel
        
        if let imageName = imageName {
            self.actionImage = UIImage(named: imageName)?.withTintColor(ThemeManager.shared.currentTheme.colours.iconSecondary)
        } else {
            self.actionImage = nil
        }
    }
    
    static let actionableItems = [
        HistoryActionables(imageName: "forget", primaryLabel: "Clear Recent History"),
        HistoryActionables(imageName: "recently_closed", primaryLabel: "Recently Closed")
    ]
    
}

extension HistoryActionables: Hashable {
    
}
