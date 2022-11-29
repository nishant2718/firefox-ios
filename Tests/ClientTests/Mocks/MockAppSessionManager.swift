// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Foundation
@testable import Client

class MockAppSessionManager: Client.AppSessionProvider {

    var inactiveTabsSessionProvider: InactiveTabsSessionProviderProtocol
    var launchSessionProvider: LaunchSessionProviderProtocol

    init(
        inactiveTabsSessionProvider: InactiveTabsSessionProviderProtocol = MockInactiveTabsSessionProvider(),
        launchSessionProvider: LaunchSessionProviderProtocol = MockLaunchSessionProvider()
    ) {
        self.inactiveTabsSessionProvider = inactiveTabsSessionProvider
        self.launchSessionProvider = launchSessionProvider
    }
}
