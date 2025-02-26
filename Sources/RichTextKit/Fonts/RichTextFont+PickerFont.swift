//
//  RichTextFontPickerFont.swift
//  RichTextKit
//
//  Created by Daniel Saidi on 2022-06-01.
//  Copyright © 2022-2023 Daniel Saidi. All rights reserved.
//

import Foundation

#if canImport(AppKit) && !targetEnvironment(macCatalyst)
import AppKit
#endif

#if canImport(UIKit)
import UIKit
#endif

public extension RichTextFont {

    /**
     This struct is used by the various font pickers.

     Instead of referring to actual fonts, the struct refers
     to fonts by name, to simplify binding.

     You can use ``all`` to get all fonts, and rearrange the
     collection as needed.

     Some fonts are special when being listed in a picker or
     displayed elsewhere. One such example is `San Francisco`,
     which must have its name adjusted.

     To change the display name of a system font, simply set
     ``RichTextFont/PickerFont/standardSystemFontDisplayName``
     to another value.

     To change how fonts are detected by the system, use the
     ``systemFontNamePrefix`` to define a font name prefix.
     */
    struct PickerFont: Identifiable, Equatable {

        public init(fontName: String) {
            let fontName = fontName.capitalized
            self.fontName = fontName
            self.fontDisplayName = ""
            self.fontDisplayName = displayName
        }

        public let fontName: String
        public private(set) var fontDisplayName: String

        /**
         Get the unique font id.
         */
        public var id: String {
            fontName.lowercased()
        }
    }
}

// MARK: - Static Properties

public extension RichTextFont.PickerFont {

    /// Get all available system fonts.
    static var all: [Self] {
        let all = systemFonts
        let systemFont = Self.init(fontName: "")
        var sorted = all.sorted { $0.fontDisplayName < $1.fontDisplayName }
        sorted.insert(systemFont, at: 0)
        return sorted
    }

    /// The display name for the standard system font.
    static var standardSystemFontDisplayName: String {
        #if macOS
        return "Standard"
        #else
        return "San Francisco"
        #endif
    }

    /// The font name prefix for the standard system font.
    static var systemFontNamePrefix: String {
        #if macOS
        return ".AppleSystemUIFont"
        #else
        return ".SFUI"
        #endif
    }
}

// MARK: - Public Properties

public extension RichTextFont.PickerFont {

    /// Get the font display name.
    var displayName: String {
        let isSystemFont = isStandardSystemFont
        let systemName = Self.standardSystemFontDisplayName
        return isSystemFont ? systemName : fontName
    }

    ///  Check if the a font name represents the system font.
    var isStandardSystemFont: Bool {
        let name = fontName.trimmingCharacters(in: .whitespaces)
        if name.isEmpty { return true }
        let systemPrefix = Self.systemFontNamePrefix
        return name.uppercased().hasPrefix(systemPrefix)
    }
}

// MARK: - Collection Extensions

public extension Collection where Element == RichTextFont.PickerFont {

    /// Get all available system fonts.
    static var all: [Element] {
        Element.all
    }

    /// Move a certain font topmost in the list.
    func moveTopmost(_ topmost: String) -> [Element] {
        let topmost = topmost.trimmingCharacters(in: .whitespaces)
        let exists = contains { $0.fontName.lowercased() == topmost.lowercased() }
        guard exists else { return Array(self) }
        var filtered = filter { $0.fontName.lowercased() != topmost.lowercased() }
        let new = Element(fontName: topmost)
        filtered.insert(new, at: 0)
        return filtered
    }
}

// MARK: - System Fonts

private extension RichTextFont.PickerFont {

    /**
     Get all available font picker fonts.
     */
    static var systemFonts: [RichTextFont.PickerFont] {
        #if canImport(AppKit) && !targetEnvironment(macCatalyst)
        return NSFontManager.shared
            .availableFontFamilies
            .map {
                RichTextFont.PickerFont(fontName: $0)
            }
        #endif

        #if canImport(UIKit)
        return UIFont.familyNames
            .map {
                RichTextFont.PickerFont(fontName: $0)
            }
        #endif
    }
}
