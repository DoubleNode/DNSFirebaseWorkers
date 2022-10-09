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

public protocol PTCLWKRFirebaseUsersAUsersResponse {
    var users: [DAOUser] { get }
}
public class WKRFirebaseUsersAUsersResponse: PTCLWKRFirebaseUsersAUsersResponse, Codable {
    public var users: [DAOUser] { _users }
    
    private var _users: [DAOUser] = []
    public enum CodingKeys: String, KeyedKey {
        case _users = "users"
    }
}
//open class WKRFirebaseUsersAUsersResponse: Codable {
//    open var users: [DAOUser] { _users }
//
//    private var _users: [DAOUser] = []
//    private enum CodingKeys: String, KeyedKey {
//        case _users = ".users"
//    }
//}
//extension WKRFirebaseUsers {
//    public enum UserArrayTransformer: Transformer {
//        public typealias Destination = [DAOUser]
//        public typealias Object = [DAOUser]
//
//        public static func transform(from decodable: [DAOUser]) -> Any? {
//            decodable.compactMap { WKRFirebaseUsers.createUser(from: $0) }
//        }
//        public static func transform(object: [DAOUser]) throws -> [DAOUser]? {
//            object as Destination
//        }
//    }
//    struct UsersResponse: Codable {
//        @CodedBy<UserArrayTransformer> var users: [DAOUser]
//        enum CodingKeys: String, KeyedKey {
//            case users = ".users"
//        }
//    }
//}
