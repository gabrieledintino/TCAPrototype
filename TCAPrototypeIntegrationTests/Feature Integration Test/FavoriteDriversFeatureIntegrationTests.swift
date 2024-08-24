//
//  FavoriteDriversFeatureIntegrationTests.swift
//  TCAPrototypeIntegrationTests
//
//  Created by Gabriele D'Intino on 24/08/24.
//

import XCTest
import ComposableArchitecture
@testable import TCAPrototype
import Cuckoo

@MainActor
final class FavoriteDriversFeatureIntegrationTests: XCTestCase {
    var drivers: [Driver]!
    var driverResponse: DriversListYearResponse!
    
    override func setUp() {
        super.setUp()
        
        driverResponse = try! FileUtils.loadJSONData(from: "drivers", withExtension: "json", in: type(of: self))
        drivers = driverResponse.mrData.driverTable.drivers
    }
    
    func testOnAppearSuccess() async {
        let store = TestStore(initialState: FavoriteDriversFeature.State()) {
            FavoriteDriversFeature()
        } withDependencies: {
            $0.networkClient = NetworkClient.shared
        }
        @Shared(.fileStorage(.applicationSupportDirectory.appending(component: "favorites"))) var favoriteIDs: [String] = [self.drivers.first!.driverID]
        favoriteIDs = [self.drivers.first!.driverID]
        
        XCTAssertNil(store.state.errorMessage)
        XCTAssertEqual(store.state.drivers, [])
        XCTAssertEqual(store.state.favoriteIDs, [self.drivers.first!.driverID])
        XCTAssertEqual(store.state.favoriteDrivers, [])
        
        await store.send(.onAppear) {
            $0.isLoading = true
        }
        
        await store.receive(\.fetchDriversResponse.success) {
            $0.drivers = self.drivers
            $0.isLoading = false
            $0.errorMessage = nil
        }
        XCTAssertEqual(store.state.favoriteDrivers, [self.drivers.first!])
    }
}
