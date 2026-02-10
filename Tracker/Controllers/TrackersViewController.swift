import UIKit

final class TrackersViewController: UIViewController {

    // MARK: - UI Elements

    private let collectionView: UICollectionView
    private let searchController = UISearchController(searchResultsController: nil)
    private let datePicker = UIDatePicker()

    // MARK: - Data

    private let trackerStore = TrackerStore()
    private let recordStore = TrackerRecordStore()

    var categories: [TrackerCategory] = []
    var completedTrackers: [TrackerRecord] = []

    private var filteredCategories: [TrackerCategory] = []
    var currentDate: Date = Date()
    private var searchText: String = ""

    private let label = UILabel()
    private let imageView = UIImageView()

    // MARK: - Initialization

    init() {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: (UIScreen.main.bounds.width - 41) / 2, height: 148)
        layout.minimumInteritemSpacing = 9
        layout.minimumLineSpacing = 16
        layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 16, right: 16)
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupStoresAndFRC()
        setupNavigationBar()
        setupSearchController()
        setupCollectionView()
        setupDatePicker()
        setupPlaceholder()
        updateFilteredCategories()
    }

    // MARK: - Setup

    private func setupStoresAndFRC() {
        do {
            try trackerStore.performFetch()
            trackerStore.onCategoriesDidChange = { [weak self] in
                self?.reloadCategoriesFromStore()
            }
            categories = trackerStore.categoriesFromFetchedResults()
            completedTrackers = (try? recordStore.allRecords()) ?? []
        } catch {
            categories = []
            completedTrackers = []
        }
    }

    private func reloadCategoriesFromStore() {
        categories = trackerStore.categoriesFromFetchedResults()
        updateFilteredCategories()
    }
    
    private func setupNavigationBar() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        navigationItem.title = "Трекеры"
        
        navigationController?.navigationBar.tintColor = AppColors.blackDay
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = .systemBackground
        appearance.largeTitleTextAttributes = [
            .foregroundColor: AppColors.blackDay,
            .font: UIFont.systemFont(ofSize: 34, weight: .bold)
        ]
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        
        let addButton = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addButtonTapped)
        )
        navigationItem.leftBarButtonItem = addButton
        
        datePicker.preferredDatePickerStyle = .compact
        datePicker.datePickerMode = .date
        datePicker.locale = Locale(identifier: "ru_RU")
        datePicker.tintColor = AppColors.blackDay
        datePicker.addTarget(self, action: #selector(datePickerValueChanged), for: .valueChanged)
        
        let dateItem = UIBarButtonItem(customView: datePicker)
        navigationItem.rightBarButtonItem = dateItem
    }
    
    private func setupDatePicker() {
        datePicker.maximumDate = Date()
    }
    
    private func setupSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Поиск"
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
    }
    
    private func setupCollectionView() {
        collectionView.backgroundColor = .white
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(TrackerCell.self, forCellWithReuseIdentifier: TrackerCell.identifier)
        collectionView.register(
            UICollectionViewCell.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: "SectionHeader"
        )
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupPlaceholder() {
        view.backgroundColor = .white
        
        label.text = "Что будем отслеживать?"
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(label)
        
        imageView.image = UIImage(resource: .placeHolder)
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(imageView)
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -220),
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.bottomAnchor.constraint(equalTo: label.topAnchor, constant: -8),
            imageView.widthAnchor.constraint(equalToConstant: 80),
            imageView.heightAnchor.constraint(equalToConstant: 80)
        ])
    }
    
    // MARK: - Actions
    
    @objc private func addButtonTapped() {
        let newHabitViewController = NewHabitViewController()
        newHabitViewController.delegate = self
        let navigationController = UINavigationController(rootViewController: newHabitViewController)
        present(navigationController, animated: true)
    }
    
    @objc private func datePickerValueChanged() {
        currentDate = datePicker.date
        updateFilteredCategories()
    }
    
    // MARK: - Data Filtering
    
    private func updateFilteredCategories() {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: currentDate)
        // iOS weekday: 1 = Sunday, 2 = Monday, ..., 7 = Saturday
        // Our enum: 1 = Monday, 2 = Tuesday, ..., 7 = Sunday
        let trackerWeekday: Tracker.Weekday
        if weekday == 1 {
            trackerWeekday = .sunday
        } else {
            trackerWeekday = Tracker.Weekday(rawValue: weekday - 1) ?? .monday
        }
        
        filteredCategories = categories.compactMap { category in
            let filteredTrackers = category.trackers.filter { tracker in
                // Фильтр по расписанию
                let matchesSchedule = tracker.schedule.isEmpty || tracker.schedule.contains(trackerWeekday)
                
                // Фильтр по поиску
                let matchesSearch = searchText.isEmpty || tracker.name.localizedCaseInsensitiveContains(searchText)
                
                return matchesSchedule && matchesSearch
            }
            if filteredTrackers.isEmpty {
                return nil
            }
            return TrackerCategory(title: category.title, trackers: filteredTrackers)
        }
        updateUI()
    }
    
    private func updateUI() {
        let hasTrackers = !filteredCategories.isEmpty
        collectionView.isHidden = !hasTrackers
        label.isHidden = hasTrackers
        imageView.isHidden = hasTrackers
        collectionView.reloadData()
    }
    
    // MARK: - Tracker Completion
    
    private func toggleTrackerCompletion(trackerId: UUID, isCompleted: Bool) {
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year, .month, .day], from: currentDate)
        guard let normalizedDate = calendar.date(from: dateComponents) else { return }

        do {
            if isCompleted {
                try recordStore.addRecord(trackerId: trackerId, date: normalizedDate)
            } else {
                try recordStore.removeRecord(trackerId: trackerId, date: normalizedDate)
            }
            completedTrackers = (try? recordStore.allRecords()) ?? completedTrackers
        } catch {
            // сохранение не удалось; можно показать ошибку
        }
        collectionView.reloadData()
    }
    
    private func isTrackerCompleted(trackerId: UUID, for date: Date) -> Bool {
        let calendar = Calendar.current
        return completedTrackers.contains { record in
            record.trackerId == trackerId &&
            calendar.isDate(record.date, inSameDayAs: date)
        }
    }
    
    private func getCompletedDaysCount(for trackerId: UUID) -> Int {
        return completedTrackers.filter { $0.trackerId == trackerId }.count
    }
}

