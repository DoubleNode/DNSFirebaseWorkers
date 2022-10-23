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

public struct PTCLRSPWKRFirebaseAccountLinkRequest: Codable {
    let id: String
    let userId: String
    let approved: Date
    let approvedBy: String
    let requested: Date
}
public protocol PTCLRSPWKRFirebaseAccountAAccountLinkRequest: Codable {
    var linkRequests: [PTCLRSPWKRFirebaseAccountLinkRequest] { get }
}
public struct RSPWKRFirebaseAccountAAccountLinkRequest: PTCLRSPWKRFirebaseAccountAAccountLinkRequest {
    // MARK: - Properties -
    public var linkRequests: [PTCLRSPWKRFirebaseAccountLinkRequest] = []
}
