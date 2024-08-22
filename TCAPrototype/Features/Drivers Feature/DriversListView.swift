//
//  DriversListView.swift
//  TCAPrototype
//
//  Created by Gabriele D'Intino on 20/08/24.
//

import SwiftUI
import ComposableArchitecture

// MARK: - View

struct DriversListView: View {
    @Bindable var store: StoreOf<DriversListFeature>
    
    var body: some View {
        NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
            ZStack {
                if store.isLoading {
                    ProgressView()
                        .accessibilityIdentifier("progress_view")
                } else if let errorMessage = store.errorMessage {
                    ErrorView(message: errorMessage)
                        .accessibilityIdentifier("error_view")
                } else {
                    driversList(store: store)
                }
            }
            .navigationTitle("F1 Drivers")
        } destination: { store in
          DriverDetailView(store: store)
        }
        .searchable(text: $store.searchText.sending(\.searchTextChanged)
                    , prompt: "Search drivers")
        .onAppear { store.send(.onAppear) }
    }
    
    private func driversList(store: Store<DriversListFeature.State, DriversListFeature.Action>) -> some View {
        List(store.filteredDrivers, id: \.driverID) { driver in
            NavigationLink(state: DriverDetailFeature.State(driver: driver)) {
                DriverRow(driver: driver)
                    .accessibilityIdentifier("DriverCell_\(driver.driverID)")
            }
        }
        .accessibilityIdentifier("list_view")
    }
}


// MARK: - Supporting Views

struct DriverRow: View {
    let driver: Driver
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(driver.fullName)
                .font(.headline)
            Text(driver.nationality)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
}

struct ErrorView: View {
    let message: String
    
    var body: some View {
        VStack {
            Image(systemName: "exclamationmark.triangle")
                .font(.largeTitle)
                .foregroundColor(.red)
            Text("Error")
                .font(.title)
                .padding()
            Text(message)
                .multilineTextAlignment(.center)
                .padding()
        }
    }
}
