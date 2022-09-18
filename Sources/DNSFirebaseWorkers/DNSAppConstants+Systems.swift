//
//  DNSAppConstants+Systems.swift
//  DoubleNode Swift Framework (DNSFramework) - DNSFirebaseWorkers
//
//  Created by Darren Ehlers.
//  Copyright © 2022 - 2016 DoubleNode.com. All rights reserved.
//

import DNSCore
import FirebaseRemoteConfig
import Foundation

public extension DNSAppConstants {
    enum Systems {  // swiftlint:disable:this type_body_length
        static let overrideBlock: Bool = {
            guard DNSAppConstants.targetType == "GAMMA" else { return false }
            return true
        }()
        enum Status {
            static let normal: String = "GREEN"
            static let warning: String = "YELLOW"
            static let error: String = "ORANGE"
            static let critical: String = "RED"
        }

        static let accounts = "accounts"
        static let auth = "auth"
        static let cart = "cart"
        static let checkout = "checkout"

        enum Accounts {
            static let codeBase = "Accounts"

            static let codeDebug = "SystemDebug\(codeBase)"
            static let codeStatus = "SystemStatus\(codeBase)"

            static var sendDebug: Bool { debug && (status != Status.normal) }

            static var status: String {
                remoteConfig[codeStatus].stringValue ?? Status.normal
            }
            static var debug: Bool {
                remoteConfig[codeDebug].boolValue
            }
            enum EndPoints {
                static let changeAdmin = "changeAdmin"
                static let checkAdmin = "checkAdmin"
                static let denyChangeRequest = "denyChangeRequest"
                static let loadAccount = "loadAccount"
                static let loadChangeRequests = "loadChangeRequests"
                static let loadTabs = "loadTabs"
                static let loadUser = "loadUser"
                static let removeUser = "removeUser"
                static let requestChangeAdmin = "requestChangeAdmin"
                static let updateAccount = "updateAccount"
                static let updateUser = "updateUser"
            }
        }
        enum Auth {
            static let codeBase = "Auth"

            static let codeDebug = "SystemDebug\(codeBase)"
            static let codeStatus = "SystemStatus\(codeBase)"

            static var sendDebug: Bool { debug && (status != Status.normal) }

            static var status: String {
                remoteConfig[codeStatus].stringValue ?? Status.normal
            }
            static var debug: Bool {
                remoteConfig[codeDebug].boolValue
            }
            enum EndPoints {
                static let checkStatus = "checkStatus"
                static let signIn = "signIn"
                static let signOut = "signOut"
                static let signUp = "signUp"
            }
        }
        enum Cart {
            static let codeBase = "Cart"

            static let codeDebug = "SystemDebug\(codeBase)"
            static let codeStatus = "SystemStatus\(codeBase)"

            static var sendDebug: Bool { debug && (status != Status.normal) }

            static var status: String {
                remoteConfig[codeStatus].stringValue ?? Status.normal
            }
            static var debug: Bool {
                remoteConfig[codeDebug].boolValue
            }
            enum EndPoints {
                static let addToBasket = "addToBasket"
                static let createBasket = "createBasket"
                static let getBasket = "getBasket"
                static let removeFromBasket = "removeFromBasket"
            }
        }
        enum Checkout {
            static let codeBase = "Checkout"

            static let codeDebug = "SystemDebug\(codeBase)"
            static let codeStatus = "SystemStatus\(codeBase)"

            static var sendDebug: Bool { debug && (status != Status.normal) }

            static var status: String {
                remoteConfig[codeStatus].stringValue ?? Status.normal
            }
            static var debug: Bool {
                remoteConfig[codeDebug].boolValue
            }
            enum EndPoints {
                static let applyCoupon = "applyCoupon"
                static let checkout = "checkout"
            }
        }
    }
}
