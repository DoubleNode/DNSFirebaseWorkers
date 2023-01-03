//
//  WKRFirebaseEvents+responses.swift
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

public protocol PTCLRSPWKRFirebaseEventsAEvent: Codable {
    var events: [DAOEvent] { get }
}
public struct RSPWKRFirebaseEventsAEvent: PTCLRSPWKRFirebaseEventsAEvent {
    // MARK: - Properties -
    public var events: [DAOEvent] = []
}
public protocol PTCLRSPWKRFirebaseEventsMeta: Codable {
    var meta: DNSMetadata { get }
}
public struct RSPWKRFirebaseEventsMeta: PTCLRSPWKRFirebaseEventsMeta {
    // MARK: - Properties -
    public var meta: DNSMetadata = DNSMetadata()
}
public protocol PTCLRSPWKRFirebaseEventsAPlace: Codable {
    var places: [DAOPlace] { get }
}
public struct RSPWKRFirebaseEventsAPlace: PTCLRSPWKRFirebaseEventsAPlace {
    // MARK: - Properties -
    public var places: [DAOPlace] = []
}
