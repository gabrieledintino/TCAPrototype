//
//  FavoriteDriversView.swift
//  TCAPrototype
//
//  Created by Gabriele D'Intino on 22/08/24.
//

import SwiftUI
import ComposableArchitecture

struct FavoriteDriversView: View {
    @Bindable var store: StoreOf<FavoriteDriversFeature>
    
    var body: some View {
        NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
            ZStack {
                if store.isLoading {
                    ProgressView()
                        .accessibilityIdentifier("progress_view")
                } else if let errorMessage = store.errorMessage {
                    ErrorView(message: errorMessage)
                        .accessibilityIdentifier("error_view")
                } else if store.favoriteDrivers.isEmpty {
                    Text("No favorite drivers yet")
                        .foregroundColor(.secondary)
                        .accessibilityIdentifier("text_view")
                } else {
                    favoriteDriversList(store: store)
                }
            }
            .navigationTitle("Favorite Drivers")
        } destination: { store in
            DriverDetailView(store: store)
        }
        .task {
            store.send(.onAppear)
        }
    }
    
    private func favoriteDriversList(store: Store<FavoriteDriversFeature.State, FavoriteDriversFeature.Action>) -> some View {
        List {
            ForEach(store.favoriteDrivers, id: \.driverID) { driver in
                NavigationLink(state: DriverDetailFeature.State(driver: driver)) {
                    DriverRow(driver: driver)
                }
            }
            .onDelete { indexSet in
                store.send(.removeFavorites(indexSet))
            }
            .accessibilityIdentifier("list_view")
        }
    }
}
