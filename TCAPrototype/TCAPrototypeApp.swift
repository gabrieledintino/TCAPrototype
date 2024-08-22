//
//  TCAPrototypeApp.swift
//  TCAPrototype
//
//  Created by Gabriele D'Intino on 20/08/24.
//

import SwiftUI
import ComposableArchitecture

@main
struct TCAPrototypeApp: App {
    static let store = Store(initialState: AppFeature.State()) {
        AppFeature()
    }
    
    var body: some Scene {
        WindowGroup {
            if TestContext.current == nil{
                AppView(store: TCAPrototypeApp.store)
            }
        }
    }
}
