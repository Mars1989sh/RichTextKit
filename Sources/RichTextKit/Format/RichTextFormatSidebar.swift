//
//  RichTextFormatSidebar.swift
//  RichTextKit
//
//  Created by Daniel Saidi on 2022-12-13.
//  Copyright © 2022-2023 Daniel Saidi. All rights reserved.
//

#if iOS || macOS || os(visionOS)
import SwiftUI

/**
 This sidebar view provides various text format options, and
 is meant to be used on macOS, in a trailing sidebar.

 > Note: The sidebar is currently designed for macOS, but it
 should also be made to look good on iPadOS in landscape, to
 let us use it instead of the ``RichTextFormatSheet``.
 */
public struct RichTextFormatSidebar: View {

    /**
     Create a rich text format sheet.

     - Parameters:
       - context: The context to apply changes to.
       - colorPickers: The color pickers to use, by default `.foreground` and `.background`.
     */
    public init(
        context: RichTextContext,
        colorPickers: [RichTextColor] = [.foreground, .background]
    ) {
        self._context = ObservedObject(wrappedValue: context)
        self.colorPickers = colorPickers
    }

    @ObservedObject
    private var context: RichTextContext

    /// The sidebar spacing.
    public var spacing = 10.0

    /// The color pickers to use.
    public var colorPickers: [RichTextColor]

    public var body: some View {
        VStack(alignment: .leading, spacing: spacing) {
            SidebarSection(title: RTKL10n.font.text) {
                RichTextFont.Picker(selection: $context.fontName, fontSize: 12)
                HStack {
                    RichTextStyle.ToggleGroup(context: context)
                    RichTextFont.SizePickerStack(context: context)
                }
            }

            SidebarSection(title: nil) {
                RichTextAlignment.Picker(selection: $context.textAlignment)
                    .pickerStyle(.segmented)
                RichTextAction.ButtonGroup(
                    context: context,
                    actions: [.decreaseIndent(), .increaseIndent()]
                )
            }

            SidebarSection(title: nil) {
                VStack(spacing: 4) {
                    ForEach(colorPickers) {
                        RichTextColor.Picker(
                            type: $0,
                            value: context.binding(for: $0),
                            quickColors: .quickPickerColors
                        )
                    }
                }
            }
            .font(.callout)
            .padding(.trailing, -8)

            Spacer()
        }
        .padding(8)
        .background(Color.white.opacity(0.05))
    }
}

private struct SidebarSection<Content: View>: View {

    let title: String?

    @ViewBuilder
    let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if let title {
                Text(title).font(.headline)
            }
            content()
            Divider()
        }
    }
}

struct RichTextFormatSidebar_Previews: PreviewProvider {

    struct Preview: View {

        @StateObject
        private var context = RichTextContext()

        var body: some View {
            RichTextFormatSidebar(context: context)
        }
    }

    static var previews: some View {
        Preview()
            .frame(width: 250)
    }
}
#endif
