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
        static public let announcements = "announcements"
        static public let auth = "auth"
        static public let cart = "cart"
        static public let chats = "chats"
        static public let checkout = "checkout"
        static public let events = "events"
        static public let media = "media"
        static public let places = "places"
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
                static public let approve = "approve"
                static public let changeAdmin = "changeAdmin"
                static public let checkAdmin = "checkAdmin"
                static public let deactivate = "deactivate"
                static public let decline = "decline"
                static public let delete = "delete"
                static public let denyChangeRequest = "denyChangeRequest"
                static public let linkPlace = "linkPlace"
                static public let linkUser = "linkUser"
                static public let loadAccount = "loadAccount"
                static public let loadAccounts = "loadAccounts"
                static public let loadChangeRequests = "loadChangeRequests"
                static public let loadPlaces = "loadPlaces"
                static public let loadTabs = "loadTabs"
                static public let requestChangeAdmin = "requestChangeAdmin"
                static public let searchAccount = "searchAccount"
                static public let unlinkPlace = "unlinkPlace"
                static public let unlinkUser = "unlinkUser"
                static public let updateAccount = "updateAccount"
                static public let updatePushToken = "updatePushToken"
                static public let updateUser = "updateUser"
                static public let verifyAccount = "verifyAccount"
            }
        }
        public enum Announcements {
            static public let codeBase = "Announcements"

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
                static public let loadAnnouncements = "loadAnnouncements"
                static public let removeAnnouncement = "removeAnnouncement"
                static public let updateAnnouncement = "updateAnnouncement"
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
        public enum Chats {
            static public let codeBase = "Chats"

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
                static public let loadChat = "loadChat"
                static public let loadMessages = "loadMessages"
                static public let removeMessage = "removeMessage"
                static public let updateMessage = "updateMessage"
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
        public enum Events {
            static public let codeBase = "Events"

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
                static public let loadEvents = "loadEvents"
                static public let removeEvent = "removeEvent"
                static public let updateEvent = "updateEvent"
            }
        }
        public enum Media {
            static public let codeBase = "Media"

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
                static public let removeMedia = "removeMedia"
                static public let uploadMedia = "uploadMedia"
            }
        }
        public enum Places {
            static public let codeBase = "Places"

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
                static public let loadPlaces = "loadPlaces"
                static public let updatePlace = "updatePlace"
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
                static public let confirm = "confirm"
                static public let consent = "consent"
                static public let loadChildUsers = "loadChildUsers"
                static public let loadLinkRequests = "loadLinkRequests"
                static public let loadPendingUsers = "loadPendingUsers"
                static public let loadUnverifiedAccounts = "loadUnverifiedAccounts"
                static public let loadUser = "loadUser"
                static public let loadUsers = "loadUsers"
                static public let setIdentity = "setIdentity"
                static public let removeUser = "removeUser"
                static public let updateUser = "updateUser"
            }
        }
    }
}
