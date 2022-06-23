// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Foundation
import os.log
import Dip

/// This is our concrete dependency container. It holds all dependencies / services the app would need through
/// a session.
struct AppContainer: ServiceProvider {
    var container: DependencyContainer?

    init() {
        container = bootstrapContainer()
    }

    func resolve(type: Any.Type) -> Any? {
        do {
            return try container?.resolve(type.self)
        } catch {
            /// If a service we've expected to be registered can't be resolved, this is likely an issue within
            /// bootstrapping. Double check your registrations and their types.
            os_log(.error, "Could not resolve the requested type!")

            /// We've made bad assumptions, and there's something very wrong with container setup! This is fatal.
            fatalError("\(error)")
        }
    }

    // MARK: - Misc helpers

    /// Prepares the container by registering all services for the app session.
    /// - Returns: A bootstrapped `DependencyContainer`.
    private func bootstrapContainer() -> DependencyContainer {
        return DependencyContainer { container in
            do {
                unowned let container = container

                container.register(.eagerSingleton) {
                    BrowserProfile(localName: "profile",
                                   syncDelegate: UIApplication.shared.syncDelegate) as Profile
                }

                

                try container.bootstrap()
            } catch {
                os_log(.error, "We couldn't resolve something inside the container!")

                /// If resolution of one item fails, the entire object graph won't be resolved. This is a fatal error.
                fatalError("\(error)")
            }
        }
    }

}
