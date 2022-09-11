//
//  WKRFirebaseSystems+api.swift
//  DoubleNode Swift Framework (DNSFramework) - DNSFirebaseWorkers
//
//  Created by Darren Ehlers.
//  Copyright © 2022 - 2016 DoubleNode.com. All rights reserved.
//

import Alamofire
import DNSBlankNetwork
import DNSBlankWorkers
import DNSCore
import DNSError
import DNSProtocols
import Foundation

public enum WKRFirebaseSystemsAPI: URLRequestConvertible {
    public typealias Router = WKRFirebaseSystemsRouter
    case apiOverrideState(router: NETPTCLRouter, systemId: String, state: String)
    case apiSystemsState(router: NETPTCLRouter, callData: WKRPTCLSystemsStateData,
                         result: WKRPTCLSystemsData.Result, failureCode: String,
                         debugString: String)

    public var dataRequest: NETPTCLRouterResDataRequest {
        .success(AF.request(self))
    }
    public func asURLRequest() throws -> NETPTCLRouterRtnURLRequest {
        var netRouter: Router?
        if case .apiOverrideState(let router, _, _) = self { netRouter = router as? Router }
        if case .apiSystemsState(let router, _, _, _, _) = self { netRouter = router as? Router }
        guard let netRouter else {
            let error = DNSError.Systems
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
