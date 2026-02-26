import UIKit

final class NewHabitViewController: UIViewController {
    
    // MARK: - Properties
    
    weak var delegate: NewHabitViewControllerDelegate?
    
    // MARK: - Private Properties
    
    // выбранное расписание
    private var selectedSchedule: [Tracker.Weekday] = []
    
    // Получение текста расписания для отображения
    private var scheduleSubtitle: String {
        selectedSchedule.formattedSchedule()
    }
    
    // выбранная категория (nil — не выбрана, категории существуют только через создание)
    private var selectedCategoryTitle: String?
    
    // Режим редактирования: если задан — экран в режиме редактирования привычки
    private var editContext: (tracker: Tracker, categoryTitle: String, completedDaysCount: Int)?
    
    private var isEditMode: Bool { editContext != nil }
    
    // Индексы выбранных эмодзи и цвета
    private var selectedEmojiIndexPath: IndexPath?
    private var selectedColorIndexPath: IndexPath?
    
    // MARK: - UI Elements
    
    // Основной ScrollView для прокрутки контента
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = true
        scrollView.alwaysBounceVertical = true
        return scrollView
    }()
    
    // Контейнер для контента внутри ScrollView
    private lazy var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // Лейбл количества отмеченных дней (только в режиме редактирования)
    private lazy var completedDaysLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.textColor = AppColors.blackDay
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isHidden = true
        return label
    }()
    
    private var completedDaysLabelHeightConstraint: NSLayoutConstraint?
    
    /// В режиме создания: поле названия от верха contentView. В режиме редактирования: от низа лейбла «N дней».
    private var trackerNameFieldTopToContentConstraint: NSLayoutConstraint?
    private var trackerNameFieldTopToLabelConstraint: NSLayoutConstraint?
    
    // Текстовое поле для ввода названия трекера
    private lazy var trackerNameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Введите название трекера"
        textField.backgroundColor = AppColors.grayBackground
        textField.layer.cornerRadius = 16
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        textField.leftViewMode = .always
        textField.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        textField.rightViewMode = .always
        textField.font = .systemFont(ofSize: 17, weight: .regular)
        textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        textField.isUserInteractionEnabled = true
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    // Таблица для отображения опций (категория и расписание)
    private lazy var optionsTableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "OptionCell")
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .singleLine
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.isScrollEnabled = false
        tableView.isUserInteractionEnabled = true
        tableView.allowsSelection = true
        tableView.estimatedRowHeight = 75
        tableView.rowHeight = 75
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.layer.masksToBounds = true
        tableView.layer.cornerRadius = 16
        return tableView
    }()
    
    // Коллекция для выбора эмодзи
    private lazy var emojiCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.isScrollEnabled = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(EmojiCollectionViewCell.self, forCellWithReuseIdentifier: EmojiCollectionViewCell.reuseIdentifier)
        collectionView.register(EmojiCollectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: EmojiCollectionHeaderView.reuseIdentifier)
        return collectionView
    }()
    
    // Коллекция для выбора цвета
    private lazy var colorCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.isScrollEnabled = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(ColorCollectionViewCell.self, forCellWithReuseIdentifier: ColorCollectionViewCell.reuseIdentifier)
        collectionView.register(ColorCollectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: ColorCollectionHeaderView.reuseIdentifier)
        return collectionView
    }()
    
    // Кнопка отмены создания трекера
    private lazy var cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Отменить", for: .normal)
        button.setTitleColor(AppColors.redButton, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .white
        button.layer.cornerRadius = 16
        button.layer.borderWidth = 1
        button.layer.borderColor = AppColors.redButton.cgColor
        button.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // Кнопка создания трекера
    private lazy var createButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Создать", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = AppColors.grayButton
        button.layer.cornerRadius = 16
        button.isEnabled = false
        button.addTarget(self, action: #selector(createButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Public
    
    /// Настройка экрана для редактирования существующей привычки
    func configureForEdit(tracker: Tracker, categoryTitle: String, completedDaysCount: Int) {
        editContext = (tracker, categoryTitle, completedDaysCount)
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupTapGesture()
        if isEditMode {
            applyEditMode()
        }
    }
    
    // MARK: - Setup Methods
    
    // Настройка основного UI
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        // Настройка Navigation Bar
        navigationItem.title = isEditMode ? "Редактирование привычки" : "Новая привычка"
        navigationController?.navigationBar.prefersLargeTitles = false
        let barAppearance = UINavigationBarAppearance()
        barAppearance.configureWithOpaqueBackground()
        barAppearance.backgroundColor = .systemBackground
        barAppearance.shadowColor = .clear
        barAppearance.titleTextAttributes = [
            .font: UIFont.systemFont(ofSize: 16, weight: .medium),
            .foregroundColor: AppColors.blackDay
        ]
        navigationController?.navigationBar.standardAppearance = barAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = barAppearance
        
        // Добавление элементов на экран
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(completedDaysLabel)
        contentView.addSubview(trackerNameTextField)
        contentView.addSubview(optionsTableView)
        contentView.addSubview(emojiCollectionView)
        contentView.addSubview(colorCollectionView)
        view.addSubview(cancelButton)
        view.addSubview(createButton)
    }
    
    private func applyEditMode() {
        guard let ctx = editContext else { return }
        completedDaysLabel.isHidden = false
        let days = ctx.completedDaysCount
        completedDaysLabel.text = days == 1 ? "1 день" : "\(days) дней"
        trackerNameTextField.text = ctx.tracker.name
        selectedCategoryTitle = ctx.categoryTitle
        selectedSchedule = ctx.tracker.schedule
        if let emojiIndex = TrackerEmoji.allCases.firstIndex(where: { $0.value == ctx.tracker.emoji }) {
            selectedEmojiIndexPath = IndexPath(item: emojiIndex, section: 0)
        }
        if let colorIndex = TrackerColor.allCases.firstIndex(where: {
            UIColorMarshalling.hexString(from: $0.uiColor) == UIColorMarshalling.hexString(from: ctx.tracker.color)
        }) {
            selectedColorIndexPath = IndexPath(item: colorIndex, section: 0)
        }
        if isEditMode {
            completedDaysLabelHeightConstraint?.constant = 38
        }
        trackerNameFieldTopToContentConstraint?.isActive = false
        trackerNameFieldTopToLabelConstraint?.isActive = true
        createButton.setTitle("Сохранить", for: .normal)
        createButton.isEnabled = true
        createButton.backgroundColor = AppColors.blackDay
        optionsTableView.reloadData()
        emojiCollectionView.reloadData()
        colorCollectionView.reloadData()
        if let ip = selectedEmojiIndexPath {
            emojiCollectionView.selectItem(at: ip, animated: false, scrollPosition: [])
        }
        if let ip = selectedColorIndexPath {
            colorCollectionView.selectItem(at: ip, animated: false, scrollPosition: [])
        }
    }
    
    // Настройка constraints для всех элементов
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // ScrollView
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: cancelButton.topAnchor, constant: -16),
            
            // ContentView внутри ScrollView
            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
            
            // Лейбл количества дней (в режиме редактирования)
            completedDaysLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24),
            completedDaysLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            completedDaysLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            trackerNameTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            trackerNameTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            trackerNameTextField.heightAnchor.constraint(equalToConstant: 75),
            
            // Таблица опций
            optionsTableView.topAnchor.constraint(equalTo: trackerNameTextField.bottomAnchor, constant: 24),
            optionsTableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            optionsTableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            optionsTableView.heightAnchor.constraint(equalToConstant: 150),
            
            // Коллекция эмодзи
            emojiCollectionView.topAnchor.constraint(equalTo: optionsTableView.bottomAnchor, constant: 32),
            emojiCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 18),
            emojiCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -18),
            emojiCollectionView.heightAnchor.constraint(equalToConstant: 198),
            
            // Коллекция цветов
            colorCollectionView.topAnchor.constraint(equalTo: emojiCollectionView.bottomAnchor, constant: 40),
            colorCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 18),
            colorCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -18),
            colorCollectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24),
            colorCollectionView.heightAnchor.constraint(equalToConstant: 198),
            
            // Кнопка "Отменить"
            cancelButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            cancelButton.trailingAnchor.constraint(equalTo: view.centerXAnchor, constant: -4),
            cancelButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            cancelButton.heightAnchor.constraint(equalToConstant: 60),
            
            // Кнопка "Создать"
            createButton.leadingAnchor.constraint(equalTo: view.centerXAnchor, constant: 4),
            createButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            createButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            createButton.heightAnchor.constraint(equalToConstant: 60)
        ])
        completedDaysLabelHeightConstraint = completedDaysLabel.heightAnchor.constraint(equalToConstant: 0)
        completedDaysLabelHeightConstraint?.isActive = true
        
        trackerNameFieldTopToContentConstraint = trackerNameTextField.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24)
        trackerNameFieldTopToLabelConstraint = trackerNameTextField.topAnchor.constraint(equalTo: completedDaysLabel.bottomAnchor, constant: 40)
        trackerNameFieldTopToContentConstraint?.isActive = true
    }
    
    // Настройка жеста для скрытия клавиатуры
    private func setupTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - Actions
    
    // Обработка изменения текста в TextField
    @objc private func textFieldDidChange() {
        updateCreateButtonState()
    }
    
    // Обновление состояния кнопки "Создать" (название не пустое и категория выбрана)
    private func updateCreateButtonState() {
        let hasName = !(trackerNameTextField.text?.trimmingCharacters(in: .whitespaces).isEmpty ?? true)
        let hasCategory = selectedCategoryTitle != nil
        let enabled = hasName && hasCategory
        createButton.isEnabled = enabled
        createButton.backgroundColor = enabled ? AppColors.blackDay : AppColors.grayButton
    }
    
    // Открытие экрана выбора категории (модально, свайп вниз для закрытия)
    private func openCategorySelection() {
        let categoryVC = CategoryListViewController(selectedCategoryTitle: selectedCategoryTitle)
        categoryVC.delegate = self
        let nav = UINavigationController(rootViewController: categoryVC)
        present(nav, animated: true)
    }

    // Открытие экрана выбора расписания
    private func openScheduleSelection() {
        let scheduleViewController = ScheduleViewController()
        scheduleViewController.delegate = self
        scheduleViewController.selectedWeekdays = Set(selectedSchedule)
        navigationController?.pushViewController(scheduleViewController, animated: true)
    }
    
    // Скрытие клавиатуры при тапе на экран
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // Обработка нажатия на кнопку "Отменить"
    @objc private func cancelButtonTapped() {
        dismiss(animated: true)
    }
    
    // Обработка нажатия на кнопку "Создать"
    @objc private func createButtonTapped() {
        guard let trackerName = trackerNameTextField.text,
              !trackerName.trimmingCharacters(in: .whitespaces).isEmpty else {
            return
        }
        
        // Получение выбранного эмодзи
        let selectedEmoji: String
        if let indexPath = selectedEmojiIndexPath,
           indexPath.item < TrackerEmoji.allCases.count {
            selectedEmoji = TrackerEmoji.allCases[indexPath.item].value
        } else {
            selectedEmoji = TrackerEmoji.smile.value
        }
        
        // Получение выбранного цвета
        let selectedColor: UIColor
        if let indexPath = selectedColorIndexPath,
           indexPath.item < TrackerColor.allCases.count {
            selectedColor = TrackerColor.allCases[indexPath.item].uiColor
        } else {
            selectedColor = AppColors.greenTracker
        }
        
        if let ctx = editContext {
            // Режим редактирования — сохраняем с тем же id
            let updatedTracker = Tracker(
                id: ctx.tracker.id,
                name: trackerName,
                color: selectedColor,
                emoji: selectedEmoji,
                schedule: selectedSchedule
            )
            guard let categoryTitle = selectedCategoryTitle else { return }
            delegate?.didUpdateTracker(updatedTracker, categoryTitle: categoryTitle)
            dismiss(animated: true)
            return
        }
        
        // Создание нового трекера
        let newTracker = Tracker(
            id: UUID(),
            name: trackerName,
            color: selectedColor,
            emoji: selectedEmoji,
            schedule: selectedSchedule
        )
        
        guard let categoryTitle = selectedCategoryTitle else { return }
        delegate?.didCreateTracker(newTracker, categoryTitle: categoryTitle)
        dismiss(animated: true)
    }
}

