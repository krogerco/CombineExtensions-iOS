/*
MIT License

Copyright (c) 2023 The Kroger Co. All rights reserved.

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/

import Foundation
import SwiftUI
import Combine
import CombineExtensions

// MARK: - View Model

class WithLatestFromExampleViewModel: ObservableObject {

    @Published var switchA: Bool = false
    @Published var switchB: Bool = false

    @Published var log: [String] = []

    var subscriptions: Set<AnyCancellable> = []

    init() {
        // The `withLatestFrom` publisher passively tracks the switchB value, but will only publish when `switchA` updates.
        $switchA
            .withLatestFrom($switchB)
            .dropFirst()
            .sink(to: WithLatestFromExampleViewModel.logWithLatestFrom, on: self, ownership: .weak)
            .store(in: &subscriptions)

        // Juxtaposed with `combineLatest`, which will publish when _either_ toggle updates.
        $switchA
            .combineLatest($switchB)
            .dropFirst()
            .sink(to: WithLatestFromExampleViewModel.logCombineLatest, on: self, ownership: .weak)
            .store(in: &subscriptions)
    }

    /// Handle Notifications
    func logCombineLatest(state: (Bool, Bool)) {
        log.insert("Combine Latest - A\(state.0 ? "🟢" : "🔴") B\(state.1 ? "🟢" : "🔴")", at: 0)
    }

    func logWithLatestFrom(state: (Bool, Bool)) {
        log.insert("With Latest From - A\(state.0 ? "🟢" : "🔴") B\(state.1 ? "🟢" : "🔴")", at: 0)
    }
}

// MARK: - View

struct WithLatestFromExampleView: View {

    @StateObject var viewModel = WithLatestFromExampleViewModel()

    var body: some View {
        List {
            Toggle("Switch A", isOn: $viewModel.switchA)
            Toggle("Switch B", isOn: $viewModel.switchB)

            ForEach(viewModel.log, id: \.self) { name in
                Text(name)
            }
        }
        .animation(.easeOut, value: viewModel.log)
    }
}
