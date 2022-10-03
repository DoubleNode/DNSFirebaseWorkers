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

enum WKRFirebaseAccountAPI: URLRequestConvertible {
    typealias Router = WKRFirebaseAccountRouter
    case apiActivate(router: NETPTCLRouter, account: DAOAccount)
    case apiDeactivate(router: NETPTCLRouter, account: DAOAccount)
    case apiDelete(router: NETPTCLRouter, account: DAOAccount)
    case apiLoadAccounts(router: NETPTCLRouter, user: DAOUser)
    case apiUpdate(router: NETPTCLRouter, account: DAOAccount)

    var dataRequest: NETPTCLRouterResDataRequest {
        .success(AF.request(self))
    }
    func asURLRequest() throws -> NETPTCLRouterRtnURLRequest {
        var netRouter: Router?
        if case .apiActivate(let router, _) = self { netRouter = router as? Router }
        if case .apiDeactivate(let router, _) = self { netRouter = router as? Router }
        if case .apiDelete(let router, _) = self { netRouter = router as? Router }
        if case .apiLoadAccounts(let router, _) = self { netRouter = router as? Router }
        if case .apiUpdate(let router, _) = self { netRouter = router as? Router }
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
