////
////  ChordBaseUITests.swift
////  ChordBaseUITests
////
////  Created by Lindar Olostur on 03.12.2022.
////
//
import XCTest




final class ChordBaseUITests: XCTestCase {


    func testExample() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()
        
        let search = app.searchFields["Поиск"]
        XCTAssertTrue(search.exists)
        search.tap()
        search.typeText("olol")

        let songList = app.collectionViews.buttons
        XCTAssertTrue(songList.count > 0)
        songList.firstMatch.tap()

        let playButtonInMenu = app.buttons["PlayInMenu"]
        XCTAssertTrue(playButtonInMenu.exists)
        playButtonInMenu.tap()

        let playButtonInPlayer = app.buttons["PlayInPlayer"]
        XCTAssertTrue(playButtonInPlayer.exists)
        playButtonInPlayer.tap()
        Thread.sleep(forTimeInterval: 5.0)
        app.tap()
        let stopButtonInPlayer = app.buttons["StopInPlayer"]
        XCTAssertTrue(stopButtonInPlayer.exists)
        stopButtonInPlayer.tap()
        

    }


}
