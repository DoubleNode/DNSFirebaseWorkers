//
//  WKRFirebaseMedia.swift
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
import FirebaseStorage
import PDFKit
import UIKit

public protocol PTCLCFGWKRFirebaseMedia: PTCLCFGDAOMedia {
}
public class CFGWKRFirebaseMedia: PTCLCFGWKRFirebaseMedia {
    public var mediaType: DAOMedia.Type = DAOMedia.self
    open func media<K>(from container: KeyedDecodingContainer<K>,
                       forKey key: KeyedDecodingContainer<K>.Key) -> DAOMedia? where K: CodingKey {
        do { return try container.decodeIfPresent(DAOMedia.self, forKey: key, configuration: self) ?? nil } catch { }
        return nil
    }
    open func mediaArray<K>(from container: KeyedDecodingContainer<K>,
                            forKey key: KeyedDecodingContainer<K>.Key) -> [DAOMedia] where K: CodingKey {
        do { return try container.decodeIfPresent([DAOMedia].self, forKey: key, configuration: self) ?? [] } catch { }
        return []
    }
}
// swiftlint:disable:next type_body_length
open class WKRFirebaseMedia: WKRBlankMedia, DecodingConfigurationProviding, EncodingConfigurationProviding {
    public typealias Config = PTCLCFGWKRFirebaseMedia
    public typealias DecodingConfiguration = Config
    public typealias EncodingConfiguration = Config
    public static var config: Config = CFGWKRFirebaseMedia()

    public static var decodingConfiguration: DecodingConfiguration { Self.config }
    public static var encodingConfiguration: EncodingConfiguration { Self.config }

    // MARK: - Class Factory methods -
    open class func createMedia() -> DAOMedia { config.mediaType.init() }
    open class func createMedia(from object: DAOMedia) -> DAOMedia { config.mediaType.init(from: object) }
    open class func createMedia(from data: DNSDataDictionary) -> DAOMedia? { config.mediaType.init(from: data) }

    // MARK: - Properties -
    let storage = Storage.storage()

    // MARK: - Internal Work Methods
    override open func intDoRemove(_ media: DAOMedia,
                                   with progress: DNSPTCLProgressBlock?,
                                   and block: WKRPTCLMediaBlkVoid?,
                                   then resultBlock: DNSPTCLResultBlock?) {
    }
    override open func intDoUpload(_ image: UIImage,
                                   to path: String,
                                   with progress: DNSPTCLProgressBlock?,
                                   and block: WKRPTCLMediaBlkMedia?,
                                   then resultBlock: DNSPTCLResultBlock?) {
        guard let imageData = image.jpegData(compressionQuality: 0.75) else {
            let error = DNSError.NetworkBase.dataError(.firebaseWorkers(self))
            block?(.failure(error)); _ = resultBlock?(.error)
            return
        }
        
        let imageRef = self.storage.reference().child(path)

        self.utilityUploadMedia(data: imageData,
                                to: imageRef,
                                with: progress) { result in
            if case .failure(let error) = result {
                DNSCore.reportError(error)
                block?(.failure(error)); _ = resultBlock?(.error)
                return
            }
            block?(result); _ = resultBlock?(.completed)
        }
    }
    override open func intDoUpload(_ pdfDocument: PDFDocument,
                                   to path: String,
                                   with progress: DNSPTCLProgressBlock?,
                                   and block: WKRPTCLMediaBlkMedia?,
                                   then resultBlock: DNSPTCLResultBlock?) {
    }
    override open func intDoUpload(_ text: String,
                                   to path: String,
                                   with progress: DNSPTCLProgressBlock?,
                                   and block: WKRPTCLMediaBlkMedia?,
                                   then resultBlock: DNSPTCLResultBlock?) {
    }
    
    // MARK: - Utility methods -
    func utilityUploadMedia(data: Data,
                            to storageRef: StorageReference,
                            with progressBlk: DNSPTCLProgressBlock?,
                            and block: WKRPTCLMediaBlkMedia?) {
        let uploadTask = storageRef.putData(data, metadata: nil) { metadata, error in
            if let error {
                block?(.failure(error));
                return
            }
//            guard let metadata = metadata else {
//                let error = DNSError.NetworkBase.dataError(.firebaseWorkers(self))
//                block?(.failure(error));
//                return
//            }

//            let size = metadata.size
            storageRef.downloadURL { url, error in
                if let error {
                    block?(.failure(error));
                    return
                }
                guard let downloadUrl = url else {
                    let error = DNSError.NetworkBase.dataError(.firebaseWorkers(self))
                    block?(.failure(error));
                    return
                }
                let media = Self.createMedia()
                media.type = .staticImage
                media.url = DNSURL(with: downloadUrl)
                block?(.success(media))
            }
        }
        _ = uploadTask.observe(.progress) { snapshot in
            guard let progress = snapshot.progress else {
                return
            }
            let percentComplete = Double(progress.completedUnitCount) / Double(progress.totalUnitCount)
            progressBlk?(progress.completedUnitCount, progress.totalUnitCount, percentComplete, progress.localizedDescription)
        }
    }
}
