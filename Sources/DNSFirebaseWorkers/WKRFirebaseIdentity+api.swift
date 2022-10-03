//
//  WKRFirebaseIdentity+api.swift
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

public enum WKRFirebaseIdentityAPI: URLRequestConvertible {
    typealias Router = WKRFirebaseIdentityRouter
    case apiClearIdentity(router: NETPTCLRouter, fcmToken: String)
    case apiSetIdentity(router: NETPTCLRouter, userId: String, fcmToken: String)

    public var dataRequest: NETPTCLRouterResDataRequest {
        .success(AF.request(self))
    }
    public func asURLRequest() throws -> NETPTCLRouterRtnURLRequest {
        var netRouter: Router?
        if case .apiClearIdentity(let router, _) = self { netRouter = router as? Router }
        if case .apiSetIdentity(let router, _, _) = self { netRouter = router as? Router }
        guard let netRouter else {
            let error = DNSError.Identity
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
