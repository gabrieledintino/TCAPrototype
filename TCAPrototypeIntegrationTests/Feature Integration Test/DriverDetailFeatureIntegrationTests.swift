//
//  DriverDetailFeatureIntegrationTests.swift
//  TCAPrototypeIntegrationTests
//
//  Created by Gabriele D'Intino on 24/08/24.
//

import XCTest
import ComposableArchitecture
@testable import TCAPrototype
import Cuckoo

@MainActor
final class DriverDetailFeatureIntegrationTests: XCTestCase {
    var drivers: [Driver]!
    var testDriver: Driver!
    var driverResponse: DriversListYearResponse!
    var raceResults: [Race]!
    //var mockNetworkClient: MockNetworkClientProtocol!
    
    override func setUp() {
        super.setUp()
        //mockNetworkClient = MockNetworkClientProtocol()

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
            $0.networkClient = NetworkClient.shared
        }
        XCTAssertNil(store.state.errorMessage)
        XCTAssertEqual(store.state.races, [])

        await store.send(.onAppear) {
            $0.isLoading = true
        }
        
        await store.receive(\.fetchRacesResponse.success, timeout: Duration.seconds(10)) {
            $0.races = self.raceResults
            $0.isLoading = false
        }
    }
}
