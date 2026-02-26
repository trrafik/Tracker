import UIKit

/// Онбординг: UIPageViewController со стилем scroll, страницы — OnboardingPageViewController.
final class OnboardingViewController: UIPageViewController {

    // MARK: - Pages content

    private let pagesContent: [OnboardingPageViewController.PageContent] = [
        .init(
            title: "Отслеживайте только то, что хотите",
            backgroundImage: .onBoardingPage1
        ),
        .init(
            title: "Даже если это не литры воды и йога",
            backgroundImage: .onBoardingPage2
        )
    ]

    private lazy var pageViewControllers: [OnboardingPageViewController] = {
        pagesContent.map { content in
            let vc = OnboardingPageViewController()
            vc.configure(with: content)
            vc.onActionButtonTap = { [weak self] in
                self?.completeOnboarding()
            }
            return vc
        }
    }()

    private lazy var pageControl: UIPageControl = {
        let pc = UIPageControl()
        pc.numberOfPages = pageViewControllers.count
        pc.currentPage = 0
        pc.currentPageIndicatorTintColor = .black
        pc.pageIndicatorTintColor = .black.withAlphaComponent(0.3)
        pc.isUserInteractionEnabled = false
        pc.translatesAutoresizingMaskIntoConstraints = false
        return pc
    }()

    // MARK: - Init

    override init(
        transitionStyle style: UIPageViewController.TransitionStyle,
        navigationOrientation: UIPageViewController.NavigationOrientation,
        options: [UIPageViewController.OptionsKey: Any]? = nil
    ) {
        super.init(
            transitionStyle: .scroll,
            navigationOrientation: .horizontal,
            options: [.interPageSpacing: 0]
        )
    }

    convenience init() {
        self.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: [.interPageSpacing: 0])
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = self
        delegate = self

        if let first = pageViewControllers.first {
            setViewControllers([first], direction: .forward, animated: false)
        }

        view.addSubview(pageControl)
        NSLayoutConstraint.activate([
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pageControl.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -134)
        ])
    }

    // MARK: - Helpers

    private func completeOnboarding() {
        UserDefaultsService.shared.isOnboardingCompleted = true
        showMainInterface()
    }

    private func showMainInterface() {
        guard let window = view.window else { return }
        window.rootViewController = TabBarController()
        UIView.transition(
            with: window,
            duration: 0.3,
            options: .transitionCrossDissolve,
            animations: nil
        )
    }
}

// MARK: - UIPageViewControllerDataSource

extension OnboardingViewController: UIPageViewControllerDataSource {

    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerBefore viewController: UIViewController
    ) -> UIViewController? {
        guard let vc = viewController as? OnboardingPageViewController,
              let index = pageViewControllers.firstIndex(of: vc),
              index > 0 else { return nil }
        return pageViewControllers[index - 1]
    }

    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerAfter viewController: UIViewController
    ) -> UIViewController? {
        guard let vc = viewController as? OnboardingPageViewController,
              let index = pageViewControllers.firstIndex(of: vc),
              index < pageViewControllers.count - 1 else { return nil }
        return pageViewControllers[index + 1]
    }
}

// MARK: - UIPageViewControllerDelegate

extension OnboardingViewController: UIPageViewControllerDelegate {

    func pageViewController(
        _ pageViewController: UIPageViewController,
        didFinishAnimating finished: Bool,
        previousViewControllers: [UIViewController],
        transitionCompleted completed: Bool
    ) {
        guard completed,
              let current = pageViewController.viewControllers?.first as? OnboardingPageViewController,
              let index = pageViewControllers.firstIndex(of: current) else { return }
        pageControl.currentPage = index
    }
}
