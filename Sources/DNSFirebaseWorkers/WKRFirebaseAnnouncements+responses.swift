//
//  WKRFirebaseAnnouncements+responses.swift
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

public protocol PTCLRSPWKRFirebaseAnnouncementsAAnnouncement: Codable {
    var announcements: [DAOAnnouncement] { get }
}
public struct RSPWKRFirebaseAnnouncementsAAnnouncement: PTCLRSPWKRFirebaseAnnouncementsAAnnouncement {
    // MARK: - Properties -
    public var announcements: [DAOAnnouncement] = []
}
public protocol PTCLRSPWKRFirebaseAnnouncementsAAnnouncementPlace: Codable {
    var announcements: [DAOAnnouncement] { get }
    var places: [DAOPlace] { get }
}
public struct RSPWKRFirebaseAnnouncementsAAnnouncementPlace: PTCLRSPWKRFirebaseAnnouncementsAAnnouncementPlace {
    // MARK: - Properties -
    public var announcements: [DAOAnnouncement] = []
    public var places: [DAOPlace] = []
}
public protocol PTCLRSPWKRFirebaseAnnouncementsMeta: Codable {
    var meta: DNSMetadata { get }
}
public struct RSPWKRFirebaseAnnouncementsMeta: PTCLRSPWKRFirebaseAnnouncementsMeta {
    // MARK: - Properties -
    public var meta: DNSMetadata = DNSMetadata()
}
