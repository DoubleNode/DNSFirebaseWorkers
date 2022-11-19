//
//  WKRFirebasePlaces+router.swift
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

open class WKRFirebasePlacesRouter: NETBlankRouter {
    public typealias API = WKRFirebasePlacesAPI // swiftlint:disable:this type_name
    public required init() { super.init() }
    public required init(with netConfig: NETPTCLConfig) { super.init(with: netConfig) }

    open func asURLRequest(for api: API) -> NETPTCLRouterResURLRequest {
        switch api {
        case .apiLoadPlace(_, let placeCode):
            return apiLoadPlace(placeCode)
        case .apiLoadPlaces(_):
            return apiLoadPlaces()
        case .apiLoadPlacesForAccount(_, let account):
            return apiLoadPlacesForAccount(account)
        case .apiUpdatePlace(_, let place):
            return apiUpdatePlace(place)
        }
    }
    open func apiLoadPlace(_ placeCode: String) -> NETPTCLRouterResURLRequest {
        let parameters: [String: String] = [:]
        let componentsResult = netConfig.urlComponents()
        if case .failure(let error) = componentsResult { DNSCore.reportError(error); return .failure(error) }

        var components = try! componentsResult.get() // swiftlint:disable:this force_try
        components.path += "/places/\(placeCode)"
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
    open func apiLoadPlaces() -> NETPTCLRouterResURLRequest {
        let parameters: [String: String] = [:]
        let componentsResult = netConfig.urlComponents()
        if case .failure(let error) = componentsResult { DNSCore.reportError(error); return .failure(error) }

        var components = try! componentsResult.get() // swiftlint:disable:this force_try
        components.path += "/places/"
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
    open func apiLoadPlacesForAccount(_ account: DAOAccount) -> NETPTCLRouterResURLRequest {
        let componentsResult = netConfig.urlComponents()
        if case .failure(let error) = componentsResult { DNSCore.reportError(error); return .failure(error) }

        var components = try! componentsResult.get() // swiftlint:disable:this force_try
        components.path += "/accounts/\(account.id)/places"
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
    open func apiUpdatePlace(_ place: DAOPlace) -> NETPTCLRouterResURLRequest {
        let componentsResult = netConfig.urlComponents()
        if case .failure(let error) = componentsResult { DNSCore.reportError(error); return .failure(error) }

        var components = try! componentsResult.get() // swiftlint:disable:this force_try
        components.path += "/places/\(place.id)"
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
            request = try JSONParameterEncoder().encode(place, into: request)
        } catch {
            DNSCore.reportError(error)
            return .failure(error)
        }
        return .success(request)
    }
}
