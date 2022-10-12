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

public protocol PTCLRSPWKRFirebaseAccountAAccount: Codable {  // , CodableWithConfiguration {
    var accounts: [DAOAccount] { get }
}
public struct RSPWKRFirebaseAccountAAccount: PTCLRSPWKRFirebaseAccountAAccount { // , DecodingConfigurationProviding, EncodingConfigurationProviding {
//    static let xlt = DNSDataTranslation()
//    public typealias Config = PTCLCFGWKRFirebaseAccount
//    public typealias DecodingConfiguration = Config
//    public typealias EncodingConfiguration = Config

    // MARK: - Properties -
//    public enum CodingKeys: String, CodingKey {
//        case accounts
//    }

//    @CodableConfiguration(from: WKRFirebaseAccount.self)
    public var accounts: [DAOAccount] = []

//    public init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//        accounts = Self.xlt.daoAccountArray(with: WKRFirebaseAccount.decodingConfiguration,
//                                            from: container, forKey: .accounts)
//    }
//
//    public func encode(to encoder: Encoder) throws {
//        var container = encoder.container(keyedBy: CodingKeys.self)
//        try container.encode(accounts, forKey: .accounts)
//    }
}
