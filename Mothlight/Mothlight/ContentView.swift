import SwiftUI

struct ContentView: View {
    @State private var viewModel: GameViewModel?

    var body: some View {
        GeometryReader { proxy in
            Group {
                if let viewModel {
                    GameContainerView(viewModel: viewModel)
                        .onAppear { viewModel.onAppearBootstrap() }
                        .background(RootViewControllerReader { vc in
                            viewModel.bindRootViewController(vc)
                        })
                } else {
                    Color(red: 0.05, green: 0.07, blue: 0.15)
                        .onAppear {
                            viewModel = GameViewModel(size: proxy.size)
                        }
                }
            }
            .onChange(of: proxy.size) { _, newSize in
                viewModel?.scene.size = newSize
            }
        }
    }
}

#Preview {
    ContentView()
}
