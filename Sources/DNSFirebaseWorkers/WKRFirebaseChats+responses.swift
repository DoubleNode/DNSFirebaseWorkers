//
//  WKRFirebaseChats+responses.swift
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

public protocol PTCLRSPWKRFirebaseChatsAChatMessage: Codable {
    var messages: [DAOChatMessage] { get }
}
public struct RSPWKRFirebaseChatsAChatMessage: PTCLRSPWKRFirebaseChatsAChatMessage {
    // MARK: - Properties -
    public var messages: [DAOChatMessage] = []
}
