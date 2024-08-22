//
//  DriversFeature.swift
//  TCAPrototype
//
//  Created by Gabriele D'Intino on 23/08/24.
//

import ComposableArchitecture

// MARK: - Feature domain
@Reducer
struct DriversListFeature {
    @ObservableState
    struct State: Equatable {
        var path = StackState<DriverDetailFeature.State>()
        var drivers: [Driver] = []
        var searchText: String = ""
        var isLoading: Bool = false
        var errorMessage: String?
        
        var filteredDrivers: [Driver] {
            if searchText.isEmpty {
                return drivers
            } else {
                return drivers.filter { $0.fullName.lowercased().contains(searchText.lowercased()) }
            }
        }
    }
    
    enum Action: Equatable {
        case path(StackAction<DriverDetailFeature.State, DriverDetailFeature.Action>)
        case onAppear
        case searchTextChanged(String)
        case fetchDriversResponse(TaskResult<[Driver]>)
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
                    
                case let .searchTextChanged(newText):
                    state.searchText = newText
                    return .none
                    
                case let .fetchDriversResponse(.success(drivers)):
                    state.drivers = drivers
                    state.isLoading = false
                    state.errorMessage = nil
                    return .none
                    
                case let .fetchDriversResponse(.failure(error)):
                    state.isLoading = false
                    state.errorMessage = error.localizedDescription
                    return .none
            }
        }
        .forEach(\.path, action: \.path) {
            DriverDetailFeature()
        }
    }
}
