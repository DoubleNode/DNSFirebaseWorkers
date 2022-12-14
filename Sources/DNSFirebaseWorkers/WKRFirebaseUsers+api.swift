//
//  WKRFirebaseUsers+api.swift
//  SeaCadetsHelper
//
//  Created by Darren Ehlers on 9/10/22.
//

import Alamofire
import DNSBlankNetwork
import DNSBlankWorkers
import DNSCore
import DNSDataObjects
import DNSError
import DNSProtocols
import Foundation

public enum WKRFirebaseUsersAPI: URLRequestConvertible {
    typealias Router = WKRFirebaseUsersRouter
    case apiActivate(router: NETPTCLRouter, user: DAOUser)
    case apiConfirm(router: NETPTCLRouter, pendingUser: DAOUser)
    case apiConsent(router: NETPTCLRouter, childUser: DAOUser)
    case apiLoadChildUsers(router: NETPTCLRouter, user: DAOUser)
    case apiLoadLinkRequests(router: NETPTCLRouter, parameters: DNSDataDictionary, user: DAOUser)
    case apiLoadPendingUsers(router: NETPTCLRouter, user: DAOUser)
    case apiLoadUnverifiedAccounts(router: NETPTCLRouter, user: DAOUser)
    case apiLoadUser(router: NETPTCLRouter, userId: String)
    case apiLoadUsers(router: NETPTCLRouter, account: DAOAccount)
    case apiRemove(router: NETPTCLRouter, user: DAOUser)
    case apiUpdate(router: NETPTCLRouter, user: DAOUser)

    public var dataRequest: NETPTCLRouterResDataRequest {
        .success(AF.request(self))
    }
    public func asURLRequest() throws -> NETPTCLRouterRtnURLRequest {
        var netRouter: Router?
        if case .apiActivate(let router, _) = self { netRouter = router as? Router }
        if case .apiConfirm(let router, _) = self { netRouter = router as? Router }
        if case .apiConsent(let router, _) = self { netRouter = router as? Router }
        if case .apiLoadChildUsers(let router, _) = self { netRouter = router as? Router }
        if case .apiLoadLinkRequests(let router, _, _) = self { netRouter = router as? Router }
        if case .apiLoadPendingUsers(let router, _) = self { netRouter = router as? Router }
        if case .apiLoadUnverifiedAccounts(let router, _) = self { netRouter = router as? Router }
        if case .apiLoadUser(let router, _) = self { netRouter = router as? Router }
        if case .apiLoadUsers(let router, _) = self { netRouter = router as? Router }
        if case .apiRemove(let router, _) = self { netRouter = router as? Router }
        if case .apiUpdate(let router, _) = self { netRouter = router as? Router }
        guard let netRouter else {
            let error = DNSError.Users
                .invalidParameters(parameters: ["netRouter"], .firebaseWorkers(self))
            throw error
        }
        let requestResult = netRouter.asURLRequest(for: self)
        if case .failure(let error) = requestResult {
            throw error
        }
        return try! requestResult.get() // swiftlint:disable:this force_try
    }
}
