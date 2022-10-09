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

extension WKRFirebaseUsers {
    public enum UserArrayTransformer: Transformer {
        public typealias Destination = [DAOUser]
        public typealias Object = [DAOUser]

        public static func transform(from decodable: [DAOUser]) -> Any? {
            decodable.compactMap { WKRFirebaseUsers.createUser(from: $0) }
        }
        public static func transform(object: [DAOUser]) throws -> [DAOUser]? {
            object as Destination
        }
    }
    struct UsersResponse: Codable {
        @CodedBy<UserArrayTransformer> var users: [DAOUser]
        enum CodingKeys: String, KeyedKey {
            case users = ".users"
        }
    }
}
