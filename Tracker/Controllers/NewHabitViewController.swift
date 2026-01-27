import UIKit

final class NewHabitViewController: UIViewController {
    
    // MARK: - Properties
    weak var delegate: NewHabitViewControllerDelegate?
    
    private var selectedSchedule: [Tracker.Weekday] = []
    private let selectedCategory = "Привычки" // Захардкоженная категория
    
    private let trackerNameTextField = UITextField()
    private let optionsTableView = UITableView(frame: .zero, style: .insetGrouped)
    private let cancelButton = UIButton(type: .system)
    private let createButton = UIButton(type: .system)
    
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupTapGesture()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        // Настройка Navigation Bar
        navigationItem.title = "Новая привычка"
        navigationController?.navigationBar.prefersLargeTitles = false
        
        // Настройка TextField для названия трекера
        trackerNameTextField.placeholder = "Введите название трекера"
        trackerNameTextField.backgroundColor = AppColors.grayBackground
        trackerNameTextField.layer.cornerRadius = 16
        trackerNameTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        trackerNameTextField.leftViewMode = .always
        trackerNameTextField.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        trackerNameTextField.rightViewMode = .always
        trackerNameTextField.font = .systemFont(ofSize: 17, weight: .regular)
        trackerNameTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        trackerNameTextField.isUserInteractionEnabled = true
        trackerNameTextField.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(trackerNameTextField)

        // Настройка таблицы для опций
        setupOptionsTableView()
        
        // Настройка кнопок внизу
        setupBottomButtons()
    }
    
    private func setupOptionsTableView() {
        optionsTableView.delegate = self
        optionsTableView.dataSource = self
        optionsTableView.register(UITableViewCell.self, forCellReuseIdentifier: "OptionCell")
        optionsTableView.backgroundColor = .clear
        optionsTableView.separatorStyle = .singleLine
        optionsTableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        optionsTableView.isScrollEnabled = false
        optionsTableView.isUserInteractionEnabled = true
        optionsTableView.allowsSelection = true
        optionsTableView.estimatedRowHeight = 75
        optionsTableView.rowHeight = 75
        optionsTableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(optionsTableView)
    }
    
    private func setupBottomButtons() {
        // Кнопка "Отменить"
        cancelButton.setTitle("Отменить", for: .normal)
        cancelButton.setTitleColor(AppColors.redButton, for: .normal)
        cancelButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        cancelButton.backgroundColor = .white
        cancelButton.layer.cornerRadius = 16
        cancelButton.layer.borderWidth = 1
        cancelButton.layer.borderColor = AppColors.redButton.cgColor
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(cancelButton)
        
        // Кнопка "Создать"
        createButton.setTitle("Создать", for: .normal)
        createButton.setTitleColor(.white, for: .normal)
        createButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        createButton.backgroundColor = AppColors.grayButton
        createButton.layer.cornerRadius = 16
        createButton.isEnabled = false
        createButton.addTarget(self, action: #selector(createButtonTapped), for: .touchUpInside)
        createButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(createButton)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Кнопка "Отменить"
            cancelButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            cancelButton.trailingAnchor.constraint(equalTo: view.centerXAnchor, constant: -4),
            cancelButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            cancelButton.heightAnchor.constraint(equalToConstant: 60),
            
            // Кнопка "Создать"
            createButton.leadingAnchor.constraint(equalTo: view.centerXAnchor, constant: 4),
            createButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            createButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            createButton.heightAnchor.constraint(equalToConstant: 60),
            
            // TextField
            trackerNameTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            trackerNameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            trackerNameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            trackerNameTextField.heightAnchor.constraint(equalToConstant: 75),
            
            // Таблица опций
            optionsTableView.topAnchor.constraint(equalTo: trackerNameTextField.bottomAnchor),
            optionsTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            optionsTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            optionsTableView.bottomAnchor.constraint(equalTo: cancelButton.topAnchor, constant: -16)
        ])
    }
    
    private func setupTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // MARK: - Actions
    
    @objc private func textFieldDidChange() {
        let hasText = !(trackerNameTextField.text?.trimmingCharacters(in: .whitespaces).isEmpty ?? true)
        updateCreateButtonState(enabled: hasText)
    }
    
    private func updateCreateButtonState(enabled: Bool) {
        createButton.isEnabled = enabled
        createButton.backgroundColor = enabled ? AppColors.blackDay : AppColors.grayButton
    }
    
    private func openScheduleSelection() {
        let scheduleViewController = ScheduleViewController()
        scheduleViewController.delegate = self
        scheduleViewController.selectedWeekdays = Set(selectedSchedule)
        navigationController?.pushViewController(scheduleViewController, animated: true)
    }
    
    private func getScheduleSubtitle() -> String {
        return selectedSchedule.formattedSchedule()
    }
    
    @objc private func cancelButtonTapped() {
        dismiss(animated: true)
    }
    
    @objc private func createButtonTapped() {
        guard let trackerName = trackerNameTextField.text,
              !trackerName.trimmingCharacters(in: .whitespaces).isEmpty else {
            return
        }
        
        // Создаем новый трекер с дефолтными значениями
        let newTracker = Tracker(
            id: UUID(),
            name: trackerName,
            color: AppColors.greenTracker,
            emoji: "😀", // Временный эмоджи, будет выбран позже
            schedule: selectedSchedule
        )
        
        delegate?.didCreateTracker(newTracker)
        dismiss(animated: true)
    }
}

