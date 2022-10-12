//
//  WKRFirebaseUsers.swift
//  SeaCadetsHelper
//
//  Created by Darren Ehlers on 9/10/22.
//

import Alamofire
import DNSBlankWorkers
import DNSCore
import DNSCrashNetwork
import DNSDataObjects
import DNSError
import DNSProtocols
import FirebaseAuth
import Foundation
import KeyedCodable

public protocol PTCLCFGWKRFirebaseUsers: PTCLCFGDAOUser {
    var usersResponseType: any PTCLRSPWKRFirebaseUsersAUser.Type { get }
}
public class CFGWKRFirebaseUsers: PTCLCFGWKRFirebaseUsers {
    public var usersResponseType: any PTCLRSPWKRFirebaseUsersAUser.Type = RSPWKRFirebaseUsersAUser.self
    public var userType: DAOUser.Type = DAOUser.self

    open func userArray<K>(from container: KeyedDecodingContainer<K>,
                           forKey key: KeyedDecodingContainer<K>.Key) -> [DAOUser] where K: CodingKey {
        do { return try container.decodeIfPresent([DAOUser].self, forKey: key, configuration: self) ?? [] } catch { }
        return []
    }
}
open class WKRFirebaseUsers: WKRBlankUsers {
    public typealias Config = PTCLCFGWKRFirebaseUsers
    public typealias DecodingConfiguration = Config
    public typealias EncodingConfiguration = Config
    public static var config: Config = CFGWKRFirebaseUsers()

    public static var decodingConfiguration: DecodingConfiguration { Self.config }
    public static var encodingConfiguration: EncodingConfiguration { Self.config }

    typealias API = WKRFirebaseUsersAPI // swiftlint:disable:this type_name

