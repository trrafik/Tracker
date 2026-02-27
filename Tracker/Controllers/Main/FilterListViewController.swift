import UIKit

protocol FilterListViewControllerDelegate: AnyObject {
    func filterListViewController(_ controller: FilterListViewController, didSelectFilter filter: TrackerFilter)
}
/// Экран выбора фильтра списка трекеров.
final class FilterListViewController: UIViewController {

    weak var delegate: FilterListViewControllerDelegate?

    /// Текущий выбранный фильтр (для отображения галочки).
    var currentFilter: TrackerFilter = UserDefaultsService.shared.trackerFilter

    private let tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .insetGrouped)
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.backgroundColor = AppColors.primaryColor
        tv.rowHeight = 75
        return tv
    }()

    private let cellReuseId = "FilterCell"

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppColors.primaryColor
        title = NSLocalizedString("main.filters", comment: "Filters screen title")
        navigationController?.navigationBar.prefersLargeTitles = false
        if let navBar = navigationController?.navigationBar {
            navBar.standardAppearance.titleTextAttributes = [
                .font: UIFont.systemFont(ofSize: 16, weight: .medium),
                .foregroundColor: AppColors.primaryInvertedColor
            ]
        }

        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])

        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseId)
    }
}

// MARK: - UITableViewDataSource

extension FilterListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        TrackerFilter.allCases.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseId, for: indexPath)
        let filter = TrackerFilter.allCases[indexPath.row]
        cell.textLabel?.text = filter.title
        cell.textLabel?.font = .systemFont(ofSize: 17, weight: .regular)
        cell.textLabel?.textColor = AppColors.primaryInvertedColor
        cell.backgroundColor = AppColors.grayBackground

        let isSelected = (currentFilter == filter)
        let showCheckmark = isSelected && filter.showsCheckmarkWhenSelected
        if showCheckmark {
            cell.accessoryType = .checkmark
            cell.tintColor = AppColors.blueSwitch
        } else {
            cell.accessoryType = .none
        }
        cell.selectionStyle = .default
        return cell
    }
}

// MARK: - UITableViewDelegate

extension FilterListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let filter = TrackerFilter.allCases[indexPath.row]
        UserDefaultsService.shared.trackerFilter = filter
        delegate?.filterListViewController(self, didSelectFilter: filter)
        dismiss(animated: true)
    }
}
