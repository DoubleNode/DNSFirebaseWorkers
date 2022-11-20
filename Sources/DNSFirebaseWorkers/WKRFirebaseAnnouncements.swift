//
//  WKRFirebaseAnnouncements.swift
//  DoubleNode Swift Framework (DNSFramework) - DNSFirebaseWorkers
//
//  Created by Darren Ehlers.
//  Copyright © 2022 - 2016 DoubleNode.com. All rights reserved.
//

import AtomicSwift
import DNSBlankWorkers
import DNSCore
import DNSCoreThreading
import DNSDataObjects
import DNSError
import DNSProtocols
import FirebaseFirestore

public protocol PTCLCFGWKRFirebaseAnnouncements: PTCLCFGDAOAnnouncement {
    var announcementsResponseType: any PTCLRSPWKRFirebaseAnnouncementsAAnnouncement.Type { get }
}
public class CFGWKRFirebaseAnnouncements: PTCLCFGWKRFirebaseAnnouncements {
    public var announcementsResponseType: any PTCLRSPWKRFirebaseAnnouncementsAAnnouncement.Type = RSPWKRFirebaseAnnouncementsAAnnouncement.self
    public var announcementType: DAOAnnouncement.Type = DAOAnnouncement.self
    open func announcement<K>(from container: KeyedDecodingContainer<K>,
                              forKey key: KeyedDecodingContainer<K>.Key) -> DAOAnnouncement? where K: CodingKey {
        do { return try container.decodeIfPresent(DAOAnnouncement.self, forKey: key, configuration: self) ?? nil } catch { }
        return nil
    }
    open func announcementArray<K>(from container: KeyedDecodingContainer<K>,
                                   forKey key: KeyedDecodingContainer<K>.Key) -> [DAOAnnouncement] where K: CodingKey {
        do { return try container.decodeIfPresent([DAOAnnouncement].self, forKey: key, configuration: self) ?? [] } catch { }
        return []
    }
}
// swiftlint:disable:next type_body_length
open class WKRFirebaseAnnouncements: WKRBlankAnnouncements, DecodingConfigurationProviding, EncodingConfigurationProviding {
    public typealias Config = PTCLCFGWKRFirebaseAnnouncements
    public typealias DecodingConfiguration = Config
    public typealias EncodingConfiguration = Config
    public static var config: Config = CFGWKRFirebaseAnnouncements()

    public static var decodingConfiguration: DecodingConfiguration { Self.config }
    public static var encodingConfiguration: EncodingConfiguration { Self.config }

    typealias API = WKRFirebaseAnnouncementsAPI // swiftlint:disable:this type_name

    // MARK: - Class Factory methods -
    open class func createAnnouncement() -> DAOAnnouncement { config.announcementType.init() }
    open class func createAnnouncement(from object: DAOAnnouncement) -> DAOAnnouncement { config.announcementType.init(from: object) }
    open class func createAnnouncement(from data: DNSDataDictionary) -> DAOAnnouncement? { config.announcementType.init(from: data) }

    // MARK: - Properties -
    let db = Firestore.firestore()

