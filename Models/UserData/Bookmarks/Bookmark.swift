//
//  Bookmark.swift
//  OBAKit
//
//  Created by Aaron Brethorst on 6/20/19.
//

import Foundation

/// This is a bookmark for a `Stop` or a trip.
@objc(OBABookmark) public class Bookmark: NSObject, Codable {

    /// Optional. The unique identifier for the `BookmarkGroup` to which this object belongs.
    public var groupUUID: UUID?

    /// The unique identifier for this object.
    public let uuid: UUID

    /// The user-visible name of this object.
    public var name: String

    /// The `Region` ID for this object.
    ///
    /// `Bookmark`s are scoped by `Region`, so that you won't see Puget Sound bookmarks while in San Diego.
    public let regionIdentifier: Int

    /// The `Stop` identifier.
    ///
    /// This value, in conjunction with the `regionIdentifier`, allows us to retrieve the information that is pointed
    /// to by this object.
    public let stopID: String

    /// Whether or not this `Bookmark` should be displayed in the Today widget, for example. `false` by default.
    public var isFavorite: Bool

    /// This object stores a complete copy of its underlying `Stop` in order to be able to show additional information
    /// to the user.
    ///
    /// - Note: The underlying `stopID` of a `Bookmark` cannot be changed. If you try to update a `Bookmark`
    ///         with a `stop` whose `id` does not match `stopID`, the change will be rejected.
    public var stop: Stop {
        didSet {
            if stop.id != stopID {
                stop = oldValue
            }
        }
    }

    // MARK: - Trip Bookmark Properties

    public let routeShortName: String?
    public let tripHeadsign: String?
    public let routeID: RouteID?

    // MARK: - Init

    public init(name: String, regionIdentifier: Int, arrivalDeparture: ArrivalDeparture) {
        self.routeShortName = arrivalDeparture.routeShortName
        self.routeID = arrivalDeparture.routeID
        self.tripHeadsign = arrivalDeparture.tripHeadsign

        self.isFavorite = false
        self.name = name
        self.regionIdentifier = regionIdentifier
        self.stop = arrivalDeparture.stop
        self.stopID = stop.id
        self.uuid = UUID()
    }

    public init(name: String, regionIdentifier: Int, stop: Stop) {
        self.routeShortName = nil
        self.routeID = nil
        self.tripHeadsign = nil

        self.isFavorite = false
        self.name = name
        self.regionIdentifier = regionIdentifier
        self.stop = stop
        self.stopID = stop.id
        self.uuid = UUID()
    }

    private enum CodingKeys: String, CodingKey {
        case groupUUID, isFavorite, name, regionIdentifier, stop, stopID, uuid

        // Trip bookmark keys
        case routeShortName, tripHeadsign, routeID
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        groupUUID = try? container.decode(UUID.self, forKey: .groupUUID)
        isFavorite = try container.decode(Bool.self, forKey: .isFavorite)
        name = try container.decode(String.self, forKey: .name)
        regionIdentifier = try container.decode(Int.self, forKey: .regionIdentifier)
        stop = try container.decode(Stop.self, forKey: .stop)
        stopID = try container.decode(String.self, forKey: .stopID)
        uuid = try container.decode(UUID.self, forKey: .uuid)

        routeShortName = try? container.decode(String.self, forKey: .routeShortName)
        tripHeadsign = try? container.decode(String.self, forKey: .tripHeadsign)
        routeID = try? container.decode(String.self, forKey: .routeID)
    }

    public override func isEqual(_ object: Any?) -> Bool {
        guard let rhs = object as? Bookmark else { return false }

        return
            uuid == rhs.uuid &&
            groupUUID == rhs.groupUUID &&
            name == rhs.name &&
            regionIdentifier == rhs.regionIdentifier &&
            stopID == rhs.stopID &&
            stop == rhs.stop &&
            isFavorite == rhs.isFavorite &&
            routeShortName == rhs.routeShortName &&
            routeID == rhs.routeID &&
            tripHeadsign == rhs.tripHeadsign
    }

    public override var hash: Int {
        var hasher = Hasher()
        hasher.combine(uuid)
        hasher.combine(groupUUID)
        hasher.combine(name)
        hasher.combine(regionIdentifier)
        hasher.combine(stopID)
        hasher.combine(stop)
        hasher.combine(isFavorite)
        hasher.combine(routeShortName)
        hasher.combine(routeID)
        hasher.combine(tripHeadsign)
        return hasher.finalize()
    }

    public override var debugDescription: String {
        let desc = super.debugDescription
        let props: [String: Any] = ["uuid": uuid as Any, "groupUUID": groupUUID as Any, "name": name as Any, "regionIdentifier": regionIdentifier as Any, "stopID": stopID as Any, "isFavorite": isFavorite as Any, "routeShortName": routeShortName as Any, "routeID": routeID as Any, "tripHeadsign": tripHeadsign as Any]
        return "\(desc) \(props)"
    }

    public var isTripBookmark: Bool {
        routeShortName != nil && routeID != nil && tripHeadsign != nil
    }
}
