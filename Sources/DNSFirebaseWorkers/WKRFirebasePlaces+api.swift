//
//  WKRFirebasePlaces+api.swift
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

public enum WKRFirebasePlacesAPI: URLRequestConvertible {
    public typealias Router = WKRFirebasePlacesRouter
    case apiLoadPlace(router: NETPTCLRouter, placeCode: String)
    case apiLoadPlaces(router: NETPTCLRouter)
    case apiUpdatePlace(router: NETPTCLRouter, place: DAOPlace)

    public var dataRequest: NETPTCLRouterResDataRequest {
        .success(AF.request(self))
    }
    public func asURLRequest() throws -> NETPTCLRouterRtnURLRequest {
        var netRouter: Router?
        if case .apiLoadPlace(let router, _) = self { netRouter = router as? Router }
        if case .apiLoadPlaces(let router) = self { netRouter = router as? Router }
        if case .apiUpdatePlace(let router, _) = self { netRouter = router as? Router }
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
