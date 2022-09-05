//
//  WKRFirebaseAnalytics.swift
//  DoubleNode Swift Framework (DNSFramework) - DNSFirebaseWorkers
//
//  Created by Darren Ehlers.
//  Copyright © 2022 - 2016 DoubleNode.com. All rights reserved.
//

import DNSBlankWorkers
import DNSCore
import DNSProtocols
import FirebaseAnalytics

open class WKRFirebaseAnalytics: WKRBlankAnalytics {
    public enum Events {
        static public let appInPlace = "app_in_place"
        static public let login = AnalyticsEventLogin
        static public let logout = "logout"
        static public let screenView = AnalyticsEventScreenView
        static public let signUp = AnalyticsEventSignUp
    }
    public enum Properties {
        static public let placeCode = "place_code"
        static public let screenClass = AnalyticsParameterScreenClass
        static public let screenName = AnalyticsParameterScreenName
        static public let signUpMethod = "sign_up_method"
        static public let timeOfDay = "time_of_day"
    }
    public enum UserTraits {
        static public let deviceId = "deviceId"
        static public let inPlace = "inPlace"
        static public let locale = "locale"
        static public let myPlace = "myPlace"
    }
    public enum Values {
        static public let morning = "morning"
        static public let afternoon = "afternoon"
        static public let evening = "evening"
        static public let lateNight = "late_night"
    }

    private enum Settings {
        enum AppInPlace {
            static public let centerCode = "WKRFirebaseAnalytics_AppInPlace_placeCode"
            static public let date = "WKRFirebaseAnalytics_AppInPlace_date"
            static public let timeOfDay = "WKRFirebaseAnalytics_AppInPlace_timeOfDay"
        }
    }

    // MARK: - Identify -
    override open func intDoIdentify(userId: String, traits: DNSDataDictionary,
                                     options: DNSDataDictionary,
                                     then resultBlock: DNSPTCLResultBlock?) -> WKRPTCLAnalyticsResVoid {
        let currentUserId = userId.isEmpty ? nil : userId
        Analytics.setUserID(currentUserId)
        traits
            .filter { $1 as? String != nil }
            .forEach { (key, value) in
                // swiftlint:disable:next force_cast
                let currentValue = self.utilityCleanupUserProperty(value as! String)
                Analytics.setUserProperty(currentValue, forName: key)
            }
        _ = resultBlock?(.completed)
        return .success
    }

    // MARK: - Screen -
    override open func intDoScreen(screenTitle: String, properties: DNSDataDictionary,
                                   options: DNSDataDictionary,
                                   then resultBlock: DNSPTCLResultBlock?) -> WKRPTCLAnalyticsResVoid {
        var properties = properties as [String: Any]
        properties[Properties.screenName] = self.utilityCleanupScreen(screenTitle)
        Analytics.logEvent(Events.screenView, parameters: properties)
        _ = resultBlock?(.completed)
        return .success
    }

    // MARK: - Track -
    override open func intDoAutoTrack(class: String, method: String, properties: DNSDataDictionary,
                                      options: DNSDataDictionary,
                                      then resultBlock: DNSPTCLResultBlock?) -> WKRPTCLAnalyticsResVoid {
        _ = resultBlock?(.unhandled)
        return .success
    }
    // swiftlint:disable:next cyclomatic_complexity
    override open func intDoTrack(event: WKRPTCLAnalyticsEvents, properties: DNSDataDictionary = .empty,
                                  options: DNSDataDictionary = .empty,
                                  then resultBlock: DNSPTCLResultBlock?) -> WKRPTCLAnalyticsResVoid {
        let firebaseData = Self.xlt.dictionary(from: properties["WKRFirebaseAnalytics"] as Any?)
        if event == WKRPTCLAnalyticsEvents.appInPlace {
            if self.utilityShouldSkipTrackAppInPlace(properties: firebaseData, options: options) {
                _ = resultBlock?(.completed)
                return .success
            }
        }

        var firebaseEvent = ""
        switch event {
        case .appInPlace: firebaseEvent = WKRFirebaseAnalytics.Events.appInPlace
        case .login: firebaseEvent = WKRFirebaseAnalytics.Events.login
        case .logout: firebaseEvent = WKRFirebaseAnalytics.Events.logout
        case .screenView: firebaseEvent = WKRFirebaseAnalytics.Events.screenView
        case .signUp: firebaseEvent = WKRFirebaseAnalytics.Events.signUp
        default:
            _ = resultBlock?(.completed)
            return .success
        }

        firebaseEvent = self.utilityCleanupEvent(firebaseEvent)
        Analytics.logEvent(firebaseEvent, parameters: firebaseData as [String: Any])
        _ = resultBlock?(.completed)
        return .success
    }

