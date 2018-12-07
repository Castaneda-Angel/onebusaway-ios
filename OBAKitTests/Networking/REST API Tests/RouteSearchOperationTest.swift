//
//  RouteSearchOperationTest.swift
//  OBAKitTests
//
//  Created by Aaron Brethorst on 10/8/18.
//  Copyright © 2018 OneBusAway. All rights reserved.
//

import XCTest
import Nimble
import OHHTTPStubs
import CoreLocation
@testable import OBAKit

class RouteSearchOperationTest: OBATestCase {
    func testSearchForRoute() {
        let query = "Link"
        let center = CLLocationCoordinate2D(latitude: 47.0, longitude: -122)
        let radius = 5000.0
        let region = CLCircularRegion(center: center, radius: radius, identifier: "identifier")

        stub(condition: isHost(self.host) && isPath(RouteSearchOperation.apiPath)) { _ in
            return self.JSONFile(named: "routes-for-location-10.json")
        }

        waitUntil { done in
            let op = self.restService.getRoute(query: query, region: region)
            op.completionBlock = {
                expect(op.outOfRange) == false

                let entries = op.entries
                expect(entries?.count) == 1

                let references = op.references!
                let agencies = references["agencies"] as! [Any]
                expect(agencies.count) == 1

                done()
            }
        }
    }
}