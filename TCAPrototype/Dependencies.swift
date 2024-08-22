//
//  Dependencies.swift
//  TCAPrototype
//
//  Created by Gabriele D'Intino on 23/08/24.
//

import ComposableArchitecture

// MARK: - Dependencies

struct NetworkClientKey: DependencyKey {
    static let liveValue: NetworkClientProtocol = NetworkClient.shared
}

extension DependencyValues {
    var networkClient: NetworkClientProtocol {
        get { self[NetworkClientKey.self] }
        set { self[NetworkClientKey.self] = newValue }
    }
}
