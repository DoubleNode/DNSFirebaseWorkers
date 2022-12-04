//
//  WKRFirebaseChats+router.swift
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

open class WKRFirebaseChatsRouter: NETBlankRouter {
    public typealias API = WKRFirebaseChatsAPI // swiftlint:disable:this type_name
    public required init() { super.init() }
    public required init(with netConfig: NETPTCLConfig) { super.init(with: netConfig) }

    open func asURLRequest(for api: API) -> NETPTCLRouterResURLRequest {
        switch api {
        case .apiLoadChat(_, let id):
            return apiLoadChat(id)
        case .apiLoadMessages(_, let chat):
            return apiLoadMessages(chat)
        case .apiRemoveMessage(_, let message):
            return apiRemoveMessage(message)
        case .apiUpdateMessage(_, let message):
            return apiUpdateMessage(message)
        }
    }
    open func apiLoadChat(_ id: String) -> NETPTCLRouterResURLRequest {
        let parameters: [String: String] = [:]
        let componentsResult = netConfig.urlComponents()
        if case .failure(let error) = componentsResult { DNSCore.reportError(error); return .failure(error) }

        var components = try! componentsResult.get() // swiftlint:disable:this force_try
        components.path += "/chats/\(id)"
        components.queryItems = parameters.map({ (key, value) -> URLQueryItem in
            URLQueryItem(name: key, value: String(value))
        })
        guard let url = components.url else {
            let error = DNSError.NetworkBase.invalidUrl(.firebaseWorkers(self))
            DNSCore.reportError(error)
            return .failure(error)
        }
        let requestResult = super.urlRequest(using: url)
        if case .failure(let error) = requestResult { DNSCore.reportError(error); return .failure(error) }

        var request = try! requestResult.get() // swiftlint:disable:this force_try
        request.method = .get
        return .success(request)
    }
    open func apiLoadMessages(_ chat: DAOChat) -> NETPTCLRouterResURLRequest {
        let componentsResult = netConfig.urlComponents()
        if case .failure(let error) = componentsResult { DNSCore.reportError(error); return .failure(error) }

        var components = try! componentsResult.get() // swiftlint:disable:this force_try
        components.path += "/chats/\(chat.id)/messages"
        guard let url = components.url else {
            let error = DNSError.NetworkBase.invalidUrl(.firebaseWorkers(self))
            DNSCore.reportError(error)
            return .failure(error)
        }

        let requestResult = super.urlRequest(using: url)
        if case .failure(let error) = requestResult { DNSCore.reportError(error); return .failure(error) }

        var request = try! requestResult.get() // swiftlint:disable:this force_try
        request.method = .get
        return .success(request)
    }
    open func apiRemoveMessage(_ message: DAOChatMessage) -> NETPTCLRouterResURLRequest {
        let componentsResult = netConfig.urlComponents()
        if case .failure(let error) = componentsResult { DNSCore.reportError(error); return .failure(error) }

        var components = try! componentsResult.get() // swiftlint:disable:this force_try
        components.path += "/chats/\(message.chat.id)/messages/\(message.id)"
        guard let url = components.url else {
            let error = DNSError.NetworkBase.invalidUrl(.firebaseWorkers(self))
            DNSCore.reportError(error)
            return .failure(error)
        }

        let requestResult = super.urlRequest(using: url)
        if case .failure(let error) = requestResult { DNSCore.reportError(error); return .failure(error) }

        var request = try! requestResult.get() // swiftlint:disable:this force_try
        request.method = .delete
        return .success(request)
    }
    open func apiUpdateMessage(_ message: DAOChatMessage) -> NETPTCLRouterResURLRequest {
        let componentsResult = netConfig.urlComponents()
        if case .failure(let error) = componentsResult { DNSCore.reportError(error); return .failure(error) }

        var components = try! componentsResult.get() // swiftlint:disable:this force_try
        components.path += "/chats/\(message.chat.id)/messages/\(message.id)"
        guard let url = components.url else {
            let error = DNSError.NetworkBase.invalidUrl(.firebaseWorkers(self))
            DNSCore.reportError(error)
            return .failure(error)
        }

        let requestResult = super.urlRequest(using: url)
        if case .failure(let error) = requestResult { DNSCore.reportError(error); return .failure(error) }

        var request = try! requestResult.get() // swiftlint:disable:this force_try
        request.method = .post
        do {
            request = try JSONParameterEncoder().encode(message, into: request)
        } catch {
            DNSCore.reportError(error)
            return .failure(error)
        }
        return .success(request)
    }
}
