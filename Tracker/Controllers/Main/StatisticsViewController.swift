import UIKit

/// Экран статистики по выполнению трекеров.
final class StatisticsViewController: UIViewController {

    private let recordStore = TrackerRecordStore()
    private let trackerStore = TrackerStore()
    private var recordsObserver: NSObjectProtocol?

    private let scrollView: UIScrollView = {
        let v = UIScrollView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.showsVerticalScrollIndicator = false
        return v
    }()

    private let stackView: UIStackView = {
        let v = UIStackView()
        v.axis = .vertical
        v.spacing = 12
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let emptyImageView: UIImageView = {
        let v = UIImageView()
        v.image = UIImage(resource: .statisticError)
        v.contentMode = .scaleAspectFit
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let emptyLabel: UILabel = {
        let l = UILabel()
        l.text = NSLocalizedString("stat.empty", comment: "Statistics empty state")
        l.font = .systemFont(ofSize: 12, weight: .medium)
        l.textColor = AppColors.primaryInvertedColor
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private enum StatItem {
        case bestPeriod, idealDays, completed, average
        var title: String {
            switch self {
            case .bestPeriod: return NSLocalizedString("stat.bestPeriod", comment: "")
            case .idealDays: return NSLocalizedString("stat.idealDays", comment: "")
            case .completed: return NSLocalizedString("stat.completed", comment: "")
            case .average: return NSLocalizedString("stat.average", comment: "")
            }
        }
    }

    deinit {
        recordsObserver.map { NotificationCenter.default.removeObserver($0) }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppColors.primaryColor
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        navigationItem.title = NSLocalizedString("main.statistics", comment: "Statistics title")

        recordsObserver = NotificationCenter.default.addObserver(
            forName: .trackerRecordsDidChange,
            object: nil,
            queue: .main
        ) { [weak self] _ in self?.updateStatistics() }

        view.addSubview(scrollView)
        scrollView.addSubview(stackView)
        view.addSubview(emptyImageView)
        view.addSubview(emptyLabel)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            stackView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 24),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            emptyImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -20),
            emptyImageView.widthAnchor.constraint(equalToConstant: 80),
            emptyImageView.heightAnchor.constraint(equalToConstant: 80),
            emptyLabel.topAnchor.constraint(equalTo: emptyImageView.bottomAnchor, constant: 8),
            emptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateStatistics()
    }

    private func updateStatistics() {
        guard let records = try? recordStore.allRecords() else {
            showEmpty()
            return
        }
        if records.isEmpty {
            showEmpty()
            return
        }

        emptyImageView.isHidden = true
        emptyLabel.isHidden = true
        stackView.isHidden = false

        try? trackerStore.performFetch()
        let trackers = trackerStore.categoriesFromFetchedResults().flatMap { $0.trackers }
        let result = TrackerStatistics.compute(records: records, trackers: trackers)

        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for (item, value) in [
            (StatItem.bestPeriod, result.bestPeriod),
            (StatItem.idealDays, result.idealDays),
            (StatItem.completed, result.completed),
            (StatItem.average, result.average)
        ] {
            stackView.addArrangedSubview(StatCardView(value: "\(value)", title: item.title))
        }
    }

    private func showEmpty() {
        emptyImageView.isHidden = false
        emptyLabel.isHidden = false
        stackView.isHidden = true
    }
}