    // MARK: - Utility methods -
    func utilityCleanupClass(_ class: String) -> String {
        var retval = `class`
            .replacingOccurrences(of: "<", with: "")
            .replacingOccurrences(of: ">", with: "")
            .replacingOccurrences(of: "MEE", with: "")
            .replacingOccurrences(of: "Interactor", with: "")
            .replacingOccurrences(of: "Presenter", with: "")
            .replacingOccurrences(of: "ViewController", with: "")
        guard let split1 = retval.split(separator: ":").first else { return retval }
        retval = "\(split1)"
        guard let split2 = retval.split(separator: ".").last else { return retval }
        retval = "\(split2)"
        return retval
    }
    func utilityCleanupEvent(_ event: String) -> String {
        return event
            .replacingOccurrences(of: "(", with: "_")
            .replacingOccurrences(of: ")", with: "_")
            .replacingOccurrences(of: ":", with: "_")
    }
    func utilityCleanupMethod(_ method: String) -> String {
        return method
            .replacingOccurrences(of: "(", with: "")
            .replacingOccurrences(of: ")", with: "")
            .replacingOccurrences(of: ":", with: "")
    }
    func utilityCleanupScreen(_ screen: String) -> String {
        var retval = screen
        guard let split = retval.split(separator: ".").last else { return retval }
        retval = "\(split)"
        return retval
            .replacingOccurrences(of: "Configurator", with: "Stage")
    }
    func utilityCleanupUserProperty(_ property: String) -> String? {
        var retval = property
        if retval.count > 36 {
            retval = String(retval.suffix(36))
        }
        if retval.isEmpty {
            return nil
        }
        return retval
    }
    func utilityShouldSkipTrackAppInPlace(properties: DNSDataDictionary,
                                          options: DNSDataDictionary) -> Bool {
        let currentCenterCode = properties[WKRFirebaseAnalytics.Properties.placeCode] as? String ?? ""
        let currentDate = Date()
        let currentTimeOfDay = properties[WKRFirebaseAnalytics.Properties.timeOfDay] as? String ?? ""

        let appInCenterLastCenterCode = DNSCore
            .setting(for: WKRFirebaseAnalytics.Settings.AppInPlace.centerCode,
                     // swiftlint:disable:next force_cast
                     withDefault: "") as! String
        let appInCenterLastDate = DNSCore
            .setting(for: WKRFirebaseAnalytics.Settings.AppInPlace.date,
                     // swiftlint:disable:next force_cast
                     withDefault: Date()) as! Date
        let appInCenterLastTimeOfDay = DNSCore
            .setting(for: WKRFirebaseAnalytics.Settings.AppInPlace.timeOfDay,
                     // swiftlint:disable:next force_cast
                     withDefault: "") as! String

        if appInCenterLastCenterCode == currentCenterCode &&
            currentDate.isSameDate(as: appInCenterLastDate) &&
            appInCenterLastTimeOfDay == currentTimeOfDay {
            return true
        }

        DNSCore.setting(set: WKRFirebaseAnalytics.Settings.AppInPlace.centerCode,
                        with: currentCenterCode)
        DNSCore.setting(set: WKRFirebaseAnalytics.Settings.AppInPlace.date,
                        with: currentDate)
        DNSCore.setting(set: WKRFirebaseAnalytics.Settings.AppInPlace.timeOfDay,
                        with: currentTimeOfDay)
        return false
    }
}
