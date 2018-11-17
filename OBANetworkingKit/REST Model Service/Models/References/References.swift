//
//  References.swift
//  OBANetworkingKit
//
//  Created by Aaron Brethorst on 10/20/18.
//  Copyright © 2018 OneBusAway. All rights reserved.
//

import Foundation

@objc(OBAReferences)
public class References: NSObject, Decodable {
    let agencies: [Agency]
    let routes: [Route]
    let situations: [Situation]
    let stops: [Stop]
    let trips: [Trip]

    // MARK: - Initialization

    private enum CodingKeys: String, CodingKey {
        case agencies, routes, situations, stops, trips
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        do {
            situations = try container.decode([Situation].self, forKey: .situations)
        } catch {
            situations = []
            print("error decoding situations: \(error)")
            throw error
        }

        do {
            agencies = try container.decode([Agency].self, forKey: .agencies)
        } catch {
            agencies = []
            print("error decoding agencies: \(error)")
            throw error
        }

        do {
            routes = try container.decode([Route].self, forKey: .routes)
        } catch {
            routes = []
            print("error decoding routes: \(error)")
            throw error
        }

        do {
            stops = try container.decode([Stop].self, forKey: .stops)
        } catch {
            stops = []
            print("error decoding stops: \(error)")
            throw error
        }

        do {
            trips = try container.decode([Trip].self, forKey: .trips)
        } catch {
            trips = []
            print("error decoding trips: \(error)")
            throw error
        }

        super.init()

        // depends: Agency
        routes.loadReferences(self)

        // depends: Route
        stops.loadReferences(self)
        trips.loadReferences(self)
    }

    public static func decodeReferences(_ data: [String: Any]) throws -> References {
        let decoder = DictionaryDecoder.restApiServiceDecoder()
        let references = try decoder.decode(References.self, from: data)
        return references
    }
}

// MARK: - HasReferences

protocol HasReferences {
    func loadReferences(_ references: References)
}

extension Array where Element: HasReferences {
    func loadReferences(_ references: References) {
        for elt in self {
            elt.loadReferences(references)
        }
    }
}

// MARK: - Finders
extension References {

    // MARK: - Agencies

    public func agencyWithID(_ id: String?) -> Agency? {
        guard let id = id else {
            return nil
        }
        return agencies.first { $0.id == id }
    }

    // MARK: - Routes

    public func routeWithID(_ id: String?) -> Route? {
        guard let id = id else {
            return nil
        }
        return routes.first { $0.id == id }
    }

    public func routesWithIDs(_ ids: [String]) -> [Route] {
        return routes.filter { ids.contains($0.id) }
    }

    // MARK: - Situations

    public func situationWithID(_ id: String?) -> Situation? {
        guard let id = id else {
            return nil
        }
        return situations.first { $0.id == id }
    }

    public func situationsWithIDs(_ ids: [String]) -> [Situation] {
        return situations.filter { ids.contains($0.id) }
    }

    // MARK: - Stops

    public func stopWithID(_ id: String?) -> Stop? {
        guard let id = id else {
            return nil
        }
        return stops.first { $0.id == id }
    }

    public func stopsWithIDs(_ ids: [String]) -> [Stop] {
        return stops.filter { ids.contains($0.id) }
    }

    // MARK: - Trips

    public func tripWithID(_ id: String?) -> Trip? {
        guard let id = id else {
            return nil
        }
        return trips.first { $0.id == id }
    }
}