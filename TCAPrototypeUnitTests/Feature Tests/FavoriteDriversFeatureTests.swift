//
//  FavoriteDriversFeatureTests.swift
//  TCAPrototypeTests
//
//  Created by Gabriele D'Intino on 23/08/24.
//

import XCTest

import XCTest
import ComposableArchitecture
@testable import TCAPrototype
import Cuckoo

@MainActor
final class FavoriteDriversFeatureTests: XCTestCase {
    var drivers: [Driver]!
    var driverResponse: DriversListYearResponse!
    var mockNetworkClient: MockNetworkClientProtocol!
    
    override func setUp() {
        super.setUp()
        mockNetworkClient = MockNetworkClientProtocol()
        
        driverResponse = try! FileUtils.loadJSONData(from: "drivers", withExtension: "json", in: type(of: self))
        drivers = driverResponse.mrData.driverTable.drivers
    }
    
    func testOnAppearSuccess() async {
        let store = TestStore(initialState: FavoriteDriversFeature.State()) {
            FavoriteDriversFeature()
        } withDependencies: {
            $0.networkClient = mockNetworkClient
        }
        @Shared(.fileStorage(.applicationSupportDirectory.appending(component: "favorites"))) var favoriteIDs: [String] = [self.drivers.first!.driverID]
        favoriteIDs = [self.drivers.first!.driverID]
        
        stub(mockNetworkClient) { stub in
            when(stub.fetchDrivers()).then { _ in
                return self.drivers
            }
        }
        
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
    
    func testOnAppearFailure() async {
        let store = TestStore(initialState: FavoriteDriversFeature.State(favoriteIDs: [self.drivers.first!.driverID])) {
            FavoriteDriversFeature()
        } withDependencies: {
            $0.networkClient = mockNetworkClient
        }
        
        let expectedError = NSError(domain: "TestError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Network error"])
        stub(mockNetworkClient) { stub in
            when(stub.fetchDrivers()).then { _ in
                throw expectedError
            }
        }
        
        XCTAssertNil(store.state.errorMessage)
        XCTAssertEqual(store.state.drivers, [])
        
        await store.send(.onAppear) {
            $0.isLoading = true
        }
        
        await store.receive(\.fetchDriversResponse.failure) {
            $0.isLoading = false
            $0.errorMessage = "Network error"
        }
        XCTAssertEqual(store.state.favoriteDrivers, [])
    }
    
    func testRemoveFavorites() async {
        let store = TestStore(initialState: FavoriteDriversFeature.State(drivers: self.drivers)) {
            FavoriteDriversFeature()
        }
        @Shared(.fileStorage(.applicationSupportDirectory.appending(component: "favorites"))) var favoriteIDs: [String] = [self.drivers.first!.driverID]
        favoriteIDs = [self.drivers.first!.driverID]
        
        await store.send(.removeFavorites(IndexSet(integer: 0))) {
            $0.favoriteIDs = []
        }
    }
    
    func testPathNavigation() async {
        let store = TestStore(initialState: FavoriteDriversFeature.State()) {
            FavoriteDriversFeature()
        }
        await store.send(.path(.push(id: 0, state: DriverDetailFeature.State(driver: self.drivers.first!)))) {
            $0.path.append(DriverDetailFeature.State(driver: self.drivers.first!))
        }
        
        await store.send(.path(.popFrom(id: 0))) {
            $0.path.removeAll()
        }
    }
}
