import UIKit

final class StatCardView: UIView {

    private let gradientLayer = CAGradientLayer()
    private let valueLabel = UILabel()
    private let titleLabel = UILabel()

    init(value: String, title: String) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        layer.cornerRadius = 16
        clipsToBounds = true
        backgroundColor = AppColors.primaryColor

        gradientLayer.colors = [
            UIColor(red: 1, green: 0.2, blue: 0.2, alpha: 1).cgColor,
            UIColor(red: 0.2, green: 0.8, blue: 0.4, alpha: 1).cgColor,
            UIColor(red: 0.2, green: 0.4, blue: 1, alpha: 1).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        gradientLayer.cornerRadius = 16
        layer.insertSublayer(gradientLayer, at: 0)

        let inner = UIView()
        inner.translatesAutoresizingMaskIntoConstraints = false
        inner.backgroundColor = AppColors.primaryColor
        inner.layer.cornerRadius = 15

        valueLabel.text = value
        valueLabel.font = .systemFont(ofSize: 34, weight: .bold)
        valueLabel.textColor = AppColors.primaryInvertedColor
        valueLabel.translatesAutoresizingMaskIntoConstraints = false

        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 12, weight: .medium)
        titleLabel.textColor = AppColors.primaryInvertedColor
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        addSubview(inner)
        inner.addSubview(valueLabel)
        inner.addSubview(titleLabel)

        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 90),
            inner.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 1),
            inner.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -1),
            inner.topAnchor.constraint(equalTo: topAnchor, constant: 1),
            inner.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -1),
            valueLabel.leadingAnchor.constraint(equalTo: inner.leadingAnchor, constant: 12),
            valueLabel.topAnchor.constraint(equalTo: inner.topAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: inner.leadingAnchor, constant: 12),
            titleLabel.topAnchor.constraint(equalTo: valueLabel.bottomAnchor, constant: 7)
        ])
    }

    required init?(coder: NSCoder) { nil }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }
}
