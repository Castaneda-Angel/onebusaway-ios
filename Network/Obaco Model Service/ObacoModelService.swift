//
//  ObacoModelService.swift
//  OBAKit
//
//  Created by Aaron Brethorst on 11/9/18.
//  Copyright © 2018 OneBusAway. All rights reserved.
//

import Foundation

/// Retrieves data and converts it into models from the Obaco/alerts API server
///
/// This is the service responsible for supplementary features: alarms, regional alerts, and weather.
public class ObacoModelService: ModelService {
    private let apiService: ObacoService

    /// Create an ObacoModelService object.
    ///
    /// - Parameters:
    ///   - apiService: The API service object
    ///   - dataQueue: An operation queue
    public init(apiService: ObacoService, dataQueue: OperationQueue) {
        self.apiService = apiService
        super.init(dataQueue: dataQueue)
    }

    // MARK: - Weather

    /// Create an operation to fetch the weather forecast for the specified region.
    ///
    /// - Returns: A model operation that returns a `Weather` object.
    public func getWeather() -> WeatherModelOperation {
        let data = WeatherModelOperation()
        transferData(from: apiService.getWeather(), to: data)
        return data
    }

    // MARK: - Alarms

    /// Create a model operation to add a push notification alarm.
    ///
    /// - Parameters:
    ///   - minutesBefore: Number of minutes before the trip departure time that the alarm should be triggered.
    ///   - stopID: The stop ID where the trip occurs.
    ///   - tripID: The trip's ID.
    ///   - serviceDate: The service date for the trip.
    ///   - vehicleID: The vehicle ID for the trip.
    ///   - stopSequence: The stop sequence for the trip.
    ///   - userPushID: The user's unique push ID.
    /// - Returns: A model operation that returns an `Alarm` object.
    public func postAlarm(minutesBefore: Int, arrivalDeparture: ArrivalDeparture, userPushID: String) -> AlarmModelOperation {
        let service = apiService.postAlarm(
            secondsBefore: TimeInterval(minutesBefore * 60),
            stopID: arrivalDeparture.stopID,
            tripID: arrivalDeparture.tripID,
            serviceDate: arrivalDeparture.serviceDate,
            vehicleID: arrivalDeparture.vehicleID,
            stopSequence: arrivalDeparture.stopSequence,
            userPushID: userPushID
        )

        let data = AlarmModelOperation()

        transferData(from: service, to: data)

        return data
    }

    /// Cancels the specified alarm.
    ///
    /// - Parameter alarm: The alarm to cancel.
    /// - Returns: A network operation that will cancel the alarm.
    public func deleteAlarm(alarm: Alarm) -> NetworkOperation {
        return apiService.deleteAlarm(url: alarm.url)
    }

    // MARK: - Vehicles

    /// A search for vehicles matching the passed-in query string.
    ///
    /// - Parameter query: The vehicle query. e.g. "1234" will match vehicles "1_1234", "2_1234", etc.
    /// - Returns: A model operation that retrieves a list of matching vehicles.
    public func getVehicles(matching query: String) -> AgencyVehicleModelOperation {
        let service = apiService.getVehicles(matching: query)
        let data = AgencyVehicleModelOperation()

        transferData(from: service, to: data)

        return data
    }

    // MARK: - Alerts

    public func getAlerts(agencies: [AgencyWithCoverage]) -> AgencyAlertsModelOperation {
        let service = apiService.getAlerts()
        let data = AgencyAlertsModelOperation(agencies: agencies)

        transferData(from: service, to: data)

        return data
    }
}
