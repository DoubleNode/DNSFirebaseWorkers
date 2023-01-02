//
//  WKRFirebaseEvents.swift
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

public protocol PTCLCFGWKRFirebaseEvents: PTCLCFGDAOEvent {
    var eventsResponseType: any PTCLRSPWKRFirebaseEventsAEvent.Type { get }
    var metaResponseType: any PTCLRSPWKRFirebaseEventsMeta.Type { get }
}
public class CFGWKRFirebaseEvents: PTCLCFGWKRFirebaseEvents {
    public var eventsResponseType: any PTCLRSPWKRFirebaseEventsAEvent.Type = RSPWKRFirebaseEventsAEvent.self
    public var metaResponseType: any PTCLRSPWKRFirebaseEventsMeta.Type = RSPWKRFirebaseEventsMeta.self

    public var eventType: DAOEvent.Type = DAOEvent.self
    open func event<K>(from container: KeyedDecodingContainer<K>,
                       forKey key: KeyedDecodingContainer<K>.Key) -> DAOEvent? where K: CodingKey {
        do { return try container.decodeIfPresent(DAOEvent.self, forKey: key, configuration: self) ?? nil } catch { }
        return nil
    }
    open func eventArray<K>(from container: KeyedDecodingContainer<K>,
                            forKey key: KeyedDecodingContainer<K>.Key) -> [DAOEvent] where K: CodingKey {
        do { return try container.decodeIfPresent([DAOEvent].self, forKey: key, configuration: self) ?? [] } catch { }
        return []
    }
}
// swiftlint:disable:next type_body_length
open class WKRFirebaseEvents: WKRBlankEvents, DecodingConfigurationProviding, EncodingConfigurationProviding {
    public typealias Config = PTCLCFGWKRFirebaseEvents
    public typealias DecodingConfiguration = Config
    public typealias EncodingConfiguration = Config
    public static var config: Config = CFGWKRFirebaseEvents()

    public static var decodingConfiguration: DecodingConfiguration { Self.config }
    public static var encodingConfiguration: EncodingConfiguration { Self.config }

    typealias API = WKRFirebaseEventsAPI // swiftlint:disable:this type_name

    // MARK: - Class Factory methods -
    open class func createEvent() -> DAOEvent { config.eventType.init() }
    open class func createEvent(from object: DAOEvent) -> DAOEvent { config.eventType.init(from: object) }
    open class func createEvent(from data: DNSDataDictionary) -> DAOEvent? { config.eventType.init(from: data) }

    // MARK: - Properties -
    let db = Firestore.firestore()

