import UIKit

class TrackerCell: UICollectionViewCell {
    static let identifier = "TrackerCell"
    
    // MARK: - UI Elements
    
    private let cardView = UIView()
    private let emojiLabel = UILabel()
    private let nameLabel = UILabel()
    private let footerView = UIView()
    private let daysCountLabel = UILabel()
    private let completeButton = UIButton(type: .system)
    
    private var tracker: Tracker?
    private var isCompleted: Bool = false
    private var completedDaysCount: Int = 0
    
    var onCompleteButtonTapped: ((UUID, Bool) -> Void)?
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        contentView.addSubview(cardView)
        cardView.addSubview(emojiLabel)
        cardView.addSubview(nameLabel)
        contentView.addSubview(footerView)
        footerView.addSubview(daysCountLabel)
        footerView.addSubview(completeButton)
        
        // Настройка cardView
        cardView.layer.cornerRadius = 16
        cardView.translatesAutoresizingMaskIntoConstraints = false
        
        // Настройка emojiLabel
        emojiLabel.font = .systemFont(ofSize: 16)
        emojiLabel.textAlignment = .center
        emojiLabel.backgroundColor = .white.withAlphaComponent(0.3)
        emojiLabel.layer.cornerRadius = 12
        emojiLabel.clipsToBounds = true
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Настройка nameLabel
        nameLabel.font = .systemFont(ofSize: 12, weight: .medium)
        nameLabel.textColor = .white
        nameLabel.numberOfLines = 2
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Настройка footerView
        footerView.backgroundColor = .systemBackground
        footerView.translatesAutoresizingMaskIntoConstraints = false
        
        // Настройка daysCountLabel
        daysCountLabel.font = .systemFont(ofSize: 12, weight: .medium)
        daysCountLabel.textColor = AppColors.blackDay
        daysCountLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Настройка completeButton
        completeButton.layer.cornerRadius = 17
        completeButton.addTarget(self, action: #selector(completeButtonTapped), for: .touchUpInside)
        completeButton.translatesAutoresizingMaskIntoConstraints = false
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // cardView
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            cardView.heightAnchor.constraint(equalToConstant: 90),
            
            // emojiLabel
            emojiLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 12),
            emojiLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            emojiLabel.widthAnchor.constraint(equalToConstant: 24),
            emojiLabel.heightAnchor.constraint(equalToConstant: 24),
            
            // nameLabel
            nameLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            nameLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12),
            nameLabel.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -12),
            
            // footerView
            footerView.topAnchor.constraint(equalTo: cardView.bottomAnchor),
            footerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            footerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            footerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            footerView.heightAnchor.constraint(equalToConstant: 58),
            
            // daysCountLabel
            daysCountLabel.leadingAnchor.constraint(equalTo: footerView.leadingAnchor, constant: 12),
            daysCountLabel.centerYAnchor.constraint(equalTo: footerView.centerYAnchor),
            
            // completeButton
            completeButton.trailingAnchor.constraint(equalTo: footerView.trailingAnchor, constant: -12),
            completeButton.centerYAnchor.constraint(equalTo: footerView.centerYAnchor),
            completeButton.widthAnchor.constraint(equalToConstant: 34),
            completeButton.heightAnchor.constraint(equalToConstant: 34)
        ])
    }
    
    // MARK: - Configuration
    
    func configure(
        with tracker: Tracker,
        isCompleted: Bool,
        completedDaysCount: Int,
        isFutureDate: Bool = false
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
    }
    
    private func updateDaysCountLabel() {
        let daysText = completedDaysCount == 1 ? "день" : "дней"
        daysCountLabel.text = "\(completedDaysCount) \(daysText)"
    }
    
    private func updateCompleteButton(isFutureDate: Bool = false) {
        if isFutureDate {
            completeButton.setImage(UIImage(systemName: "plus"), for: .normal)
            completeButton.tintColor = cardView.backgroundColor
            completeButton.backgroundColor = .white
            completeButton.isEnabled = false
        } else if isCompleted {
            completeButton.setImage(UIImage(systemName: "checkmark"), for: .normal)
            completeButton.tintColor = .white
            completeButton.backgroundColor = cardView.backgroundColor?.withAlphaComponent(0.3)
            completeButton.isEnabled = true
        } else {
            completeButton.setImage(UIImage(systemName: "plus"), for: .normal)
            completeButton.tintColor = .white
            completeButton.backgroundColor = cardView.backgroundColor
            completeButton.isEnabled = true
        }
    }
    
    // MARK: - Actions
    
    @objc private func completeButtonTapped() {
        guard let tracker = tracker else { return }
        let newState = !isCompleted
        onCompleteButtonTapped?(tracker.id, newState)
    }
}


