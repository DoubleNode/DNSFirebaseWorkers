//
//  WKRFirebaseSystems.swift
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

// swiftlint:disable:next type_body_length
open class WKRFirebaseSystems: WKRBlankSystems {
    // MARK: - Class Factory methods -
    static var systemEndPointType: DAOSystemEndPoint.Type = DAOSystemEndPoint.self
    static var systemStateType: DAOSystemState.Type = DAOSystemState.self
    static var systemType: DAOSystem.Type = DAOSystem.self
    open class var systemEndPoint: DAOSystemEndPoint.Type { systemEndPointType }
    open class var systemState: DAOSystemState.Type { systemStateType }
    open class var system: DAOSystem.Type { systemType }

    open class func createSystemEndPoint() -> DAOSystemEndPoint { systemEndPointType.init() }
    open class func createSystemEndPoint(from object: DAOSystemEndPoint) -> DAOSystemEndPoint { systemEndPointType.init(from: object) }
    open class func createSystemEndPoint(from data: DNSDataDictionary) -> DAOSystemEndPoint { systemEndPointType.init(from: data) }

    open class func createSystemState() -> DAOSystemState { systemStateType.init() }
    open class func createSystemState(from object: DAOSystemState) -> DAOSystemState { systemStateType.init(from: object) }
    open class func createSystemState(from data: DNSDataDictionary) -> DAOSystemState { systemStateType.init(from: data) }

    open class func createSystem() -> DAOSystem { systemType.init() }
    open class func createSystem(from object: DAOSystem) -> DAOSystem { systemType.init(from: object) }
    open class func createSystem(from data: DNSDataDictionary) -> DAOSystem { systemType.init(from: data) }

    // MARK: - Properties -
    let db = Firestore.firestore()

    // MARK: - Internal Work Methods
    override open func intDoLoadSystem(for id: String,
                                       with progress: DNSPTCLProgressBlock?,
                                       and block: WKRPTCLSystemsBlkSystem?,
                                       then resultBlock: DNSPTCLResultBlock?) {
        guard !id.isEmpty else {
            let error = DNSError.Systems.invalidParameters(parameters: ["id"], .firebaseWorkers(self))
            block?(.failure(error))
            _ = resultBlock?(.failure(error))
            return
        }
        self.utilityLoadSystems(with: progress) { result in
            if case .failure(let error) = result {
                DNSCore.reportError(error)
                block?(.failure(error))
                _ = resultBlock?(.failure(error))
                return
            }
            if case .success(let systems) = result {
                guard let system = systems.first(where: { $0.id == id }) else {
                    let error = DNSError.Systems.notFound(field: "id", value: id, .firebaseWorkers(self))
                    block?(.failure(error))
                    _ = resultBlock?(.failure(error))
                    return
                }
                block?(.success(system))
                _ = resultBlock?(.completed)
            }
        }
    }
    override open func intDoLoadEndPoints(for system: DAOSystem,
                                          with progress: DNSPTCLProgressBlock?,
                                          and block: WKRPTCLSystemsBlkASystemEndPoint?,
                                          then resultBlock: DNSPTCLResultBlock?) {
        guard !system.id.isEmpty else {
            let error = DNSError.Systems
                .invalidParameters(parameters: ["system"], .firebaseWorkers(self))
            block?(.failure(error))
            _ = resultBlock?(.failure(error))
            return
        }
        self.utilityLoadEndPoints(for: system,
                                  with: progress) { result in
            if case .failure(let error) = result {
                DNSCore.reportError(error)
                block?(.failure(error))
                _ = resultBlock?(.failure(error))
                return
            }
            if case .success(let endPoints) = result {
                guard !endPoints.isEmpty else {
                    let error = DNSError.Systems
                        .notFound(field: "id", value: "Any", .firebaseWorkers(self))
                    block?(.failure(error))
                    _ = resultBlock?(.failure(error))
                    return
                }
                block?(.success(endPoints))
                _ = resultBlock?(.completed)
            }
        }
    }
    override open func intDoLoadHistory(for system: DAOSystem,
                                        since time: Date,
                                        with progress: DNSPTCLProgressBlock?,
                                        and block: WKRPTCLSystemsBlkASystemState?,
                                        then resultBlock: DNSPTCLResultBlock?) {
        guard !system.id.isEmpty else {
            let error = DNSError.Systems
                .invalidParameters(parameters: ["system"], .firebaseWorkers(self))
            block?(.failure(error))
            _ = resultBlock?(.failure(error))
            return
        }
        self.utilityLoadHistory(for: system,
                                since: time,
                                with: progress) { result in
            if case .failure(let error) = result {
                DNSCore.reportError(error)
                block?(.failure(error))
                _ = resultBlock?(.failure(error))
                return
            }
            if case .success(let history) = result {
                guard !history.isEmpty else {
                    let error = DNSError.Systems
                        .notFound(field: "id", value: "Any", .firebaseWorkers(self))
                    block?(.failure(error))
                    _ = resultBlock?(.failure(error))
                    return
                }
                block?(.success(history))
                _ = resultBlock?(.completed)
            }
        }
    }
    override open func intDoLoadHistory(for endPoint: DAOSystemEndPoint,
                                        since time: Date,
                                        include failureCodes: Bool,
                                        with progress: DNSPTCLProgressBlock?,
                                        and block: WKRPTCLSystemsBlkASystemState?,
                                        then resultBlock: DNSPTCLResultBlock?) {
        guard !endPoint.id.isEmpty else {
            let error = DNSError.Systems
                .invalidParameters(parameters: ["endPoint"], .firebaseWorkers(self))
            block?(.failure(error))
            _ = resultBlock?(.failure(error))
            return
        }
        self.utilityLoadHistory(for: endPoint,
                                since: time,
                                include: failureCodes,
                                with: progress) { result in
            if case .failure(let error) = result {
                DNSCore.reportError(error)
                block?(.failure(error))
                _ = resultBlock?(.failure(error))
                return
            }
            if case .success(let history) = result {
                guard !history.isEmpty else {
                    let error = DNSError.Systems
                        .notFound(field: "id", value: "Any", .firebaseWorkers(self))
                    block?(.failure(error))
                    _ = resultBlock?(.failure(error))
                    return
                }
                block?(.success(history))
                _ = resultBlock?(.completed)
            }
        }
    }
    override open func intDoLoadSystems(with progress: DNSPTCLProgressBlock?,
                                        and block: WKRPTCLSystemsBlkASystem?,
                                        then resultBlock: DNSPTCLResultBlock?) {
        self.utilityLoadSystems(with: progress) { result in
            if case .failure(let error) = result {
                DNSCore.reportError(error)
                block?(.failure(error))
                _ = resultBlock?(.failure(error))
                return
            }
            if case .success(let systems) = result {
                guard !systems.isEmpty else {
                    let error = DNSError.Systems.notFound(field: "id", value: "Any", .firebaseWorkers(self))
                    block?(.failure(error))
                    _ = resultBlock?(.failure(error))
                    return
                }
                block?(.success(systems))
                _ = resultBlock?(.completed)
            }
        }
    }

