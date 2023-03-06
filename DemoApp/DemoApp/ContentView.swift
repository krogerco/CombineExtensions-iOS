//
//  ContentView.swift
//  DemoApp
//
//  Created by Isaac Ruiz on 2/28/23.
//

import SwiftUI
import CombineExtensions

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundColor(.accentColor)
            }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
