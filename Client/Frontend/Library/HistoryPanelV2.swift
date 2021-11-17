// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import UIKit
import Storage

private struct HistoryPanelUXV2 {
    
}

class HistoryPanelV2: UIViewController, LibraryPanel {
    
    // MARK: - Properties
    
    var libraryPanelDelegate: LibraryPanelDelegate?
    lazy var siteImageHelper = SiteImageHelper(profile: profile)
    lazy var viewModel = HistoryPanelV2ViewModel(profile: profile)
    
    let profile: Profile
    
    typealias HistoryPanelSections = HistoryPanelV2ViewModel.HistoryPanelSection
    
    // UI
    lazy private var diffableDatasource: UICollectionViewDiffableDataSource<HistoryPanelSections, AnyHashable>! = nil
    lazy private var collectionView: UICollectionView = {
        var collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        collectionView.delegate = self
        collectionView.backgroundColor = ThemeManager.shared.currentTheme.colours.layer2
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(LibraryPanelListCell.self, forCellWithReuseIdentifier: LibraryPanelListCell.reuseIdentifier)
        collectionView.register(LibraryPanelListSubtitleCell.self, forCellWithReuseIdentifier: LibraryPanelListSubtitleCell.reuseIdentifier)
        collectionView.register(LibraryPanelSectionHeaderView.self,
                                forSupplementaryViewOfKind: LibraryPanelSectionHeaderView.reuseIdentifier,
                                withReuseIdentifier: LibraryPanelSectionHeaderView.reuseIdentifier)
        return collectionView
    }()
    
    // MARK: - Inits
    
    init(profile: Profile) {
        self.profile = profile
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        viewModel.viewDidLoad()
        setupLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        viewModel.viewWillAppear()
        configureDataSource()
        applySnapshot()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        viewModel.viewDidAppear()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        viewModel.viewWillDisappear()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        viewModel.viewDidDisappear()
    }
    
    
    // MARK: - Helpers
    
    private func createLayout() -> UICollectionViewLayout {
        let sectionProvider = { (sectionClassifier: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            guard let sectionNumber = HistoryPanelSections(rawValue: sectionClassifier) else { return nil }
            let section: NSCollectionLayoutSection
            
            switch sectionNumber {
            default:
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                item.contentInsets = NSDirectionalEdgeInsets(top: 4, leading: 0, bottom: 4, trailing: 0)
                
                var groupSize: NSCollectionLayoutSize
                if UIWindow.isPortrait {
                    groupSize =  NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(0.1))
                } else {
                    groupSize =  NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(0.2))
                }
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                
                section = NSCollectionLayoutSection(group: group)
                let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(36)),
                                                                                elementKind: LibraryPanelSectionHeaderView.reuseIdentifier,
                                                                                alignment: .topLeading)
                sectionHeader.pinToVisibleBounds = true
                section.boundarySupplementaryItems = [sectionHeader]
            }
            
            return section
        }
        
        return UICollectionViewCompositionalLayout(sectionProvider: sectionProvider)
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
    
    private func configureDataSource() {
        diffableDatasource = UICollectionViewDiffableDataSource<HistoryPanelSections, AnyHashable>(collectionView: collectionView) { [weak self] (collectionView, indexPath, item) -> UICollectionViewCell? in
            if let site = item as? Site {
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LibraryPanelListSubtitleCell.reuseIdentifier, for: indexPath) as? LibraryPanelListSubtitleCell else {
                    fatalError("Cannot create new LibraryPanelListSubtitleCell!")
                }
                
                cell.primaryLabel.text = site.title
                cell.secondaryLabel.text = site.url
                self?.siteImageHelper.fetchImageFor(site: site, imageType: .favicon, shouldFallback: false, completion: { image in
                    cell.faviconImageView.image = image
                })
                
                return cell
            }
            
            if let actionable = item as? HistoryActionables {
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LibraryPanelListCell.reuseIdentifier, for: indexPath) as? LibraryPanelListCell else {
                    fatalError("Cannot create a new LibraryPanelListCell!")
                }
                
                cell.primaryLabel.text = actionable.primaryLabel
                cell.imageView.image = actionable.actionImage
                
                return cell
            }
            
            return nil
        }
        
        // Header UI
        diffableDatasource.supplementaryViewProvider = { [weak self] (collectionView: UICollectionView, kind: String, indexPath: IndexPath) -> LibraryPanelSectionHeaderView? in
            guard let self = self else { return nil }
            
            guard let panelSection = HistoryPanelSections(rawValue: indexPath.section) else {
                fatalError("Unknown section encountered - this should never happen!")
            }
            
            if let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: LibraryPanelSectionHeaderView.reuseIdentifier, for: indexPath) as? LibraryPanelSectionHeaderView {
                return self.viewModel.configureHeaderView(with: panelSection, on: header)
            }
            
            return nil
        }
        
    }
    
    private func applySnapshot() {
        var snapshot = diffableDatasource.snapshot()
        
        // Apply sections and their respective items to the snapshot, with an offset to account for actionables
        viewModel.visibleSections.forEach {
            if let bufferedSection = HistoryPanelSections(rawValue: $0.rawValue)?.next() {
                snapshot.appendSections([bufferedSection])
                snapshot.appendItems(viewModel.historyItems.itemsForSection(bufferedSection.rawValue - 1), toSection:  bufferedSection)
            }
        }
        
        // Actionables are always the first section and present, so...
        if let firstSection = viewModel.visibleSections.first?.next() {
            snapshot.insertSections([.actionables], beforeSection: firstSection)
            snapshot.appendItems(viewModel.actionables, toSection: .actionables)
        }
        
        diffableDatasource.apply(snapshot, animatingDifferences: true, completion: nil)
    }
    
    func applyTheme() { /* not yet*/ }
    
}

extension HistoryPanelV2: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        guard let item = self.diffableDatasource.itemIdentifier(for: indexPath) else { return }
        
        if let site = item as? Site, let url = URL(string: site.url) {
            libraryPanelDelegate?.libraryPanel(didSelectURL: url, visitType: .typed)
        }
    }
    
}