    // MARK: - Internal Work Methods
    override open func intDoActivate(_ user: DAOUser,
                                     with progress: DNSPTCLProgressBlock?,
                                     and block: WKRPTCLUsersBlkBool?,
                                     then resultBlock: DNSPTCLResultBlock?) {
        let callData = WKRPTCLSystemsStateData(system: DNSAppConstants.Systems.users,
                                               endPoint: DNSAppConstants.Systems.Users.EndPoints.activate,
                                               sendDebug: DNSAppConstants.Systems.Users.sendDebug)

        guard let dataRequest = try? API.apiActivate(router: self.netRouter, user: user)
            .dataRequest.get() else {
            let error = DNSError.NetworkBase.dataError(.firebaseWorkers(self))
            block?(.failure(error)); _ = resultBlock?(.error)
            return
        }
        self.processRequestJSON(callData, dataRequest, with: resultBlock,
                                onSuccess: { data in
            let result = Self.xlt.dictionary(from: data)
            let wasDeleted = Self.xlt.bool(from: result["wasDeleted"] as Any?) ?? false
            block?(.success(wasDeleted))
            return .success
        },
                                onPendingError: { error, _ in
            if case DNSError.NetworkBase.dataError = error {
                return DNSError.Account.notDeactivated(.firebaseWorkers(self))
            }
            if case DNSError.NetworkBase.expiredAccessToken = error {
                return error
            }
            return DNSError.NetworkBase.lowerError(error: error, .firebaseWorkers(self))
        },
                                onError: { error, _ in
            block?(.failure(error))
        })
    }
    override open func intDoLoadCurrentUser(with progress: DNSPTCLProgressBlock?,
                                            and block: WKRPTCLUsersBlkUser?,
                                            then resultBlock: DNSPTCLResultBlock?) {
        let systemStateSystem = DNSAppConstants.Systems.users
        let systemStateEndPoint = DNSAppConstants.Systems.Users.EndPoints.loadUser
//        let systemStateSendDebug = DNSAppConstants.Systems.Users.sendDebug

        guard let currentUser = Auth.auth().currentUser else {
            self.utilityReportSystemSuccess(for: systemStateSystem, and: systemStateEndPoint)
            let error = DNSError.Users.notFound(field: "User", value: "Current", .firebaseWorkers(self))
            block?(.failure(error))
            _ = resultBlock?(.notFound)
            return
        }
        self.doLoadUser(for: currentUser.uid) { result in
            if case .failure(let error) = result {
                self.utilityReportSystemSuccess(for: systemStateSystem, and: systemStateEndPoint)
                block?(.failure(error))
                _ = resultBlock?(.notFound)
                return
            }
            let user = try! result.get()    // swiftlint:disable:this force_try
            
            self.utilityReportSystemSuccess(for: systemStateSystem, and: systemStateEndPoint)
            block?(.success(user))
            _ = resultBlock?(.completed)
        }
    }
    override open func intDoLoadUser(for id: String,
                                     with progress: DNSPTCLProgressBlock?,
                                     and block: WKRPTCLUsersBlkUser?,
                                     then resultBlock: DNSPTCLResultBlock?) {
        let callData = WKRPTCLSystemsStateData(system: DNSAppConstants.Systems.users,
                                               endPoint: DNSAppConstants.Systems.Users.EndPoints.loadUser,
                                               sendDebug: DNSAppConstants.Systems.Users.sendDebug)

        guard let dataRequest = try? API.apiLoadUser(router: self.netRouter, userId: id)
            .dataRequest.get() else {
            let error = DNSError.NetworkBase.dataError(.firebaseWorkers(self))
            block?(.failure(error)); _ = resultBlock?(.error)
            return
        }
        self.processRequestData(callData, dataRequest, with: resultBlock,
                                onSuccess: { data in
            do {
                let user = try JSONDecoder().decode(Self.config.userType, from: data)
                block?(.success(user))
                return .success
            } catch {
                DNSCore.reportError(error)
                return .failure(error)
            }
        },
                                onPendingError: { error, _ in
            if case DNSError.NetworkBase.expiredAccessToken = error {
                return error
            }
            return DNSError.NetworkBase.lowerError(error: error, .firebaseWorkers(self))
        },
                                onError: { error, _ in
            block?(.failure(error))
        })
    }
    override open func intDoLoadUsers(for account: DAOAccount,
                                      with progress: DNSPTCLProgressBlock?,
                                      and block: WKRPTCLUsersBlkAUser?,
                                      then resultBlock: DNSPTCLResultBlock?) {
        let callData = WKRPTCLSystemsStateData(system: DNSAppConstants.Systems.users,
                                               endPoint: DNSAppConstants.Systems.Users.EndPoints.loadUsers,
                                               sendDebug: DNSAppConstants.Systems.Users.sendDebug)

        guard let dataRequest = try? API.apiLoadUsers(router: self.netRouter, account: account)
            .dataRequest.get() else {
            let error = DNSError.NetworkBase.dataError(.firebaseWorkers(self))
            block?(.failure(error)); _ = resultBlock?(.error)
            return
        }
        self.processRequestData(callData, dataRequest, with: resultBlock,
                                onSuccess: { data in
            do {
                let response = try JSONDecoder().decode(Self.config.usersResponseType, from: data)
                block?(.success(response.users))
                return .success
            } catch {
                DNSCore.reportError(error)
                return .failure(error)
            }
        },
                                onPendingError: { error, _ in
            if case DNSError.NetworkBase.expiredAccessToken = error {
                return error
            }
            return DNSError.NetworkBase.lowerError(error: error, .firebaseWorkers(self))
        },
                                onError: { error, _ in
            block?(.failure(error))
        })
    }
    override open func intDoRemove(_ user: DAOUser,
                                   with progress: DNSPTCLProgressBlock?,
                                   and block: WKRPTCLUsersBlkVoid?,
                                   then resultBlock: DNSPTCLResultBlock?) {
        let callData = WKRPTCLSystemsStateData(system: DNSAppConstants.Systems.users,
                                               endPoint: DNSAppConstants.Systems.Users.EndPoints.removeUser,
                                               sendDebug: DNSAppConstants.Systems.Users.sendDebug)

        guard let dataRequest = try? API.apiRemove(router: self.netRouter, user: user)
            .dataRequest.get() else {
            let error = DNSError.NetworkBase.dataError(.firebaseWorkers(self))
            block?(.failure(error)); _ = resultBlock?(.error)
            return
        }
        self.processRequestJSON(callData, dataRequest, with: resultBlock,
                                onSuccess: { _ in
            block?(.success)
            return .success
        },
                                onPendingError: { error, _ in
            if case DNSError.NetworkBase.expiredAccessToken = error {
                return error
            }
            return DNSError.NetworkBase.lowerError(error: error, .firebaseWorkers(self))
        },
                                onError: { error, _ in
            block?(.failure(error))
        })
    }
    override open func intDoUpdate(_ user: DAOUser,
                                   with progress: DNSPTCLProgressBlock?,
                                   and block: WKRPTCLUsersBlkVoid?,
                                   then resultBlock: DNSPTCLResultBlock?) {
        let callData = WKRPTCLSystemsStateData(system: DNSAppConstants.Systems.users,
                                               endPoint: DNSAppConstants.Systems.Users.EndPoints.updateUser,
                                               sendDebug: DNSAppConstants.Systems.Users.sendDebug)

        guard let dataRequest = try? API.apiUpdate(router: self.netRouter, user: user)
            .dataRequest.get() else {
            let error = DNSError.NetworkBase.dataError(.firebaseWorkers(self))
            block?(.failure(error)); _ = resultBlock?(.error)
            return
        }
        self.processRequestJSON(callData, dataRequest, with: resultBlock,
                                onSuccess: { _ in
            block?(.success)
            return .success
        },
                                onPendingError: { error, _ in
            if case DNSError.NetworkBase.expiredAccessToken = error {
                return error
            }
            return DNSError.NetworkBase.lowerError(error: error, .firebaseWorkers(self))
        },
                                onError: { error, _ in
            block?(.failure(error))
        })
    }
}
