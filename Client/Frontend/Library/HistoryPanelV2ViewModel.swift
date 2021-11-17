// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Foundation
import Shared
import Storage

private class FetchInProgressError: MaybeErrorType {
    internal var description: String { "Fetch is already in-progress" }
}

class HistoryPanelV2ViewModel {
    
    // MARK: - Properties
    
    var profile: Profile
    var visibleSections: [HistoryPanelSection] = []
    var historyItems = DateGroupedTableData<Site>()
    var actionables = HistoryActionables.actionableItems
    
    private var ASGroupedItems: [ASGroup<Site>] = []
    var todaysHistoryGroupings: [ASGroup<Site>] = []
    var yesterdaysHistoryGroupings: [ASGroup<Site>] = []
    var lastWeeksHistoryGroupings: [ASGroup<Site>] = []
    
    private var isFetchInProgress = false
    private var currentFetchOffset = 0
    private let queryLimitPerFetch = 100
    
    enum HistoryPanelSection: Int, CaseIterable {
        case actionables, today, yesterday, lastWeek, lastMonth, older
    }
    
    // MARK: - Inits
    
    init(profile: Profile) {
        self.profile = profile
    }
    
    // MARK: - Lifecycles
    
    func viewDidLoad() {
        reloadData()
    }
    
    func viewWillAppear() {
        // placeholder
    }
    
    func viewDidAppear() {
        // Placeholder
    }
    
    func viewWillDisappear() {
        // placeholder
    }
    
    func viewDidDisappear() {
        // Placeholder
    }
    
    // MARK: - Helpers
    
    // - Datasouce
    
    private func fetchHistory() -> Deferred<Maybe<Cursor<Site>>> {
        guard !isFetchInProgress else {
            return deferMaybe(FetchInProgressError())
        }
        
        isFetchInProgress = true
        return profile.history.getSitesByLastVisit(limit: queryLimitPerFetch, offset: currentFetchOffset) >>== { result in
            // Force 100ms delay between resolution of the last batch of results
            // and the next time `fetchData()` can be called.
            print(result)
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)) {
                self.currentFetchOffset += self.queryLimitPerFetch
                self.isFetchInProgress = false
            }
            
            return deferMaybe(result)
        }
    }
    
    private func reloadData() {
        guard !profile.isShutdown, !isFetchInProgress else { return }
        
        fetchHistory().uponQueue(.global(qos: .userInteractive)) { [weak self] result in
            guard let sites = result.successValue?.asArray(), let self = self else { return }
            
            // Get all history
            for item in sites {
                guard let latestVisit = item.latestVisit else { return }
                self.historyItems.add(item, timestamp: TimeInterval.fromMicrosecondTimestamp(latestVisit.date))
            }
            
            // Get all groups out of all history within the past two weeks
            SearchTermGroupsManager.getURLGroups(with: self.profile, from: sites, using: .orderedAscending) { group, filteredItems in
                guard let group = group else { return }
                self.ASGroupedItems = group
            }
            
            // Have sections appear only when there's data to populate inside
            self.visibleSections = HistoryPanelSection.allCases.filter { section in
                self.historyItems.numberOfItemsForSection(section.rawValue) > 0
            }
        }
    }
    
}

// An extension for its public interface
extension HistoryPanelV2ViewModel {
    
    func configureHeaderView(with panel: HistoryPanelV2.HistoryPanelSections, on headerView: LibraryPanelSectionHeaderView) -> LibraryPanelSectionHeaderView {
        switch panel {
        case .actionables:
//            headerView.isHidden = true
            headerView.primaryLabel.text = "actionables"
        case .today:
            headerView.primaryLabel.text = "Today"
        case .yesterday:
            headerView.primaryLabel.text = "Yesterday"
        case .lastWeek:
            headerView.primaryLabel.text = "Last Week"
        case .lastMonth:
            headerView.primaryLabel.text = "Last Month"
        case .older:
            headerView.primaryLabel.text = "Older"
        }
        
        return headerView
    }
    
}
