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
    case apiLoadCurrentAnnouncements(router: NETPTCLRouter)
    case apiLoadAnnouncements(router: NETPTCLRouter)
    case apiLoadAnnouncementsForPlace(router: NETPTCLRouter, place: DAOPlace)
    case apiReact(router: NETPTCLRouter, reaction: DNSReactionType, announcement: DAOAnnouncement)
    case apiReactForPlace(router: NETPTCLRouter, reaction: DNSReactionType, announcement: DAOAnnouncement, place: DAOPlace)
    case apiRemoveAnnouncement(router: NETPTCLRouter, announcement: DAOAnnouncement)
    case apiRemoveAnnouncementForPlace(router: NETPTCLRouter, announcement: DAOAnnouncement, place: DAOPlace)
    case apiUnreact(router: NETPTCLRouter, reaction: DNSReactionType, announcement: DAOAnnouncement)
    case apiUnreactForPlace(router: NETPTCLRouter, reaction: DNSReactionType, announcement: DAOAnnouncement, place: DAOPlace)
    case apiUpdateAnnouncement(router: NETPTCLRouter, announcement: DAOAnnouncement)
    case apiUpdateAnnouncementForPlace(router: NETPTCLRouter, announcement: DAOAnnouncement, place: DAOPlace)
    case apiView(router: NETPTCLRouter, announcement: DAOAnnouncement)
    case apiViewForPlace(router: NETPTCLRouter, announcement: DAOAnnouncement, place: DAOPlace)

    public var dataRequest: NETPTCLRouterResDataRequest {
        .success(AF.request(self))
    }
    public func asURLRequest() throws -> NETPTCLRouterRtnURLRequest {
        var netRouter: Router?
        if case .apiLoadCurrentAnnouncements(let router) = self { netRouter = router as? Router }
        if case .apiLoadAnnouncements(let router) = self { netRouter = router as? Router }
        if case .apiLoadAnnouncementsForPlace(let router, _) = self { netRouter = router as? Router }
        if case .apiReact(let router, _, _) = self { netRouter = router as? Router }
        if case .apiReactForPlace(let router, _, _, _) = self { netRouter = router as? Router }
        if case .apiRemoveAnnouncement(let router, _) = self { netRouter = router as? Router }
        if case .apiRemoveAnnouncementForPlace(let router, _, _) = self { netRouter = router as? Router }
        if case .apiUnreact(let router, _, _) = self { netRouter = router as? Router }
        if case .apiUnreactForPlace(let router, _, _, _) = self { netRouter = router as? Router }
        if case .apiUpdateAnnouncement(let router, _) = self { netRouter = router as? Router }
        if case .apiUpdateAnnouncementForPlace(let router, _, _) = self { netRouter = router as? Router }
        if case .apiView(let router, _) = self { netRouter = router as? Router }
        if case .apiViewForPlace(let router, _, _) = self { netRouter = router as? Router }
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