// MARK: - CategoryListViewControllerDelegate

extension NewHabitViewController: CategoryListViewControllerDelegate {
    func categoryListViewController(_ controller: CategoryListViewController, didSelectCategory title: String) {
        selectedCategoryTitle = title
        optionsTableView.reloadData()
        updateCreateButtonState()
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
        
        // Удаление старых subviews для переиспользования ячейки
        cell.contentView.subviews.forEach { $0.removeFromSuperview() }
        
        cell.backgroundColor = AppColors.grayBackground
        cell.selectionStyle = .gray
        
        // Создание UI элементов ячейки
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
        
        // Настройка контента в зависимости от строки
        titleLabel.text = indexPath.row == 0 ? "Категория" : "Расписание"
        let subtitleText = indexPath.row == 0 ? (selectedCategoryTitle ?? "") : scheduleSubtitle
        subtitleLabel.text = subtitleText
        subtitleLabel.isHidden = subtitleText.isEmpty
        
        // Скрытие separator у последней ячейки
        let isLast = indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1
        if isLast {
            cell.separatorInset = UIEdgeInsets(
                top: 0,
                left: 0,
                bottom: 0,
                right: .greatestFiniteMagnitude
            )
        }
        
        // Constraints: без subtitle — только заголовок по центру, с subtitle — заголовок сверху и subtitle под ним
        var constraints: [NSLayoutConstraint] = [
            titleLabel.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: disclosureImageView.leadingAnchor, constant: -8),
            disclosureImageView.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -16),
            disclosureImageView.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor)
        ]
        if subtitleText.isEmpty {
            constraints.append(contentsOf: [
                titleLabel.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor)
            ])
        } else {
            constraints.append(contentsOf: [
                titleLabel.topAnchor.constraint(equalTo: cell.contentView.topAnchor, constant: 15),
                subtitleLabel.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 16),
                subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2),
                subtitleLabel.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor, constant: -15),
                subtitleLabel.trailingAnchor.constraint(lessThanOrEqualTo: disclosureImageView.leadingAnchor, constant: -8)
            ])
        }
        NSLayoutConstraint.activate(constraints)
        
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
        if indexPath.row == 0 {
            openCategorySelection()
        } else if indexPath.row == 1 {
            openScheduleSelection()
        }
    }
}

