import UIKit

class TrackerCell: UICollectionViewCell {
    // MARK: - Constants

    private enum Constants {
        static let cardCornerRadius: CGFloat = 16
        static let emojiCornerRadius: CGFloat = 12
        static let completeButtonCornerRadius: CGFloat = 17

        static let cardHeight: CGFloat = 90
        static let footerHeight: CGFloat = 58

        static let emojiSize: CGFloat = 24
        static let completeButtonSize: CGFloat = 34

        static let horizontalPadding: CGFloat = 12
        static let verticalPadding: CGFloat = 12
    }
    
    // MARK: - Public
    
    static let identifier = "TrackerCell"
    var onCompleteButtonTapped: ((UUID, Bool) -> Void)?
    /// Конфигурация контекстного меню для ячейки.
    var onContextMenuConfiguration: (() -> UIContextMenuConfiguration?)?
    
    // MARK: - Private

    private var tracker: Tracker?
    private var isCompleted: Bool = false
    private var completedDaysCount: Int = 0
    private var contextMenuInteraction: UIContextMenuInteraction?
    
    // MARK: - UI Elements
    
    private lazy var cardView: UIView = {
            let view = UIView()
            view.layer.cornerRadius = Constants.cardCornerRadius
            view.translatesAutoresizingMaskIntoConstraints = false
            return view
        }()
    
    private lazy var emojiLabel: UILabel = {
            let label = UILabel()
            label.font = .systemFont(ofSize: 16)
            label.textAlignment = .center
            label.backgroundColor = .white.withAlphaComponent(0.3)
            label.layer.cornerRadius = Constants.emojiCornerRadius
            label.clipsToBounds = true
            label.translatesAutoresizingMaskIntoConstraints = false
            return label
        }()
    
    private lazy var nameLabel: UILabel = {
            let label = UILabel()
            label.font = .systemFont(ofSize: 12, weight: .medium)
            label.textColor = .white
            label.numberOfLines = 2
            label.translatesAutoresizingMaskIntoConstraints = false
            return label
        }()
    
    private lazy var footerView: UIView = {
            let view = UIView()
            view.backgroundColor = AppColors.primaryColor
            view.translatesAutoresizingMaskIntoConstraints = false
            return view
        }()
    
    private lazy var daysCountLabel: UILabel = {
            let label = UILabel()
            label.font = .systemFont(ofSize: 12, weight: .medium)
            label.textColor = AppColors.primaryInvertedColor
            label.translatesAutoresizingMaskIntoConstraints = false
            return label
        }()
    
    private lazy var completeButton: UIButton = {
            let button = UIButton(type: .system)
            button.layer.cornerRadius = Constants.completeButtonCornerRadius
            button.addTarget(self, action: #selector(completeButtonTapped), for: .touchUpInside)
            button.translatesAutoresizingMaskIntoConstraints = false
            return button
        }()
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViewHierarchy()
        setupConstraints()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }
    
    // MARK: - Setup

    private func setupViewHierarchy() {
        contentView.addSubview(cardView)
        contentView.addSubview(footerView)

        cardView.addSubview(emojiLabel)
        cardView.addSubview(nameLabel)

        footerView.addSubview(daysCountLabel)
        footerView.addSubview(completeButton)
    }
    
    private func setupConstraints() {
            NSLayoutConstraint.activate([
                // Card
                cardView.topAnchor.constraint(equalTo: contentView.topAnchor),
                cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
                cardView.heightAnchor.constraint(equalToConstant: Constants.cardHeight),

                // Emoji
                emojiLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: Constants.verticalPadding),
                emojiLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: Constants.horizontalPadding),
                emojiLabel.widthAnchor.constraint(equalToConstant: Constants.emojiSize),
                emojiLabel.heightAnchor.constraint(equalToConstant: Constants.emojiSize),

                // Name
                nameLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: Constants.horizontalPadding),
                nameLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -Constants.horizontalPadding),
                nameLabel.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -Constants.verticalPadding),

                // Footer
                footerView.topAnchor.constraint(equalTo: cardView.bottomAnchor),
                footerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                footerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
                footerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
                footerView.heightAnchor.constraint(equalToConstant: Constants.footerHeight),

                // Days label
                daysCountLabel.leadingAnchor.constraint(equalTo: footerView.leadingAnchor, constant: Constants.horizontalPadding),
                daysCountLabel.centerYAnchor.constraint(equalTo: footerView.centerYAnchor),

                // Complete button
                completeButton.trailingAnchor.constraint(equalTo: footerView.trailingAnchor, constant: -Constants.horizontalPadding),
                completeButton.centerYAnchor.constraint(equalTo: footerView.centerYAnchor),
                completeButton.widthAnchor.constraint(equalToConstant: Constants.completeButtonSize),
                completeButton.heightAnchor.constraint(equalToConstant: Constants.completeButtonSize)
            ])
        }
    
    // MARK: - Configuration
    
    func configure(
        with tracker: Tracker,
        isCompleted: Bool,
        completedDaysCount: Int,
        isFutureDate: Bool
    ) {
        self.tracker = tracker
        self.isCompleted = isCompleted
        self.completedDaysCount = completedDaysCount
        
        // Настройка карточки
        cardView.backgroundColor = tracker.color
        emojiLabel.text = tracker.emoji
        nameLabel.text = tracker.name
        
        // Настройка счетчика
        updateDaysCountLabel()
        
        // Настройка кнопки
        updateCompleteButton(isFutureDate: isFutureDate)
        
        if contextMenuInteraction == nil {
            let interaction = UIContextMenuInteraction(delegate: self)
            cardView.addInteraction(interaction)
            contextMenuInteraction = interaction
        }
    }
    
    // MARK: - Private Helpers
    
    private func updateDaysCountLabel() {
        daysCountLabel.text = String.localizedStringWithFormat(
            NSLocalizedString("days_count", comment: "N days"),
            completedDaysCount
        )
    }
    
    private func updateCompleteButton(isFutureDate: Bool = false) {
        if isFutureDate {
            completeButton.setImage(UIImage(systemName: "plus"), for: .normal)
            completeButton.tintColor = cardView.backgroundColor
            completeButton.backgroundColor = AppColors.primaryColor
            completeButton.isEnabled = false
        } else if isCompleted {
            completeButton.setImage(UIImage(systemName: "checkmark"), for: .normal)
            completeButton.tintColor = AppColors.primaryColor
            completeButton.backgroundColor = cardView.backgroundColor?.withAlphaComponent(0.3)
            completeButton.isEnabled = true
        } else {
            completeButton.setImage(UIImage(systemName: "plus"), for: .normal)
            completeButton.tintColor = AppColors.primaryColor
            completeButton.backgroundColor = cardView.backgroundColor
            completeButton.isEnabled = true
        }
    }
    
    // MARK: - Actions
    
    @objc private func completeButtonTapped() {
        guard let tracker = tracker else { return }
        onCompleteButtonTapped?(tracker.id, !isCompleted)
    }
}

// MARK: - UIContextMenuInteractionDelegate

extension TrackerCell: UIContextMenuInteractionDelegate {
    func contextMenuInteraction(
        _ interaction: UIContextMenuInteraction,
        configurationForMenuAtLocation location: CGPoint
    ) -> UIContextMenuConfiguration? {
        return onContextMenuConfiguration?()
    }
}


