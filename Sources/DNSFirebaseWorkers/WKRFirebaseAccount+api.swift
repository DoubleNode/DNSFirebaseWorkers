//
//  WKRFirebaseAccount+api.swift
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

public enum WKRFirebaseAccountAPI: URLRequestConvertible {
    typealias Router = WKRFirebaseAccountRouter
    case apiActivate(router: NETPTCLRouter, account: DAOAccount)
    case apiApprove(router: NETPTCLRouter, linkRequest: DAOAccountLinkRequest)
    case apiDeactivate(router: NETPTCLRouter, account: DAOAccount)
    case apiDecline(router: NETPTCLRouter, linkRequest: DAOAccountLinkRequest)
    case apiDelete(router: NETPTCLRouter, account: DAOAccount)
    case apiLinkPlace(router: NETPTCLRouter, account: DAOAccount, place: DAOPlace)
    case apiLinkUser(router: NETPTCLRouter, account: DAOAccount, user: DAOUser)
    case apiLoadAccount(router: NETPTCLRouter, accountId: String)
    case apiLoadAccounts(router: NETPTCLRouter, user: DAOUser)
    case apiLoadLinkRequests(router: NETPTCLRouter, user: DAOUser)
    case apiLoadPlaces(router: NETPTCLRouter, account: DAOAccount)
    case apiLoadUnverifiedAccounts(router: NETPTCLRouter, user: DAOUser)
    case apiSearchAccounts(router: NETPTCLRouter, parameters: DNSDataDictionary)
    case apiUnlinkPlace(router: NETPTCLRouter, account: DAOAccount, place: DAOPlace)
    case apiUnlinkUser(router: NETPTCLRouter, account: DAOAccount, user: DAOUser)
    case apiUpdate(router: NETPTCLRouter, account: DAOAccount)
    case apiVerify(router: NETPTCLRouter, account: DAOAccount)

    public var dataRequest: NETPTCLRouterResDataRequest {
        .success(AF.request(self))
    }
    public func asURLRequest() throws -> NETPTCLRouterRtnURLRequest {
        var netRouter: Router?
        if case .apiActivate(let router, _) = self { netRouter = router as? Router }
        if case .apiApprove(let router, _) = self { netRouter = router as? Router }
        if case .apiDeactivate(let router, _) = self { netRouter = router as? Router }
        if case .apiDecline(let router, _) = self { netRouter = router as? Router }
        if case .apiDelete(let router, _) = self { netRouter = router as? Router }
        if case .apiLinkPlace(let router, _, _) = self { netRouter = router as? Router }
        if case .apiLinkUser(let router, _, _) = self { netRouter = router as? Router }
        if case .apiLoadAccount(let router, _) = self { netRouter = router as? Router }
        if case .apiLoadAccounts(let router, _) = self { netRouter = router as? Router }
        if case .apiLoadLinkRequests(let router, _) = self { netRouter = router as? Router }
        if case .apiLoadPlaces(let router, _) = self { netRouter = router as? Router }
        if case .apiLoadUnverifiedAccounts(let router, _) = self { netRouter = router as? Router }
        if case .apiSearchAccounts(let router, _) = self { netRouter = router as? Router }
        if case .apiUnlinkPlace(let router, _, _) = self { netRouter = router as? Router }
        if case .apiUnlinkUser(let router, _, _) = self { netRouter = router as? Router }
        if case .apiUpdate(let router, _) = self { netRouter = router as? Router }
        if case .apiVerify(let router, _) = self { netRouter = router as? Router }
        guard let netRouter else {
            let error = DNSError.Account
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
