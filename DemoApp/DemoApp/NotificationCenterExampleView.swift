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

class NotificationCenterViewModel: ObservableObject {

    let notificationCenter = NotificationCenter()

    let notificationA = Notification.Name("A")
    let notificationB = Notification.Name("B")
    let notificationC = Notification.Name("C")

    @Published var capturedNotificationNames: [String] = []

    var subscription: AnyCancellable?

    init() {

        let notificationNames = [notificationA, notificationB, notificationC]

        /// Subscribe to multiple notifications in a single publisher.
        subscription = notificationCenter
            .publisher(for: notificationNames)
            .receive(on: RunLoop.main)
            .sink(to: NotificationCenterViewModel.handle, on: self, ownership: .weak)
    }

    /// Handle Notifications
    func handle(notification: Notification) {
        capturedNotificationNames.insert(notification.name.rawValue, at: 0)
    }

    // MARK: - Handle Button Taps

    func onTapA() {
        notificationCenter.post(name: notificationA, object: nil)
    }

    func onTapB() {
        notificationCenter.post(name: notificationB, object: nil)
    }

    func onTapC() {
        notificationCenter.post(name: notificationC, object: nil)
    }

}

// MARK: - View

struct NotificationCenterExampleView: View {

    @StateObject var viewModel = NotificationCenterViewModel()

    var body: some View {
        List {
            Text("Tap a button to send a notification.")

            HStack {
                Button("A", action: viewModel.onTapA)
                    .buttonStyle(.borderedProminent)
                Button("B", action: viewModel.onTapB)
                    .buttonStyle(.borderedProminent)
                Button("C", action: viewModel.onTapC)
                    .buttonStyle(.borderedProminent)
            }

            ForEach(viewModel.capturedNotificationNames, id: \.self) { name in
                Text("\(name) tapped.")
            }
        }
    }
}
