//
//  RichTextCoordinator.swift
//  RichTextKit
//
//  Created by Daniel Saidi on 2022-05-22.
//  Copyright © 2022-2023 Daniel Saidi. All rights reserved.
//

#if iOS || macOS || os(tvOS) || os(visionOS)
import Combine
import SwiftUI

/**
 This coordinator is used to keep a ``RichTextView`` in sync
 with a ``RichTextContext``.

 The coordinator sets itself as the text view's delegate and
 updates the context when things change in the text view. It
 also subscribes to context observable changes and keeps the
 text view in sync with these changes.

 You can inherit this class to customize the coordinator for
 your own use cases.
 */
open class RichTextCoordinator: NSObject {

    // MARK: - Initialization

    /**
     Create a rich text coordinator.

     - Parameters:
       - text: The rich text to edit.
       - textView: The rich text view to keep in sync.
       - richTextContext: The context to keep in sync.
     */
    public init(
        text: Binding<NSAttributedString>,
        textView: RichTextView,
        richTextContext: RichTextContext
    ) {
        textView.attributedString = text.wrappedValue
        self.text = text
        self.textView = textView
        self.richTextContext = richTextContext
        super.init()
        self.textView.delegate = self
        subscribeToUserActions()
    }

    // MARK: - Properties

    /// The rich text context to coordinate with.
    public let richTextContext: RichTextContext

    /// The rich text to edit.
    public var text: Binding<NSAttributedString>

    /// The text view for which the coordinator is used.
    public private(set) var textView: RichTextView

    /// This set is used to store context observations.
    public var cancellables = Set<AnyCancellable>()

    /// This flag is used to avoid delaying context sync.
    var shouldDelaySyncContextWithTextView = true

    // MARK: - Internal Properties

    /**
     The background color that was used before the currently
     highlighted range was set.
     */
    var highlightedRangeOriginalBackgroundColor: ColorRepresentable?

    /**
     The foreground color that was used before the currently
     highlighted range was set.
     */
     var highlightedRangeOriginalForegroundColor: ColorRepresentable?

    #if canImport(UIKit)

    // MARK: - UITextViewDelegate

    open func textViewDidBeginEditing(_ textView: UITextView) {
        richTextContext.isEditingText = true
    }

    open func textViewDidChange(_ textView: UITextView) {
        syncWithTextView()
    }

    open func textViewDidChangeSelection(_ textView: UITextView) {
        syncWithTextView()
    }

    open func textViewDidEndEditing(_ textView: UITextView) {
        richTextContext.isEditingText = false
    }
    #endif

    #if canImport(AppKit) && !targetEnvironment(macCatalyst)

    // MARK: - NSTextViewDelegate

    open func textDidBeginEditing(_ notification: Notification) {
        richTextContext.isEditingText = true
    }

    open func textDidChange(_ notification: Notification) {
        syncWithTextView()
    }

    open func textViewDidChangeSelection(_ notification: Notification) {
        syncWithTextView()
    }

    open func textDidEndEditing(_ notification: Notification) {
        richTextContext.isEditingText = false
    }
    #endif
}

#if iOS || os(tvOS) || os(visionOS)
import UIKit

extension RichTextCoordinator: UITextViewDelegate {}

#elseif macOS
import AppKit

extension RichTextCoordinator: NSTextViewDelegate {}
#endif

// MARK: - Public Extensions

public extension RichTextCoordinator {

    /// Reset appearance for the currently highlighted range.
    func resetHighlightedRangeAppearance() {
        guard
            let range = richTextContext.highlightedRange,
            let background = highlightedRangeOriginalBackgroundColor,
            let foreground = highlightedRangeOriginalForegroundColor
        else { return }
        textView.setRichTextColor(.background, to: background, at: range)
        textView.setRichTextColor(.foreground, to: foreground, at: range)
    }
}

// MARK: - Internal Extensions

extension RichTextCoordinator {

    /// Sync state from the text view's current state.
    func syncWithTextView() {
        syncContextWithTextView()
        syncTextWithTextView()
    }

    /// Sync the rich text context with the text view.
    func syncContextWithTextView() {
        if shouldDelaySyncContextWithTextView {
            DispatchQueue.main.async {
                self.syncContextWithTextViewAfterDelay()
            }
        } else {
            syncContextWithTextViewAfterDelay()
        }
    }

