//
//  WKRFirebaseAccount+responses.swift
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

public protocol PTCLRSPWKRFirebaseAccountAAccount: Codable {
    var accounts: [DAOAccount] { get }
}
public struct RSPWKRFirebaseAccountAAccount: PTCLRSPWKRFirebaseAccountAAccount {
    // MARK: - Properties -
    public var accounts: [DAOAccount] = []
}

public protocol PTCLRSPWKRFirebaseAccountAAccountLinkRequest: Codable {
    var linkRequests: [DAOAccountLinkRequest] { get }
}
public struct RSPWKRFirebaseAccountAAccountLinkRequest: PTCLRSPWKRFirebaseAccountAAccountLinkRequest {
    // MARK: - Properties -
    public var linkRequests: [DAOAccountLinkRequest] = []
}

public protocol PTCLRSPWKRFirebaseAccountAPlace: Codable {
    var places: [DAOPlace] { get }
}
public struct RSPWKRFirebaseAccountAPlace: PTCLRSPWKRFirebaseAccountAPlace {
    // MARK: - Properties -
    public var places: [DAOPlace] = []
}

public protocol PTCLRSPWKRFirebaseAccountAUser: Codable {
    var users: [DAOUser] { get }
}
public struct RSPWKRFirebaseAccountAUser: PTCLRSPWKRFirebaseAccountAUser {
    // MARK: - Properties -
    public var users: [DAOUser] = []
}
