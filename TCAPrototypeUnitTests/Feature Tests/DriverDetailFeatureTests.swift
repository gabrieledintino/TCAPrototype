//
//  DriverDetailFeatureTests.swift
//  TCAPrototypeTests
//
//  Created by Gabriele D'Intino on 23/08/24.
//

import XCTest
import ComposableArchitecture
@testable import TCAPrototype 
import Cuckoo

@MainActor
final class DriverDetailFeatureTests: XCTestCase {
    var drivers: [Driver]!
    var testDriver: Driver!
    var driverResponse: DriversListYearResponse!
    var raceResults: [Race]!
    var mockNetworkClient: MockNetworkClientProtocol!
    
    override func setUp() {
        super.setUp()
        mockNetworkClient = MockNetworkClientProtocol()

        driverResponse = try! FileUtils.loadJSONData(from: "drivers", withExtension: "json", in: type(of: self))
        drivers = driverResponse.mrData.driverTable.drivers
        testDriver = drivers.first(where: { $0.driverID == "leclerc" })
        let resultsResponse: RaceResultResponse = try! FileUtils.loadJSONData(from: "leclerc_results", withExtension: "json", in: type(of: self))
        raceResults = resultsResponse.mrData.raceTable.races
    }
    
    func testOnAppearSuccess() async {
        let store = TestStore(initialState: DriverDetailFeature.State(driver: testDriver)) {
            DriverDetailFeature()
        } withDependencies: {
            $0.networkClient = mockNetworkClient
        }
        stub(mockNetworkClient) { stub in
          when(stub.fetchRaceResults(forDriver: "leclerc")).then { _ in
              return self.raceResults
          }
        }
        XCTAssertNil(store.state.errorMessage)
        XCTAssertEqual(store.state.races, [])

        await store.send(.onAppear) {
            $0.isLoading = true
        }
        
        await store.receive(\.fetchRacesResponse.success) {
            $0.races = self.raceResults
            $0.isLoading = false
        }
    }
    
    func testOnAppearFailure() async {
        let store = TestStore(initialState: DriverDetailFeature.State(driver: testDriver)) {
            DriverDetailFeature()
        } withDependencies: {
            $0.networkClient = mockNetworkClient
        }
        
        let expectedError = NSError(domain: "TestError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Network error"])
        stub(mockNetworkClient) { stub in
          when(stub.fetchRaceResults(forDriver: "leclerc")).then { _ in
              throw expectedError
          }
        }
        
        XCTAssertNil(store.state.errorMessage)
        XCTAssertEqual(store.state.races, [])
        
        await store.send(.onAppear) {
            $0.isLoading = true
        }
        
        await store.receive(\.fetchRacesResponse.failure) {
            $0.isLoading = false
            $0.errorMessage = "Network error"
        }
    }
    
    func testToggleFavorite() async {
        let store = TestStore(initialState: DriverDetailFeature.State(driver: testDriver)) {
            DriverDetailFeature()
        }
        XCTAssertFalse(store.state.isFavorite)

        // Test adding to favorites
        await store.send(.toggleFavorite) {
            $0.favoriteIDs = ["leclerc"]
        }
        XCTAssertTrue(store.state.isFavorite)

        // Test removing from favorites
        await store.send(.toggleFavorite) {
            $0.favoriteIDs = []
        }
        XCTAssertFalse(store.state.isFavorite)

    }
}
