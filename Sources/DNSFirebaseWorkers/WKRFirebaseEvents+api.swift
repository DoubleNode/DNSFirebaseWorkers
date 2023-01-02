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
    case apiLoadCurrentEvents(router: NETPTCLRouter)
    case apiLoadEvents(router: NETPTCLRouter, place: DAOPlace)
    case apiReact(router: NETPTCLRouter, reaction: DNSReactionType, event: DAOEvent, place: DAOPlace)
    case apiRemoveEvent(router: NETPTCLRouter, event: DAOEvent, place: DAOPlace)
    case apiRemoveEventDay(router: NETPTCLRouter, eventDay: DAOEventDay, event: DAOEvent, place: DAOPlace)
    case apiUnreact(router: NETPTCLRouter, reaction: DNSReactionType, event: DAOEvent, place: DAOPlace)
    case apiUpdateEvent(router: NETPTCLRouter, event: DAOEvent, place: DAOPlace)
    case apiUpdateEventDay(router: NETPTCLRouter, eventDay: DAOEventDay, event: DAOEvent, place: DAOPlace)
    case apiView(router: NETPTCLRouter, event: DAOEvent, place: DAOPlace)

    public var dataRequest: NETPTCLRouterResDataRequest {
        .success(AF.request(self))
    }
    public func asURLRequest() throws -> NETPTCLRouterRtnURLRequest {
        var netRouter: Router?
        if case .apiLoadCurrentEvents(let router) = self { netRouter = router as? Router }
        if case .apiLoadEvents(let router, _) = self { netRouter = router as? Router }
        if case .apiReact(let router, _, _, _) = self { netRouter = router as? Router }
        if case .apiRemoveEvent(let router, _, _) = self { netRouter = router as? Router }
        if case .apiRemoveEventDay(let router, _, _, _) = self { netRouter = router as? Router }
        if case .apiUnreact(let router, _, _, _) = self { netRouter = router as? Router }
        if case .apiUpdateEvent(let router, _, _) = self { netRouter = router as? Router }
        if case .apiUpdateEventDay(let router, _, _, _) = self { netRouter = router as? Router }
        if case .apiView(let router, _, _) = self { netRouter = router as? Router }
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
