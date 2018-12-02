//
//  AlarmModelOperation.swift
//  OBANetworkingKit
//
//  Created by Aaron Brethorst on 11/10/18.
//  Copyright © 2018 OneBusAway. All rights reserved.
//

import Foundation
import OBAModelKit

public class AlarmModelOperation: Operation {
    var apiOperation: CreateAlarmOperation?
    public private(set) var alarm: Alarm?

    public override func main() {
        super.main()

        guard let data = apiOperation?.data else {
            return
        }

        let decoder = JSONDecoder.obacoServiceDecoder()

        alarm = try? decoder.decode(Alarm.self, from: data)
    }
}
