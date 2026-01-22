import UIKit

class TrackersViewController: UIViewController {
    private let label = UILabel()
    private let imageView = UIImageView()
    private let searchController = UISearchController(searchResultsController: nil)
    private let datePicker = UIDatePicker()

    private let blackDayColor = UIColor(red: 26.0 / 255.0, green: 27.0 / 255.0, blue: 34.0 / 255.0, alpha: 1.0) // #1A1B22
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupSearchController()
        setupUI()
        addPlaceHolder()
    }
    
    // MARK: - Navigation Bar
    
    private func setupNavigationBar() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        navigationItem.title = "Трекеры"

        // Цвета элементов Navigation Bar
        navigationController?.navigationBar.tintColor = blackDayColor
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = .systemBackground
        appearance.largeTitleTextAttributes = [
            .foregroundColor: blackDayColor,
            .font: UIFont.systemFont(ofSize: 34, weight: .bold) // SF Pro, 34pt, 700
        ]
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        
        // Левая кнопка с иконкой "плюс"
        let addButton = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addButtonTapped)
        )
        navigationItem.leftBarButtonItem = addButton
        
        // Правая часть — UIDatePicker с компактным стилем и режимом Date
        datePicker.preferredDatePickerStyle = .compact
        datePicker.datePickerMode = .date
        datePicker.locale = Locale(identifier: "ru_RU")
        datePicker.tintColor = blackDayColor
        
        let dateItem = UIBarButtonItem(customView: datePicker)
        navigationItem.rightBarButtonItem = dateItem
    }
    
    @objc
    private func addButtonTapped() {
        // TODO: Обработка нажатия на кнопку "плюс" будет добавлена позже
    }
    
    // MARK: - Search
    
    private func setupSearchController() {
        searchController.searchResultsUpdater = nil
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Поиск"
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
    }
    
    // MARK: - UI
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        label.text = "Что будем отслеживать?"
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -220)
        ])
    }
    
    private func addPlaceHolder() {
        imageView.image = UIImage(resource: .placeHolder)
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(imageView)
        
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.bottomAnchor.constraint(equalTo: label.topAnchor, constant: -8),
            imageView.widthAnchor.constraint(equalToConstant: 80),
            imageView.heightAnchor.constraint(equalToConstant: 80)
        ])
    }
}
