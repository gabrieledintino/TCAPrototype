//
//  DriverDetailViewUITests.swift
//  MVVMPrototypeTests
//
//  Created by Gabriele D'intino (EXT) on 12/08/24.
//

import XCTest
import ViewInspector
@testable import TCAPrototype
import SwiftUI
import ComposableArchitecture
import Cuckoo

final class DriverDetailViewUITests: XCTestCase {
    var drivers: [Driver]!
    var driverResponse: DriversListYearResponse!
    var raceResults: [Race]!
    var sut: DriverDetailView!
    var mockNetworkClient: MockNetworkClientProtocol!

    override func setUp() {
        super.setUp()
        mockNetworkClient = MockNetworkClientProtocol()
        
        driverResponse = try! FileUtils.loadJSONData(from: "drivers", withExtension: "json", in: type(of: self))
        drivers = driverResponse.mrData.driverTable.drivers
        let resultsResponse: RaceResultResponse = try! FileUtils.loadJSONData(from: "leclerc_results", withExtension: "json", in: type(of: self))
        raceResults = resultsResponse.mrData.raceTable.races
        
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testProgressViewIsShownAndOthersHidden() throws {
        let store = Store(initialState: DriverDetailFeature.State(driver: drivers.first!, isLoading: true)) {
            DriverDetailFeature()
        } withDependencies: {
            $0.networkClient = self.mockNetworkClient
        }
        stub(mockNetworkClient) { stub in
          when(stub.fetchRaceResults(forDriver: "albon")).then { _ in
              return self.raceResults
          }
        }
        
        sut = DriverDetailView(store: store)

        let exp = sut.inspection.inspect() { view in
            XCTAssertFalse(try view.find(viewWithAccessibilityIdentifier: "progress_view").isHidden())
            XCTAssertThrowsError(try view.find(viewWithAccessibilityIdentifier: "detail_text_view"))
            XCTAssertThrowsError(try view.find(viewWithAccessibilityIdentifier: "error_view"))
            XCTAssertThrowsError(try view.find(viewWithAccessibilityIdentifier: "list_view"))
        }
        ViewHosting.host(view: sut)
        wait(for: [exp], timeout: 0.1)
    }
    
    func testErrorViewIsShownAndOthersHidden() throws {
        let store = Store(initialState: DriverDetailFeature.State(driver: drivers.first!, errorMessage: "Test error")) {
            DriverDetailFeature()
        } withDependencies: {
            $0.networkClient = self.mockNetworkClient
        }
        stub(mockNetworkClient) { stub in
          when(stub.fetchRaceResults(forDriver: "albon")).then { _ in
              return self.raceResults
          }
        }
        
        sut = DriverDetailView(store: store)
        let exp = sut.inspection.inspect() { view in
            XCTAssertThrowsError(try view.find(viewWithAccessibilityIdentifier: "progress_view"))
            XCTAssertFalse(try view.find(viewWithAccessibilityIdentifier: "error_view").isHidden())
            XCTAssertEqual(try view.list().section(1).view(ErrorView.self, 0).vStack().image(0).actualImage().name(), "exclamationmark.triangle")
            XCTAssertEqual(try view.list().section(1).view(ErrorView.self, 0).vStack().text(1).string(), "Error")
            XCTAssertEqual(try view.list().section(1).view(ErrorView.self, 0).vStack().text(2).string(), "Test error")
            XCTAssertThrowsError(try view.find(viewWithAccessibilityIdentifier: "detail_text_view"))
            XCTAssertThrowsError(try view.find(viewWithAccessibilityIdentifier: "list_view"))

        }
        ViewHosting.host(view: sut)
        wait(for: [exp], timeout: 0.1)
    }
    
    func testDriverListIsEmptyShowsText() throws {
        let store = Store(initialState: DriverDetailFeature.State(driver: drivers.first!, races: [])) {
            DriverDetailFeature()
        } withDependencies: {
            $0.networkClient = self.mockNetworkClient
        }
        stub(mockNetworkClient) { stub in
          when(stub.fetchRaceResults(forDriver: "albon")).then { _ in
              return []
          }
        }
        
        sut = DriverDetailView(store: store)
        let exp = sut.inspection.inspect() { view in
            XCTAssertThrowsError(try view.find(viewWithAccessibilityIdentifier: "progress_view"))
            XCTAssertThrowsError(try view.find(viewWithAccessibilityIdentifier: "error_view"))
            XCTAssertFalse(try view.find(viewWithAccessibilityIdentifier: "detail_text_view").isHidden())
            XCTAssertEqual(try view.list().section(1).text(0).string(), "No race results available.")
            XCTAssertThrowsError(try view.find(viewWithAccessibilityIdentifier: "list_view"))
        }
        ViewHosting.host(view: sut)
        wait(for: [exp], timeout: 0.1)
    }
    
    func testDriverListIsShownAndOthersHidden() throws {
        let store = Store(initialState: DriverDetailFeature.State(driver: drivers.first!, races: [self.raceResults[0], self.raceResults[1], self.raceResults[2]])) {
            DriverDetailFeature()
        } withDependencies: {
            $0.networkClient = self.mockNetworkClient
        }
        stub(mockNetworkClient) { stub in
          when(stub.fetchRaceResults(forDriver: "albon")).then { _ in
              return [self.raceResults[0], self.raceResults[1], self.raceResults[2]]
          }
        }
        
        sut = DriverDetailView(store: store)
        let exp = sut.inspection.inspect() { view in
            XCTAssertThrowsError(try view.find(viewWithAccessibilityIdentifier: "progress_view"))
            XCTAssertThrowsError(try view.find(viewWithAccessibilityIdentifier: "error_view"))
            XCTAssertThrowsError(try view.find(viewWithAccessibilityIdentifier: "detail_text_view"))
            XCTAssertFalse(try view.find(viewWithAccessibilityIdentifier: "list_view").isHidden())
            XCTAssertEqual(try view.list().section(1).forEach(0).count, 3)
        }
        ViewHosting.host(view: sut)
        wait(for: [exp], timeout: 0.1)
    }
    
    func testSectionTitlesAreCorrect() throws {
        let store = Store(initialState: DriverDetailFeature.State(driver: drivers.first!, races: [self.raceResults[0], self.raceResults[1], self.raceResults[2]])) {
            DriverDetailFeature()
        } withDependencies: {
            $0.networkClient = self.mockNetworkClient
        }
        stub(mockNetworkClient) { stub in
          when(stub.fetchRaceResults(forDriver: "albon")).then { _ in
              return [self.raceResults[0], self.raceResults[1], self.raceResults[2]]
          }
        }
        
        sut = DriverDetailView(store: store)
        let exp = sut.inspection.inspect() { view in
            XCTAssertEqual(try view.list().section(0).header().text(0).string(), "Driver Information")
            XCTAssertEqual(try view.list().section(1).header().text(0).string(), "Race Results for current season")
        }
        ViewHosting.host(view: sut)
        wait(for: [exp], timeout: 0.1)
    }
    
    func testAllInfoRowsAreRendered() throws {
        let store = Store(initialState: DriverDetailFeature.State(driver: drivers.first!)) {
            DriverDetailFeature()
        } withDependencies: {
            $0.networkClient = self.mockNetworkClient
        }
        stub(mockNetworkClient) { stub in
          when(stub.fetchRaceResults(forDriver: "albon")).then { _ in
              return [self.raceResults[0], self.raceResults[1], self.raceResults[2]]
          }
        }
        
        sut = DriverDetailView(store: store)
        let exp = sut.inspection.inspect() { view in
            XCTAssertEqual(try view.list().section(0).count, 4)
        }
        ViewHosting.host(view: sut)
        wait(for: [exp], timeout: 0.1)
    }
    
    func testResultRowIsRendered() throws {
        let store = Store(initialState: DriverDetailFeature.State(driver: drivers.first!, races: [self.raceResults[0]])) {
            DriverDetailFeature()
        } withDependencies: {
            $0.networkClient = self.mockNetworkClient
        }
        stub(mockNetworkClient) { stub in
          when(stub.fetchRaceResults(forDriver: "albon")).then { _ in
              return [self.raceResults[0]]
          }
        }
        
        sut = DriverDetailView(store: store)
        let exp = sut.inspection.inspect() { view in
            XCTAssertNoThrow(try view.list().section(1).forEach(0).view(RaceResultRow.self, 0))
            XCTAssertThrowsError(try view.list().section(1).forEach(0).view(RaceResultRow.self, 1))
        }
        ViewHosting.host(view: sut)
        wait(for: [exp], timeout: 0.1)
    }
    
    func testButtonTapChangeIcon() throws {
        let store = Store(initialState: DriverDetailFeature.State(driver: drivers.first!)) {
            DriverDetailFeature()
        } withDependencies: {
            $0.networkClient = self.mockNetworkClient
        }
        stub(mockNetworkClient) { stub in
          when(stub.fetchRaceResults(forDriver: "albon")).then { _ in
              return [self.raceResults[0], self.raceResults[1], self.raceResults[2]]
          }
        }
        @Shared(.fileStorage(.applicationSupportDirectory.appending(component: "favorites"))) var favoriteIDs: [String] = [self.drivers.first!.driverID]
        favoriteIDs = []
        sut = DriverDetailView(store: store)
        
        let exp1 = sut.inspection.inspect() { view in
            let button = try view.list().toolbar().item(0).button()
            XCTAssertEqual(try button.labelView().image().actualImage().name(), "star")
            try button.tap()
            favoriteIDs = [self.drivers.first!.driverID]
        }

        let exp2 = sut.inspection.inspect() { view in
            let button = try view.list().toolbar().item(0).button()
            XCTAssertEqual(try button.labelView().image().actualImage().name(), "star.fill")
        }
        ViewHosting.host(view: sut)
        wait(for: [exp1, exp2], timeout: 3)
    }
}
