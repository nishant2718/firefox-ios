// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Foundation
import Shared
import Storage

@available (iOS 14, *)
private class FetchInProgressError: MaybeErrorType {
    internal var description: String { "Fetch is already in-progress" }
}

@available (iOS 14, *)
class HistoryPanelV2ViewModel {
    
    // MARK: - Properties
    
    enum HistoryPanelSection: Int, CaseIterable {
        case actionables, today, yesterday, lastWeek, lastMonth, older
    }
    
    var profile: Profile
    var visibleSections: [HistoryPanelSection] = []
    var historyItems = DateGroupedTableData<Site>()
    var actionables = HistoryActionables.activeActionables
    
    private var isFetchInProgress = false
    private var currentFetchOffset = 0
    private let queryLimitPerFetch = 100
    
    private var ASGroupedItems: [ASGroup<Site>] = []
    var todaysHistoryGroupings: [ASGroup<Site>] = []
    var yesterdaysHistoryGroupings: [ASGroup<Site>] = []
    var lastWeeksHistoryGroupings: [ASGroup<Site>] = []
    
    // MARK: - Inits
    
    init(profile: Profile) {
        self.profile = profile
    }
    
    
    // MARK: - Lifecycles
    
    func viewDidLoad() {
        reloadData()
    }
    
    func viewWillAppear() {
        
    }
    
    func viewDidAppear() {
        
    }
    
    func viewWillDisappear() {
        
    }
    
    func viewDidDisappear() {
        
    }
    
    // MARK: - Helpers
    
    // Fetching history from local storage - that needs to be updated.
    
    private func fetchData() -> Deferred<Maybe<Cursor<Site>>> {
        guard !isFetchInProgress else {
            return deferMaybe(FetchInProgressError())
        }
        
        isFetchInProgress = true
        
        return profile.history.getSitesByLastVisit(limit: queryLimitPerFetch, offset: currentFetchOffset) >>== { result in
            // Force 100ms delay between resolution of the last batch of results
            // and the next time `fetchData()` can be called.
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)) {
                self.currentFetchOffset += self.queryLimitPerFetch
                self.isFetchInProgress = false
            }
            
            return deferMaybe(result)
        }
    }
    
    private func reloadData() {
        fetchData().uponQueue(.main) { [weak self] result in
            guard let self = self else { return }
            
            // Get all history
            if let sites = result.successValue {
                let fetchedSites = sites.asArray()
                let allCurrentGroupedSites = self.historyItems.allItems()
                let allUniquedSitesToAdd = (allCurrentGroupedSites + fetchedSites).uniqued().filter {
                    !allCurrentGroupedSites.contains($0)
                }
                
                allUniquedSitesToAdd.forEach { site in
                    if let latestVisit = site.latestVisit {
                        self.historyItems.add(site, timestamp: TimeInterval.fromMicrosecondTimestamp(latestVisit.date))
                    }
                }
                
                //                self.tableView.reloadData()
                //                self.updateEmptyPanelState()
                // Make groups from the past two weeks of history
                SearchTermGroupsManager.getSiteGroups(with: self.profile, from: self.historyItems.allItems() , using: .orderedAscending) { grouping, filteredItems in
                    guard let searchTermGrouping = grouping else { return }
                    self.ASGroupedItems = searchTermGrouping
                }
                
                // Make sure datasource contains ONLY sections with history data
                self.visibleSections = HistoryPanelSection.allCases.filter { section in
                    self.historyItems.numberOfItemsForSection(section.rawValue) > 0
                }
                
            }
        }
        
    }
    
    // TODO: Fill this out!
    private func updateEmptyPanelState() {
        
    }
    
}

// An extension for its public interface
@available (iOS 14, *)
extension HistoryPanelV2ViewModel {
    
    func configureHeaderView(with panel: HistoryPanelV2.HistoryPanelSections, on headerView: LibraryPanelSectionHeaderView) {
        switch panel {
        case .actionables:
            headerView.sectionTitleLabel.text = "History Options"
            headerView.sectionActionButton.isHidden = true
        case .today:
            headerView.sectionTitleLabel.text = "Today"
        case .yesterday:
            headerView.sectionTitleLabel.text = "Yesterday"
        case.lastWeek:
            headerView.sectionTitleLabel.text = "Last Week"
        case .lastMonth:
            headerView.sectionTitleLabel.text = "Last Month"
        case .older:
            headerView.sectionTitleLabel.text = "Older"
        }
        
    }
    
}
