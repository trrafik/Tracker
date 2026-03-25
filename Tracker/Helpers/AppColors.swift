import UIKit

enum AppColors {
    static let blackDay = UIColor(red: 26.0 / 255.0, green: 27.0 / 255.0, blue: 34.0 / 255.0, alpha: 1.0)
    static let grayBackground = UIColor(red: 230.0 / 255.0, green: 232.0 / 255.0, blue: 235.0 / 255.0, alpha: 0.3)
    static let redButton = UIColor(red: 245.0 / 255.0, green: 107.0 / 255.0, blue: 108.0 / 255.0, alpha: 1.0)
    static let grayButton = UIColor(red: 174.0 / 255.0, green: 175.0 / 255.0, blue: 180.0 / 255.0, alpha: 1.0)
    static let blueSwitch = UIColor(red: 55.0 / 255.0, green: 114.0 / 255.0, blue: 231.0 / 255.0, alpha: 1.0) // #3772E7
    static let greenTracker = UIColor(red: 51.0 / 255.0, green: 207.0 / 255.0, blue: 105.0 / 255.0, alpha: 1.0) // #33CF69
    /// Динамический цвет: в светлой теме — blackDay, в тёмной — белый.
    static let primaryInvertedColor = UIColor { traitCollection in
        traitCollection.userInterfaceStyle == .dark
        ? .white
            : blackDay
    }
    /// Динамический цвет: в светлой теме — белый, в тёмной — blackDay.
    static let primaryColor = UIColor { traitCollection in
        traitCollection.userInterfaceStyle == .dark
            ? blackDay
            : .white
    }
}

