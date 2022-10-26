//
//  WKRFirebaseAccount.swift
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

public protocol PTCLCFGWKRFirebaseAccount: PTCLCFGDAOAccount {
    var accountsResponseType: any PTCLRSPWKRFirebaseAccountAAccount.Type { get }
    var linkRequestsResponseType: any PTCLRSPWKRFirebaseAccountAAccountLinkRequest.Type { get }
    var linkRequestType: DAOAccountLinkRequest.Type { get }
    var userType: DAOUser.Type { get }
}
public class CFGWKRFirebaseAccount: PTCLCFGWKRFirebaseAccount {
    public var accountsResponseType: any PTCLRSPWKRFirebaseAccountAAccount.Type = RSPWKRFirebaseAccountAAccount.self
    public var linkRequestsResponseType: any PTCLRSPWKRFirebaseAccountAAccountLinkRequest.Type = RSPWKRFirebaseAccountAAccountLinkRequest.self
    public var accountType: DAOAccount.Type = DAOAccount.self
    public var linkRequestType: DAOAccountLinkRequest.Type = DAOAccountLinkRequest.self
    public var userType: DAOUser.Type = DAOUser.self

    open func account<K>(from container: KeyedDecodingContainer<K>,
                         forKey key: KeyedDecodingContainer<K>.Key) -> DAOAccount? where K: CodingKey {
        do { return try container.decodeIfPresent(self.accountType, forKey: key, configuration: self) ?? nil } catch { }
        return nil
    }

    open func accountArray<K>(from container: KeyedDecodingContainer<K>,
                              forKey key: KeyedDecodingContainer<K>.Key) -> [DAOAccount] where K: CodingKey {
        do { return try container.decodeIfPresent([DAOAccount].self, forKey: key, configuration: self) ?? [] } catch { }
        return []
    }
    open func accountLinkRequestArray<K>(from container: KeyedDecodingContainer<K>,
                                         forKey key: KeyedDecodingContainer<K>.Key) -> [DAOAccountLinkRequest] where K: CodingKey {
        do { return try container.decodeIfPresent([DAOAccountLinkRequest].self, forKey: key, configuration: self) ?? [] } catch { }
        return []
    }
}
open class WKRFirebaseAccount: WKRBlankAccount, DecodingConfigurationProviding, EncodingConfigurationProviding {
    public typealias Config = PTCLCFGWKRFirebaseAccount
    public typealias DecodingConfiguration = Config
    public typealias EncodingConfiguration = Config
    public static var config: Config = CFGWKRFirebaseAccount()

    public static var decodingConfiguration: DecodingConfiguration { Self.config }
    public static var encodingConfiguration: EncodingConfiguration { Self.config }

    typealias API = WKRFirebaseAccountAPI // swiftlint:disable:this type_name

    // MARK: - Class Factory methods -
    open class func createLinkRequest() -> DAOAccountLinkRequest { config.linkRequestType.init() }
    open class func createLinkRequest(from object: DAOAccountLinkRequest) -> DAOAccountLinkRequest { config.linkRequestType.init(from: object) }
    open class func createLinkRequest(from data: DNSDataDictionary) -> DAOAccountLinkRequest? { config.linkRequestType.init(from: data) }

