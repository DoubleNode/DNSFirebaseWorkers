//
//  WKRFirebaseIdentity+network.swift
//  SeaCadetsHelper
//
//  Created by Darren Ehlers on 9/10/22.
//

import Combine
import DNSCore
import DNSError
import DNSProtocols
import Foundation

extension WKRFirebaseIdentity {
    func netClearIdentity(_ fcmToken: String,
                          with progress: DNSPTCLProgressBlock?) -> WKRPTCLIdentityFutVoid {
        let callData = WKRPTCLSystemsStateData(system: DNSAppConstants.Systems.users,
                                               endPoint: DNSAppConstants.Systems.Users.EndPoints.clearIdentity,
                                               sendDebug: DNSAppConstants.Systems.Users.sendDebug)

        let netRouter = self.netRouter
        return Future { promise in
            guard let dataRequest = try? API.apiClearIdentity(router: netRouter, fcmToken: fcmToken)
                .dataRequest.get() else {
                let error = DNSError.NetworkBase.dataError(.firebaseWorkers(self))
                promise(.failure(error))
                return
            }
            self.processRequestJSON(callData, dataRequest, with: nil,
                                    onSuccess: { _ in
                promise(.success)
                return .success
            },
                                    onError: { error, _ in
                promise(.failure(error))
            })
        }
    }
//    func netJoin(group: String,
//                   with progress: DNSPTCLProgressBlock?) -> WKRPTCLIdentityFutVoid {
//    }
//    func netLeave(group: String,
//                    with progress: DNSPTCLProgressBlock?) -> WKRPTCLIdentityFutVoid {
//    }
    func netSetIdentity(_ fcmToken: String,
                        for userId: String,
                        with progress: DNSPTCLProgressBlock?) -> WKRPTCLIdentityFutVoid {
        let callData = WKRPTCLSystemsStateData(system: DNSAppConstants.Systems.users,
                                               endPoint: DNSAppConstants.Systems.Users.EndPoints.setIdentity,
                                               sendDebug: DNSAppConstants.Systems.Users.sendDebug)

        let netRouter = self.netRouter
        return Future { promise in
            guard let dataRequest = try? API.apiSetIdentity(router: netRouter, userId: userId,
                                                            fcmToken: fcmToken)
                .dataRequest.get() else {
                let error = DNSError.NetworkBase.dataError(.firebaseWorkers(self))
                promise(.failure(error))
                return
            }
            self.processRequestJSON(callData, dataRequest, with: nil,
                                    onSuccess: { _ in
                promise(.success)
                return .success
            },
                                    onError: { error, _ in
                promise(.failure(error))
            })
        }
    }
}