// MARK: - UICollectionViewDataSource

extension NewHabitViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        collectionView === emojiCollectionView ? TrackerEmoji.allCases.count : TrackerColor.allCases.count
    }
    
    // Создание ячеек
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        switch collectionView {
        case emojiCollectionView:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EmojiCollectionViewCell.reuseIdentifier, for: indexPath) as? EmojiCollectionViewCell else {
                preconditionFailure("Failed to dequeue EmojiCollectionViewCell")
            }
            let emoji = TrackerEmoji.allCases[indexPath.item].value
            cell.configure(with: emoji)
            return cell
        case colorCollectionView:
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: ColorCollectionViewCell.reuseIdentifier,
                for: indexPath
            ) as? ColorCollectionViewCell else {
                preconditionFailure("Failed to dequeue ColorCollectionViewCell")
            }
            let color = TrackerColor.allCases[indexPath.item].uiColor
            cell.configure(with: color)
            return cell
        default:
            assertionFailure("Unexpected collectionView")
            return UICollectionViewCell()
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension NewHabitViewController: UICollectionViewDelegateFlowLayout {
    
    // Создание хэдера для секции коллекции
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {

        guard kind == UICollectionView.elementKindSectionHeader else {
            return UICollectionReusableView()
        }

        let reuseIdentifier: String
        
        switch collectionView {
        case emojiCollectionView:
            reuseIdentifier = EmojiCollectionHeaderView.reuseIdentifier
        case colorCollectionView:
            reuseIdentifier = ColorCollectionHeaderView.reuseIdentifier
        default:
            assertionFailure("Unexpected collectionView")
            return UICollectionReusableView()
        }

        return collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: reuseIdentifier, for: indexPath)
    }

    
    // Размер хэдера коллекции
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 42)
    }
    
    // Отступы для секции коллекции
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    // Обработка выбора элемента в коллекции
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if collectionView.cellForItem(at: indexPath) is EmojiCollectionViewCell {
            selectedEmojiIndexPath = indexPath
        }
        if collectionView.cellForItem(at: indexPath) is ColorCollectionViewCell {
            selectedColorIndexPath = indexPath
        }
    }
    
    // Размер ячейки в коллекции
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 52, height: 52)
    }
    
    // Минимальный отступ между ячейками в строке
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    // Минимальный отступ между строками ячеек
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}

// MARK: - Delegate Protocol

protocol NewHabitViewControllerDelegate: AnyObject {
    func didCreateTracker(_ tracker: Tracker, categoryTitle: String)
    func didUpdateTracker(_ tracker: Tracker, categoryTitle: String)
}
