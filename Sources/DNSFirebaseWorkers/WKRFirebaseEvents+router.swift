//
//  WKRFirebaseEvents+router.swift
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

open class WKRFirebaseEventsRouter: NETBlankRouter {
    public typealias API = WKRFirebaseEventsAPI // swiftlint:disable:this type_name
    public required init() { super.init() }
    public required init(with netConfig: NETPTCLConfig) { super.init(with: netConfig) }

    open func asURLRequest(for api: API) -> NETPTCLRouterResURLRequest {
        switch api {
        case .apiLoadCurrentEvents(_):
            return apiLoadCurrentEvents()
        case .apiLoadEvents(_, let place):
            return apiLoadEvents(place)
        case .apiReact(_, let reaction, let event, let place):
            return apiReact(reaction, event, place)
        case .apiRemoveEvent(_, let event, let place):
            return apiRemoveEvent(event, place)
        case .apiRemoveEventDay(_, let eventDay, let event, let place):
            return apiRemoveEventDay(eventDay, event, place)
        case .apiUnreact(_, let reaction, let event, let place):
            return apiUnreact(reaction, event, place)
        case .apiUpdateEvent(_, let event, let place):
            return apiUpdateEvent(event, place)
        case .apiUpdateEventDay(_, let eventDay, let event, let place):
            return apiUpdateEventDay(eventDay, event, place)
        case .apiView(_, let event, let place):
            return apiView(event, place)
        }
    }
    open func apiLoadCurrentEvents() -> NETPTCLRouterResURLRequest {
        let parameters: [String: String] = [:]
        let componentsResult = netConfig.urlComponents()
        if case .failure(let error) = componentsResult { DNSCore.reportError(error); return .failure(error) }

        var components = try! componentsResult.get() // swiftlint:disable:this force_try
        components.path += "/events/current"
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
    open func apiLoadEvents(_ place: DAOPlace) -> NETPTCLRouterResURLRequest {
        let componentsResult = netConfig.urlComponents()
        if case .failure(let error) = componentsResult { DNSCore.reportError(error); return .failure(error) }

        var components = try! componentsResult.get() // swiftlint:disable:this force_try
        components.path += "/places/\(place.id)/events"
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
    open func apiReact(_ reaction: DNSReactionType, _ event: DAOEvent, _ place: DAOPlace) -> NETPTCLRouterResURLRequest {
        let parameters: [String: String] = [
            "reaction": reaction.rawValue,
        ]
        let componentsResult = netConfig.urlComponents()
        if case .failure(let error) = componentsResult { DNSCore.reportError(error); return .failure(error) }

        var components = try! componentsResult.get() // swiftlint:disable:this force_try
        components.path += "/events/\(event.id)/places/\(place.id)/react"
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
        request.method = .put
        return .success(request)
    }
    open func apiRemoveEvent(_ event: DAOEvent, _ place: DAOPlace) -> NETPTCLRouterResURLRequest {
        let componentsResult = netConfig.urlComponents()
        if case .failure(let error) = componentsResult { DNSCore.reportError(error); return .failure(error) }

        var components = try! componentsResult.get() // swiftlint:disable:this force_try
        components.path += "/places/\(place.id)/events/\(event.id)"
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
    open func apiRemoveEventDay(_ eventDay: DAOEventDay, _ event: DAOEvent, _ place: DAOPlace) -> NETPTCLRouterResURLRequest {
        let componentsResult = netConfig.urlComponents()
        if case .failure(let error) = componentsResult { DNSCore.reportError(error); return .failure(error) }

        var components = try! componentsResult.get() // swiftlint:disable:this force_try
        components.path += "/places/\(place.id)/events/\(event.id)/eventDay/\(eventDay.id)"
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
    open func apiUnreact(_ reaction: DNSReactionType, _ event: DAOEvent, _ place: DAOPlace) -> NETPTCLRouterResURLRequest {
        let parameters: [String: String] = [
            "reaction": reaction.rawValue,
        ]
        let componentsResult = netConfig.urlComponents()
        if case .failure(let error) = componentsResult { DNSCore.reportError(error); return .failure(error) }

        var components = try! componentsResult.get() // swiftlint:disable:this force_try
        components.path += "/events/\(event.id)/places/\(place.id)/unreact"
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
        request.method = .put
        return .success(request)
    }
    open func apiUpdateEvent(_ event: DAOEvent, _ place: DAOPlace) -> NETPTCLRouterResURLRequest {
        let componentsResult = netConfig.urlComponents()
        if case .failure(let error) = componentsResult { DNSCore.reportError(error); return .failure(error) }

        var components = try! componentsResult.get() // swiftlint:disable:this force_try
        components.path += "/places/\(place.id)/events/\(event.id)"
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
            request = try JSONParameterEncoder().encode(event, into: request)
        } catch {
            DNSCore.reportError(error)
            return .failure(error)
        }
        return .success(request)
    }
    open func apiUpdateEventDay(_ eventDay: DAOEventDay, _ event: DAOEvent, _ place: DAOPlace) -> NETPTCLRouterResURLRequest {
        let componentsResult = netConfig.urlComponents()
        if case .failure(let error) = componentsResult { DNSCore.reportError(error); return .failure(error) }

        var components = try! componentsResult.get() // swiftlint:disable:this force_try
        components.path += "/places/\(place.id)/events/\(event.id)/eventDays/\(eventDay.id)"
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
            request = try JSONParameterEncoder().encode(event, into: request)
        } catch {
            DNSCore.reportError(error)
            return .failure(error)
        }
        return .success(request)
    }
    open func apiView(_ event: DAOEvent, _ place: DAOPlace) -> NETPTCLRouterResURLRequest {
        let componentsResult = netConfig.urlComponents()
        if case .failure(let error) = componentsResult { DNSCore.reportError(error); return .failure(error) }

        var components = try! componentsResult.get() // swiftlint:disable:this force_try
        components.path += "/events/\(event.id)/places/\(place.id)/view"
        guard let url = components.url else {
            let error = DNSError.NetworkBase.invalidUrl(.firebaseWorkers(self))
            DNSCore.reportError(error)
            return .failure(error)
        }

        let requestResult = super.urlRequest(using: url)
        if case .failure(let error) = requestResult { DNSCore.reportError(error); return .failure(error) }

        var request = try! requestResult.get() // swiftlint:disable:this force_try
        request.method = .put
        return .success(request)
    }
}
