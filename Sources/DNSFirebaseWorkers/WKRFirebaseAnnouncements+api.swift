//
//  WKRFirebaseAnnouncements+api.swift
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

public enum WKRFirebaseAnnouncementsAPI: URLRequestConvertible {
    public typealias Router = WKRFirebaseAnnouncementsRouter
    case apiLoadAnnouncements(router: NETPTCLRouter)
    case apiLoadAnnouncementsForPlace(router: NETPTCLRouter, place: DAOPlace)
    case apiRemoveAnnouncement(router: NETPTCLRouter, announcement: DAOAnnouncement, place: DAOPlace)
    case apiUpdateAnnouncement(router: NETPTCLRouter, announcement: DAOAnnouncement, place: DAOPlace)

    public var dataRequest: NETPTCLRouterResDataRequest {
        .success(AF.request(self))
    }
    public func asURLRequest() throws -> NETPTCLRouterRtnURLRequest {
        var netRouter: Router?
        if case .apiLoadAnnouncements(let router) = self { netRouter = router as? Router }
        if case .apiLoadAnnouncementsForPlace(let router, _) = self { netRouter = router as? Router }
        if case .apiRemoveAnnouncement(let router, _, _) = self { netRouter = router as? Router }
        if case .apiUpdateAnnouncement(let router, _, _) = self { netRouter = router as? Router }
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
