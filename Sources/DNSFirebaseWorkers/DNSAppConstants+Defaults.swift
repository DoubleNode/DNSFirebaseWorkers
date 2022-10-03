//
//  DNSAppConstants+Defaults.swift
//  DoubleNode Swift Framework (DNSFramework) - DNSFirebaseWorkers
//
//  Created by Darren Ehlers.
//  Copyright © 2022 - 2016 DoubleNode.com. All rights reserved.
//

import DNSCore
import Foundation

public extension DNSAppConstants {
    static let bundleId = Bundle.main.bundleIdentifier ?? "com.doublenode.firebaseWorkers"
    enum Auth {
        static let accessData = "\(DNSAppConstants.bundleId).accessData"
        static let accessToken = "\(DNSAppConstants.bundleId).accessToken"
    }
}
