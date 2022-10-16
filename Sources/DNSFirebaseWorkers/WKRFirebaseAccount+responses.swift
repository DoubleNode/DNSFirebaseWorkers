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
