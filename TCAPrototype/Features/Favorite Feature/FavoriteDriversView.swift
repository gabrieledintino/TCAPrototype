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
    internal let inspection = Inspection<Self>()

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
                    favoriteDriversList
                }
            }
            .navigationTitle("Favorite Drivers")
        } destination: { store in
            DriverDetailView(store: store)
        }
        .task {
            store.send(.onAppear)
        }
        .onReceive(inspection.notice) { self.inspection.visit(self, $0) }
    }
    
    private var favoriteDriversList: some View {
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
