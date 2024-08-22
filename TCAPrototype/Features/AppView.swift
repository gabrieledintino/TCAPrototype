//
//  ContentView.swift
//  TCAPrototype
//
//  Created by Gabriele D'Intino on 20/08/24.
//

import SwiftUI
import ComposableArchitecture

struct AppView: View {
    let store: StoreOf<AppFeature>
    
    var body: some View {
        TabView {
              DriversListView(store: store.scope(state: \.tab1, action: \.tab1))
                .tabItem {
                    Label("Drivers", systemImage: "person.3")
                }
              
            FavoriteDriversView(store: store.scope(state: \.tab2, action: \.tab2))
                .tabItem {
                    Label("Favorites", systemImage: "star")
                }
            }
    }
}
