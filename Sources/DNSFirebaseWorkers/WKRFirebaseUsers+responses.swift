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
//    static let xlt = DNSDataTranslation()
//    public typealias Config = PTCLCFGWKRFirebaseUser
//    public typealias DecodingConfiguration = Config
//    public typealias EncodingConfiguration = Config

    // MARK: - Properties -
//    public enum CodingKeys: String, CodingKey {
//        case users
//    }

//    @CodableConfiguration(from: WKRFirebaseUsers.self)
    public var users: [DAOUser] = []

//    public init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//        users = Self.xlt.daoUserArray(with: WKRFirebaseUsers.decodingConfiguration,
//                                      from: container, forKey: .users)
//    }
//
//    public func encode(to encoder: Encoder) throws {
//        var container = encoder.container(keyedBy: CodingKeys.self)
//        try container.encode(users, forKey: .users)
//    }
}
