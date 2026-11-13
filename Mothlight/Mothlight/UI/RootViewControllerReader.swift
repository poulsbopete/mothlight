import SwiftUI
import UIKit

struct RootViewControllerReader: UIViewControllerRepresentable {
    let onResolve: (UIViewController) -> Void

    func makeUIViewController(context: Context) -> ResolverViewController {
        let vc = ResolverViewController()
        vc.onResolve = onResolve
        return vc
    }

    func updateUIViewController(_ uiViewController: ResolverViewController, context: Context) {}

    final class ResolverViewController: UIViewController {
        var onResolve: ((UIViewController) -> Void)?

        override func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)
            if let parent = view.window?.rootViewController {
                onResolve?(parent)
            } else {
                onResolve?(self)
            }
        }
    }
}
