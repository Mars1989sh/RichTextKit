//
//  RTKL10n.swift
//  KeyboardKit
//
//  Created by Daniel Saidi on 2022-12-14.
//  Copyright © 2022-2023 Daniel Saidi. All rights reserved.
//

import SwiftUI

/**
 This enum defines RichTextKit-specific, localized texts.
 */
public enum RTKL10n: String, CaseIterable, Identifiable {

    case
    done,

    font,
    fontSize,

    color,
    foregroundColor,
    backgroundColor,
    underlineColor,
    strikethroughColor,
    strokeColor,

    actionCopy,
    actionDismissKeyboard,
    actionFontSizeIncrease,
    actionFontSizeDecrease,
    actionIndentIncrease,
    actionIndentDecrease,
    actionPrint,

    actionRedoLatestChange,
    actionUndoLatestChange,

    fileFormatRtk,
    fileFormatPdf,
    fileFormatRtf,
    fileFormatTxt,

    menuExport,
    menuExportAs,
    menuFont,
    menuFormat,
    menuIndent,
    menuIndentIncrease,
    menuIndentDecrease,
    menuPrint,
    menuSave,
    menuSaveAs,
    menuShare,
    menuShareAs,
    menuText,

    highlightedRange,
    highlightingStyle,

    pasteImage,
    pasteImages,
    pasteText,
    selectRange,

    setAttributedString,

    styleBold,
    styleItalic,
    styleStrikethrough,
    styleUnderlined,

    textAlignment,
    textAlignmentLeft,
    textAlignmentRight,
    textAlignmentCentered,
    textAlignmentJustified
}

public extension RTKL10n {

    static func actionStepFontSize(
        _ points: Int
    ) -> RTKL10n {
        points < 0 ?
            .actionFontSizeDecrease :
            .actionFontSizeIncrease
    }

    static func actionStepIndent(
        _ points: Double
    ) -> RTKL10n {
        points < 0 ?
            .actionIndentDecrease :
            .actionIndentIncrease
    }

    static func actionStepSuperscript(
        _ steps: Int
    ) -> RTKL10n {
        steps < 0 ?
            .actionIndentDecrease :
            .actionIndentIncrease
    }

    static func menuIndent(_ points: Double) -> RTKL10n {
        points < 0 ?
            .menuIndentDecrease :
            .menuIndentIncrease
    }
}

public extension RTKL10n {

    /**
     The bundle to use to retrieve localized strings.

     You should only override this value when the entire set
     of localized texts should be loaded from another bundle.
     */
    static var bundle: Bundle = .richTextKit
}

public extension RTKL10n {

    /// The item's unique identifier.
    var id: String { rawValue }

    /// The item's localization key.
    var key: String { rawValue }

    /// The item's localized text.
    var text: String {
        text(for: .current)
    }

    /// Get the localized text for a certain `Locale`.
    func text(for locale: Locale) -> String {
        guard let bundle = Bundle.richTextKit.bundle(for: locale) else { return "" }
        return NSLocalizedString(key, bundle: bundle, comment: "")
    }
}

#if iOS || os(tvOS) || os(visionOS)
struct RTKL10n_Previews: PreviewProvider {

    static var locales: [Locale] = [
        .init(identifier: "en"),
        .init(identifier: "da"),
        .init(identifier: "de"),
        .init(identifier: "nb"),
        .init(identifier: "sv")
    ]

    static var previews: some View {
        NavigationView {
            List {
                ForEach(RTKL10n.allCases) { item in
                    VStack(alignment: .leading, spacing: 10) {
                        Text("\(item.key)")
                        VStack(alignment: .leading) {
                            Text("default: \(item.text)")
                            ForEach(Array(locales.enumerated()), id: \.offset) {
                                Text("\($0.element.identifier): \(item.text(for: $0.element))")
                            }
                        }.font(.footnote)
                    }.padding(.vertical, 4)
                }
            }.navigationBarTitle("Translations")
        }.navigationViewStyle(.stack)
    }
}
#endif