    // MARK: - Internal Work Methods
    override open func intDoLoadAnnouncements(with progress: DNSPTCLProgressBlock?,
                                              and block: WKRPTCLAnnouncementsBlkAAnnouncement?,
                                              then resultBlock: DNSPTCLResultBlock?) {
        let callData = WKRPTCLSystemsStateData(system: DNSAppConstants.Systems.announcements,
                                               endPoint: DNSAppConstants.Systems.Announcements.EndPoints.loadAnnouncements,
                                               sendDebug: DNSAppConstants.Systems.Announcements.sendDebug)

        guard let dataRequest = try? API.apiLoadAnnouncements(router: self.netRouter)
            .dataRequest.get() else {
            let error = DNSError.NetworkBase.dataError(.firebaseWorkers(self))
            block?(.failure(error)); _ = resultBlock?(.error)
            return
        }
        self.processRequestData(callData, dataRequest, with: resultBlock,
                                onSuccess: { data in
            do {
                let response = try JSONDecoder().decode(Self.config.announcementsResponseType, from: data)
                block?(.success(response.announcements))
                return .success
            } catch {
                DNSCore.reportError(error)
                return .failure(error)
            }
        },
                                onPendingError: { error, _ in
            if case DNSError.NetworkBase.expiredAccessToken = error {
                return error
            }
            return DNSError.NetworkBase.lowerError(error: error, .firebaseWorkers(self))
        },
                                onError: { error, _ in
            block?(.failure(error))
        })
    }
    override open func intDoLoadAnnouncements(for place: DAOPlace,
                                              with progress: DNSPTCLProgressBlock?,
                                              and block: WKRPTCLAnnouncementsBlkAAnnouncement?,
                                              then resultBlock: DNSPTCLResultBlock?) {
        let callData = WKRPTCLSystemsStateData(system: DNSAppConstants.Systems.announcements,
                                               endPoint: DNSAppConstants.Systems.Announcements.EndPoints.loadAnnouncements,
                                               sendDebug: DNSAppConstants.Systems.Announcements.sendDebug)

        guard let dataRequest = try? API.apiLoadAnnouncementsForPlace(router: self.netRouter, place: place)
            .dataRequest.get() else {
            let error = DNSError.NetworkBase.dataError(.firebaseWorkers(self))
            block?(.failure(error)); _ = resultBlock?(.error)
            return
        }
        self.processRequestData(callData, dataRequest, with: resultBlock,
                                onSuccess: { data in
            do {
                let response = try JSONDecoder().decode(Self.config.announcementsResponseType, from: data)
                block?(.success(response.announcements))
                return .success
            } catch {
                DNSCore.reportError(error)
                return .failure(error)
            }
        },
                                onPendingError: { error, _ in
            if case DNSError.NetworkBase.expiredAccessToken = error {
                return error
            }
            return DNSError.NetworkBase.lowerError(error: error, .firebaseWorkers(self))
        },
                                onError: { error, _ in
            block?(.failure(error))
        })
    }
    override open func intDoRemove(_ announcement: DAOAnnouncement,
                                   for place: DAOPlace,
                                   with progress: DNSPTCLProgressBlock?,
                                   and block: WKRPTCLAnnouncementsBlkVoid?,
                                   then resultBlock: DNSPTCLResultBlock?) {
        let callData = WKRPTCLSystemsStateData(system: DNSAppConstants.Systems.announcements,
                                               endPoint: DNSAppConstants.Systems.Announcements.EndPoints.removeAnnouncement,
                                               sendDebug: DNSAppConstants.Systems.Announcements.sendDebug)

        guard let dataRequest = try? API.apiRemoveAnnouncement(router: self.netRouter, announcement: announcement, place: place)
            .dataRequest.get() else {
            let error = DNSError.NetworkBase.dataError(.firebaseWorkers(self))
            block?(.failure(error)); _ = resultBlock?(.error)
            return
        }
        self.processRequestData(callData, dataRequest, with: resultBlock,
                                onSuccess: { data in
            block?(.success)
            return .success
        },
                                onPendingError: { error, _ in
            if case DNSError.NetworkBase.expiredAccessToken = error {
                return error
            }
            return DNSError.NetworkBase.lowerError(error: error, .firebaseWorkers(self))
        },
                                onError: { error, _ in
            block?(.failure(error))
        })
    }
    override open func intDoUpdate(_ announcement: DAOAnnouncement,
                                   for place: DAOPlace,
                                   with progress: DNSPTCLProgressBlock?,
                                   and block: WKRPTCLAnnouncementsBlkVoid?,
                                   then resultBlock: DNSPTCLResultBlock?) {
        let callData = WKRPTCLSystemsStateData(system: DNSAppConstants.Systems.announcements,
                                               endPoint: DNSAppConstants.Systems.Announcements.EndPoints.updateAnnouncement,
                                               sendDebug: DNSAppConstants.Systems.Announcements.sendDebug)

        guard let dataRequest = try? API.apiUpdateAnnouncement(router: self.netRouter, announcement: announcement, place: place)
            .dataRequest.get() else {
            let error = DNSError.NetworkBase.dataError(.firebaseWorkers(self))
            block?(.failure(error)); _ = resultBlock?(.error)
            return
        }
        self.processRequestData(callData, dataRequest, with: resultBlock,
                                onSuccess: { data in
            block?(.success)
            return .success
        },
                                onPendingError: { error, _ in
            if case DNSError.NetworkBase.expiredAccessToken = error {
                return error
            }
            return DNSError.NetworkBase.lowerError(error: error, .firebaseWorkers(self))
        },
                                onError: { error, _ in
            block?(.failure(error))
        })
    }
}
