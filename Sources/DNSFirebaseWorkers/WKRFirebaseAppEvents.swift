//
//  WKRFirebaseAppEvents.swift
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

open class WKRFirebaseAppEvents: WKRBlankAppEvents {
    // MARK: - Class Factory methods -
    static var appEventType: DAOAppEvent.Type = DAOAppEvent.self
    open class var appEvent: DAOAppEvent.Type { appEventType }

    open class func createAppEvent() -> DAOAppEvent { appEvent.init() }
    open class func createAppEvent(from object: DAOAppEvent) -> DAOAppEvent { appEvent.init(from: object) }
    open class func createAppEvent(from data: DNSDataDictionary) -> DAOAppEvent { appEvent.init(from: data) }

    // MARK: - Properties -
    let db = Firestore.firestore()

    // MARK: - Internal Work Methods
    override open func intDoLoadAppEvents(with progress: DNSPTCLProgressBlock?,
                                          and block: WKRPTCLAppEventsBlkAAppEvent?,
                                          then resultBlock: DNSPTCLResultBlock?) {
        self.utilityLoadAppEvents(with: progress) { result in
            if case .failure(let error) = result {
                DNSCore.reportError(error)
                block?(.failure(error))
                _ = resultBlock?(.failure(error))
                return
            }
            if case .success(let appEvents) = result {
                block?(.success(appEvents))
                _ = resultBlock?(.completed)
            }
        }
    }

    // MARK: - Utility methods -
    func utilityLoadAppEvent(for document: DocumentSnapshot) -> DAOAppEvent? {
        guard let appEventData = document.data() else {
            return nil
        }
        let appEvent = Self.createAppEvent(from: appEventData)
        appEvent.id = document.documentID
        return appEvent
    }
    // swiftlint:disable:next function_body_length
    func utilityLoadAppEvents(with progress: DNSPTCLProgressBlock?,
                              and block: WKRPTCLAppEventsBlkAAppEvent?) {
        let appEventsRef = db.collection("appEvents")
        appEventsRef.getDocuments { (querySnapshot, error) in
            DNSThread.run {
                guard error == nil else {
                    let dnsError = DNSError.WorkerBase.systemError(error: error!, .firebaseWorkers(self))
                    DNSCore.reportError(dnsError)
                    block?(.failure(dnsError))
                    return
                }
                guard let appEventDocuments = querySnapshot?.documents else {
                    let dnsError = DNSError.WorkerBase.unknown(.firebaseWorkers(self))
                    DNSCore.reportError(dnsError)
                    block?(.failure(dnsError))
                    return
                }

                @Atomic var appEvents: [DAOAppEvent] = []
                DNSThreadingGroup.run(block: { (threadingGroup) in
                    appEventDocuments.forEach { (document) in
                        threadingGroup.run(DNSLowThread.init(.asynchronously) { (thread) in
                            let appEvent = self.utilityLoadAppEvent(for: document)
                            guard let appEvent else {
                                thread.done()
                                return
                            }
                            appEvents.append(appEvent)
                            thread.done()
                        })
                    }
                },
                with: DispatchTime.now().advanced(by: .seconds(120)),
                then: { error in
                    if let error {
                        DNSCore.reportError(error)
                        block?(.failure(error))
                        return
                    }
                    guard !appEvents.isEmpty else {
                        let error = DNSError.WorkerBase.unknown(.firebaseWorkers(self))
                        DNSCore.reportError(error)
                        block?(.failure(error))
                        return
                    }
                    block?(.success(appEvents))
                })
            }
        }
    }
}