// MARK: - UICollectionViewDataSource

extension TrackersViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return filteredCategories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredCategories[section].trackers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackerCell.identifier, for: indexPath) as? TrackerCell else {
            preconditionFailure("Failed to dequeue TrackerCell")
        }

        let tracker = filteredCategories[indexPath.section].trackers[indexPath.item]
        let isCompleted = isTrackerCompleted(trackerId: tracker.id, for: currentDate)
        let completedDaysCount = getCompletedDaysCount(for: tracker.id)
        let isFutureDate = currentDate > Date()
        
        cell.configure(
            with: tracker,
            isCompleted: isCompleted,
            completedDaysCount: completedDaysCount,
            isFutureDate: isFutureDate
        )
        
        cell.onCompleteButtonTapped = { [weak self] trackerId, newState in
            guard let self = self else { return }
            
            // Проверка на будущую дату
            if self.currentDate > Date() {
                return
            }
            
            self.toggleTrackerCompletion(trackerId: trackerId, isCompleted: newState)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let headerView = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: "SectionHeader",
            for: indexPath
        )
        
        // Удаляем старые subviews
        headerView.subviews.forEach { $0.removeFromSuperview() }
        
        let label = UILabel()
        label.text = filteredCategories[indexPath.section].title
        label.font = .systemFont(ofSize: 19, weight: .bold)
        label.textColor = AppColors.blackDay
        label.translatesAutoresizingMaskIntoConstraints = false
        
        headerView.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            label.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
            label.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 16),
            label.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -8)
        ])
        
        return headerView
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension TrackersViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 50)
    }
}

// MARK: - UISearchResultsUpdating

extension TrackersViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        searchText = searchController.searchBar.text ?? ""
        updateFilteredCategories()
    }
}

// MARK: - NewHabitViewControllerDelegate

extension TrackersViewController: NewHabitViewControllerDelegate {
    func didCreateTracker(_ tracker: Tracker) {
        do {
            try trackerStore.add(tracker)
            // FRC вызовет controllerDidChangeContent и обновит categories
        } catch {
            // сохранение не удалось
        }
    }
}

