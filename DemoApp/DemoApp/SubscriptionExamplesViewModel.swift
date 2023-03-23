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

class SubscriptionExamplesViewModel: ObservableObject {
    let subjectA = PassthroughSubject<Date, Never>()
    let subjectB = PassthroughSubject<Date, Never>()

    @Published var lastTappedB: String = ""

    @Published var capturedNotificationNames: [String] = []

    var subscriptions: Set<AnyCancellable> = []

    init() {
        // Calls a function on a weakly captured `self`
        subjectA
            .receive(on: RunLoop.main)
            .sink(to: SubscriptionExamplesViewModel.handleSubjectA, on: self, ownership: .weak)
            .store(in: &subscriptions)

        /// Assigns value to a property on a weakly captured `self`
        subjectB
            .map { publishedDate in
                "Last B Tap: \(publishedDate)"
            }
            .receive(on: RunLoop.main)
            .assign(to: \.lastTappedB, on: self, ownership: .weak)
            .store(in: &subscriptions)
    }

    /// Handle Notifications
    func handleSubjectA(date: Date) {
        capturedNotificationNames.insert("A \(date)", at: 0)
    }

    // MARK: - Handle Button Taps

    func onTapA() {
        subjectA.send(Date())
    }

    func onTapB() {
        subjectB.send(Date())
    }
}

// MARK: - View

struct SubscriptionExamplesView: View {

    @StateObject var viewModel = SubscriptionExamplesViewModel()

    var body: some View {
        List {
            Text("Tap a button to send a notification.")

            HStack {
                Button("A", action: viewModel.onTapA)
                    .buttonStyle(.borderedProminent)
                Button("B", action: viewModel.onTapB)
                    .buttonStyle(.borderedProminent)
            }

            Text(viewModel.lastTappedB)

            ForEach(viewModel.capturedNotificationNames, id: \.self) { name in
                Text("\(name) tapped.")
            }
        }
    }
}
