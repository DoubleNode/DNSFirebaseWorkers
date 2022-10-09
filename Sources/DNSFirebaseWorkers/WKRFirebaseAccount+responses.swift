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

public protocol PTCLWKRFirebaseAccountAAccountsResponse {
    var accounts: [DAOAccount] { get }
}
open class WKRFirebaseAccountAAccountsResponse: PTCLWKRFirebaseAccountAAccountsResponse, Codable {
    open var accounts: [DAOAccount] { _accounts }
    
    private var _accounts: [DAOAccount] = []
    public enum CodingKeys: String, KeyedKey {
        case _accounts = "accounts"
    }
}
