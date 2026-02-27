import UIKit

/// Главный экран со списком трекеров и фильтрами.
final class TrackersViewController: UIViewController {

    // MARK: - UI Elements

    private let collectionView: UICollectionView
    private let searchController = UISearchController(searchResultsController: nil)
    private let datePicker = UIDatePicker()

    /// Обёртка над коллекцией: не скроллится, чтобы навбар не сворачивал large title «Трекеры».
    private let scrollWrapper: UIScrollView = {
        let sv = UIScrollView()
        sv.isScrollEnabled = false
        sv.showsVerticalScrollIndicator = false
        sv.showsHorizontalScrollIndicator = false
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()

    /// Кнопка «Фильтры» внизу экрана. Скрыта, если на выбранный день нет трекеров.
    private let filterButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle(NSLocalizedString("main.filters", comment: "Filters button"), for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 17, weight: .regular)
        b.setTitleColor(.white, for: .normal)
        b.backgroundColor = AppColors.blueSwitch
        b.layer.cornerRadius = 16
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()

    // MARK: - Data

    private let trackerStore = TrackerStore()
    private let recordStore = TrackerRecordStore()

    private let analyticsService = AnalyticsService()

    /// Используется в тестах, чтобы отключить работу с Core Data и FRC.
    private let shouldSetupStores: Bool

    var categories: [TrackerCategory] = []
    var completedTrackers: [TrackerRecord] = []

    private var filteredCategories: [TrackerCategory] = []
    var currentDate: Date = Date()
    private var searchText: String = ""

    /// Трекеры на выбранный день (по расписанию и поиску), до применения фильтра «завершённые/незавершённые». Используется для видимости кнопки «Фильтры».
    private var categoriesForSelectedDay: [TrackerCategory] = []

    private let label = UILabel()
    private let imageView = UIImageView()

    // MARK: - Initialization

    init(shouldSetupStores: Bool = true) {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: (UIScreen.main.bounds.width - 41) / 2, height: 148)
        layout.minimumInteritemSpacing = 9
        layout.minimumLineSpacing = 16
        layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 16, right: 16)
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        self.shouldSetupStores = shouldSetupStores
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        if shouldSetupStores {
            setupStoresAndFRC()
        }
        setupNavigationBar()
        setupSearchController()
        setupCollectionView()
        setupDatePicker()
        setupPlaceholder()
        updateFilteredCategories()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        analyticsService.reportMainScreen(event: "open")
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        analyticsService.reportMainScreen(event: "close")
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
        navigationItem.title = NSLocalizedString("main.trackers", comment: "Main screen title")
        
        navigationController?.navigationBar.tintColor = AppColors.primaryInvertedColor
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = AppColors.primaryColor
        appearance.largeTitleTextAttributes = [
            .foregroundColor: AppColors.primaryInvertedColor,
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
        datePicker.locale = Locale.current
        datePicker.tintColor = AppColors.primaryInvertedColor
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
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.placeholder = NSLocalizedString("search.placeholder", comment: "Search placeholder")
        searchController.searchBar.tintColor = .systemBlue
        searchController.searchBar.setValue(NSLocalizedString("search.cancel", comment: "Search cancel button"), forKey: "cancelButtonText")
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
    }
    
