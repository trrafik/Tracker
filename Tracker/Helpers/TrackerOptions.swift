import UIKit

// Эмодзи для трекеров
enum TrackerEmoji: String, CaseIterable {
    case smile = "🙂"
    case heartEyes = "😻"
    case hibiscus = "🌺"
    case dog = "🐶"
    case heart = "❤️"
    case scream = "😱"
    case halo = "😇"
    case angry = "😡"
    case cold = "🥶"
    case thinking = "🤔"
    case raisedHands = "🙌"
    case burger = "🍔"
    case broccoli = "🥦"
    case pingPong = "🏓"
    case medal = "🥇"
    case guitar = "🎸"
    case island = "🏝"
    case sleepy = "😪"
    
    // Строковое представление эмодзи
    var value: String {
        return rawValue
    }
}

// Цвета для трекеров
enum TrackerColor: CaseIterable {
    case red
    case orange
    case blue
    case purple
    case green
    case pink
    case peach
    case lightBlue
    case cyan
    case indigo
    case darkOrange
    case lightPink
    case lightPeach
    case lavender
    case violet
    case lightViolet
    case lightPurple
    case brightGreen
    
    // UIColor для каждого цвета
    var uiColor: UIColor {
        switch self {
        case .red:
            return UIColor(red: 255/255, green: 105/255, blue: 97/255, alpha: 1)
        case .orange:
            return UIColor(red: 255/255, green: 179/255, blue: 71/255, alpha: 1)
        case .blue:
            return UIColor(red: 64/255, green: 156/255, blue: 255/255, alpha: 1)
        case .purple:
            return UIColor(red: 120/255, green: 122/255, blue: 255/255, alpha: 1)
        case .green:
            return UIColor(red: 52/255, green: 199/255, blue: 89/255, alpha: 1)
        case .pink:
            return UIColor(red: 255/255, green: 111/255, blue: 246/255, alpha: 1)
        case .peach:
            return UIColor(red: 255/255, green: 204/255, blue: 153/255, alpha: 1)
        case .lightBlue:
            return UIColor(red: 173/255, green: 216/255, blue: 230/255, alpha: 1)
        case .cyan:
            return UIColor(red: 120/255, green: 220/255, blue: 220/255, alpha: 1)
        case .indigo:
            return UIColor(red: 88/255, green: 86/255, blue: 214/255, alpha: 1)
        case .darkOrange:
            return UIColor(red: 255/255, green: 149/255, blue: 0/255, alpha: 1)
        case .lightPink:
            return UIColor(red: 255/255, green: 192/255, blue: 203/255, alpha: 1)
        case .lightPeach:
            return UIColor(red: 255/255, green: 229/255, blue: 204/255, alpha: 1)
        case .lavender:
            return UIColor(red: 174/255, green: 174/255, blue: 255/255, alpha: 1)
        case .violet:
            return UIColor(red: 191/255, green: 90/255, blue: 242/255, alpha: 1)
        case .lightViolet:
            return UIColor(red: 218/255, green: 143/255, blue: 255/255, alpha: 1)
        case .lightPurple:
            return UIColor(red: 178/255, green: 190/255, blue: 255/255, alpha: 1)
        case .brightGreen:
            return UIColor(red: 48/255, green: 209/255, blue: 88/255, alpha: 1)
        }
    }
}