    /**
     Sync the rich text context with the text view after the
     dispatch queue delay above. The delay will silence some
     purple alert warnings about how state is updated.
     */
    func syncContextWithTextViewAfterDelay() {
        let styles = textView.richTextStyles

        let string = textView.attributedString
        if richTextContext.attributedString != string {
            richTextContext.attributedString = string
        }

        let range = textView.selectedRange
        if richTextContext.selectedRange != range {
            richTextContext.selectedRange = range
        }

        RichTextColor.allCases.forEach {
            if let color = textView.richTextColor($0) {
                richTextContext.setColor($0, to: color)
            }
        }

        let foreground = textView.richTextColor(.foreground)
        if richTextContext.foregroundColor != foreground {
            richTextContext.foregroundColor = foreground
        }

        let background = textView.richTextColor(.background)
        if richTextContext.backgroundColor != background {
            richTextContext.backgroundColor = background
        }

        let stroke = textView.richTextColor(.stroke)
        if richTextContext.strokeColor != stroke {
            richTextContext.strokeColor = stroke
        }

        let strikethrough = textView.richTextColor(.strikethrough)
        if richTextContext.strikethroughColor != strikethrough {
            richTextContext.strikethroughColor = strikethrough
        }

        let underline = textView.richTextColor(.underline)
        if richTextContext.underlineColor != underline {
            richTextContext.underlineColor = underline
        }

        let hasRange = textView.hasSelectedRange
        if richTextContext.canCopy != hasRange {
            richTextContext.canCopy = hasRange
        }

        let canRedo = textView.undoManager?.canRedo ?? false
        if richTextContext.canRedoLatestChange != canRedo {
            richTextContext.canRedoLatestChange = canRedo
        }

        let canUndo = textView.undoManager?.canUndo ?? false
        if richTextContext.canUndoLatestChange != canUndo {
            richTextContext.canUndoLatestChange = canUndo
        }

        if let fontName = textView.richTextFont?.fontName,
            !fontName.isEmpty,
            richTextContext.fontName != fontName {
            richTextContext.fontName = fontName
        }

        let fontSize = textView.richTextFont?.pointSize ?? .standardRichTextFontSize
        if richTextContext.fontSize != fontSize {
            richTextContext.fontSize = fontSize
        }

        let isBold = styles.hasStyle(.bold)
        if richTextContext.isBold != isBold {
            richTextContext.isBold = isBold
        }

        let isItalic = styles.hasStyle(.italic)
        if richTextContext.isItalic != isItalic {
            richTextContext.isItalic = isItalic
        }

        let isStrikethrough = styles.hasStyle(.strikethrough)
        if richTextContext.isStrikethrough != isStrikethrough {
            richTextContext.isStrikethrough = isStrikethrough
        }

        let isUnderlined = styles.hasStyle(.underlined)
        if richTextContext.isUnderlined != isUnderlined {
            richTextContext.isUnderlined = isUnderlined
        }

        let isEditingText = textView.isFirstResponder
        if richTextContext.isEditingText != isEditingText {
            richTextContext.isEditingText = isEditingText
        }

        let alignment = textView.richTextAlignment ?? .left
        if richTextContext.textAlignment != alignment {
            richTextContext.textAlignment = alignment
        }

        updateTextViewAttributesIfNeeded()
    }

    /// Sync the text binding with the text view.
    func syncTextWithTextView() {
        DispatchQueue.main.async {
            self.text.wrappedValue = self.textView.attributedString
        }
    }

    /**
     On macOS, we have to update the font and colors when we
     move the text input cursor and there's no selected text.

     The code looks very strange, but setting current values
     to the current values will reset the text view in a way
     that is otherwise not done correctly.

     To try out the incorrect behavior, comment out the code
     below, then change font size, colors etc. for a part of
     the text then move the input cursor around. When you do,
     the presented information will be correct, but when you
     type, the last selected font, colors etc. will be used.
     */
    func updateTextViewAttributesIfNeeded() {
        #if macOS
        if textView.hasSelectedRange { return }
        let attributes = textView.richTextAttributes
        textView.setRichTextAttributes(attributes)
        #endif
    }
}
#endif
