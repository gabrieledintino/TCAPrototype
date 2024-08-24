//
//  TestUiTest.swift
//  MVVMPrototypeTests
//
//  Created by Gabriele D'intino (EXT) on 05/08/24.
//

import XCTest
import ViewInspector
@testable import TCAPrototype
import SwiftUI
import ComposableArchitecture
import Cuckoo

class DriversListViewUITests: XCTestCase {
    var drivers: [Driver]!
    var driverResponse: DriversListYearResponse!
    var sut: DriversListView!
    var mockNetworkClient: MockNetworkClientProtocol!

    override func setUp() {
        super.setUp()
        mockNetworkClient = MockNetworkClientProtocol()

        driverResponse = try! FileUtils.loadJSONData(from: "drivers", withExtension: "json", in: type(of: self))
        drivers = driverResponse.mrData.driverTable.drivers
        
//        mockVM = MockDriversListViewModel()
//        originalVM = DriversListViewModel()        
//        mockVM.enableDefaultImplementation(originalVM)
//        sut = DriversListView(viewModel: mockVM)
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
//    func testTaskMethodIsInvoked() throws {
//        let store = TestStore(initialState: DriversListFeature.State(isLoading: true)) {
//            DriversListFeature()
//        }
//        let exp = sut.inspection.inspect(after: 1.0) { view in
//            verify(self.mockVM).fetchDrivers()
//        }
//        ViewHosting.host(view: sut)
//        wait(for: [exp], timeout: 2.0)
//    }
    
    func testProgressViewIsShownAndOthersHidden() throws {
        let store = Store(initialState: DriversListFeature.State(isLoading: true)) {
            DriversListFeature()
        } withDependencies: {
            $0.networkClient = self.mockNetworkClient
        }
        stub(mockNetworkClient) { stub in
          when(stub.fetchDrivers()).then { _ in
              return self.drivers
          }
        }
        
        sut = DriversListView(store: store)
        let exp = sut.inspection.inspect() { view in
            XCTAssertFalse(try view.find(viewWithAccessibilityIdentifier: "progress_view").isHidden())
            XCTAssertThrowsError(try view.find(viewWithAccessibilityIdentifier: "error_view"))
            XCTAssertThrowsError(try view.find(viewWithAccessibilityIdentifier: "list_view"))
        }
        ViewHosting.host(view: sut)
        wait(for: [exp], timeout: 0.1)
    }
    
    func testErrorViewIsShownAndOthersHidden() throws {
        let store = Store(initialState: DriversListFeature.State(errorMessage: "Test error")) {
            DriversListFeature()
        } withDependencies: {
            $0.networkClient = self.mockNetworkClient
        }
        stub(mockNetworkClient) { stub in
          when(stub.fetchDrivers()).then { _ in
              return self.drivers
          }
        }
        sut = DriversListView(store: store)
        let exp = sut.inspection.inspect() { view in
            XCTAssertThrowsError(try view.find(viewWithAccessibilityIdentifier: "progress_view"))
            XCTAssertFalse(try view.find(viewWithAccessibilityIdentifier: "error_view").isHidden())
            XCTAssertEqual(try view.navigationStack().zStack().view(ErrorView.self, 0).vStack().image(0).actualImage().name(), "exclamationmark.triangle")
            XCTAssertEqual(try view.navigationStack().zStack().view(ErrorView.self, 0).vStack().text(1).string(), "Error")
            XCTAssertEqual(try view.navigationStack().zStack().view(ErrorView.self, 0).vStack().text(2).string(), "Test error")
            XCTAssertThrowsError(try view.find(viewWithAccessibilityIdentifier: "list_view"))
        }
        ViewHosting.host(view: sut)
        wait(for: [exp], timeout: 0.1)
    }
    
    func testDriverListIsShownAndOthersHidden() throws {
        let store = Store(initialState: DriversListFeature.State(drivers: self.drivers)) {
            DriversListFeature()
        } withDependencies: {
            $0.networkClient = self.mockNetworkClient
        }
        stub(mockNetworkClient) { stub in
          when(stub.fetchDrivers()).then { _ in
              return self.drivers
          }
        }
        sut = DriversListView(store: store)
        let exp = sut.inspection.inspect() { view in
            XCTAssertThrowsError(try view.find(viewWithAccessibilityIdentifier: "progress_view"))
            XCTAssertThrowsError(try view.find(viewWithAccessibilityIdentifier: "error_view"))
            XCTAssertFalse(try view.find(viewWithAccessibilityIdentifier: "list_view").isHidden())
        }
        ViewHosting.host(view: sut)
        wait(for: [exp], timeout: 0.1)
    }
    
    func testDriverRowIsRenderedCorrectly() throws {
        let store = Store(initialState: DriversListFeature.State(drivers: self.drivers)) {
            DriversListFeature()
        } withDependencies: {
            $0.networkClient = self.mockNetworkClient
        }
        stub(mockNetworkClient) { stub in
          when(stub.fetchDrivers()).then { _ in
              return self.drivers
          }
        }
        sut = DriversListView(store: store)
        let exp = sut.inspection.inspect() { view in
            XCTAssertEqual(try view.navigationStack().zStack().list(0).forEach(0).navigationLink(0).labelView().view(_NavigationLinkStoreContent<State<Any>,EmptyView>.self).view(DriverRow.self).vStack().text(0).string(), "Alexander Albon")
            XCTAssertEqual(try view.navigationStack().zStack().list(0).forEach(0).navigationLink(0).labelView().view(_NavigationLinkStoreContent<State<Any>,EmptyView>.self).view(DriverRow.self).vStack().text(1).string(), "Thai")
            XCTAssertEqual(try view.navigationStack().zStack().list(0).forEach(0).navigationLink(1).labelView().view(_NavigationLinkStoreContent<State<Any>,EmptyView>.self).view(DriverRow.self).vStack().text(0).string(), "Fernando Alonso")
            XCTAssertEqual(try view.navigationStack().zStack().list(0).forEach(0).navigationLink(1).labelView().view(_NavigationLinkStoreContent<State<Any>,EmptyView>.self).view(DriverRow.self).vStack().text(1).string(), "Spanish")
        }
        ViewHosting.host(view: sut)
        wait(for: [exp], timeout: 0.1)
    }
    
    func testNavigation() throws {
        let store = Store(initialState: DriversListFeature.State(drivers: self.drivers)) {
            DriversListFeature()
        } withDependencies: {
            $0.networkClient = self.mockNetworkClient
        }
        stub(mockNetworkClient) { stub in
          when(stub.fetchDrivers()).then { _ in
              return self.drivers
          }
        }
        sut = DriversListView(store: store)
        let exp = sut.inspection.inspect() { view in
            XCTAssertEqual(try view.navigationStack().zStack().list(0).forEach(0).navigationLink(0).labelView().view(_NavigationLinkStoreContent<State<Any>,EmptyView>.self).view(DriverRow.self).vStack().text(0).string(), "Alexander Albon")
            XCTAssertEqual(try view.navigationStack().zStack().list(0).forEach(0).navigationLink(0).labelView().view(_NavigationLinkStoreContent<State<Any>,EmptyView>.self).view(DriverRow.self).vStack().text(1).string(), "Thai")
            XCTAssertEqual(try view.navigationStack().zStack().list(0).forEach(0).navigationLink(1).labelView().view(_NavigationLinkStoreContent<State<Any>,EmptyView>.self).view(DriverRow.self).vStack().text(0).string(), "Fernando Alonso")
            XCTAssertEqual(try view.navigationStack().zStack().list(0).forEach(0).navigationLink(1).labelView().view(_NavigationLinkStoreContent<State<Any>,EmptyView>.self).view(DriverRow.self).vStack().text(1).string(), "Spanish")
        }
        ViewHosting.host(view: sut)
        wait(for: [exp], timeout: 0.1)
    }
}
