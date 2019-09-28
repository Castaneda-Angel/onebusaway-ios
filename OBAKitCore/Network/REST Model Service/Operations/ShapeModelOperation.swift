//
//  ShapeModelOperation.swift
//  OBAKit
//
//  Created by Aaron Brethorst on 11/5/18.
//  Copyright © 2018 OneBusAway. All rights reserved.
//

import Foundation
import MapKit

public class ShapeModelOperation: RESTModelOperation {
    public private(set) var polyline: MKPolyline?

    override public func main() {
        super.main()
        polyline = decodeModels(type: PolylineEntity.self).first?.polyline
    }
}
