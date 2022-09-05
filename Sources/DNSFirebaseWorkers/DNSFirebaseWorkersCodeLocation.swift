//
//  DNSFirebaseWorkersCodeLocation.swift
//  DoubleNode Swift Framework (DNSFramework) - DNSFirebaseWorkers
//
//  Created by Darren Ehlers.
//  Copyright © 2022 - 2016 DoubleNode.com. All rights reserved.
//

import DNSError

public extension DNSCodeLocation {
    typealias firebaseWorkers = DNSFirebaseWorkersCodeLocation
}
open class DNSFirebaseWorkersCodeLocation: DNSCodeLocation {
    override open class var domainPreface: String { "com.doublenode.firebaseWorkers." }
}
