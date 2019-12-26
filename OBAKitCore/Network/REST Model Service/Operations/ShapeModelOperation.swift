//
//  ShapeModelOperation.swift
//  OBAKit
//
//  Created by Aaron Brethorst on 11/5/18.
//  Copyright © 2018 OneBusAway. All rights reserved.
//

import Foundation
import MapKit

/// Creates a `MKPolyline` model response to an API request to the `/api/where/shape/{id}.json` endpoint.
public class ShapeModelOperation: RESTModelOperation {
    public private(set) var polyline: MKPolyline?

    override public func main() {
        super.main()

        guard !hasError else {
            return
        }

        polyline = decodeModels(type: PolylineEntity.self).first?.polyline
    }
}