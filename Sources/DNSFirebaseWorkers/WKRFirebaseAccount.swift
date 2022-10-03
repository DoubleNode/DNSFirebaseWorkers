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

open class WKRFirebaseAccount: WKRBlankAccount {
    typealias API = WKRFirebaseAccountAPI // swiftlint:disable:this type_name

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
    override open func intDoDeactivate(account: DAOAccount,
                                       with progress: DNSPTCLProgressBlock?,
                                       and block: WKRPTCLAccountBlkVoid?,
                                       then resultBlock: DNSPTCLResultBlock?) {
//        guard let account = account as? DAOAccount else {
//            let dnsError = DNSError.WorkerBase
//                .invalidParameters(parameters: ["account"], .firebaseWorkers(self))
//            DNSCore.reportError(dnsError)
//            block?(.failure(dnsError))
//            _ = resultBlock?(.error)
//            return
//        }
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
            DNSError.NetworkBase.lowerError(error: error, .firebaseWorkers(self))
        },
                                onError: { error, _ in
            block?(.failure(error))
        })
    }
    override open func intDoDelete(account: DAOAccount,
                                   with progress: DNSPTCLProgressBlock?,
                                   and block: WKRPTCLAccountBlkVoid?,
                                   then resultBlock: DNSPTCLResultBlock?) {
//        guard let account = account as? DAOAccount else {
//            let dnsError = DNSError.WorkerBase
//                .invalidParameters(parameters: ["account"], .firebaseWorkers(self))
//            DNSCore.reportError(dnsError)
//            block?(.failure(dnsError))
//            _ = resultBlock?(.error)
//            return
//        }
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
            DNSError.NetworkBase.lowerError(error: error, .firebaseWorkers(self))
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
        self.processRequestJSON(callData, dataRequest, with: resultBlock,
                                onSuccess: { data in
            let result = Self.xlt.dictionary(from: data)
            guard let account = DAOAccount(from: result) else {
                let error = DNSError.Account.unknown(.firebaseWorkers(self))
                return .failure(error)
            }
            account.id = user.id
            account.name = user.email
            account.users = [user]
            block?(.success([account]))
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
//        guard let account = account as? DAOAccount else {
//            let dnsError = DNSError.WorkerBase
//                .invalidParameters(parameters: ["account"], .firebaseWorkers(self))
//            DNSCore.reportError(dnsError)
//            block?(.failure(dnsError))
//            _ = resultBlock?(.error)
//            return
//        }
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
}