// MARK: - ScheduleViewControllerDelegate

extension NewHabitViewController: ScheduleViewControllerDelegate {
    func didSelectSchedule(_ weekdays: [Tracker.Weekday]) {
        selectedSchedule = weekdays
        optionsTableView.reloadData()
    }
}

// MARK: - UITableViewDataSource

extension NewHabitViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "OptionCell", for: indexPath)
        
        // Удаляем старые subviews
        cell.contentView.subviews.forEach { $0.removeFromSuperview() }
        
        cell.backgroundColor = AppColors.grayBackground
        cell.selectionStyle = .none
        
        let titleLabel = UILabel()
        titleLabel.font = .systemFont(ofSize: 17, weight: .regular)
        titleLabel.textColor = AppColors.blackDay
        titleLabel.isUserInteractionEnabled = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let subtitleLabel = UILabel()
        subtitleLabel.font = .systemFont(ofSize: 17, weight: .regular)
        subtitleLabel.textColor = AppColors.grayButton
        subtitleLabel.isUserInteractionEnabled = false
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let disclosureImageView = UIImageView(image: UIImage(systemName: "chevron.right"))
        disclosureImageView.tintColor = .systemGray
        disclosureImageView.isUserInteractionEnabled = false
        disclosureImageView.translatesAutoresizingMaskIntoConstraints = false
        
        cell.contentView.addSubview(titleLabel)
        cell.contentView.addSubview(subtitleLabel)
        cell.contentView.addSubview(disclosureImageView)
        
        if indexPath.row == 0 {
            // Категория
            titleLabel.text = "Категория"
            subtitleLabel.text = selectedCategory
        } else {
            // Расписание
            titleLabel.text = "Расписание"
            subtitleLabel.text = getScheduleSubtitle()
        }
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 16),
            titleLabel.topAnchor.constraint(equalTo: cell.contentView.topAnchor, constant: 15),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: disclosureImageView.leadingAnchor, constant: -8),
            
            subtitleLabel.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 16),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2),
            subtitleLabel.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor, constant: -15),
            subtitleLabel.trailingAnchor.constraint(lessThanOrEqualTo: disclosureImageView.leadingAnchor, constant: -8),
            
            disclosureImageView.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -16),
            disclosureImageView.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor)
        ])
        
        return cell
    }
}

// MARK: - UITableViewDelegate

extension NewHabitViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.row == 1 {
            openScheduleSelection()
        }
    }
}

// MARK: - Delegate Protocol

protocol NewHabitViewControllerDelegate: AnyObject {
    func didCreateTracker(_ tracker: Tracker)
}

#Preview {
    NewHabitViewController()
}
