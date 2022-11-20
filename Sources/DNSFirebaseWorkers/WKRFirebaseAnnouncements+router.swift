//
//  WKRFirebaseAnnouncements+router.swift
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

open class WKRFirebaseAnnouncementsRouter: NETBlankRouter {
    public typealias API = WKRFirebaseAnnouncementsAPI // swiftlint:disable:this type_name
    public required init() { super.init() }
    public required init(with netConfig: NETPTCLConfig) { super.init(with: netConfig) }

    open func asURLRequest(for api: API) -> NETPTCLRouterResURLRequest {
        switch api {
        case .apiLoadAnnouncements(_):
            return apiLoadAnnouncements()
        case .apiLoadAnnouncementsForPlace(_, let place):
            return apiLoadAnnouncementsForPlace(place)
        case .apiRemoveAnnouncement(_, let announcement, let place):
            return apiRemoveAnnouncement(announcement, place)
        case .apiUpdateAnnouncement(_, let announcement, let place):
            return apiUpdateAnnouncement(announcement, place)
        }
    }
    open func apiLoadAnnouncements() -> NETPTCLRouterResURLRequest {
        let parameters: [String: String] = [:]
        let componentsResult = netConfig.urlComponents()
        if case .failure(let error) = componentsResult { DNSCore.reportError(error); return .failure(error) }

        var components = try! componentsResult.get() // swiftlint:disable:this force_try
        components.path += "/announcements/"
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
    open func apiLoadAnnouncementsForPlace(_ place: DAOPlace) -> NETPTCLRouterResURLRequest {
        let componentsResult = netConfig.urlComponents()
        if case .failure(let error) = componentsResult { DNSCore.reportError(error); return .failure(error) }

        var components = try! componentsResult.get() // swiftlint:disable:this force_try
        components.path += "/place/\(place.id)/announcements"
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
    open func apiRemoveAnnouncement(_ announcement: DAOAnnouncement, _ place: DAOPlace) -> NETPTCLRouterResURLRequest {
        let componentsResult = netConfig.urlComponents()
        if case .failure(let error) = componentsResult { DNSCore.reportError(error); return .failure(error) }

        var components = try! componentsResult.get() // swiftlint:disable:this force_try
        components.path += "/places/\(place.id)/announcements/\(announcement.id)"
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
    open func apiUpdateAnnouncement(_ announcement: DAOAnnouncement, _ place: DAOPlace) -> NETPTCLRouterResURLRequest {
        let componentsResult = netConfig.urlComponents()
        if case .failure(let error) = componentsResult { DNSCore.reportError(error); return .failure(error) }

        var components = try! componentsResult.get() // swiftlint:disable:this force_try
        components.path += "/places/\(place.id)/announcements/\(announcement.id)"
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
            request = try JSONParameterEncoder().encode(announcement, into: request)
        } catch {
            DNSCore.reportError(error)
            return .failure(error)
        }
        return .success(request)
    }
}
