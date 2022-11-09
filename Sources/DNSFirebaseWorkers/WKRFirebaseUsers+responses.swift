//
//  WKRFirebaseUsers+responses.swift
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

public protocol PTCLRSPWKRFirebaseUsersAUser: Codable {  // , CodableWithConfiguration {
    var users: [DAOUser] { get }
}
public struct RSPWKRFirebaseUsersAUser: PTCLRSPWKRFirebaseUsersAUser { // , DecodingConfigurationProviding, EncodingConfigurationProviding {
    public var users: [DAOUser] = []
}

public protocol PTCLRSPWKRFirebaseUsersAAccount: Codable {
    var accounts: [DAOAccount] { get }
}
public struct RSPWKRFirebaseUsersAAccount: PTCLRSPWKRFirebaseUsersAAccount {
    // MARK: - Properties -
    public var accounts: [DAOAccount] = []
}

public protocol PTCLRSPWKRFirebaseUsersAAccountLinkRequest: Codable {
    var linkRequests: [DAOAccountLinkRequest] { get }
}
public struct RSPWKRFirebaseUsersAAccountLinkRequest: PTCLRSPWKRFirebaseUsersAAccountLinkRequest {
    // MARK: - Properties -
    public var linkRequests: [DAOAccountLinkRequest] = []
}