    // MARK: - Utility methods -
    func utilityLoadSystem(for document: DocumentSnapshot) -> DAOSystem? {
        guard let systemData = document.data() else {
            return nil
        }

        let system = Self.createSystem(from: systemData)
        system.id = document.documentID
        system.meta.updated = Self.xlt.time(from: systemData["updated"]) ?? system.meta.updated
        system.currentState = Self.createSystemState(from: systemData)
        system.currentState.meta.updated = system.meta.updated
        return system
    }
    func utilityLoadSystemEndPoint(for document: DocumentSnapshot) -> DAOSystemEndPoint? {
        guard let endPointData = document.data() else {
            return nil
        }

        let systemEndPoint = Self.createSystemEndPoint(from: endPointData)
        systemEndPoint.id = document.documentID
        systemEndPoint.meta.updated = Self.xlt.time(from: endPointData["updated"]) ?? systemEndPoint.meta.updated
        if systemEndPoint.name.asString.isEmpty {
            systemEndPoint.name = DNSString(with: systemEndPoint.id)
        }
        systemEndPoint.currentState = utilityLoadSystemState(for: document) ?? systemEndPoint.currentState
        return systemEndPoint
    }
    func utilityLoadFailureCode(for document: DocumentSnapshot) -> DNSSystemStateNumbers? {
        guard let failureCodeData = document.data() else {
            return nil
        }
        let failure = Self.xlt.double(from: failureCodeData["failure"]) ?? 0.0
        let failureAndroid = Self.xlt.double(from: failureCodeData["failure_android"]) ?? 0.0
        let failureIOS = Self.xlt.double(from: failureCodeData["failure_ios"]) ?? 0.0
        let numbers = DNSSystemStateNumbers(android: failureAndroid,
                                            iOS: failureIOS,
                                            total: failure)
        return numbers
    }
    func utilityLoadSystemState(for document: DocumentSnapshot) -> DAOSystemState? {
        guard let historyData = document.data() else {
            return nil
        }

        let systemState = Self.createSystemState(from: historyData)
        if let updated = Self.xlt.time(from: document.documentID) {
            systemState.meta.updated = updated
        } else {
            systemState.meta.updated = Self.xlt.time(from: historyData["updated"] as Any?) ?? systemState.meta.updated
        }
        return systemState
    }
    func utilityLoadEndPoints(for system: DAOSystem,
                              with progress: DNSPTCLProgressBlock?,
                              and block: WKRPTCLSystemsBlkASystemEndPoint?) {
        let endPointsRef = self.db.collection("systems/\(system.id)/endPoints")
        endPointsRef.getDocuments { querySnapshot, error in
            DNSThread.run {
                if let error {
                    let dnsError = DNSError.WorkerBase.systemError(error: error, .firebaseWorkers(self))
                    DNSCore.reportError(dnsError)
                    block?(.failure(dnsError))
                    return
                }
                guard let endPointsDocuments = querySnapshot?.documents else {
                    let dnsError = DNSError.Systems.unknown(.firebaseWorkers(self))
                    DNSCore.reportError(dnsError)
                    block?(.failure(dnsError))
                    return
                }

                var endPoints: [DAOSystemEndPoint] = []
                endPointsDocuments.forEach { document in
                    guard let systemEndPoint = self.utilityLoadSystemEndPoint(for: document) else {
                        return
                    }
                    systemEndPoint.system = system
                    endPoints.append(systemEndPoint)
                }
                guard !endPoints.isEmpty else {
                    let dnsError = DNSError.Systems.unknown(.firebaseWorkers(self))
                    DNSCore.reportError(dnsError)
                    block?(.failure(dnsError))
                    return
                }
                block?(.success(endPoints))
            }
        }
    }
    func utilityLoadHistory(for system: DAOSystem,
                            since time: Date,
                            with progress: DNSPTCLProgressBlock?,
                            and block: WKRPTCLSystemsBlkASystemState?) {
        guard time < Date() else {
            let dnsError = DNSError.WorkerBase
                .invalidParameters(parameters: ["time"], .firebaseWorkers(self))
            DNSCore.reportError(dnsError)
            block?(.failure(dnsError))
            return
        }
        let limitCount = Int((0 - time.timeIntervalSinceNow) / Date.Seconds.deltaFifteenMinutes)
        let historyRef = self.db.collection("systems/\(system.id)/history")
        historyRef.order(by: "updated", descending: true)
            .limit(to: limitCount)
            .getDocuments { querySnapshot, error in
            DNSThread.run {
                if let error {
                    let dnsError = DNSError.WorkerBase.systemError(error: error, .firebaseWorkers(self))
                    DNSCore.reportError(dnsError)
                    block?(.failure(dnsError))
                    return
                }
                guard let historyDocuments = querySnapshot?.documents else {
                    let dnsError = DNSError.Systems.unknown(.firebaseWorkers(self))
                    DNSCore.reportError(dnsError)
                    block?(.failure(dnsError))
                    return
                }

                @Atomic
                var history: [DAOSystemState] = []
                historyDocuments.forEach { document in
                    guard let systemState = self.utilityLoadSystemState(for: document) else {
                        return
                    }
                    history.append(systemState)
                }
                guard !history.isEmpty else {
                    let dnsError = DNSError.Systems.unknown(.firebaseWorkers(self))
                    DNSCore.reportError(dnsError)
                    block?(.failure(dnsError))
                    return
                }
                block?(.success(history))
            }
        }
    }
    // swiftlint:disable:next function_body_length
    func utilityLoadHistory(for endPoint: DAOSystemEndPoint,
                            since time: Date,
                            include failureCodes: Bool,
                            with progress: DNSPTCLProgressBlock?,
                            and block: WKRPTCLSystemsBlkASystemState?) {
        let system = endPoint.system
        let limitCount = Int((0 - time.timeIntervalSinceNow) / Date.Seconds.deltaFifteenMinutes)
        let historyRef = self.db.collection("systems/\(system.id)/endPoints/\(endPoint.id)/history")
        historyRef.order(by: "updated", descending: true)
            .limit(to: limitCount)
            .getDocuments { querySnapshot, error in
            DNSThread.run {
                if let error {
                    let dnsError = DNSError.WorkerBase.systemError(error: error, .firebaseWorkers(self))
                    DNSCore.reportError(dnsError)
                    block?(.failure(dnsError))
                    return
                }
                guard let historyDocuments = querySnapshot?.documents else {
                    let dnsError = DNSError.Systems.unknown(.firebaseWorkers(self))
                    DNSCore.reportError(dnsError)
                    block?(.failure(dnsError))
                    return
                }

                @Atomic var history: [DAOSystemState] = []
                DNSThreadingGroup.run(block: { threadingGroup in
                    historyDocuments.forEach { document in
                        threadingGroup.run(DNSLowThread.init(.asynchronously) { thread in
                            guard let systemState = self.utilityLoadSystemState(for: document) else {
                                thread.done()
                                return
                            }
                            history.append(systemState)
                            thread.done()
                        })
                    }
                },
                                      with: DispatchTime.now().advanced(by: .seconds(120)),
                                      then: { _ in
                    block?(.success(history))
                    guard failureCodes else {
                        return
                    }

                    @Atomic var historyPlus: [DAOSystemState] = []
                    DNSThreadingGroup.run(block: { threadingGroup in
                        history.forEach { systemState in
                            threadingGroup.run(DNSLowThread.init(.asynchronously) { thread in
                                let timestamp = systemState.meta.updated.dnsDateTime(as: .shortMilitary,
                                                                                     in: TimeZone(secondsFromGMT: 0)!)
                                self.utilityLoadHistoryFailureCodes(for: endPoint, on: timestamp,
                                                                    with: progress) { result in
                                    if case .failure(let error) = result {
                                        DNSCore.reportError(error)
                                        historyPlus.append(systemState)
                                        thread.done()
                                        return
                                    }
                                    if case .success(let failureCodes) = result {
                                        systemState.failureCodes = failureCodes
                                        historyPlus.append(systemState)
                                        thread.done()
                                    }
                                }
                            })
                        }
                    },
                                          with: DispatchTime.now().advanced(by: .seconds(120)),
                                          then: { _ in
                        block?(.success(historyPlus))
                    })
                })
            }
        }
    }

