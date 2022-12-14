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
        let imageRef = self.storage.reference().child(media.path)
        self.utilityRemoveMedia(from: imageRef,
                                with: progress) { result in
            if case .failure(let error) = result {
                DNSCore.reportError(error)
                block?(.failure(error)); _ = resultBlock?(.error)
                return
            }
            block?(.success); _ = resultBlock?(.completed)
        }
    }
    override open func intDoUpload(from fileUrl: URL,
                                   to path: String,
                                   with progress: DNSPTCLProgressBlock?,
                                   and block: WKRPTCLMediaBlkMedia?,
                                   then resultBlock: DNSPTCLResultBlock?) {
        let imageRef = self.storage.reference().child(path)
        let metadata = StorageMetadata()
        let pathUrl = URL(string: path)
        var mediaType: DNSMediaType = .unknown
        switch pathUrl?.pathExtension {
        case "gif":
            mediaType = .animatedImage
            metadata.contentType = "image/gif"
            metadata.customMetadata = ["dnsMediaType": DNSMediaType.animatedImage.rawValue]
        case "jpg", "jpeg":
            mediaType = .staticImage
            metadata.contentType = "image/jpeg"
            metadata.customMetadata = ["dnsMediaType": DNSMediaType.staticImage.rawValue]
        case "pdf":
            mediaType = .pdfDocument
            metadata.contentType = "application/pdf"
            metadata.customMetadata = ["dnsMediaType": DNSMediaType.pdfDocument.rawValue]
        case "png":
            mediaType = .staticImage
            metadata.contentType = "image/png"
            metadata.customMetadata = ["dnsMediaType": DNSMediaType.staticImage.rawValue]
        case "txt":
            mediaType = .text
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
            media.path = path
            media.type = mediaType
            block?(.success(media)); _ = resultBlock?(.completed)
        }
    }
    override open func intDoUpload(_ image: UIImage,
                                   to path: String,
                                   with progress: DNSPTCLProgressBlock?,
                                   and block: WKRPTCLMediaBlkMedia?,
                                   then resultBlock: DNSPTCLResultBlock?) {
        let imageRef = self.storage.reference().child(path)
        let metadata = StorageMetadata()
        let pathUrl = URL(string: path)
        var mediaType: DNSMediaType = .unknown
        var imageData: Data?
        switch pathUrl?.pathExtension {
//        case "gif":
//            imageData = pngData
//            mediaType = .animatedImage
//            metadata.contentType = "image/gif"
//            metadata.customMetadata = ["dnsMediaType": DNSMediaType.animatedImage.rawValue]
        case "png":
            imageData = image.pngData()
            mediaType = .staticImage
            metadata.contentType = "image/png"
            metadata.customMetadata = ["dnsMediaType": DNSMediaType.staticImage.rawValue]
        case "jpg", "jpeg":
            fallthrough
        default:
            imageData = image.jpegData(compressionQuality: 0.75)
            mediaType = .staticImage
            metadata.contentType = "image/jpeg"
            metadata.customMetadata = ["dnsMediaType": DNSMediaType.staticImage.rawValue]
        }
        guard let imageData else {
            let error = DNSError.NetworkBase.dataError(.firebaseWorkers(self))
            block?(.failure(error)); _ = resultBlock?(.error)
            return
        }
        self.utilityUploadMedia(data: imageData, with: metadata,
                                to: imageRef,
                                with: progress) { result in
            if case .failure(let error) = result {
                DNSCore.reportError(error)
                block?(.failure(error)); _ = resultBlock?(.error)
                return
            }
            let media = try! result.get() // swiftlint:disable:this force_try
            media.path = path
            media.type = mediaType
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
            media.path = path
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
            media.path = path
            media.type = .text
            block?(.success(media)); _ = resultBlock?(.completed)
        }
    }

    // MARK: - Utility methods -
    func utilityRemoveMedia(from storageRef: StorageReference,
                            with progressBlk: DNSPTCLProgressBlock?,
                            and block: WKRPTCLMediaBlkVoid?) {
        storageRef.delete { error in
            if let error = error as? NSError {
                switch (StorageErrorCode(rawValue: error.code)!) {
                case .objectNotFound:
                    let dnsError = DNSError.Media.notFound(field: "object", value: storageRef.fullPath, .firebaseWorkers(self))
                    block?(.failure(dnsError));
                case .bucketNotFound:
                    let dnsError = DNSError.Media.notFound(field: "bucket", value: storageRef.bucket, .firebaseWorkers(self))
                    block?(.failure(dnsError));
                case .projectNotFound:
                    let dnsError = DNSError.Media.notFound(field: "project", value: "[project]", .firebaseWorkers(self))
                    block?(.failure(dnsError));
                case .invalidArgument:
                    let dnsError = DNSError.Media.invalidParameters(parameters: [], .firebaseWorkers(self))
                    block?(.failure(dnsError));
                default:
                    let dnsError = DNSError.Media.lowerError(error: error, .firebaseWorkers(self))
                    block?(.failure(dnsError));
                }
            }
            block?(.success)
        }
    }
    func utilityUploadMedia(data: Data,
                            with metadata: StorageMetadata? = nil,
                            to storageRef: StorageReference,
                            with progressBlk: DNSPTCLProgressBlock?,
                            and block: WKRPTCLMediaBlkMedia?) {
        let uploadTask = storageRef.putData(data, metadata: metadata) { metadata, error in
            if let error = error as? NSError {
                switch (StorageErrorCode(rawValue: error.code)!) {
                case .objectNotFound:
                    let dnsError = DNSError.Media.notFound(field: "object", value: storageRef.fullPath, .firebaseWorkers(self))
                    block?(.failure(dnsError));
                case .bucketNotFound:
                    let dnsError = DNSError.Media.notFound(field: "bucket", value: storageRef.bucket, .firebaseWorkers(self))
                    block?(.failure(dnsError));
                case .projectNotFound:
                    let dnsError = DNSError.Media.notFound(field: "project", value: "[project]", .firebaseWorkers(self))
                    block?(.failure(dnsError));
                case .invalidArgument:
                    let dnsError = DNSError.Media.invalidParameters(parameters: [], .firebaseWorkers(self))
                    block?(.failure(dnsError));
                default:
                    let dnsError = DNSError.Media.lowerError(error: error, .firebaseWorkers(self))
                    block?(.failure(dnsError));
                }
            }
            storageRef.downloadURL { url, error in
                if let error = error as? NSError {
                    switch (StorageErrorCode(rawValue: error.code)!) {
                    case .objectNotFound:
                        let dnsError = DNSError.Media.notFound(field: "object", value: storageRef.fullPath, .firebaseWorkers(self))
                        block?(.failure(dnsError));
                    case .bucketNotFound:
                        let dnsError = DNSError.Media.notFound(field: "bucket", value: storageRef.bucket, .firebaseWorkers(self))
                        block?(.failure(dnsError));
                    case .projectNotFound:
                        let dnsError = DNSError.Media.notFound(field: "project", value: "[project]", .firebaseWorkers(self))
                        block?(.failure(dnsError));
                    case .invalidArgument:
                        let dnsError = DNSError.Media.invalidParameters(parameters: [], .firebaseWorkers(self))
                        block?(.failure(dnsError));
                    default:
                        let dnsError = DNSError.Media.lowerError(error: error, .firebaseWorkers(self))
                        block?(.failure(dnsError));
                    }
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
            if let error = error as? NSError {
                switch (StorageErrorCode(rawValue: error.code)!) {
                case .objectNotFound:
                    let dnsError = DNSError.Media.notFound(field: "object", value: storageRef.fullPath, .firebaseWorkers(self))
                    block?(.failure(dnsError));
                case .bucketNotFound:
                    let dnsError = DNSError.Media.notFound(field: "bucket", value: storageRef.bucket, .firebaseWorkers(self))
                    block?(.failure(dnsError));
                case .projectNotFound:
                    let dnsError = DNSError.Media.notFound(field: "project", value: "[project]", .firebaseWorkers(self))
                    block?(.failure(dnsError));
                case .invalidArgument:
                    let dnsError = DNSError.Media.invalidParameters(parameters: [], .firebaseWorkers(self))
                    block?(.failure(dnsError));
                default:
                    let dnsError = DNSError.Media.lowerError(error: error, .firebaseWorkers(self))
                    block?(.failure(dnsError));
                }
            }
            storageRef.downloadURL { url, error in
                if let error = error as? NSError {
                    switch (StorageErrorCode(rawValue: error.code)!) {
                    case .objectNotFound:
                        let dnsError = DNSError.Media.notFound(field: "object", value: storageRef.fullPath, .firebaseWorkers(self))
                        block?(.failure(dnsError));
                    case .bucketNotFound:
                        let dnsError = DNSError.Media.notFound(field: "bucket", value: storageRef.bucket, .firebaseWorkers(self))
                        block?(.failure(dnsError));
                    case .projectNotFound:
                        let dnsError = DNSError.Media.notFound(field: "project", value: "[project]", .firebaseWorkers(self))
                        block?(.failure(dnsError));
                    case .invalidArgument:
                        let dnsError = DNSError.Media.invalidParameters(parameters: [], .firebaseWorkers(self))
                        block?(.failure(dnsError));
                    default:
                        let dnsError = DNSError.Media.lowerError(error: error, .firebaseWorkers(self))
                        block?(.failure(dnsError));
                    }
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
