//
//  WKRFirebasePlaces.swift
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

public protocol PTCLCFGWKRFirebasePlaces: PTCLCFGDAOPlace {
    var placesResponseType: any PTCLRSPWKRFirebasePlacesAPlace.Type { get }
}
public class CFGWKRFirebasePlaces: PTCLCFGWKRFirebasePlaces {
    public var placesResponseType: any PTCLRSPWKRFirebasePlacesAPlace.Type = RSPWKRFirebasePlacesAPlace.self
    public var placeType: DAOPlace.Type = DAOPlace.self
    open func placeArray<K>(from container: KeyedDecodingContainer<K>,
                            forKey key: KeyedDecodingContainer<K>.Key) -> [DAOPlace] where K: CodingKey {
        do { return try container.decodeIfPresent([DAOPlace].self, forKey: key, configuration: self) ?? [] } catch { }
        return []
    }
}
// swiftlint:disable:next type_body_length
open class WKRFirebasePlaces: WKRBlankPlaces, DecodingConfigurationProviding, EncodingConfigurationProviding {
    public typealias Config = PTCLCFGWKRFirebasePlaces
    public typealias DecodingConfiguration = Config
    public typealias EncodingConfiguration = Config
    public static var config: Config = CFGWKRFirebasePlaces()

    public static var decodingConfiguration: DecodingConfiguration { Self.config }
    public static var encodingConfiguration: EncodingConfiguration { Self.config }

    typealias API = WKRFirebasePlacesAPI // swiftlint:disable:this type_name

    // MARK: - Class Factory methods -
    open class func createPlace() -> DAOPlace { config.placeType.init() }
    open class func createPlace(from object: DAOPlace) -> DAOPlace { config.placeType.init(from: object) }
    open class func createPlace(from data: DNSDataDictionary) -> DAOPlace? { config.placeType.init(from: data) }

    // MARK: - Properties -
    let db = Firestore.firestore()

    // MARK: - Internal Work Methods
    override open func intDoFilterPlaces(for activity: DAOActivity,
                                         using places: [DAOPlace],
                                         with progress: DNSPTCLProgressBlock?,
                                         and block: WKRPTCLPlacesBlkAPlace?,
                                         then resultBlock: DNSPTCLResultBlock?) {
    }
    override open func intDoLoadPlace(for placeCode: String,
                                      with progress: DNSPTCLProgressBlock?,
                                      and block: WKRPTCLPlacesBlkPlace?,
                                      then resultBlock: DNSPTCLResultBlock?) {
        let callData = WKRPTCLSystemsStateData(system: DNSAppConstants.Systems.places,
                                               endPoint: DNSAppConstants.Systems.Places.EndPoints.loadPlaces,
                                               sendDebug: DNSAppConstants.Systems.Places.sendDebug)

        guard let dataRequest = try? API.apiLoadPlace(router: self.netRouter, placeCode: placeCode)
            .dataRequest.get() else {
            let error = DNSError.NetworkBase.dataError(.firebaseWorkers(self))
            block?(.failure(error)); _ = resultBlock?(.error)
            return
        }
        self.processRequestData(callData, dataRequest, with: resultBlock,
                                onSuccess: { data in
            do {
                let user = try JSONDecoder().decode(Self.config.placeType, from: data)
                block?(.success(user))
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
    override open func intDoLoadPlaces(with progress: DNSPTCLProgressBlock?,
                                       and block: WKRPTCLPlacesBlkAPlace?,
                                       then resultBlock: DNSPTCLResultBlock?) {
        let callData = WKRPTCLSystemsStateData(system: DNSAppConstants.Systems.places,
                                               endPoint: DNSAppConstants.Systems.Places.EndPoints.loadPlaces,
                                               sendDebug: DNSAppConstants.Systems.Places.sendDebug)

        guard let dataRequest = try? API.apiLoadPlaces(router: self.netRouter)
            .dataRequest.get() else {
            let error = DNSError.NetworkBase.dataError(.firebaseWorkers(self))
            block?(.failure(error)); _ = resultBlock?(.error)
            return
        }
        self.processRequestData(callData, dataRequest, with: resultBlock,
                                onSuccess: { data in
            do {
                let response = try JSONDecoder().decode(Self.config.placesResponseType, from: data)
                block?(.success(response.places))
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
    override open func intDoLoadPlaces(for section: DAOSection,
                                       with progress: DNSPTCLProgressBlock?,
                                       and block: WKRPTCLPlacesBlkAPlace?,
                                       then resultBlock: DNSPTCLResultBlock?) {
    }
    override open func intDoLoadHolidays(for place: DAOPlace,
                                         with progress: DNSPTCLProgressBlock?,
                                         and block: WKRPTCLPlacesBlkAPlaceHoliday?,
                                         then resultBlock: DNSPTCLResultBlock?) {
    }
    override open func intDoLoadHours(for place: DAOPlace,
                                      with progress: DNSPTCLProgressBlock?,
                                      and block: WKRPTCLPlacesBlkPlaceHours?,
                                      then resultBlock: DNSPTCLResultBlock?) {
    }
    override open func intDoLoadState(for place: DAOPlace,
                                      with progress: DNSPTCLProgressBlock?,
                                      then resultBlock: DNSPTCLResultBlock?) -> WKRPTCLPlacesPubAlertEventStatus {
        return resultBlock?(.unhandled) as! WKRPTCLPlacesPubAlertEventStatus // swiftlint:disable:this force_cast
//        return .success([], [], [])
    }
    override open func intDoSearchPlace(for geohash: String,
                                        with progress: DNSPTCLProgressBlock?,
                                        and block: WKRPTCLPlacesBlkPlace?,
                                        then resultBlock: DNSPTCLResultBlock?) {
    }
    override open func intDoUpdate(_ place: DAOPlace,
                                   with progress: DNSPTCLProgressBlock?,
                                   and block: WKRPTCLPlacesBlkVoid?,
                                   then resultBlock: DNSPTCLResultBlock?) {
        let callData = WKRPTCLSystemsStateData(system: DNSAppConstants.Systems.places,
                                               endPoint: DNSAppConstants.Systems.Places.EndPoints.updatePlace,
                                               sendDebug: DNSAppConstants.Systems.Places.sendDebug)

        guard let dataRequest = try? API.apiUpdatePlace(router: self.netRouter, place: place)
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
    override open func intDoUpdate(_ hours: DAOPlaceHours,
                                   for place: DAOPlace,
                                   with progress: DNSPTCLProgressBlock?,
                                   and block: WKRPTCLPlacesBlkVoid?,
                                   then resultBlock: DNSPTCLResultBlock?) {
    }
}
