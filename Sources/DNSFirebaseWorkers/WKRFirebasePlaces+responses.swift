//
//  WKRFirebasePlaces+responses.swift
//  SeaCadetsHelper
//
//  Created by Darren Ehlers on 9/10/22.
//

import DNSBlankWorkers
import DNSCore
import DNSCoreThreading
import DNSCrashNetwork
import DNSDataObjects
import DNSError
import DNSProtocols
import Foundation
import KeyedCodable

public protocol PTCLRSPWKRFirebasePlacesAPlace: Codable {
    var places: [DAOPlace] { get }
}
public struct RSPWKRFirebasePlacesAPlace: PTCLRSPWKRFirebasePlacesAPlace {
    // MARK: - Properties -
    public var places: [DAOPlace] = []
}
