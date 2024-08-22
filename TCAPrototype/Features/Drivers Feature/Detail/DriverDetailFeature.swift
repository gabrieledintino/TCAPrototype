//
//  DriverDetailFeature.swift
//  TCAPrototype
//
//  Created by Gabriele D'Intino on 23/08/24.
//

import ComposableArchitecture

@Reducer
struct DriverDetailFeature {
    @ObservableState
    struct State: Equatable {
        var driver: Driver
        var races: [Race] = []
        var isLoading: Bool = false
        var errorMessage: String?
        @Shared(.fileStorage(.applicationSupportDirectory.appending(component: "favorites"))) var favoriteIDs: [String] = []
        
        var isFavorite: Bool {
            favoriteIDs.contains(driver.driverID)
        }
    }
    
    enum Action: Equatable {
        case onAppear
        case toggleFavorite
        case fetchRacesResponse(TaskResult<[Race]>)
    }
    
    @Dependency(\.networkClient) var networkClient
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
                case .onAppear:
                    state.isLoading = true
                    return .run { [state] send in
                        await send(.fetchRacesResponse(TaskResult { try await networkClient.fetchRaceResults(forDriver: state.driver.driverID) }))
                    }
                    
                case .toggleFavorite:
                    if state.favoriteIDs.contains(state.driver.driverID) {
                        state.favoriteIDs.removeAll { $0 == state.driver.driverID }
                    } else {
                        state.favoriteIDs.append(state.driver.driverID)
                    }
                    return .none
                    
                case let .fetchRacesResponse(.success(races)):
                    state.races = races
                    state.isLoading = false
                    state.errorMessage = nil
                    return .none
                    
                case let .fetchRacesResponse(.failure(error)):
                    state.isLoading = false
                    state.errorMessage = error.localizedDescription
                    return .none
            }
        }
    }
}
