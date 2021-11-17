// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Foundation

extension CaseIterable where Self: Equatable {
    
    func next() -> Self {
        let allCases = Self.allCases
        let current = allCases.firstIndex(of: self)!
        let next = allCases.index(after: current)
        
        return allCases[next == allCases.endIndex ? allCases.startIndex : next]
    }
    
}
