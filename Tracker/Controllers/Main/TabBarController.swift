import UIKit

/// Корневой таб-бар с вкладками «Трекеры» и «Статистика».
final class TabBarController: UITabBarController {
    // MARK: - Constants

    private enum Constants {
        static let trackersTitle = NSLocalizedString("main.trackers", comment: "Trackers tab")
        static let statisticsTitle = NSLocalizedString("main.statistics", comment: "Statistics tab")

        static let trackersIcon = UIImage(systemName: "record.circle")
        static let trackersSelectedIcon = UIImage(systemName: "record.circle.fill")
        static let statisticsIcon = UIImage(systemName: "hare")
        static let statisticsSelectedIcon = UIImage(systemName: "hare.fill")
    }

    private lazy var trackersNavigationController: UINavigationController = {
        let vc = TrackersViewController()
        let nav = UINavigationController(rootViewController: vc)
        nav.tabBarItem = UITabBarItem(
            title: Constants.trackersTitle,
            image: Constants.trackersIcon,
            selectedImage: Constants.trackersSelectedIcon)
        return nav
    }()
    
    private lazy var statisticsNavigationController: UINavigationController = {
        let vc = StatisticsViewController()
        let nav = UINavigationController(rootViewController: vc)
        nav.tabBarItem = UITabBarItem(
            title: Constants.statisticsTitle,
            image: Constants.statisticsIcon,
            selectedImage: Constants.statisticsSelectedIcon
        )
        return nav
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabBar()
        viewControllers = [trackersNavigationController, statisticsNavigationController]
    }
    
    private func setupTabBar() {
        tabBar.backgroundColor = AppColors.primaryColor
        tabBar.tintColor = .systemBlue
        tabBar.unselectedItemTintColor = .systemGray
        
        // Добавляем разделительную линию сверху
        let separatorLine = UIView()
        separatorLine.backgroundColor = .separator
        separatorLine.translatesAutoresizingMaskIntoConstraints = false
        tabBar.addSubview(separatorLine)
        
        NSLayoutConstraint.activate([
            separatorLine.topAnchor.constraint(equalTo: tabBar.topAnchor),
            separatorLine.leadingAnchor.constraint(equalTo: tabBar.leadingAnchor),
            separatorLine.trailingAnchor.constraint(equalTo: tabBar.trailingAnchor),
            separatorLine.heightAnchor.constraint(equalToConstant: 0.5)
        ])
    }
}
