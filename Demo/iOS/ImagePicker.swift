import SwiftUI
import UIKit

struct ImagePicker: UIViewControllerRepresentable {
    @Environment(\.presentationMode) private var presentationMode
    var completionHandler: (UIImage?) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = context.coordinator
        return imagePickerController
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let originalImage = info[.originalImage] as? UIImage {
                let resizedImage = originalImage.resizeToWidth(600) // 调整图片宽度为 300
                parent.completionHandler(resizedImage)
            } else {
                parent.completionHandler(nil)
            }
            parent.presentationMode.wrappedValue.dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.completionHandler(nil)
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}


extension UIImage {
    func resizeToWidth(_ width: CGFloat) -> UIImage? {
        let scaleFactor = width / size.width
        let newHeight = size.height * scaleFactor
        let newSize = CGSize(width: width, height: newHeight)

        UIGraphicsBeginImageContextWithOptions(newSize, false, scale)
        draw(in: CGRect(origin: .zero, size: newSize))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return resizedImage
    }
}