    // Protocol Return Types
    public typealias WKRPTCLSystemsRtnASystemStateNumbers = [String: DNSSystemStateNumbers]

    // Protocol Result Types
    public typealias WKRPTCLSystemsResASystemStateNumbers = Result<WKRPTCLSystemsRtnASystemStateNumbers, Error>

    // Protocol Block Types
    public typealias WKRPTCLSystemsBlkASystemStateNumbers = (WKRPTCLSystemsResASystemStateNumbers) -> Void

    func utilityLoadHistoryFailureCodes(for endPoint: DAOSystemEndPoint,
                                        on timestamp: String,
                                        with progress: DNSPTCLProgressBlock?,
                                        and block: WKRPTCLSystemsBlkASystemStateNumbers?) {
        let system = endPoint.system
        let path = "systems/\(system.id)/endPoints/\(endPoint.id)/history/\(timestamp)/failureCodes"
        let failureCodesRef = self.db.collection(path)
        failureCodesRef.getDocuments { querySnapshot, error in
            DNSThread.run {
                if let error {
                    let dnsError = DNSError.WorkerBase.systemError(error: error, .firebaseWorkers(self))
                    DNSCore.reportError(dnsError)
                    block?(.failure(dnsError))
                    return
                }
                guard let failureCodesDocuments = querySnapshot?.documents else {
                    let dnsError = DNSError.Systems.unknown(.firebaseWorkers(self))
                    DNSCore.reportError(dnsError)
                    block?(.failure(dnsError))
                    return
                }

                var failureCodes: [String: DNSSystemStateNumbers] = [:]
                failureCodesDocuments.forEach { (document) in
                    guard let numbers = self.utilityLoadFailureCode(for: document) else {
                        return
                    }
                    failureCodes[document.documentID] = numbers
                }
                block?(.success(failureCodes))
            }
        }
    }
    func utilityLoadSystems(with progress: DNSPTCLProgressBlock?,
                            and block: WKRPTCLSystemsBlkASystem?) {
        let systemsRef = self.db.collection("systems")
        systemsRef.getDocuments { querySnapshot, error in
            DNSThread.run {
                if let error {
                    let dnsError = DNSError.WorkerBase.systemError(error: error, .firebaseWorkers(self))
                    DNSCore.reportError(dnsError)
                    block?(.failure(dnsError))
                    return
                }
                guard let systemDocuments = querySnapshot?.documents else {
                    let dnsError = DNSError.Systems.unknown(.firebaseWorkers(self))
                    DNSCore.reportError(dnsError)
                    block?(.failure(dnsError))
                    return
                }

                var systems: [DAOSystem] = []
                systemDocuments.forEach { (document) in
                    guard let system = self.utilityLoadSystem(for: document) else {
                        return
                    }
                    systems.append(system)
                }
                guard !systems.isEmpty else {
                    let dnsError = DNSError.Systems.unknown(.firebaseWorkers(self))
                    DNSCore.reportError(dnsError)
                    block?(.failure(dnsError))
                    return
                }
                block?(.success(systems))
            }
        }
    }
}
