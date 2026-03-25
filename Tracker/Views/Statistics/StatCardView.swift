
import UIKit

final class StatCardView: UIView {

    // MARK: - Constants
    
    private enum Constants {
        static let cornerRadius: CGFloat = 16
        static let innerInset: CGFloat = 1
        static let height: CGFloat = 90
        static let horizontalPadding: CGFloat = 12
        static let verticalPadding: CGFloat = 12
        static let labelSpacing: CGFloat = 7
    }
    
    // MARK: - Layers
    
    private let gradientLayer = CAGradientLayer()
    
    // MARK: - UI
    
    private let innerView = UIView()
    private let valueLabel = UILabel()
    private let titleLabel = UILabel()
    
    // MARK: - Init
    
    init(value: String, title: String) {
        super.init(frame: .zero)
        setupView()
        configure(value: value, title: title)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }
    
    // MARK: - Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }
    
    // MARK: - Setup
    
    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = AppColors.primaryColor
        layer.cornerRadius = Constants.cornerRadius
        clipsToBounds = true
        
        setupGradient()
        setupInnerView()
        setupLabels()
        setupConstraints()
    }
    
    private func setupGradient() {
        gradientLayer.colors = [
            UIColor.systemRed.cgColor,
            UIColor.systemGreen.cgColor,
            UIColor.systemBlue.cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        gradientLayer.cornerRadius = Constants.cornerRadius
        
        layer.insertSublayer(gradientLayer, at: 0)
    }
    
    private func setupInnerView() {
        innerView.translatesAutoresizingMaskIntoConstraints = false
        innerView.backgroundColor = AppColors.primaryColor
        innerView.layer.cornerRadius = Constants.cornerRadius - Constants.innerInset
        addSubview(innerView)
    }
    
    private func setupLabels() {
        valueLabel.font = .systemFont(ofSize: 34, weight: .bold)
        valueLabel.textColor = AppColors.primaryInvertedColor
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        
        titleLabel.font = .systemFont(ofSize: 12, weight: .medium)
        titleLabel.textColor = AppColors.primaryInvertedColor
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        innerView.addSubview(valueLabel)
        innerView.addSubview(titleLabel)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: Constants.height),
            
            innerView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.innerInset),
            innerView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.innerInset),
            innerView.topAnchor.constraint(equalTo: topAnchor, constant: Constants.innerInset),
            innerView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Constants.innerInset),
            
            valueLabel.leadingAnchor.constraint(equalTo: innerView.leadingAnchor, constant: Constants.horizontalPadding),
            valueLabel.topAnchor.constraint(equalTo: innerView.topAnchor, constant: Constants.verticalPadding),
            
            titleLabel.leadingAnchor.constraint(equalTo: innerView.leadingAnchor, constant: Constants.horizontalPadding),
            titleLabel.topAnchor.constraint(equalTo: valueLabel.bottomAnchor, constant: Constants.labelSpacing)
        ])
    }
    
    // MARK: - Public
    
    func configure(value: String, title: String) {
        valueLabel.text = value
        titleLabel.text = title
    }
}
