// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Foundation

/**
 The history panel has a fixed first section and cells. In this case, we'll only need some properties of that to serve as our model.
 */

@available (iOS 14, *)
struct HistoryActionables {
    
    // MARK: - Properties
    
    let itemImage: UIImage?
    let itemTitle: String
    let identifier = UUID()
    
    init(imageName: String?, title: String) {
        self.itemTitle = title
        
        if let imageName = imageName {
            self.itemImage = UIImage(named: imageName)?.withTintColor(ThemeManager.shared.currentTheme.colours.iconSecondary)
        } else {
            self.itemImage = nil
        }
    }
    
    // As this section evolves (or we experiment with it), we may need to replace items within. Let's keep separate stashes of ALL and ACTIVE items.
    static let allActionables = [
        HistoryActionables(imageName: "forget", title: "Clear Recent History"),
        HistoryActionables(imageName: "recently_closed", title: "Recently Closed"),
        HistoryActionables(imageName: "synced_devices", title: "Synced History")
    ]
    
    static let activeActionables = [
        HistoryActionables(imageName: "forget", title: "Clear Recent History"),
        HistoryActionables(imageName: "recently_closed", title: "Recently Closed Tabs")
    ]
    
}

@available (iOS 14, *)
extension HistoryActionables: Hashable { }
