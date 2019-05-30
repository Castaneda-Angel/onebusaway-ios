//
//  FormattersTests.swift
//  OBAKitTests
//
//  Created by Aaron Brethorst on 1/9/19.
//  Copyright © 2019 OneBusAway. All rights reserved.
//

import Foundation
import XCTest
@testable import OBAKit
import Nimble

// swiftlint:disable force_try

enum ModelDecodingError: Error {
    case invalidData
    case invalidReferences
    case invalidModelList
}

class FormattersTests: OBATestCase {
    let usLocale = Locale(identifier: "en_US")

    func testExample() {
        let formatters = Formatters(locale: usLocale)
        let json = loadJSONDictionary(file: "arrivals-and-departures-for-stop-1_75414.json")
        let stopArrivals = try! decodeModels(type: StopArrivals.self, json: json)
        let arrDep = stopArrivals.first!.arrivalsAndDepartures.first!

        let str = formatters.explanation(from: arrDep)

        expect(str).to(match("Arrived \\d+ min ago"))
    }
}
