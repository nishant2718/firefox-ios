// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import UIKit
import Storage

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    // MARK: - Properties

    var window: UIWindow?

    var profile: Profile
    var imageStore: DiskImageStore
    var tabManager: TabManager

    // MARK: - Scene Connections / Disconnections

    override init() {
        /// A stand-in solution before proper dependency management - `SoHo`.
        self.profile = BrowserProfile(localName: "profile", syncDelegate: AppSyncDelegate(app: UIApplication.shared))
        self.imageStore = DiskImageStore(files: profile.files, namespace: "TabManagerScreenshots", quality: UIConstants.ScreenshotQuality)
        self.tabManager = TabManager(profile: profile, imageStore: imageStore)

        super.init()
    }

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        /// Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        /// If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        /// This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).

        guard let windowScene = scene as? UIWindowScene else { return }

        /// Each scene of our app should handle its own BVC.
        let browserVC = prepareBrowserViewController(with: session)

        /// Each unique BVC should live inside its own navigation controller.
        let navigationController = prepareNavigationController(with: browserVC)

        /// Each scene should have its own window and rootVC configured.
        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = navigationController

        /// Add observations on window
        setupWindowObservers(on: window)

        /// This should be the last step. Your window should have a rootVC by this point that's configured properly.
        self.window = window
        window.makeKeyAndVisible()
    }

    /// We prepare all aspects of BVC for each Scene here - all things needed before providing a scene to a window.
    private func prepareBrowserViewController(with session: UISceneSession) -> BrowserViewController {
        let browserViewController = BrowserViewController(profile: profile, tabManager: tabManager, scene: session)
        browserViewController.edgesForExtendedLayout = []
        browserViewController.restorationIdentifier = NSStringFromClass(BrowserViewController.self)
        browserViewController.restorationClass = SceneDelegate.self as? UIViewControllerRestoration.Type

        return browserViewController
    }

    private func prepareNavigationController(with browser: BrowserViewController) -> UINavigationController  {
        let navigationController = UINavigationController(rootViewController: browser)
        navigationController.isNavigationBarHidden = true
        navigationController.edgesForExtendedLayout = UIRectEdge(rawValue: 0)
        navigationController.delegate = self

        return navigationController
    }

    private func setupWindowObservers(on window: UIWindow) {
        NotificationCenter.default.addObserver(forName: .DisplayThemeChanged, object: nil, queue: .main) { (notification) -> Void in
            if !LegacyThemeManager.instance.systemThemeIsOn {
                window.overrideUserInterfaceStyle = LegacyThemeManager.instance.userInterfaceStyle
            } else {
                window.overrideUserInterfaceStyle = .unspecified
            }
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        /// Called as the scene is being released by the system.
        /// This occurs shortly after the scene enters the background, or when its session is discarded.
        /// Release any resources associated with this scene that can be re-created the next time the scene connects.
        /// The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).

        print("SceneDelegate --> sceneDidDisconnect")
    }

    // MARK: - Scene Foregrounding

    func sceneWillEnterForeground(_ scene: UIScene) {
        /// Called as the scene transitions from the background to the foreground.
        /// Use this method to undo the changes made on entering the background.

        print("SceneDelegate --> sceneWillEnterForeground")
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        /// Called when the scene has moved from an inactive state to an active state.
        /// Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.

        print("SceneDelegate --> sceneDidBecomeActive")
    }

    // MARK: - Scene Backgrounding

    func sceneWillResignActive(_ scene: UIScene) {
        /// Called when the scene will move from an active state to an inactive state.
        /// This may occur due to temporary interruptions (ex. an incoming phone call).

        print("SceneDelegate --> sceneWillResignActive")
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        /// Called as the scene transitions from the foreground to the background.
        /// Use this method to save data, release shared resources, and store enough scene-specific state information
        /// to restore the scene back to its current state.

        print("sceneDelegate --> sceneDidEnterBackground")
    }

    // MARK: - User Activity Continuations

    func scene(_ scene: UIScene, willContinueUserActivityWithType userActivityType: String) {
        // Placeholder
    }

    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        // Placeholder
    }

    func scene(_ scene: UIScene, didFailToContinueUserActivityWithType userActivityType: String, error: Error) {
        // Placeholder
    }

    // MARK: - Saving Scene State

    func stateRestorationActivity(for scene: UIScene) -> NSUserActivity? {
        // Placeholder

        return nil
    }

    func scene(_ scene: UIScene, didUpdate userActivity: NSUserActivity) {
        // Placeholder
    }

    // MARK: - Opening URLs

    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        // Placeholder
    }

}

extension SceneDelegate: UINavigationControllerDelegate {

    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        switch operation {
        case .push:
            return BrowserToTrayAnimator()
        case .pop:
            return TrayToBrowserAnimator()
        default:
            return nil
        }
    }

}

/// This extension handles resolving all dependencies the `SceneDelegate` needs.
extension SceneDelegate {

    fileprivate func resolveDependencies() {
        getProfile()
        getDiskImageStore()
        getTabManager()
    }

    private func getProfile() {
        self.profile = BrowserProfile(localName: "profile", syncDelegate: AppSyncDelegate(app: UIApplication.shared))
    }

    private func getDiskImageStore() {
        self.imageStore = DiskImageStore(files: profile.files, namespace: "TabManagerScreenshots", quality: UIConstants.ScreenshotQuality)
    }

    private func getTabManager() {
        self.tabManager = TabManager(profile: profile, imageStore: imageStore)
    }

}