    // MARK: - Internal Work Methods
    override open func intDoActivate(account: DAOAccount,
                                     with progress: DNSPTCLProgressBlock?,
                                     and block: WKRPTCLAccountBlkBool?,
                                     then resultBlock: DNSPTCLResultBlock?) {
        let callData = WKRPTCLSystemsStateData(system: DNSAppConstants.Systems.accounts,
                                               endPoint: DNSAppConstants.Systems.Accounts.EndPoints.activate,
                                               sendDebug: DNSAppConstants.Systems.Accounts.sendDebug)

        guard let dataRequest = try? API.apiActivate(router: self.netRouter, account: account)
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
    override open func intDoApprove(linkRequest: DAOAccountLinkRequest,
                                    with progress: DNSPTCLProgressBlock?,
                                    and block: WKRPTCLAccountBlkVoid?,
                                    then resultBlock: DNSPTCLResultBlock?) {
        let callData = WKRPTCLSystemsStateData(system: DNSAppConstants.Systems.accounts,
                                               endPoint: DNSAppConstants.Systems.Accounts.EndPoints.approve,
                                               sendDebug: DNSAppConstants.Systems.Accounts.sendDebug)

        guard let dataRequest = try? API.apiApprove(router: self.netRouter, linkRequest: linkRequest)
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
    override open func intDoDeactivate(account: DAOAccount,
                                       with progress: DNSPTCLProgressBlock?,
                                       and block: WKRPTCLAccountBlkVoid?,
                                       then resultBlock: DNSPTCLResultBlock?) {
        let callData = WKRPTCLSystemsStateData(system: DNSAppConstants.Systems.accounts,
                                               endPoint: DNSAppConstants.Systems.Accounts.EndPoints.deactivate,
                                               sendDebug: DNSAppConstants.Systems.Accounts.sendDebug)

        guard let dataRequest = try? API.apiDeactivate(router: self.netRouter, account: account)
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
    override open func intDoDecline(linkRequest: DAOAccountLinkRequest,
                                    with progress: DNSPTCLProgressBlock?,
                                    and block: WKRPTCLAccountBlkVoid?,
                                    then resultBlock: DNSPTCLResultBlock?) {
        let callData = WKRPTCLSystemsStateData(system: DNSAppConstants.Systems.accounts,
                                               endPoint: DNSAppConstants.Systems.Accounts.EndPoints.decline,
                                               sendDebug: DNSAppConstants.Systems.Accounts.sendDebug)

        guard let dataRequest = try? API.apiDecline(router: self.netRouter, linkRequest: linkRequest)
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
    override open func intDoDelete(account: DAOAccount,
                                   with progress: DNSPTCLProgressBlock?,
                                   and block: WKRPTCLAccountBlkVoid?,
                                   then resultBlock: DNSPTCLResultBlock?) {
        let callData = WKRPTCLSystemsStateData(system: DNSAppConstants.Systems.accounts,
                                               endPoint: DNSAppConstants.Systems.Accounts.EndPoints.delete,
                                               sendDebug: DNSAppConstants.Systems.Accounts.sendDebug)

        guard let dataRequest = try? API.apiDelete(router: self.netRouter, account: account)
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
    override open func intDoLink(account: DAOAccount,
                                 to user: DAOUser,
                                 with progress: DNSPTCLProgressBlock?,
                                 and block: WKRPTCLAccountBlkVoid?,
                                 then resultBlock: DNSPTCLResultBlock?) {
        let callData = WKRPTCLSystemsStateData(system: DNSAppConstants.Systems.accounts,
                                               endPoint: DNSAppConstants.Systems.Accounts.EndPoints.linkAccount,
                                               sendDebug: DNSAppConstants.Systems.Accounts.sendDebug)

        guard let dataRequest = try? API.apiLinkAccount(router: self.netRouter, account: account, user: user)
            .dataRequest.get() else {
            let error = DNSError.NetworkBase.dataError(.firebaseWorkers(self))
            block?(.failure(error)); _ = resultBlock?(.error)
            return
        }
        self.processRequestData(callData, dataRequest, with: resultBlock,
                                onSuccess: { data in
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
    override open func intDoLoadAccount(for id: String,
                                        with progress: DNSPTCLProgressBlock?,
                                        and block: WKRPTCLAccountBlkAccount?,
                                        then resultBlock: DNSPTCLResultBlock?) {
        let callData = WKRPTCLSystemsStateData(system: DNSAppConstants.Systems.accounts,
                                               endPoint: DNSAppConstants.Systems.Accounts.EndPoints.loadAccount,
                                               sendDebug: DNSAppConstants.Systems.Accounts.sendDebug)

        guard let dataRequest = try? API.apiLoadAccount(router: self.netRouter, accountId: id)
            .dataRequest.get() else {
            let error = DNSError.NetworkBase.dataError(.firebaseWorkers(self))
            block?(.failure(error)); _ = resultBlock?(.error)
            return
        }
        self.processRequestData(callData, dataRequest, with: resultBlock,
                                onSuccess: { data in
            do {
                let user = try JSONDecoder().decode(Self.config.accountType, from: data)
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
    override open func intDoLoadAccounts(for user: DAOUser,
                                         with progress: DNSPTCLProgressBlock?,
                                         and block: WKRPTCLAccountBlkAAccount?,
                                         then resultBlock: DNSPTCLResultBlock?) {
        let callData = WKRPTCLSystemsStateData(system: DNSAppConstants.Systems.accounts,
                                               endPoint: DNSAppConstants.Systems.Accounts.EndPoints.loadAccounts,
                                               sendDebug: DNSAppConstants.Systems.Accounts.sendDebug)

        guard let dataRequest = try? API.apiLoadAccounts(router: self.netRouter, user: user)
            .dataRequest.get() else {
            let error = DNSError.NetworkBase.dataError(.firebaseWorkers(self))
            block?(.failure(error)); _ = resultBlock?(.error)
            return
        }
        self.processRequestData(callData, dataRequest, with: resultBlock,
                                onSuccess: { data in
            do {
                let response = try JSONDecoder().decode(Self.config.accountsResponseType, from: data)
                block?(.success(response.accounts))
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
    override open func intDoLoadLinkRequests(for user: DAOUser,
                                             with progress: DNSProtocols.DNSPTCLProgressBlock?,
                                             and block: WKRPTCLAccountBlkAAccountLinkRequest?,
                                             then resultBlock: DNSPTCLResultBlock?) {
        let callData = WKRPTCLSystemsStateData(system: DNSAppConstants.Systems.accounts,
                                               endPoint: DNSAppConstants.Systems.Accounts.EndPoints.loadLinkRequests,
                                               sendDebug: DNSAppConstants.Systems.Accounts.sendDebug)

        guard let dataRequest = try? API.apiLoadLinkRequests(router: self.netRouter, user: user)
            .dataRequest.get() else {
            let error = DNSError.NetworkBase.dataError(.firebaseWorkers(self))
            block?(.failure(error)); _ = resultBlock?(.error)
            return
        }
        self.processRequestData(callData, dataRequest, with: resultBlock,
                                onSuccess: { data in
            do {
                let response = try JSONDecoder().decode(Self.config.linkRequestsResponseType, from: data)
                block?(.success(response.linkRequests))
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
    override open func intDoLoadUnverifiedAccounts(for user: DAOUser,
                                                   with progress: DNSPTCLProgressBlock?,
                                                   and block: WKRPTCLAccountBlkAAccount?,
                                                   then resultBlock: DNSPTCLResultBlock?) {
        let callData = WKRPTCLSystemsStateData(system: DNSAppConstants.Systems.accounts,
                                               endPoint: DNSAppConstants.Systems.Accounts.EndPoints.loadUnverifiedAccounts,
                                               sendDebug: DNSAppConstants.Systems.Accounts.sendDebug)

        guard let dataRequest = try? API.apiLoadUnverifiedAccounts(router: self.netRouter, user: user)
            .dataRequest.get() else {
            let error = DNSError.NetworkBase.dataError(.firebaseWorkers(self))
            block?(.failure(error)); _ = resultBlock?(.error)
            return
        }
        self.processRequestData(callData, dataRequest, with: resultBlock,
                                onSuccess: { data in
            do {
                let response = try JSONDecoder().decode(Self.config.accountsResponseType, from: data)
                block?(.success(response.accounts))
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
    override open func intDoSearchAccounts(using parameters: DNSDataDictionary,
                                           with progress: DNSPTCLProgressBlock?,
                                           and block: WKRPTCLAccountBlkAAccount?,
                                           then resultBlock: DNSPTCLResultBlock?) {
        let callData = WKRPTCLSystemsStateData(system: DNSAppConstants.Systems.accounts,
                                               endPoint: DNSAppConstants.Systems.Accounts.EndPoints.searchAccount,
                                               sendDebug: DNSAppConstants.Systems.Accounts.sendDebug)

        guard let dataRequest = try? API.apiSearchAccounts(router: self.netRouter, parameters: parameters)
            .dataRequest.get() else {
            let error = DNSError.NetworkBase.dataError(.firebaseWorkers(self))
            block?(.failure(error)); _ = resultBlock?(.error)
            return
        }
        self.processRequestData(callData, dataRequest, with: resultBlock,
                                onSuccess: { data in
            do {
                let response = try JSONDecoder().decode(Self.config.accountsResponseType, from: data)
                block?(.success(response.accounts))
                return .success
            } catch {
                DNSCore.reportError(error)
                return .failure(error)
            }
        },
                                onPendingError: { error, _ in
            if case DNSError.NetworkBase.alreadyLinked = error {
                let value = Self.xlt.string(from: parameters["accountId"] as Any?) ?? "<blank>"
                return DNSError.Account.alreadyLinked(value: value, .firebaseWorkers(self))
            }
            if case DNSError.NetworkBase.expiredAccessToken = error {
                return error
            }
            if case DNSError.NetworkBase.notFound = error {
                return error
            }
            return DNSError.NetworkBase.lowerError(error: error, .firebaseWorkers(self))
        },
                                onError: { error, _ in
            block?(.failure(error))
        })
    }
    override open func intDoUnlink(account: DAOAccount,
                                   from user: DAOUser,
                                   with progress: DNSPTCLProgressBlock?,
                                   and block: WKRPTCLAccountBlkVoid?,
                                   then resultBlock: DNSPTCLResultBlock?) {
        let callData = WKRPTCLSystemsStateData(system: DNSAppConstants.Systems.accounts,
                                               endPoint: DNSAppConstants.Systems.Accounts.EndPoints.unlinkAccount,
                                               sendDebug: DNSAppConstants.Systems.Accounts.sendDebug)

        guard let dataRequest = try? API.apiUnlinkAccount(router: self.netRouter, account: account, user: user)
            .dataRequest.get() else {
            let error = DNSError.NetworkBase.dataError(.firebaseWorkers(self))
            block?(.failure(error)); _ = resultBlock?(.error)
            return
        }
        self.processRequestData(callData, dataRequest, with: resultBlock,
                                onSuccess: { data in
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
    override open func intDoUpdate(account: DAOAccount,
                                   with progress: DNSPTCLProgressBlock?,
                                   and block: WKRPTCLAccountBlkVoid?,
                                   then resultBlock: DNSPTCLResultBlock?) {
        let callData = WKRPTCLSystemsStateData(system: DNSAppConstants.Systems.accounts,
                                               endPoint: DNSAppConstants.Systems.Accounts.EndPoints.updateAccount,
                                               sendDebug: DNSAppConstants.Systems.Accounts.sendDebug)

        guard let dataRequest = try? API.apiUpdate(router: self.netRouter, account: account)
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
    override open func intDoVerify(account: DAOAccount,
                                   with progress: DNSPTCLProgressBlock?,
                                   and block: WKRPTCLAccountBlkVoid?,
                                   then resultBlock: DNSPTCLResultBlock?) {
        let callData = WKRPTCLSystemsStateData(system: DNSAppConstants.Systems.accounts,
                                               endPoint: DNSAppConstants.Systems.Accounts.EndPoints.verifyAccount,
                                               sendDebug: DNSAppConstants.Systems.Accounts.sendDebug)

        guard let dataRequest = try? API.apiVerify(router: self.netRouter, account: account)
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
