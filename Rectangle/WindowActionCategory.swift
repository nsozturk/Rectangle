/// WindowActionCategory.swift

import Foundation

enum WindowActionCategory {

    case halves, corners, thirds, max, size, display, move, other, sixths, fourths, eighths, ninths, twelfths, sixteenths,
         sixthColumns, eighthColumns, topHalfEighthColumns, topHalfTenthColumns

    var menuOrder: Int {
        switch self {
        case .size: return 0
        case .move: return 1
        case .thirds: return 2
        case .fourths: return 3
        case .sixths: return 4
        case .eighths: return 5
        case .ninths: return 6
        case .twelfths: return 7
        case .sixteenths: return 8
        case .sixthColumns: return 9
        case .eighthColumns: return 10
        case .topHalfEighthColumns: return 11
        case .topHalfTenthColumns: return 12
        default: return 99
        }
    }

    var displayName: String {
        switch self {
        case .halves:
            return NSLocalizedString("Sides", tableName: "Main", value: "", comment: "")
        case .corners:
            return NSLocalizedString("Corners", tableName: "Main", value: "", comment: "")
        case .thirds:
            return NSLocalizedString("Thirds", tableName: "Main", value: "", comment: "")
        case .max:
            return NSLocalizedString("Maximize", tableName: "Main", value: "", comment: "")
        case .size:
            return NSLocalizedString("Size", tableName: "Main", value: "", comment: "")
        case .display:
            return NSLocalizedString("Display", tableName: "Main", value: "", comment: "")
        case .other:
            return NSLocalizedString("Other", tableName: "Main", value: "", comment: "")
        case .move:
            return NSLocalizedString("Move to Edge", tableName: "Main", value: "", comment: "")
        case .fourths:
            return NSLocalizedString("Fourths", tableName: "Main", value: "", comment: "")
        case .sixths:
            return NSLocalizedString("Sixths", tableName: "Main", value: "", comment: "")
        case .eighths:
            return NSLocalizedString("Eighths", tableName: "Main", value: "", comment: "")
        case .ninths:
            return NSLocalizedString("Ninths", tableName: "Main", value: "Ninths", comment: "")
        case .twelfths:
            return NSLocalizedString("Twelfths", tableName: "Main", value: "Twelfths", comment: "")
        case .sixteenths:
            return NSLocalizedString("Sixteenths", tableName: "Main", value: "Sixteenths", comment: "")
        case .sixthColumns:
            return NSLocalizedString("Full-Height Sixths", tableName: "Main", value: "Full-Height Sixths", comment: "")
        case .eighthColumns:
            return NSLocalizedString("Full-Height Eighths", tableName: "Main", value: "Full-Height Eighths", comment: "")
        case .topHalfEighthColumns:
            return NSLocalizedString("Top-Half Eighths", tableName: "Main", value: "Top-Half Eighths", comment: "")
        case .topHalfTenthColumns:
            return NSLocalizedString("Top-Half Tenths", tableName: "Main", value: "Top-Half Tenths", comment: "")
        }
    }
}
