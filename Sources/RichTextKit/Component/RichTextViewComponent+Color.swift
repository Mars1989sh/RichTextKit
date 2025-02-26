//
//  RichTextViewComponent+Color.swift
//  RichTextKit
//
//  Created by Daniel Saidi on 2022-05-30.
//  Copyright © 2022-2023 Daniel Saidi. All rights reserved.
//

import Foundation

public extension RichTextViewComponent {

    /// Get a certain rich text color at current range.
    func richTextColor(
        _ color: RichTextColor
    ) -> ColorRepresentable? {
        guard let attribute = color.attribute else { return nil }
        return richTextAttribute(attribute)
    }

    /// Set a certain rich text color at current range.
    func setRichTextColor(
        _ color: RichTextColor,
        to val: ColorRepresentable
    ) {
        if richTextColor(color) == val { return }
        guard let attribute = color.attribute else { return }
        setRichTextAttribute(attribute, to: val)
    }
}
