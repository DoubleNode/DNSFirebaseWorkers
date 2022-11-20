//
//  WKRFirebaseEvents+api.swift
//  DoubleNode Swift Framework (DNSFramework) - DNSFirebaseWorkers
//
//  Created by Darren Ehlers.
//  Copyright © 2022 - 2016 DoubleNode.com. All rights reserved.
//

import Alamofire
import DNSBlankNetwork
import DNSBlankWorkers
import DNSCore
import DNSDataObjects
import DNSError
import DNSProtocols
import Foundation

public enum WKRFirebaseEventsAPI: URLRequestConvertible {
    public typealias Router = WKRFirebaseEventsRouter
    case apiLoadEvents(router: NETPTCLRouter)
    case apiLoadEventsForPlace(router: NETPTCLRouter, place: DAOPlace)
    case apiRemoveEvent(router: NETPTCLRouter, event: DAOEvent, place: DAOPlace)
    case apiUpdateEvent(router: NETPTCLRouter, event: DAOEvent, place: DAOPlace)

    public var dataRequest: NETPTCLRouterResDataRequest {
        .success(AF.request(self))
    }
    public func asURLRequest() throws -> NETPTCLRouterRtnURLRequest {
        var netRouter: Router?
        if case .apiLoadEvents(let router) = self { netRouter = router as? Router }
        if case .apiLoadEventsForPlace(let router, _) = self { netRouter = router as? Router }
        if case .apiRemoveEvent(let router, _, _) = self { netRouter = router as? Router }
        if case .apiUpdateEvent(let router, _, _) = self { netRouter = router as? Router }
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
