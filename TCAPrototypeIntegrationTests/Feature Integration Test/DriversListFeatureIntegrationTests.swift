//
//  DriversListFeatureIntegrationTests.swift
//  TCAPrototypeIntegrationTests
//
//  Created by Gabriele D'Intino on 24/08/24.
//

import XCTest
import ComposableArchitecture
@testable import TCAPrototype
import Cuckoo

@MainActor
final class DriversListFeatureIntegrationTests: XCTestCase {
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
        let store = TestStore(initialState: DriversListFeature.State()) {
            DriversListFeature()
        } withDependencies: {
            $0.networkClient = NetworkClient.shared
        }
        
        XCTAssertNil(store.state.errorMessage)
        XCTAssertEqual(store.state.drivers, [])
        
        await store.send(.onAppear) {
            $0.isLoading = true
        }
        
        await store.receive(\.fetchDriversResponse.success) {
            $0.drivers = self.drivers
            $0.isLoading = false
            $0.errorMessage = nil
        }
    }
    
    //    func testOnAppearFailure() async {
    //        let store = TestStore(initialState: DriversListFeature.State()) {
    //            DriversListFeature()
    //        } withDependencies: {
    //            $0.networkClient = mockNetworkClient
    //        }
    //        
    //        let expectedError = NSError(domain: "TestError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Network error"])
    //        stub(mockNetworkClient) { stub in
    //          when(stub.fetchDrivers()).then { _ in
    //              throw expectedError
    //          }
    //        }
    //        
    //        XCTAssertNil(store.state.errorMessage)
    //        XCTAssertEqual(store.state.drivers, [])
    //        
    //        await store.send(.onAppear) {
    //            $0.isLoading = true
    //        }
    //        
    //        await store.receive(\.fetchDriversResponse.failure) {
    //            $0.isLoading = false
    //            $0.errorMessage = "Network error"
    //        }
    //    }
}
