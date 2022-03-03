// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import UIKit
import Storage

// MARK: - UX related

@available(iOS 14, *)
private struct HistoryPanelV2UX { }

@available(iOS 14, *)
class HistoryPanelV2: UIViewController, LibraryPanel {
    
    // MARK: - Properties
    
    let profile: Profile
    let tabManager: TabManager

    var libraryPanelDelegate: LibraryPanelDelegate?
    lazy var viewModel = HistoryPanelV2ViewModel(profile: profile)
    lazy var siteImageHelper = SiteImageHelper(profile: profile)
    
    typealias HistoryPanelSections = HistoryPanelV2ViewModel.HistoryPanelSection
    
    // UI
    lazy private var diffableDatasource: UICollectionViewDiffableDataSource<HistoryPanelSections, AnyHashable>! = nil
    lazy private var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createSectionLayout())
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.delegate = self
        collectionView.backgroundColor = ThemeManager.shared.currentTheme.colours.layer2
        collectionView.accessibilityIdentifier = "History List"
        
        return collectionView
    }()
    
    // MARK: - Inits
    
    init(profile: Profile, tabManager: TabManager) {
        self.profile = profile
        self.tabManager = tabManager
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("LOG statement to indicate deinit.")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.viewDidLoad()
        setupLayout()
        configureDatasource()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        applySnapshot()
        viewModel.viewWillAppear()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        viewModel.viewDidAppear()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // A patchy solution to HistoryPanel staying in memory despite an attempt to remove.
        var snapshot = diffableDatasource.snapshot()
        snapshot.deleteSections(HistoryPanelSections.allCases)
        diffableDatasource.apply(snapshot)
        viewModel.viewWillDisappear()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        viewModel.viewDidDisappear()
    }
    
    
    // MARK: - Helpers
    
    func applyTheme() {
        // Not yet
    }
    
    private func setupLayout() {
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
    }
    
    // CollectionView Specific Helpers
    
    private func createSectionLayout() -> UICollectionViewCompositionalLayout {
        let layout = UICollectionViewCompositionalLayout() { sectionIndex, layoutEnvironment in
            var listConfiguration = UICollectionLayoutListConfiguration(appearance: .plain)
            listConfiguration.headerMode = .supplementary
            
            // Add swipe action here.
            
            let section = NSCollectionLayoutSection.list(using: listConfiguration, layoutEnvironment: layoutEnvironment)
            let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(28)),
                                                                            elementKind: LibraryPanelSectionHeaderView.reuseIdentifier,
                                                                            alignment: .topLeading)
            sectionHeader.pinToVisibleBounds = true
            section.boundarySupplementaryItems = [sectionHeader]
            
            return section
        }
        
        return layout
    }
    
    /// Handles cell registration and dequeing the appropriate cell when needed.
    private func configureDatasource() {
        
        // Header UI
        let headerViewRegistration = UICollectionView.SupplementaryRegistration<LibraryPanelSectionHeaderView>(elementKind: LibraryPanelSectionHeaderView.reuseIdentifier) { [weak self] headerView, elementKind, indexPath in
            if let section = HistoryPanelSections.init(rawValue: indexPath.section) {
                self?.viewModel.configureHeaderView(with: section, on: headerView)
                headerView.backgroundColor = UIColor.theme.tableView.selectedBackground
            }
        }
        
        // Fixed first section actionable items UI
        let fixedActionablesCellRegistration = UICollectionView.CellRegistration<LibraryPanelCustomListCell, AnyHashable> { (cell, indexPath, actionableItem) in
            if let item = actionableItem as? HistoryActionables {
                cell.updateWithItem(item)
            }
        }
        
        // History Cell UI
        let siteCellRegistration = UICollectionView.CellRegistration<LibraryPanelCustomListCell, AnyHashable> { [weak self] (cell, indexPath, historyItem) in
            if let item = historyItem as? Site {
                self?.siteImageHelper.fetchImageFor(site: item, imageType: .favicon, shouldFallback: false, completion: { image in
                    item.faviconImage = image
                    cell.updateWithItem(item)
                })
            }
        }
        
        diffableDatasource = UICollectionViewDiffableDataSource<HistoryPanelSections, AnyHashable> (collectionView: collectionView) { (collectionView, indexPath, item) -> UICollectionViewCell? in
            if let site = item as? Site {
                let siteCell = collectionView.dequeueConfiguredReusableCell(using: siteCellRegistration, for: indexPath, item: site)
                return siteCell
            }
            
            if let actionable = item as? HistoryActionables {
                let fixedActionCell = collectionView.dequeueConfiguredReusableCell(using: fixedActionablesCellRegistration, for: indexPath, item: actionable)
                return fixedActionCell
            }
            
            // Log statement saying OH NO! We're returning an empty cell?! PANIC.
            return UICollectionViewCell()
        }
        
        diffableDatasource.supplementaryViewProvider = { (collectionView, kind, indexPath) in
            let headerViewCell = collectionView.dequeueConfiguredReusableSupplementary(using: headerViewRegistration, for: indexPath)
            return headerViewCell
        }
        
    }
    
    private func applySnapshot() {
        var snapshot = diffableDatasource.snapshot()
        
        // Apply sections and their respective items to the snapshot, with an offset to account for actionables
        viewModel.visibleSections.forEach {
            if let bufferedPositionForActionables = HistoryPanelSections(rawValue: $0.rawValue)?.next() {
                snapshot.appendSections([bufferedPositionForActionables])
                snapshot.appendItems(viewModel.historyItems.itemsForSection(bufferedPositionForActionables.rawValue - 1), toSection: bufferedPositionForActionables)
            }
        }
        
        // History Actionables are always present and the first section, so...
        if let firstSection = viewModel.visibleSections.first?.next() {
            snapshot.insertSections([.actionables], beforeSection: firstSection)
            snapshot.appendItems(viewModel.actionables, toSection: .actionables)
        }
        
        diffableDatasource.apply(snapshot, animatingDifferences: true, completion: nil)
    }
    
}

@available(iOS 14, *)
extension HistoryPanelV2: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        guard let item = self.diffableDatasource.itemIdentifier(for: indexPath) else { return }
        
        if let site = item as? Site, let url = URL(string: site.url) {
            libraryPanelDelegate?.libraryPanel(didSelectURL: url, visitType: .typed)
        }
    }
}
