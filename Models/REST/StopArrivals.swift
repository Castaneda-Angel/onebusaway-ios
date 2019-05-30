//
//  StopArrivals.swift
//  OBAKit
//
//  Created by Aaron Brethorst on 11/2/18.
//  Copyright © 2018 OneBusAway. All rights reserved.
//

import Foundation

public class StopArrivals: NSObject, Decodable {

    /// Upcoming and just-passed vehicle arrivals and departures.
    public let arrivalsAndDepartures: [ArrivalDeparture]

    /// A list of nearby stop IDs.
    let nearbyStopIDs: [String]

    /// A list of nearby `Stop`s.
    public let nearbyStops: [Stop]

    /// A list of active service alert IDs.
    let situationIDs: [String]

    /// Active service alerts.
    public let situations: [Situation]

    /// The stop ID for the stop this represents.
    let stopID: String

    /// The stop to which this object refers.
    public let stop: Stop

    private enum CodingKeys: String, CodingKey {
        case arrivalsAndDepartures
        case nearbyStopIDs = "nearbyStopIds"
        case situationIDs = "situationIds"
        case stopID = "stopId"
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let references = decoder.references

        arrivalsAndDepartures = try container.decode([ArrivalDeparture].self, forKey: .arrivalsAndDepartures)

        nearbyStopIDs = try container.decode([String].self, forKey: .nearbyStopIDs)
        nearbyStops = references.stopsWithIDs(nearbyStopIDs)

        situationIDs = try container.decode([String].self, forKey: .situationIDs)
        situations = references.situationsWithIDs(situationIDs)

        stopID = try container.decode(String.self, forKey: .stopID)
        stop = references.stopWithID(stopID)!
    }
}
