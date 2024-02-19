//
//  EditorScreen.swift
//  Demo (iOS)
//
//  Created by Daniel Saidi on 2022-06-06.
//  Copyright © 2022-2023 Daniel Saidi. All rights reserved.
//

import RichTextKit
import SwiftUI

struct EditorScreen: View {

    init() {
        // RichTextEditor.standardRichTextFontSize = 100
    }

    @State private var text = NSAttributedString.empty

    @State private var selectedImage: UIImage?
    
    @State private var isShowingImagePicker = false
    
    @StateObject
    var context = RichTextContext()

    var body: some View {
        VStack {
            editor
                .padding()
                .onAppear {
                    setAttributedString()
                }
            toolbar
        }
        .background(Color.primary.opacity(0.15))
        .navigationTitle("RichTextKit")
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarLeading) {
                Button(action: {
                    saveAttributedString()
                }) {
                    Text("save")
                }
            }
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                MainMenu()
            }
        }
        .viewDebug()
    }
    
    func setAttributedString() {
        if let archivedData = UserDefaults.standard.data(forKey: "myData") {
            // 将 Data 转换回 NSAttributedString
            do {
                if let attributedString = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(archivedData) as? NSAttributedString {
                    print("Converted Data back to NSAttributedString: \(attributedString)")
                    context.setAttributedString(to: attributedString)
                }
            } catch {
                print("Failed to convert Data back to NSAttributedString: \(error)")
            }
        }
    }
    
    func saveAttributedString() {
        let attributedString = context.attributedString
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: attributedString, requiringSecureCoding: false)
            // 存储或处理转换后的 data
            print("Converted NSAttributedString to Data: \(data)")
            UserDefaults.standard.set(data, forKey: "myData")
        } catch {
            print("Failed to convert NSAttributedString to Data: \(error)")
        }
    }
    
    func imageToAttributedString(image: UIImage) -> NSAttributedString {
        // 创建一个 NSTextAttachment，并将 UIImage 设置为其图像
        let textAttachment = NSTextAttachment()
        textAttachment.image = image

        // 调整图像边界以在左右留下 8px 的空隙
        let xOffset: CGFloat = 8.0
        let yOffset: CGFloat = (textAttachment.bounds.height - image.size.height) / 2
        textAttachment.bounds = CGRect(x: -xOffset, y: yOffset, width: image.size.width, height: image.size.height)

        // 创建一个带有图像附件的 NSMutableAttributedString
        let attributedString = NSMutableAttributedString(attachment: textAttachment)

        // 设置段落样式以在左右留下 8px 的空隙
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        paragraphStyle.firstLineHeadIndent = xOffset
        paragraphStyle.headIndent = xOffset
        paragraphStyle.tailIndent = -xOffset
        attributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: attributedString.length))

        return attributedString
    }
}

private extension EditorScreen {

    var editor: some View {
        RichTextEditor(
            text: $text,
            context: context,
            config: .init(isScrollingEnabled: true)
        ) {
            $0.textContentInset = CGSize(width: 10, height: 20)
        }
        .background(Material.regular)
        .cornerRadius(5)
        .focusedValue(\.richTextContext, context)
    }

    var toolbar: some View {
        RichTextKeyboardToolbar(
            context: context,
            leadingButtons: {
                Button {
                    isShowingImagePicker.toggle()
                } label: {
                    Text("add photo")
                }
            },
            trailingButtons: {}
        ) {
            let sheet = $0
            // Uncomment this to show all color pickers
            // sheet.colorPickers = .allCases
            return sheet
        }
        .sheet(isPresented: $isShowingImagePicker) {
            ImagePicker { image in
                // 处理选中的图片
                if let image = image {
                    selectedImage = image
                    print("Selected image: \(image)")
                    let aa = imageToAttributedString(image: image)
                    context.setAttributedString(to: aa)
                }
            }
        }
    }
}

struct EditorScreen_Previews: PreviewProvider {

    static var previews: some View {
        EditorScreen()
    }
}
