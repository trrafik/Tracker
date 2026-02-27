import UIKit

/// Экран выбора расписания трекера по дням недели.
final class ScheduleViewController: UIViewController {
    
    // MARK: - Properties
    
    weak var delegate: ScheduleViewControllerDelegate?
    var selectedWeekdays: Set<Tracker.Weekday> = []
    
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private let doneButton = UIButton(type: .system)
    
    private let weekdays = Tracker.Weekday.allCases
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.backgroundColor = AppColors.primaryColor
        
        navigationItem.title = NSLocalizedString("habit.scheduleTitle", comment: "")
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.hidesBackButton = true
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "WeekdayCell")
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .singleLine
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(tableView)
        
        doneButton.setTitle(NSLocalizedString("common.done", comment: "Done"), for: .normal)
        doneButton.setTitleColor(AppColors.primaryColor, for: .normal)
        doneButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        doneButton.backgroundColor = AppColors.primaryInvertedColor
        doneButton.layer.cornerRadius = 16
        doneButton.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(doneButton)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: doneButton.topAnchor, constant: -16),
            
            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            doneButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    // MARK: - Actions
    
    @objc private func doneButtonTapped() {
        delegate?.didSelectSchedule(Array(selectedWeekdays))
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func switchValueChanged(_ sender: UISwitch) {
        let weekday = weekdays[sender.tag]
        
        if sender.isOn {
            selectedWeekdays.insert(weekday)
        } else {
            selectedWeekdays.remove(weekday)
        }
    }
}

// MARK: - UITableViewDataSource

extension ScheduleViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return weekdays.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WeekdayCell", for: indexPath)
        let weekday = weekdays[indexPath.row]
        
        // Настройка текста
        cell.textLabel?.text = weekday.fullName
        cell.textLabel?.font = .systemFont(ofSize: 17, weight: .regular)
        cell.textLabel?.textColor = AppColors.primaryInvertedColor
        cell.backgroundColor = AppColors.grayBackground

        
        // Настройка переключателя
        let switchControl = UISwitch()
        switchControl.tag = indexPath.row
        switchControl.isOn = selectedWeekdays.contains(weekday)
        switchControl.onTintColor = AppColors.blueSwitch
        switchControl.addTarget(self, action: #selector(switchValueChanged(_:)), for: .valueChanged)
        cell.accessoryView = switchControl
        cell.selectionStyle = .none
        
        return cell
    }
}

// MARK: - UITableViewDelegate

extension ScheduleViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
}

// MARK: - Delegate Protocol

/// Делегат экрана выбора расписания.
protocol ScheduleViewControllerDelegate: AnyObject {
    func didSelectSchedule(_ weekdays: [Tracker.Weekday])
}
