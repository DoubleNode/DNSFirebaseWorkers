//
//  DNSAppConstants+RemoteConfig.swift
//  DoubleNode Swift Framework (DNSFramework) - DNSFirebaseWorkers
//
//  Created by Darren Ehlers.
//  Copyright © 2022 - 2016 DoubleNode.com. All rights reserved.
//

import DNSCore
import FirebaseRemoteConfig
import Foundation

private var intRemoteConfig: RemoteConfig?

public extension DNSAppConstants {
    static var remoteConfig: RemoteConfig {
        var remoteConfig: RemoteConfig
        if intRemoteConfig == nil {
            remoteConfig = RemoteConfig.remoteConfig()
            let settings = RemoteConfigSettings()
            settings.minimumFetchInterval = DNSAppConstants.remoteConfigDirtyAge
            remoteConfig.configSettings = settings
            remoteConfig.setDefaults(fromPlist: "RemoteConfigDefaults")
            intRemoteConfig = remoteConfig
        }
        remoteConfig = intRemoteConfig!
        remoteConfig.fetchAndActivate { status, error in
            guard error == nil else {
                print("RemoteConfig Fetch Error: \(error!.localizedDescription)")
                return
            }
            guard status == .successFetchedFromRemote else {
                print("RemoteConfig Fetch Error: No error available.")
                return
            }
            print("RemoteConfig Fetch Success")
        }
        return remoteConfig
    }
    static var remoteConfigDirtyAge: Double = {
        switch DNSCore.targetType {
            // Admin
        case "ADMIN_DEV", "ADMIN_QA", "ADMIN_ALPHA", "ADMIN_BETA": return Date.Seconds.deltaOneMinute
        case "ADMIN_GAMMA", "ADMIN_PROD": return Date.Seconds.deltaOneMinute
            // Dev
        case "DEV", "WIDGET_DEV": return Date.Seconds.deltaOneMinute
        case "QA", "WIDGET_QA": return Date.Seconds.deltaThreeMinutes
        case "ALPHA", "WIDGET_ALPHA": return Date.Seconds.deltaSixMinutes
        case "BETA", "WIDGET_BETA": return Date.Seconds.deltaSixMinutes
            // Prod & GAMMA
        default: return Date.Seconds.deltaSixMinutes
        }
    }()

}
