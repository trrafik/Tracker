import UIKit

final class NewCategoryViewController: UIViewController {

    // Вызывается после успешного создания категории (передаётся название)
    var onCategoryCreated: ((String) -> Void)?

    // MARK: - UI

    private lazy var textField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Введите название категории"
        tf.backgroundColor = AppColors.grayBackground
        tf.layer.cornerRadius = 16
        tf.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        tf.leftViewMode = .always
        tf.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        tf.rightViewMode = .always
        tf.font = .systemFont(ofSize: 17, weight: .regular)
        tf.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()

    private lazy var doneButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("Готово", for: .normal)
        b.setTitleColor(.white, for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        b.backgroundColor = AppColors.grayButton
        b.layer.cornerRadius = 16
        b.isEnabled = false
        b.addTarget(self, action: #selector(doneTapped), for: .touchUpInside)
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationItem.title = "Новая категория"
        navigationController?.navigationBar.prefersLargeTitles = false
        view.addSubview(textField)
        view.addSubview(doneButton)
        setupTapGesture()
        NSLayoutConstraint.activate([
            textField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            textField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            textField.heightAnchor.constraint(equalToConstant: 75),
            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            doneButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }

    private func setupTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }

    // MARK: - Actions

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    @objc private func textFieldDidChange() {
        let hasText = !(textField.text?.trimmingCharacters(in: .whitespaces).isEmpty ?? true)
        doneButton.isEnabled = hasText
        doneButton.backgroundColor = hasText ? AppColors.blackDay : AppColors.grayButton
    }

    @objc private func doneTapped() {
        guard let title = textField.text?.trimmingCharacters(in: .whitespaces), !title.isEmpty else { return }
        let store = TrackerCategoryStore()
        do {
            _ = try store.category(withTitle: title)
            onCategoryCreated?(title)
            dismiss(animated: true)
        } catch {
            // можно показать алерт
        }
    }
}
