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

extension WKRFirebaseAccount {
    public enum AccountArrayTransformer: Transformer {
        public typealias Destination = [DAOAccount]
        public typealias Object = [DAOAccount]

        public static func transform(from decodable: [DAOAccount]) -> Any? {
            decodable.compactMap { WKRFirebaseAccount.createAccount(from: $0) }
        }
        public static func transform(object: [DAOAccount]) throws -> [DAOAccount]? {
            object as Destination
        }
    }
    struct AccountsResponse: Codable {
        @CodedBy<AccountArrayTransformer> var accounts: [DAOAccount]
        enum CodingKeys: String, KeyedKey {
            case accounts = ".accounts"
        }
    }
}