    private func setupCollectionView() {
        scrollWrapper.backgroundColor = AppColors.primaryColor
        collectionView.backgroundColor = AppColors.primaryColor
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(TrackerCell.self, forCellWithReuseIdentifier: TrackerCell.identifier)
        collectionView.register(
            UICollectionViewCell.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: "SectionHeader"
        )
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.alwaysBounceVertical = true
        view.addSubview(scrollWrapper)
        scrollWrapper.addSubview(collectionView)
        view.addSubview(filterButton)

        filterButton.addTarget(self, action: #selector(filterButtonTapped), for: .touchUpInside)

        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 50 + 16, right: 0)

        NSLayoutConstraint.activate([
            scrollWrapper.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollWrapper.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollWrapper.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollWrapper.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            collectionView.topAnchor.constraint(equalTo: scrollWrapper.contentLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: scrollWrapper.contentLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: scrollWrapper.contentLayoutGuide.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: scrollWrapper.contentLayoutGuide.bottomAnchor),
            collectionView.widthAnchor.constraint(equalTo: scrollWrapper.frameLayoutGuide.widthAnchor),
            collectionView.heightAnchor.constraint(equalTo: scrollWrapper.frameLayoutGuide.heightAnchor),

            filterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            filterButton.widthAnchor.constraint(equalToConstant: 114),
            filterButton.heightAnchor.constraint(equalToConstant: 50),
            filterButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
    }
    
    private func setupPlaceholder() {
        view.backgroundColor = AppColors.primaryColor

        label.text = "Что будем отслеживать?"
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textAlignment = .center
        label.textColor = AppColors.primaryInvertedColor
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
        analyticsService.reportMainScreen(event: "click", item: "add_track")
        let newHabitViewController = NewHabitViewController()
        newHabitViewController.delegate = self
        let navigationController = UINavigationController(rootViewController: newHabitViewController)
        present(navigationController, animated: true)
    }
    
    @objc private func datePickerValueChanged() {
        currentDate = datePicker.date
        updateFilteredCategories()
    }

    @objc private func filterButtonTapped() {
        analyticsService.reportMainScreen(event: "click", item: "filter")
        let filterVC = FilterListViewController()
        filterVC.currentFilter = UserDefaultsService.shared.trackerFilter
        filterVC.delegate = self
        let nav = UINavigationController(rootViewController: filterVC)
        present(nav, animated: true)
    }
    
    // MARK: - Data Filtering
    func updateFilteredCategories() {
        let baseCategories = makeBaseCategories(for: currentDate)
        categoriesForSelectedDay = baseCategories
        filteredCategories = applyCompletionFilter(to: baseCategories, for: currentDate)
        updateUI()
    }

    /// Категории с трекерами, отфильтрованными по расписанию и поисковому запросу.
    private func makeBaseCategories(for date: Date) -> [TrackerCategory] {
        let weekday = makeTrackerWeekday(for: date)
        return categories.compactMap { category in
            let filteredTrackers = category.trackers.filter { tracker in
                let matchesSchedule = tracker.schedule.isEmpty || tracker.schedule.contains(weekday)
                let matchesSearch = searchText.isEmpty || tracker.name.localizedCaseInsensitiveContains(searchText)
                return matchesSchedule && matchesSearch
            }
            guard !filteredTrackers.isEmpty else { return nil }
            return TrackerCategory(title: category.title, trackers: filteredTrackers)
        }
    }

    /// Преобразует `Date` в `Tracker.Weekday` с учётом того, что в календаре воскресенье — 1.
    private func makeTrackerWeekday(for date: Date) -> Tracker.Weekday {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: date)
        if weekday == 1 {
            return .sunday
        }
        return Tracker.Weekday(rawValue: weekday - 1) ?? .monday
    }

    /// Применяет фильтр «все / завершённые / незавершённые» к категориям.
    private func applyCompletionFilter(to baseCategories: [TrackerCategory], for date: Date) -> [TrackerCategory] {
        let filter = UserDefaultsService.shared.trackerFilter
        switch filter {
        case .all, .today:
            return baseCategories
        case .completed:
            return baseCategories.compactMap { category in
                let trackers = category.trackers.filter { tracker in
                    isTrackerCompleted(trackerId: tracker.id, for: date)
                }
                guard !trackers.isEmpty else { return nil }
                return TrackerCategory(title: category.title, trackers: trackers)
            }
        case .uncompleted:
            return baseCategories.compactMap { category in
                let trackers = category.trackers.filter { tracker in
                    !isTrackerCompleted(trackerId: tracker.id, for: date)
                }
                guard !trackers.isEmpty else { return nil }
                return TrackerCategory(title: category.title, trackers: trackers)
            }
        }
    }
    
    private func updateUI() {
        let hasTrackers = !filteredCategories.isEmpty
        let isSearchActive = !searchText.isEmpty
        let isFilterActive = UserDefaultsService.shared.trackerFilter != .all && UserDefaultsService.shared.trackerFilter != .today
        let hasTrackersForSelectedDay = !categoriesForSelectedDay.isEmpty

        collectionView.isHidden = !hasTrackers
        label.isHidden = hasTrackers
        imageView.isHidden = hasTrackers

        filterButton.isHidden = !hasTrackersForSelectedDay

        if hasTrackers {
            collectionView.reloadData()
        } else {
            if isSearchActive || isFilterActive {
                imageView.image = UIImage(resource: .notFound)
                label.text = NSLocalizedString("main.placeholderNotFound", comment: "Nothing found")
            } else {
                imageView.image = UIImage(resource: .placeHolder)
                label.text = NSLocalizedString("main.placeholderEmpty", comment: "Empty state placeholder")
            }
            label.isHidden = false
            imageView.isHidden = false
        }
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
        NotificationCenter.default.post(name: .trackerRecordsDidChange, object: nil)
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

            self.analyticsService.reportMainScreen(event: "click", item: "track")
            self.toggleTrackerCompletion(trackerId: trackerId, isCompleted: newState)
        }
        
        let categoryTitle = filteredCategories[indexPath.section].title
        cell.onContextMenuConfiguration = { [weak self] in
            self?.contextMenuConfiguration(tracker: tracker, categoryTitle: categoryTitle, completedDaysCount: completedDaysCount)
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
        label.textColor = AppColors.primaryInvertedColor
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
    
    /// Конфигурация контекстного меню для cardView (вызывается из ячейки). previewProvider: nil — превью будет сам cardView.
    private func contextMenuConfiguration(tracker: Tracker, categoryTitle: String, completedDaysCount: Int) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { [weak self] _ in
            guard let self = self else { return nil }
            
            let editAction = UIAction(title: NSLocalizedString("main.editTracker", comment: "Edit tracker"), image: nil) { _ in
                self.analyticsService.reportMainScreen(event: "click", item: "edit")
                self.openEditHabit(tracker: tracker, categoryTitle: categoryTitle, completedDaysCount: completedDaysCount)
            }
            
            let deleteAction = UIAction(
                title: NSLocalizedString("main.delete", comment: "Delete"),
                image: nil,
                attributes: .destructive
            ) { _ in
                self.analyticsService.reportMainScreen(event: "click", item: "delete")
                self.showDeleteConfirmation(tracker: tracker)
            }
            
            return UIMenu(title: "", children: [editAction, deleteAction])
        }
    }
    
    private func openEditHabit(tracker: Tracker, categoryTitle: String, completedDaysCount: Int) {
        let editVC = NewHabitViewController()
        editVC.delegate = self
        editVC.configureForEdit(tracker: tracker, categoryTitle: categoryTitle, completedDaysCount: completedDaysCount)
        let nav = UINavigationController(rootViewController: editVC)
        present(nav, animated: true)
    }
    
    private func showDeleteConfirmation(tracker: Tracker) {
        let alert = UIAlertController(
            title: nil,
            message: NSLocalizedString("main.deleteConfirmation", comment: "Delete confirmation"),
            preferredStyle: .actionSheet
        )
        let deleteAction = UIAlertAction(title: NSLocalizedString("main.delete", comment: "Delete"), style: .destructive) { [weak self] _ in
            self?.deleteTracker(tracker)
        }
        let cancelAction = UIAlertAction(title: NSLocalizedString("common.cancel", comment: "Cancel"), style: .cancel)
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        present(alert, animated: true)
    }
    
    private func deleteTracker(_ tracker: Tracker) {
        do {
            try trackerStore.delete(trackerId: tracker.id)
            completedTrackers = completedTrackers.filter { $0.trackerId != tracker.id }
            NotificationCenter.default.post(name: .trackerRecordsDidChange, object: nil)
            updateFilteredCategories()
        } catch {
            // удаление не удалось
        }
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
    func didCreateTracker(_ tracker: Tracker, categoryTitle: String) {
        do {
            try trackerStore.add(tracker, categoryTitle: categoryTitle)
            // FRC вызовет controllerDidChangeContent и обновит categories
        } catch {
            // сохранение не удалось
        }
    }
    
    func didUpdateTracker(_ tracker: Tracker, categoryTitle: String) {
        do {
            try trackerStore.update(tracker, categoryTitle: categoryTitle)
            // Обновляем локальное состояние, если FRC не уведомит об изменении
            reloadCategoriesFromStore()
        } catch {
            // обновление не удалось
        }
    }
}

// MARK: - FilterListViewControllerDelegate

extension TrackersViewController: FilterListViewControllerDelegate {
    func filterListViewController(_ controller: FilterListViewController, didSelectFilter filter: TrackerFilter) {
        if filter == .today {
            currentDate = Date()
            datePicker.setDate(currentDate, animated: false)
        }
        updateFilteredCategories()
    }
}

