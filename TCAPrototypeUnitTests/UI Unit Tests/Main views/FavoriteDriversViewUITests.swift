//
//  FavorireDriversViewUITests.swift
//  MVVMPrototypeTests
//
//  Created by Gabriele D'intino (EXT) on 10/08/24.
//

import XCTest
import ViewInspector
@testable import TCAPrototype
import ComposableArchitecture
import SwiftUI
import Cuckoo

final class FavoriteDriversViewUITests: XCTestCase {
    var drivers: [Driver]!
    var driverResponse: DriversListYearResponse!
    var sut: FavoriteDriversView!
    var mockNetworkClient: MockNetworkClientProtocol!
    
    override func setUp() {
        super.setUp()
        mockNetworkClient = MockNetworkClientProtocol()
        
        driverResponse = try! FileUtils.loadJSONData(from: "drivers", withExtension: "json", in: type(of: self))
        drivers = driverResponse.mrData.driverTable.drivers
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
//    func testTaskMethodIsInvoked() throws {
//        let exp = sut.inspection.inspect(after: 1.0) { view in
//            verify(self.mockVM).fetchDrivers()
//        }
//        ViewHosting.host(view: sut)
//        wait(for: [exp], timeout: 2.0)
//    }
    
    func testProgressViewIsShownAndOthersHidden() throws {
        let store = Store(initialState: FavoriteDriversFeature.State(isLoading: true)) {
            FavoriteDriversFeature()
        } withDependencies: {
            $0.networkClient = self.mockNetworkClient
        }
        stub(mockNetworkClient) { stub in
          when(stub.fetchDrivers()).then { _ in
              return self.drivers
          }
        }
        sut = FavoriteDriversView(store: store)
        let exp = sut.inspection.inspect() { view in
            XCTAssertFalse(try view.find(viewWithAccessibilityIdentifier: "progress_view").isHidden())
            XCTAssertThrowsError(try view.find(viewWithAccessibilityIdentifier: "text_view"))
            XCTAssertThrowsError(try view.find(viewWithAccessibilityIdentifier: "error_view"))
            XCTAssertThrowsError(try view.find(viewWithAccessibilityIdentifier: "list_view"))
        }
        ViewHosting.host(view: sut)
        wait(for: [exp], timeout: 0.1)
    }
    
    func testErrorViewIsShownAndOthersHidden() throws {
        let store = Store(initialState: FavoriteDriversFeature.State(errorMessage: "Test error")) {
            FavoriteDriversFeature()
        } withDependencies: {
            $0.networkClient = self.mockNetworkClient
        }
        stub(mockNetworkClient) { stub in
          when(stub.fetchDrivers()).then { _ in
              return self.drivers
          }
        }
        sut = FavoriteDriversView(store: store)

        let exp = sut.inspection.inspect() { view in
            XCTAssertThrowsError(try view.find(viewWithAccessibilityIdentifier: "progress_view"))
            XCTAssertFalse(try view.find(viewWithAccessibilityIdentifier: "error_view").isHidden())
            XCTAssertEqual(try view.navigationStack().zStack().view(ErrorView.self, 0).vStack().image(0).actualImage().name(), "exclamationmark.triangle")
            XCTAssertEqual(try view.navigationStack().zStack().view(ErrorView.self, 0).vStack().text(1).string(), "Error")
            XCTAssertEqual(try view.navigationStack().zStack().view(ErrorView.self, 0).vStack().text(2).string(), "Test error")
            XCTAssertThrowsError(try view.find(viewWithAccessibilityIdentifier: "text_view"))
            XCTAssertThrowsError(try view.find(viewWithAccessibilityIdentifier: "list_view"))

        }
        ViewHosting.host(view: sut)
        wait(for: [exp], timeout: 0.1)
    }
    
    func testDriverListIsEmptyShowsText() throws {
        let store = Store(initialState: FavoriteDriversFeature.State(drivers: [])) {
            FavoriteDriversFeature()
        } withDependencies: {
            $0.networkClient = self.mockNetworkClient
        }
        stub(mockNetworkClient) { stub in
          when(stub.fetchDrivers()).then { _ in
              return []
          }
        }
        sut = FavoriteDriversView(store: store)
        let exp = sut.inspection.inspect() { view in
            XCTAssertThrowsError(try view.find(viewWithAccessibilityIdentifier: "progress_view"))
            XCTAssertThrowsError(try view.find(viewWithAccessibilityIdentifier: "error_view"))
            XCTAssertFalse(try view.find(viewWithAccessibilityIdentifier: "text_view").isHidden())
            XCTAssertEqual(try view.navigationStack().zStack().text(0).string(), "No favorite drivers yet")
            XCTAssertEqual(try view.navigationStack().zStack().text(0).attributes().foregroundColor(), .secondary)
            XCTAssertThrowsError(try view.find(viewWithAccessibilityIdentifier: "list_view"))
        }
        ViewHosting.host(view: sut)
        wait(for: [exp], timeout: 0.1)
    }
    
    func testDriverListIsShownAndOthersHidden() throws {
        let store = Store(initialState: FavoriteDriversFeature.State(drivers: self.drivers, favoriteIDs: ["leclerc"])) {
            FavoriteDriversFeature()
        } withDependencies: {
            $0.networkClient = self.mockNetworkClient
        }
        stub(mockNetworkClient) { stub in
          when(stub.fetchDrivers()).then { _ in
              return self.drivers
          }
        }
        sut = FavoriteDriversView(store: store)
        let exp = sut.inspection.inspect() { view in
            XCTAssertThrowsError(try view.find(viewWithAccessibilityIdentifier: "progress_view"))
            XCTAssertThrowsError(try view.find(viewWithAccessibilityIdentifier: "error_view"))
            XCTAssertThrowsError(try view.find(viewWithAccessibilityIdentifier: "text_view"))
            XCTAssertFalse(try view.find(viewWithAccessibilityIdentifier: "list_view").isHidden())
        }
        ViewHosting.host(view: sut)
        wait(for: [exp], timeout: 1.0)
    }
    
    func testDriverRowIsRenderedCorrectly() throws {
        let store = Store(initialState: FavoriteDriversFeature.State(drivers: self.drivers, favoriteIDs: ["albon"])) {
            FavoriteDriversFeature()
        } withDependencies: {
            $0.networkClient = self.mockNetworkClient
        }
        stub(mockNetworkClient) { stub in
          when(stub.fetchDrivers()).then { _ in
              return self.drivers
          }
        }
        sut = FavoriteDriversView(store: store)
        let exp = sut.inspection.inspect() { view in
            XCTAssertEqual(try view.navigationStack().zStack().list(0).forEach(0).navigationLink(0).labelView().view(_NavigationLinkStoreContent<State<Any>,EmptyView>.self).view(DriverRow.self).vStack().text(0).string(), "Alexander Albon")
            XCTAssertEqual(try view.navigationStack().zStack().list(0).forEach(0).navigationLink(0).labelView().view(_NavigationLinkStoreContent<State<Any>,EmptyView>.self).view(DriverRow.self).vStack().text(1).string(), "Thai")
        }
        ViewHosting.host(view: sut)
        wait(for: [exp], timeout: 0.1)
    }
}
