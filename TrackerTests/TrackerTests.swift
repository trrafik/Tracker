import SnapshotTesting
import XCTest
import UIKit
@testable import Tracker

final class TrackerTests: XCTestCase {

    func testTrackersViewController_emptyState() {
        UserDefaultsService.shared.isOnboardingCompleted = true
        UserDefaultsService.shared.trackerFilter = .all

        let vc = TrackersViewController(shouldSetupStores: false)
        let nav = UINavigationController(rootViewController: vc)
        nav.loadViewIfNeeded()

        vc.categories = []
        vc.completedTrackers = []
        vc.updateFilteredCategories()
        
        assertSnapshot(
            of: nav,
            as: .image(traits: .init(userInterfaceStyle: .light)),
            named: "empty_light"
        )
        assertSnapshot(
            of: nav,
            as: .image(traits: .init(userInterfaceStyle: .dark)),
            named: "empty_dark"
        )
    }

    func testTrackersViewController_withTrackers() {
        UserDefaultsService.shared.isOnboardingCompleted = true
        UserDefaultsService.shared.trackerFilter = .all

        let vc = TrackersViewController(shouldSetupStores: false)
        let nav = UINavigationController(rootViewController: vc)
        nav.loadViewIfNeeded()

        let trackerId = UUID()
        let tracker = Tracker(
            id: trackerId,
            name: "Тестовый трекер",
            color: .systemBlue,
            emoji: "🏃",
            schedule: [] // пустое расписание — трекер показывается в любой день
        )
        vc.categories = [TrackerCategory(title: "Спорт", trackers: [tracker])]
        vc.completedTrackers = []
        vc.currentDate = Date()
        vc.updateFilteredCategories()

        assertSnapshot(
            of: nav,
            as: .image(traits: .init(userInterfaceStyle: .light)),
            named: "withTrackers_light"
        )
        assertSnapshot(
            of: nav,
            as: .image(traits: .init(userInterfaceStyle: .dark)),
            named: "withTrackers_dark"
        )
    }
}