    // MARK: - Internal Work Methods
    override open func intDoLoadCurrentEvents(with progress: DNSPTCLProgressBlock?,
                                              and block: WKRPTCLEventsBlkAEvent?,
                                              then resultBlock: DNSPTCLResultBlock?) {
        let callData = WKRPTCLSystemsStateData(system: DNSAppConstants.Systems.events,
                                               endPoint: DNSAppConstants.Systems.Events.EndPoints.loadEvents,
                                               sendDebug: DNSAppConstants.Systems.Events.sendDebug)

        guard let dataRequest = try? API.apiLoadCurrentEvents(router: self.netRouter)
            .dataRequest.get() else {
            let error = DNSError.NetworkBase.dataError(.firebaseWorkers(self))
            block?(.failure(error)); _ = resultBlock?(.error)
            return
        }
        self.processRequestData(callData, dataRequest, with: resultBlock,
                                onSuccess: { data in
            do {
                let response = try JSONDecoder().decode(Self.config.eventsResponseType, from: data)
                block?(.success(response.events))
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
    override open func intDoLoadEvents(for place: DAOPlace,
                                       with progress: DNSPTCLProgressBlock?,
                                       and block: WKRPTCLEventsBlkAEvent?,
                                       then resultBlock: DNSPTCLResultBlock?) {
        let callData = WKRPTCLSystemsStateData(system: DNSAppConstants.Systems.events,
                                               endPoint: DNSAppConstants.Systems.Events.EndPoints.loadEvents,
                                               sendDebug: DNSAppConstants.Systems.Events.sendDebug)

        guard let dataRequest = try? API.apiLoadEvents(router: self.netRouter, place: place)
            .dataRequest.get() else {
            let error = DNSError.NetworkBase.dataError(.firebaseWorkers(self))
            block?(.failure(error)); _ = resultBlock?(.error)
            return
        }
        self.processRequestData(callData, dataRequest, with: resultBlock,
                                onSuccess: { data in
            do {
                let response = try JSONDecoder().decode(Self.config.eventsResponseType, from: data)
                block?(.success(response.events))
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
    override open func intDoReact(with reaction: DNSReactionType,
                                  to event: DAOEvent,
                                  for place: DAOPlace,
                                  with progress: DNSPTCLProgressBlock?,
                                  and block: WKRPTCLEventsBlkMeta?,
                                  then resultBlock: DNSPTCLResultBlock?) {
        let callData = WKRPTCLSystemsStateData(system: DNSAppConstants.Systems.events,
                                               endPoint: DNSAppConstants.Systems.Events.EndPoints.reactUnreact,
                                               sendDebug: DNSAppConstants.Systems.Events.sendDebug)

        guard let dataRequest = try? API.apiReact(router: self.netRouter, reaction: reaction, event: event, place: place)
            .dataRequest.get() else {
            let error = DNSError.NetworkBase.dataError(.firebaseWorkers(self))
            block?(.failure(error)); _ = resultBlock?(.error)
            return
        }
        self.processRequestData(callData, dataRequest, with: resultBlock,
                                onSuccess: { data in
            do {
                let response = try JSONDecoder().decode(Self.config.metaResponseType, from: data)
                block?(.success(response.meta))
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
    override open func intDoRemove(_ event: DAOEvent,
                                   for place: DAOPlace,
                                   with progress: DNSPTCLProgressBlock?,
                                   and block: WKRPTCLEventsBlkVoid?,
                                   then resultBlock: DNSPTCLResultBlock?) {
        let callData = WKRPTCLSystemsStateData(system: DNSAppConstants.Systems.events,
                                               endPoint: DNSAppConstants.Systems.Events.EndPoints.removeEvent,
                                               sendDebug: DNSAppConstants.Systems.Events.sendDebug)

        guard let dataRequest = try? API.apiRemoveEvent(router: self.netRouter, event: event, place: place)
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
    override open func intDoRemove(_ eventDay: DAOEventDay,
                                   for event: DAOEvent,
                                   and place: DAOPlace,
                                   with progress: DNSPTCLProgressBlock?,
                                   and block: WKRPTCLEventsBlkVoid?,
                                   then resultBlock: DNSPTCLResultBlock?) {
        let callData = WKRPTCLSystemsStateData(system: DNSAppConstants.Systems.events,
                                               endPoint: DNSAppConstants.Systems.Events.EndPoints.removeEventDay,
                                               sendDebug: DNSAppConstants.Systems.Events.sendDebug)

        guard let dataRequest = try? API.apiRemoveEventDay(router: self.netRouter, eventDay: eventDay, event: event, place: place)
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
    override open func intDoUnreact(with reaction: DNSReactionType,
                                    to event: DAOEvent,
                                    for place: DAOPlace,
                                    with progress: DNSPTCLProgressBlock?,
                                    and block: WKRPTCLEventsBlkMeta?,
                                    then resultBlock: DNSPTCLResultBlock?) {
        let callData = WKRPTCLSystemsStateData(system: DNSAppConstants.Systems.events,
                                               endPoint: DNSAppConstants.Systems.Events.EndPoints.reactUnreact,
                                               sendDebug: DNSAppConstants.Systems.Events.sendDebug)

        guard let dataRequest = try? API.apiUnreact(router: self.netRouter, reaction: reaction, event: event, place: place)
            .dataRequest.get() else {
            let error = DNSError.NetworkBase.dataError(.firebaseWorkers(self))
            block?(.failure(error)); _ = resultBlock?(.error)
            return
        }
        self.processRequestData(callData, dataRequest, with: resultBlock,
                                onSuccess: { data in
            do {
                let response = try JSONDecoder().decode(Self.config.metaResponseType, from: data)
                block?(.success(response.meta))
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
    override open func intDoUpdate(_ event: DAOEvent,
                                   for place: DAOPlace,
                                   with progress: DNSPTCLProgressBlock?,
                                   and block: WKRPTCLEventsBlkVoid?,
                                   then resultBlock: DNSPTCLResultBlock?) {
        let callData = WKRPTCLSystemsStateData(system: DNSAppConstants.Systems.events,
                                               endPoint: DNSAppConstants.Systems.Events.EndPoints.updateEvent,
                                               sendDebug: DNSAppConstants.Systems.Events.sendDebug)

        guard let dataRequest = try? API.apiUpdateEvent(router: self.netRouter, event: event, place: place)
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
    override open func intDoUpdate(_ eventDay: DAOEventDay,
                                   for event: DAOEvent,
                                   and place: DAOPlace,
                                   with progress: DNSPTCLProgressBlock?,
                                   and block: WKRPTCLEventsBlkVoid?,
                                   then resultBlock: DNSPTCLResultBlock?) {
        let callData = WKRPTCLSystemsStateData(system: DNSAppConstants.Systems.events,
                                               endPoint: DNSAppConstants.Systems.Events.EndPoints.updateEventDay,
                                               sendDebug: DNSAppConstants.Systems.Events.sendDebug)

        guard let dataRequest = try? API.apiUpdateEventDay(router: self.netRouter, eventDay: eventDay, event: event, place: place)
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
    override open func intDoView(_ event: DAOEvent,
                                 for place: DAOPlace,
                                 with progress: DNSPTCLProgressBlock?,
                                 and block: WKRPTCLEventsBlkMeta?,
                                 then resultBlock: DNSPTCLResultBlock?) {
        let callData = WKRPTCLSystemsStateData(system: DNSAppConstants.Systems.events,
                                               endPoint: DNSAppConstants.Systems.Events.EndPoints.view,
                                               sendDebug: DNSAppConstants.Systems.Events.sendDebug)

        guard let dataRequest = try? API.apiView(router: self.netRouter, event: event, place: place)
            .dataRequest.get() else {
            let error = DNSError.NetworkBase.dataError(.firebaseWorkers(self))
            block?(.failure(error)); _ = resultBlock?(.error)
            return
        }
        self.processRequestData(callData, dataRequest, with: resultBlock,
                                onSuccess: { data in
            do {
                let response = try JSONDecoder().decode(Self.config.metaResponseType, from: data)
                block?(.success(response.meta))
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
}
