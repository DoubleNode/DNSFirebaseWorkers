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
        static public let overrideBlock: Bool = {
            guard DNSAppConstants.targetType == "GAMMA" else { return false }
            return true
        }()
        public enum Status {
            static public let normal: String = "GREEN"
            static public let warning: String = "YELLOW"
            static public let error: String = "ORANGE"
            static public let critical: String = "RED"
        }

        static public let accounts = "accounts"
        static public let auth = "auth"
        static public let cart = "cart"
        static public let checkout = "checkout"
        static public let users = "users"

        public enum Accounts {
            static public let codeBase = "Accounts"

            static public let codeDebug = "SystemDebug\(codeBase)"
            static public let codeStatus = "SystemStatus\(codeBase)"

            static public var sendDebug: Bool { debug && (status != Status.normal) }

            static public var status: String {
                remoteConfig[codeStatus].stringValue ?? Status.normal
            }
            static public var debug: Bool {
                remoteConfig[codeDebug].boolValue
            }
            public enum EndPoints {
                static public let activate = "activate"
                static public let changeAdmin = "changeAdmin"
                static public let checkAdmin = "checkAdmin"
                static public let deactivate = "deactivate"
                static public let delete = "delete"
                static public let denyChangeRequest = "denyChangeRequest"
                static public let linkAccount = "linkAccount"
                static public let loadAccount = "loadAccount"
                static public let loadAccounts = "loadAccounts"
                static public let loadChangeRequests = "loadChangeRequests"
                static public let loadTabs = "loadTabs"
                static public let requestChangeAdmin = "requestChangeAdmin"
                static public let searchAccount = "searchAccount"
                static public let unlinkAccount = "unlinkAccount"
                static public let updateAccount = "updateAccount"
                static public let updatePushToken = "updatePushToken"
                static public let updateUser = "updateUser"
            }
        }
        public enum Auth {
            static public let codeBase = "Auth"

            static public let codeDebug = "SystemDebug\(codeBase)"
            static public let codeStatus = "SystemStatus\(codeBase)"

            static public var sendDebug: Bool { debug && (status != Status.normal) }

            static public var status: String {
                remoteConfig[codeStatus].stringValue ?? Status.normal
            }
            static public var debug: Bool {
                remoteConfig[codeDebug].boolValue
            }
            public enum EndPoints {
                static let checkAuth = "checkAuth"
                static let linkAuth = "linkAuth"
                static let signIn = "signIn"
                static let signOut = "signOut"
                static let signUp = "signUp"
            }
        }
        public enum Cart {
            static public let codeBase = "Cart"

            static public let codeDebug = "SystemDebug\(codeBase)"
            static public let codeStatus = "SystemStatus\(codeBase)"

            static public var sendDebug: Bool { debug && (status != Status.normal) }

            static public var status: String {
                remoteConfig[codeStatus].stringValue ?? Status.normal
            }
            static public var debug: Bool {
                remoteConfig[codeDebug].boolValue
            }
            public enum EndPoints {
                static public let addToBasket = "addToBasket"
                static public let createBasket = "createBasket"
                static public let getBasket = "getBasket"
                static public let removeFromBasket = "removeFromBasket"
            }
        }
        public enum Checkout {
            static public let codeBase = "Checkout"

            static public let codeDebug = "SystemDebug\(codeBase)"
            static public let codeStatus = "SystemStatus\(codeBase)"

            static public var sendDebug: Bool { debug && (status != Status.normal) }

            static public var status: String {
                remoteConfig[codeStatus].stringValue ?? Status.normal
            }
            static public var debug: Bool {
                remoteConfig[codeDebug].boolValue
            }
            public enum EndPoints {
                static public let applyCoupon = "applyCoupon"
                static public let checkout = "checkout"
            }
        }
        public enum Users {
            static public let codeBase = "Users"

            static public let codeDebug = "SystemDebug\(codeBase)"
            static public let codeStatus = "SystemStatus\(codeBase)"

            static public var sendDebug: Bool { debug && (status != Status.normal) }

            static public var status: String {
                remoteConfig[codeStatus].stringValue ?? Status.normal
            }
            static public var debug: Bool {
                remoteConfig[codeDebug].boolValue
            }
            public enum EndPoints {
                static public let activate = "activate"
                static public let clearIdentity = "clearIdentity"
                static public let loadUser = "loadUser"
                static public let loadUsers = "loadUsers"
                static public let setIdentity = "setIdentity"
                static public let removeUser = "removeUser"
                static public let updateUser = "updateUser"
            }
        }
    }
}
