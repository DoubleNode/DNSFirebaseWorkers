//
//  WKRFirebaseIdentity.swift
//  SeaCadetsHelper
//
//  Created by Darren Ehlers on 9/10/22.
//

import Combine
import DNSBlankWorkers
import DNSCore
import DNSCoreThreading
import DNSCrashNetwork
import DNSDataObjects
import DNSError
import DNSProtocols
import FirebaseAuth
import FirebaseMessaging
import Foundation

open class WKRFirebaseIdentity: WKRBlankIdentity {
    typealias API = WKRFirebaseIdentityAPI // swiftlint:disable:this type_name

    // MARK: - Internal Work Methods
    override open func intDoClearIdentity(with progress: DNSPTCLProgressBlock?,
                                          then resultBlock: DNSPTCLResultBlock?) -> WKRPTCLIdentityPubVoid {
        let future = WKRPTCLIdentityFutVoid { promise in
            guard let fcmToken = Messaging.messaging().fcmToken else {
                let error = DNSError.Identity
                    .invalidParameters(parameters: ["fcmToken"], .firebaseWorkers(self))
                DNSCore.reportError(error)
                promise(.failure(error))
                _ = resultBlock?(.error)
                return
            }

            let envelope = DNSSubscriberEnvelope()
            let subscriber = self.netClearIdentity(fcmToken, with: progress)
                .receive(on: DNSThreadingQueue.backgroundQueue.queue)
                .sink(receiveCompletion: { completion in
                    switch completion {
                    case .failure(let error):
                        promise(.failure(error))
                        envelope.close()
                        _ = resultBlock?(.error)
                    case .finished:
                        break
                    }
                }, receiveValue: { success in
                    promise(.success)
                    envelope.close()
                    _ = resultBlock?(.completed)
                })
            envelope.open(with: subscriber)
        }
        guard let nextWorker = self.nextWorker else { return future.eraseToAnyPublisher() }
        return Publishers.Zip(future, nextWorker.doClearIdentity(with: progress))
            .map { _, _ in () }
            .eraseToAnyPublisher()
    }
    override open func intDoJoin(group: String,
                                 with progress: DNSPTCLProgressBlock?,
                                 then resultBlock: DNSPTCLResultBlock?) -> WKRPTCLIdentityPubVoid {
        return resultBlock?(.unhandled) as! WKRPTCLIdentityPubVoid // swiftlint:disable:this force_cast
    }
    override open func intDoLeave(group: String,
                                  with progress: DNSPTCLProgressBlock?,
                                  then resultBlock: DNSPTCLResultBlock?) -> WKRPTCLIdentityPubVoid {
        return resultBlock?(.unhandled) as! WKRPTCLIdentityPubVoid // swiftlint:disable:this force_cast
    }
    override open func intDoSetIdentity(using data: DNSDataDictionary,
                                        with progress: DNSPTCLProgressBlock?,
                                        then resultBlock: DNSPTCLResultBlock?) -> WKRPTCLIdentityPubVoid {
        let future = WKRPTCLIdentityFutVoid { promise in
            guard let fcmToken = Messaging.messaging().fcmToken else {
                let error = DNSError.Identity
                    .invalidParameters(parameters: ["fcmToken"], .firebaseWorkers(self))
                DNSCore.reportError(error)
                promise(.failure(error))
                _ = resultBlock?(.error)
                return
            }
            guard let userId = Self.xlt.id(from: data["userId"] as Any?) else {
                let error = DNSError.Identity
                    .invalidParameters(parameters: ["data[\"userId\"]"], .firebaseWorkers(self))
                DNSCore.reportError(error)
                promise(.failure(error))
                _ = resultBlock?(.error)
                return
            }

            let envelope = DNSSubscriberEnvelope()
            let subscriber = self.netSetIdentity(fcmToken, for: userId, with: progress)
                .receive(on: DNSThreadingQueue.backgroundQueue.queue)
                .sink(receiveCompletion: { completion in
                    switch completion {
                    case .failure(let error):
                        promise(.failure(error))
                        envelope.close()
                        _ = resultBlock?(.error)
                    case .finished:
                        break
                    }
                }, receiveValue: { success in
                    promise(.success)
                    envelope.close()
                    _ = resultBlock?(.completed)
                })
            envelope.open(with: subscriber)
        }
        guard let nextWorker = self.nextWorker else { return future.eraseToAnyPublisher() }
        return Publishers.Zip(future, nextWorker.doSetIdentity(using: data, with: progress))
            .map { _, _ in () }
            .eraseToAnyPublisher()
    }
}
