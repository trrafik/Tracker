import SnapshotTesting
import XCTest
import UIKit
@testable import Tracker

final class TrackersViewControllerSnapshotTests: XCTestCase {
    
    // MARK: - Setup
    
    override func setUp() {
        super.setUp()
        UserDefaultsService.shared.isOnboardingCompleted = true
        UserDefaultsService.shared.trackerFilter = .all
    }
    
    // MARK: - Tests
    
    func test_emptyState_rendersCorrectly() {
        let vc = makeSUT()
        
        vc.categories = []
        vc.completedTrackers = []
        vc.updateFilteredCategories()
        
        assertSnapshots(of: vc, named: "emptyState")
    }
    
    func test_withTrackers_rendersCorrectly() {
        let vc = makeSUT()
        
        let tracker = makeTracker(name: "Тестовый трекер")
        
        vc.categories = [
            TrackerCategory(title: "Спорт", trackers: [tracker])
        ]
        
        vc.completedTrackers = []
        vc.currentDate = Date()
        vc.updateFilteredCategories()
        
        assertSnapshots(of: vc, named: "withTrackers")
    }
}

// MARK: - Helpers

private extension TrackersViewControllerSnapshotTests {
    
    func makeSUT() -> TrackersViewController {
        let vc = TrackersViewController(shouldSetupStores: false)
        let nav = UINavigationController(rootViewController: vc)
        nav.loadViewIfNeeded()
        return vc
    }
    
    func makeTracker(name: String) -> Tracker {
        Tracker(
            id: UUID(),
            name: name,
            color: .systemBlue,
            emoji: "🏃",
            schedule: []
        )
    }
    
    func assertSnapshots(of vc: TrackersViewController, named prefix: String) {
        guard let nav = vc.navigationController else { return }
        
        assertSnapshot(
            of: nav,
            as: .image(traits: .init(userInterfaceStyle: .light)),
            named: "\(prefix)-light"
        )
        
        assertSnapshot(
            of: nav,
            as: .image(traits: .init(userInterfaceStyle: .dark)),
            named: "\(prefix)-dark"
        )
    }
}
