//
//  DriversListFeatureTests.swift
//  TCAPrototypeTests
//
//  Created by Gabriele D'Intino on 23/08/24.
//

import XCTest
import ComposableArchitecture
@testable import TCAPrototype
import Cuckoo

@MainActor
final class DriversListFeatureTests: XCTestCase {
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
            $0.networkClient = mockNetworkClient
        }
        
        stub(mockNetworkClient) { stub in
          when(stub.fetchDrivers()).then { _ in
              return self.drivers
          }
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
    
    func testOnAppearFailure() async {
        let store = TestStore(initialState: DriversListFeature.State()) {
            DriversListFeature()
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
    }
    
    func testSearchTextChanged() async {
        let store = TestStore(initialState: DriversListFeature.State(
            drivers: self.drivers
        )) {
            DriversListFeature()
        }
        XCTAssertEqual(store.state.filteredDrivers, self.drivers)

        await store.send(.searchTextChanged("al")) {
            $0.searchText = "al"
        }
        
        XCTAssertEqual(store.state.filteredDrivers.count, 3)
        XCTAssertEqual(store.state.filteredDrivers.first?.fullName, "Alexander Albon")
        
        await store.send(.searchTextChanged("alb")) {
            $0.searchText = "alb"
        }
        XCTAssertEqual(store.state.filteredDrivers.count, 1)
        XCTAssertEqual(store.state.filteredDrivers.first?.fullName, "Alexander Albon")
        
        await store.send(.searchTextChanged("zzz")) {
            $0.searchText = "zzz"
        }
        XCTAssertEqual(store.state.filteredDrivers.count, 0)
        XCTAssertNil(store.state.filteredDrivers.first?.fullName)
    }
    
    func testPathNavigation() async {
        let store = TestStore(initialState: DriversListFeature.State()) {
            DriversListFeature()
        }
//        } withDependencies: {
//            $0.networkClient = mockNetworkClient
//        }
//        
//        stub(mockNetworkClient) { stub in
//          when(stub.fetchDrivers()).then { _ in
//              return self.drivers
//          }
//        }
        
        await store.send(.path(.push(id: 0, state: DriverDetailFeature.State(driver: self.drivers.first!)))) {
            $0.path.append(DriverDetailFeature.State(driver: self.drivers.first!))
        }
        
        await store.send(.path(.popFrom(id: 0))) {
            $0.path.removeAll()
        }
    }
}
