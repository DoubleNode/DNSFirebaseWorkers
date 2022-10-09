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

public protocol PTCLWKRFirebaseUsersAUsersResponse: Codable {
    var users: [DAOUser] { get }
}
public class WKRFirebaseUsersAUsersResponse: PTCLWKRFirebaseUsersAUsersResponse {
    public var users: [DAOUser] { _users }
    
    private var _users: [DAOUser] = []
    public enum CodingKeys: String, KeyedKey {
        case _users = "users"
    }
}
