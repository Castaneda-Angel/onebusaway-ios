//
//  FoundationExtensions.swift
//  OBAKitTests
//
//  Copyright © Open Transit Software Foundation
//  This source code is licensed under the Apache 2.0 license found in the
//  LICENSE file in the root directory of this source tree.
//

import Foundation

// MARK: - Date

public extension Date {
    static func fromComponents(year: Int, month: Int, day: Int, hour: Int, minute: Int, second: Int) -> Date {
        let timeZone = TimeZone(secondsFromGMT: 0)
        let components = DateComponents(calendar: Calendar(identifier: .gregorian), timeZone: timeZone, era: nil, year: year, month: month, day: day, hour: hour, minute: minute, second: second, nanosecond: nil, weekday: nil, weekdayOrdinal: nil, quarter: nil, weekOfMonth: nil, weekOfYear: nil, yearForWeekOfYear: nil)
        return components.date!
    }
}

// MARK: - URL

public extension URL {
    func containsQueryParams(_ params: [String: String?]) -> Bool {
        guard
            let comps = URLComponents(url: self, resolvingAgainstBaseURL: true),
            let queryItems = comps.queryItems
        else {
            return false
        }

        for (k, v) in params {
            if queryItems.filter({ qi in qi.name == k && qi.value == v }).count == 0 {
                return false
            }
        }

        return true
    }
}

// MARK: - URLComponents

public extension URLComponents {
    func queryItemValueMatching(name: String) -> String? {
        guard let queryItems = queryItems else {
            return nil
        }

        return queryItems.filter({$0.name == name}).first?.value
    }
}
