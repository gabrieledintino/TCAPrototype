//
//  FavoriteDriversFeature.swift
//  TCAPrototype
//
//  Created by Gabriele D'Intino on 23/08/24.
//

import SwiftUI
import ComposableArchitecture

@Reducer
struct FavoriteDriversFeature {
    @ObservableState
    struct State: Equatable {
        var path = StackState<DriverDetailFeature.State>()
        fileprivate var drivers: [Driver] = []
        var isLoading: Bool = false
        var errorMessage: String?
        @Shared(.fileStorage(.applicationSupportDirectory.appending(component: "favorites"))) var favoriteIDs: [String] = []
        
        var favoriteDrivers: [Driver] {
            return drivers.filter { favoriteIDs.contains($0.driverID) }
        }
    }
    
    enum Action: Equatable {
        case path(StackAction<DriverDetailFeature.State, DriverDetailFeature.Action>)
        case onAppear
        case fetchDriversResponse(TaskResult<[Driver]>)
        case removeFavorites(IndexSet)
    }
    
    @Dependency(\.networkClient) var networkClient
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
                case .path:
                    return .none
                case .onAppear:
                    state.isLoading = true
                    return .run { send in
                        await send(.fetchDriversResponse(TaskResult { try await networkClient.fetchDrivers() }))
                    }
                    
                case let .fetchDriversResponse(.success(drivers)):
                    state.drivers = drivers
                    state.isLoading = false
                    state.errorMessage = nil
                    return .none
                    
                case let .fetchDriversResponse(.failure(error)):
                    state.isLoading = false
                    state.errorMessage = error.localizedDescription
                    return .none
                    
                case let .removeFavorites(indexSet):
                    state.favoriteIDs.remove(atOffsets: indexSet)
                    return .none
            }
        }
        .forEach(\.path, action: \.path) {
            DriverDetailFeature()
        }
    }
}
