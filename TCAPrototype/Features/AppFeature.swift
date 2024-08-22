//
//  AppFeature.swift
//  TCAPrototype
//
//  Created by Gabriele D'Intino on 22/08/24.
//

import Foundation
import ComposableArchitecture

@Reducer
struct AppFeature {
  struct State: Equatable {
    var tab1 = DriversListFeature.State()
    var tab2 = FavoriteDriversFeature.State()
  }
  enum Action {
    case tab1(DriversListFeature.Action)
    case tab2(FavoriteDriversFeature.Action)
  }
  var body: some ReducerOf<Self> {
    Scope(state: \.tab1, action: \.tab1) {
        DriversListFeature()
    }
    Scope(state: \.tab2, action: \.tab2) {
        FavoriteDriversFeature()
    }
    Reduce { state, action in
      // Core logic of the app feature
      return .none
    }
  }
}
