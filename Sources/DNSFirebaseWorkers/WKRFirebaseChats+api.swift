//
//  WKRFirebaseChats+api.swift
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

public enum WKRFirebaseChatsAPI: URLRequestConvertible {
    public typealias Router = WKRFirebaseChatsRouter
    case apiLoadChat(router: NETPTCLRouter, id: String)
    case apiLoadMessages(router: NETPTCLRouter, chat: DAOChat)
    case apiRemoveMessage(router: NETPTCLRouter, message: DAOChatMessage)
    case apiUpdateMessage(router: NETPTCLRouter, message: DAOChatMessage)

    public var dataRequest: NETPTCLRouterResDataRequest {
        .success(AF.request(self))
    }
    public func asURLRequest() throws -> NETPTCLRouterRtnURLRequest {
        var netRouter: Router?
        if case .apiLoadChat(let router, _) = self { netRouter = router as? Router }
        if case .apiLoadMessages(let router, _) = self { netRouter = router as? Router }
        if case .apiRemoveMessage(let router, _) = self { netRouter = router as? Router }
        if case .apiUpdateMessage(let router, _) = self { netRouter = router as? Router }
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
