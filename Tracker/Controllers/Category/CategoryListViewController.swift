import UIKit

final class CategoryListViewController: UIViewController {

    weak var delegate: CategoryListViewControllerDelegate?

    private let viewModel: CategoryListViewModel

    // MARK: - UI

    private lazy var placeholderView: UIView = {
        let v = UIView()
        v.isHidden = true
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let placeholderImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(resource: .placeHolder)
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let placeholderLabel: UILabel = {
        let l = UILabel()
        let p = NSMutableParagraphStyle()
        p.minimumLineHeight = 18
        p.maximumLineHeight = 18
        p.alignment = .center
        l.attributedText = NSAttributedString(
            string: "Привычки и события можно\nобъединить по смыслу",
            attributes: [.font: UIFont.systemFont(ofSize: 12, weight: .medium), .paragraphStyle: p]
        )
        l.numberOfLines = 0
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private lazy var tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.delegate = self
        tv.dataSource = self
        tv.register(CategoryTableViewCell.self, forCellReuseIdentifier: CategoryTableViewCell.reuseIdentifier)
        tv.backgroundColor = .clear
        tv.separatorStyle = .none
        tv.layer.cornerRadius = 16
        tv.layer.masksToBounds = true
        tv.rowHeight = 75
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()

    private lazy var addCategoryButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("Добавить категорию", for: .normal)
        b.setTitleColor(.white, for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        b.backgroundColor = AppColors.blackDay
        b.layer.cornerRadius = 16
        b.addAction(UIAction { [weak self] _ in self?.addCategoryTapped() }, for: .touchUpInside)
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()

    // MARK: - Init

    init(selectedCategoryTitle: String?) {
        self.viewModel = CategoryListViewModel(selectedCategoryTitle: selectedCategoryTitle)
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationItem.title = "Категория"
        navigationController?.navigationBar.prefersLargeTitles = false
        setupBindings()
        setupUI()
        viewModel.loadCategories()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.loadCategories()
    }

    private func setupBindings() {
        viewModel.onCategoriesDidChange = { [weak self] in
            self?.updateUI()
        }
        viewModel.onSelectionDidChange = { [weak self] title in
            guard let self else { return }
            self.delegate?.categoryListViewController(self, didSelectCategory: title)
        }
        viewModel.onSelectionIndexDidChange = { [weak self] previousIndex, newIndex in
            guard let self else { return }
            // Обновляем только галочку в ячейках без reload — separator не перерисовывается
            func updateCell(at row: Int) {
                let indexPath = IndexPath(row: row, section: 0)
                guard let cell = self.tableView.cellForRow(at: indexPath) as? CategoryTableViewCell,
                      let title = self.viewModel.categoryTitle(at: row) else { return }
                cell.configure(title: title, isSelected: self.viewModel.isSelected(at: row))
            }
            updateCell(at: newIndex)
            if let prev = previousIndex, prev != newIndex {
                updateCell(at: prev)
            }
        }
    }

    private func setupUI() {
        placeholderView.addSubview(placeholderImageView)
        placeholderView.addSubview(placeholderLabel)
        view.addSubview(placeholderView)
        view.addSubview(tableView)
        view.addSubview(addCategoryButton)

        NSLayoutConstraint.activate([
            placeholderImageView.centerXAnchor.constraint(equalTo: placeholderView.centerXAnchor),
            placeholderImageView.topAnchor.constraint(equalTo: placeholderView.topAnchor),
            placeholderImageView.widthAnchor.constraint(equalToConstant: 80),
            placeholderImageView.heightAnchor.constraint(equalToConstant: 80),
            placeholderLabel.topAnchor.constraint(equalTo: placeholderImageView.bottomAnchor, constant: 8),
            placeholderLabel.leadingAnchor.constraint(equalTo: placeholderView.leadingAnchor, constant: 16),
            placeholderLabel.trailingAnchor.constraint(equalTo: placeholderView.trailingAnchor, constant: -16),
            placeholderLabel.bottomAnchor.constraint(equalTo: placeholderView.bottomAnchor),

            placeholderView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholderView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -40),

            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            tableView.bottomAnchor.constraint(equalTo: addCategoryButton.topAnchor, constant: -16),

            addCategoryButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            addCategoryButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addCategoryButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            addCategoryButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }

    private func updateUI() {
        let isEmpty = viewModel.isEmpty
        placeholderView.isHidden = !isEmpty
        tableView.isHidden = isEmpty
        tableView.reloadData()
    }

    private func addCategoryTapped() {
        let newCategoryVC = NewCategoryViewController()
        newCategoryVC.onCategoryCreated = { [weak self] _ in
            self?.viewModel.loadCategories()
        }
        let nav = UINavigationController(rootViewController: newCategoryVC)
        present(nav, animated: true)
    }
}

// MARK: - UITableViewDataSource

extension CategoryListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.rowsAmount
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CategoryTableViewCell.reuseIdentifier, for: indexPath) as? CategoryTableViewCell,
              let title = viewModel.categoryTitle(at: indexPath.row) else {
            return UITableViewCell()
        }
        let count = viewModel.rowsAmount
        let isFirst = indexPath.row == 0
        let isLast = indexPath.row == count - 1
        cell.configure(title: title, isSelected: viewModel.isSelected(at: indexPath.row))
        cell.configureRounding(isFirst: isFirst, isLast: isLast)
        return cell
    }
}

// MARK: - UITableViewDelegate

extension CategoryListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        viewModel.selectCategory(at: indexPath.row)
    }
}

// MARK: - Delegate

protocol CategoryListViewControllerDelegate: AnyObject {
    func categoryListViewController(_ controller: CategoryListViewController, didSelectCategory title: String)
}
