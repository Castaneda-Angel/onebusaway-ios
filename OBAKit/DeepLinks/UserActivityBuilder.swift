//
//  UserActivityBuilder.swift
//  OBAKit
//
//  Created by Aaron Brethorst on 5/31/19.
//

import Foundation
import Intents
import OBAKitCore

/// Simplifies creating `NSUserActivity` objects suitable for use with Handoff and Siri.
public class UserActivityBuilder: NSObject {
    private let application: Application

    public init(application: Application) {
        self.application = application
        super.init()

        validateInfoPlistUserActivityTypes()
    }

    public struct UserInfoKeys {
        public static let stopID = "stopID"
        public static let regionID = "regionID"
    }

    public func userActivity(for stop: Stop, region: Region) -> NSUserActivity {
        let activity = NSUserActivity(activityType: stopActivityType)
        activity.title = Formatters.formattedTitle(stop: stop)

        activity.isEligibleForHandoff = true

        // Per WWDC 2018 Session "Intro to Siri Shortcuts", this must be set to `true`
        // for `isEligibleForPrediction` to have any effect. Timecode: 8:30
        activity.isEligibleForSearch = true

        activity.isEligibleForPrediction = true
        activity.suggestedInvocationPhrase = OBALoc("user_activity_builder.show_me_my_bus", value: "Show me my bus", comment: "Suggested invocation phrase for Siri Shortcut")
        activity.persistentIdentifier = "region_\(region.regionIdentifier)_stop_\(stop.id)"

        activity.requiredUserInfoKeys = [UserInfoKeys.stopID, UserInfoKeys.regionID]
        activity.userInfo = [UserInfoKeys.stopID: stop.id, UserInfoKeys.regionID: region.regionIdentifier]

        if let router = application.deepLinkRouter {
            activity.webpageURL = router.url(for: stop, region: region)
        }

        return activity
    }

    public var stopActivityType: String {
        return "\(application.applicationBundle.bundleIdentifier).user_activity.stop"
    }

    public var tripActivityType: String {
        return "\(application.applicationBundle.bundleIdentifier).user_activity.trip"
    }

    // MARK: - Private Helpers

    /// Checks to see if the application's Info.plist file contains `NSUserActivityTypes` data
    /// that matches what this class expects it to have.
    private func validateInfoPlistUserActivityTypes() {
        guard
            let activityTypes = application.applicationBundle.userActivityTypes,
            activityTypes.contains(stopActivityType),
            activityTypes.contains(tripActivityType)
        else {
            fatalError("The Info.plist file must include the necessary NSUserActivityTypes values.")
        }
    }
}
