//
//  WKRFirebaseChats.swift
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

public protocol PTCLCFGWKRFirebaseChats: PTCLCFGDAOChat {
    var messagesResponseType: any PTCLRSPWKRFirebaseChatsAChatMessage.Type { get }
}
public class CFGWKRFirebaseChats: PTCLCFGWKRFirebaseChats {
    public var messagesResponseType: any PTCLRSPWKRFirebaseChatsAChatMessage.Type = RSPWKRFirebaseChatsAChatMessage.self

    public var chatType: DAOChat.Type = DAOChat.self
    open func chat<K>(from container: KeyedDecodingContainer<K>,
                      forKey key: KeyedDecodingContainer<K>.Key) -> DAOChat? where K: CodingKey {
        do { return try container.decodeIfPresent(DAOChat.self, forKey: key, configuration: self) ?? nil } catch { }
        return nil
    }
    open func chatArray<K>(from container: KeyedDecodingContainer<K>,
                           forKey key: KeyedDecodingContainer<K>.Key) -> [DAOChat] where K: CodingKey {
        do { return try container.decodeIfPresent([DAOChat].self, forKey: key, configuration: self) ?? [] } catch { }
        return []
    }
}
// swiftlint:disable:next type_body_length
open class WKRFirebaseChats: WKRBlankChats, DecodingConfigurationProviding, EncodingConfigurationProviding {
    public typealias Config = PTCLCFGWKRFirebaseChats
    public typealias DecodingConfiguration = Config
    public typealias EncodingConfiguration = Config
    public static var config: Config = CFGWKRFirebaseChats()

    public static var decodingConfiguration: DecodingConfiguration { Self.config }
    public static var encodingConfiguration: EncodingConfiguration { Self.config }

    typealias API = WKRFirebaseChatsAPI // swiftlint:disable:this type_name

    // MARK: - Class Factory methods -
    open class func createChat() -> DAOChat { config.chatType.init() }
    open class func createChat(from object: DAOChat) -> DAOChat { config.chatType.init(from: object) }
    open class func createChat(from data: DNSDataDictionary) -> DAOChat? { config.chatType.init(from: data) }

    // MARK: - Properties -
    let db = Firestore.firestore()

    // MARK: - Internal Work Methods
    override open func intDoLoadChat(for id: String,
                                     with progress: DNSPTCLProgressBlock?,
                                     and block: WKRPTCLChatsBlkChat?,
                                     then resultBlock: DNSPTCLResultBlock?) {
        let callData = WKRPTCLSystemsStateData(system: DNSAppConstants.Systems.chats,
                                               endPoint: DNSAppConstants.Systems.Chats.EndPoints.loadChat,
                                               sendDebug: DNSAppConstants.Systems.Chats.sendDebug)

        guard let dataRequest = try? API.apiLoadChat(router: self.netRouter, id: id)
            .dataRequest.get() else {
            let error = DNSError.NetworkBase.dataError(.firebaseWorkers(self))
            block?(.failure(error)); _ = resultBlock?(.error)
            return
        }
        self.processRequestData(callData, dataRequest, with: resultBlock,
                                onSuccess: { data in
            do {
                let chat = try JSONDecoder().decode(Self.config.chatType, from: data)
                block?(.success(chat))
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
    override open func intDoLoadMessages(for chat: DAOChat,
                                         with progress: DNSPTCLProgressBlock?,
                                         and block: WKRPTCLChatsBlkAChatMessage?,
                                         then resultBlock: DNSPTCLResultBlock?) {
        let callData = WKRPTCLSystemsStateData(system: DNSAppConstants.Systems.chats,
                                               endPoint: DNSAppConstants.Systems.Chats.EndPoints.loadMessages,
                                               sendDebug: DNSAppConstants.Systems.Chats.sendDebug)

        guard let dataRequest = try? API.apiLoadMessages(router: self.netRouter, chat: chat)
            .dataRequest.get() else {
            let error = DNSError.NetworkBase.dataError(.firebaseWorkers(self))
            block?(.failure(error)); _ = resultBlock?(.error)
            return
        }
        self.processRequestData(callData, dataRequest, with: resultBlock,
                                onSuccess: { data in
            do {
                let response = try JSONDecoder().decode(Self.config.messagesResponseType, from: data)
                block?(.success(response.messages))
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
    override open func intDoRemove(_ message: DAOChatMessage,
                                   with progress: DNSPTCLProgressBlock?,
                                   and block: WKRPTCLChatsBlkVoid?,
                                   then resultBlock: DNSPTCLResultBlock?) {
        let callData = WKRPTCLSystemsStateData(system: DNSAppConstants.Systems.chats,
                                               endPoint: DNSAppConstants.Systems.Chats.EndPoints.removeMessage,
                                               sendDebug: DNSAppConstants.Systems.Chats.sendDebug)

        guard let dataRequest = try? API.apiRemoveMessage(router: self.netRouter, message: message)
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
    override open func intDoUpdate(_ message: DAOChatMessage,
                                   with progress: DNSPTCLProgressBlock?,
                                   and block: WKRPTCLChatsBlkVoid?,
                                   then resultBlock: DNSPTCLResultBlock?) {
        let callData = WKRPTCLSystemsStateData(system: DNSAppConstants.Systems.chats,
                                               endPoint: DNSAppConstants.Systems.Chats.EndPoints.updateMessage,
                                               sendDebug: DNSAppConstants.Systems.Chats.sendDebug)

        guard let dataRequest = try? API.apiUpdateMessage(router: self.netRouter, message: message)
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
