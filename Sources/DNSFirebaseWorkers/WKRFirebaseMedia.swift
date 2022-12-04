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
    override open func intDoUpload(from fileUrl: URL,
                                   to path: String,
                                   with progress: DNSPTCLProgressBlock?,
                                   and block: WKRPTCLMediaBlkMedia?,
                                   then resultBlock: DNSPTCLResultBlock?) {
        let imageRef = self.storage.reference().child(path)
        let metadata = StorageMetadata()
        switch fileUrl.pathExtension {
        case "gif":
            metadata.contentType = "image/gif"
            metadata.customMetadata = ["dnsMediaType": DNSMediaType.animatedImage.rawValue]
        case "jpg", "jpeg":
            metadata.contentType = "image/jpeg"
            metadata.customMetadata = ["dnsMediaType": DNSMediaType.staticImage.rawValue]
        case "pdf":
            metadata.contentType = "application/pdf"
            metadata.customMetadata = ["dnsMediaType": DNSMediaType.pdfDocument.rawValue]
        case "png":
            metadata.contentType = "image/png"
            metadata.customMetadata = ["dnsMediaType": DNSMediaType.staticImage.rawValue]
        case "txt":
            metadata.contentType = "text/plain"
            metadata.customMetadata = ["dnsMediaType": DNSMediaType.text.rawValue]
        default:
            break
        }

        self.utilityUploadMedia(from: fileUrl, with: metadata,
                                to: imageRef,
                                with: progress) { result in
            if case .failure(let error) = result {
                DNSCore.reportError(error)
                block?(.failure(error)); _ = resultBlock?(.error)
                return
            }
            let media = try! result.get() // swiftlint:disable:this force_try
            media.type = .staticImage
            block?(.success(media)); _ = resultBlock?(.completed)
        }
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
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        metadata.customMetadata = ["dnsMediaType": DNSMediaType.staticImage.rawValue]

        self.utilityUploadMedia(data: imageData, with: metadata,
                                to: imageRef,
                                with: progress) { result in
            if case .failure(let error) = result {
                DNSCore.reportError(error)
                block?(.failure(error)); _ = resultBlock?(.error)
                return
            }
            let media = try! result.get() // swiftlint:disable:this force_try
            media.type = .staticImage
            block?(.success(media)); _ = resultBlock?(.completed)
        }
    }
    override open func intDoUpload(_ pdfDocument: PDFDocument,
                                   to path: String,
                                   with progress: DNSPTCLProgressBlock?,
                                   and block: WKRPTCLMediaBlkMedia?,
                                   then resultBlock: DNSPTCLResultBlock?) {
        guard let pdfDocumentData = pdfDocument.dataRepresentation() else {
            let error = DNSError.NetworkBase.dataError(.firebaseWorkers(self))
            block?(.failure(error)); _ = resultBlock?(.error)
            return
        }
        
        let pdfDocumentRef = self.storage.reference().child(path)
        let metadata = StorageMetadata()
        metadata.contentType = "application/pdf"
        metadata.customMetadata = ["dnsMediaType": DNSMediaType.pdfDocument.rawValue]

        self.utilityUploadMedia(data: pdfDocumentData, with: metadata,
                                to: pdfDocumentRef,
                                with: progress) { result in
            if case .failure(let error) = result {
                DNSCore.reportError(error)
                block?(.failure(error)); _ = resultBlock?(.error)
                return
            }
            let media = try! result.get() // swiftlint:disable:this force_try
            media.type = .pdfDocument
            block?(.success(media)); _ = resultBlock?(.completed)
        }
    }
    override open func intDoUpload(_ text: String,
                                   to path: String,
                                   with progress: DNSPTCLProgressBlock?,
                                   and block: WKRPTCLMediaBlkMedia?,
                                   then resultBlock: DNSPTCLResultBlock?) {
        let textData = Data(text.utf8)

        let textRef = self.storage.reference().child(path)
        let metadata = StorageMetadata()
        metadata.contentType = "text/plain"
        metadata.customMetadata = ["dnsMediaType": DNSMediaType.text.rawValue]

        self.utilityUploadMedia(data: textData, with: metadata,
                                to: textRef,
                                with: progress) { result in
            if case .failure(let error) = result {
                DNSCore.reportError(error)
                block?(.failure(error)); _ = resultBlock?(.error)
                return
            }
            let media = try! result.get() // swiftlint:disable:this force_try
            media.type = .text
            block?(.success(media)); _ = resultBlock?(.completed)
        }
    }
    
    // MARK: - Utility methods -
    func utilityUploadMedia(data: Data,
                            with metadata: StorageMetadata? = nil,
                            to storageRef: StorageReference,
                            with progressBlk: DNSPTCLProgressBlock?,
                            and block: WKRPTCLMediaBlkMedia?) {
        let uploadTask = storageRef.putData(data, metadata: metadata) { metadata, error in
            if let error {
                block?(.failure(error));
                return
            }
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
                let mediaTypeStr = metadata?.customMetadata?["dnsMediaType"] ?? ""
                let media = Self.createMedia()
                media.type = DNSMediaType(rawValue: mediaTypeStr) ?? .unknown
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
    func utilityUploadMedia(from fileUrl: URL,
                            with metadata: StorageMetadata? = nil,
                            to storageRef: StorageReference,
                            with progressBlk: DNSPTCLProgressBlock?,
                            and block: WKRPTCLMediaBlkMedia?) {
        let uploadTask = storageRef.putFile(from: fileUrl, metadata: metadata) { metadata, error in
            if let error {
                block?(.failure(error));
                return
            }
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
                let mediaTypeStr = metadata?.customMetadata?["dnsMediaType"] ?? ""
                let media = Self.createMedia()
                media.type = DNSMediaType(rawValue: mediaTypeStr) ?? .unknown
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
