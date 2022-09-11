//
//  WKRFirebaseSystems+router.swift
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

open class WKRFirebaseSystemsRouter: NETBlankRouter {
    public typealias API = WKRFirebaseSystemsAPI // swiftlint:disable:this type_name
    public required init() { super.init() }
    public required init(with netConfig: NETPTCLConfig) { super.init(with: netConfig) }

    open func asURLRequest(for api: API) -> NETPTCLRouterResURLRequest {
        switch api {
        case .apiOverrideState(_, let systemId, let state):
            return apiOverrideState(systemId, state)
        case .apiSystemsState(_, let callData, let result, let failureCode, let debugString):
            return apiSystemsState(callData, result, failureCode, debugString)
        }
    }
    open func apiOverrideState(_ systemId: String, _ state: String) -> NETPTCLRouterResURLRequest {
        let parameters = [
            "systemId": systemId,
            "state": state,
        ]
        let componentsResult = netConfig.urlComponents()
        if case .failure(let error) = componentsResult { DNSCore.reportError(error); return .failure(error) }

        var components = try! componentsResult.get() // swiftlint:disable:this force_try
        components.path += "/systems/override"
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
        request.method = .post
        return .success(request)
    }
    open func apiSystemsState(_ callData: WKRPTCLSystemsStateData,
                              _ result: WKRPTCLSystemsData.Result, _ failureCode: String,
                              _ debugString: String) -> NETPTCLRouterResURLRequest {
        var bodyParams: [String: String] = [:]
        if !debugString.isEmpty {
            bodyParams["debugString"] = debugString
        }
        let parameters = [
            "systemId": callData.system,
            "endPointCode": callData.endPoint,
            "statusCode": result.rawValue,
            "failureCode": failureCode,
            "platform": "ios",
        ]
        let componentsResult = netConfig.urlComponents()
        if case .failure(let error) = componentsResult { DNSCore.reportError(error); return .failure(error) }

        var components = try! componentsResult.get() // swiftlint:disable:this force_try
        components.path += "/systems/status"
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
        request.method = .post
        if !bodyParams.isEmpty {
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: bodyParams,
                                                              options: [])
            } catch {
                DNSCore.reportError(error)
                return .failure(error)
            }
        }
        return .success(request)
    }
}
