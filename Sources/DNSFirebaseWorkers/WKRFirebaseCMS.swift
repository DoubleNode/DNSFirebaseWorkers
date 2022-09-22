//
//  WKRFirebaseCMS.swift
//  DoubleNode Swift Framework (DNSFramework) - DNSFirebaseWorkers
//
//  Created by Darren Ehlers.
//  Copyright © 2022 - 2016 DoubleNode.com. All rights reserved.
//

import DNSBlankWorkers
import DNSCore
import DNSCoreThreading
import DNSDataObjects
import DNSError
import DNSProtocols
import FirebaseFirestore

open class WKRFirebaseCMS: WKRBlankCms {
    public enum Group {
        public static let faqs = "faqs"
        public static let legalDocuments = "legalDocuments"
        public static let stringsAboutUsDocuments = "strings/aboutUs"
    }
    public enum Page {
        public static let strings = "strings"
        public static let aboutUs = "aboutUs"
    }

    public enum FAQSections {
        public static let iconKey = "iconKey"
        public static let items = "items"
        public static let key = "key"
        public static let sortOrder = "sortOrder"
        public static let title = "title"
    }
    public enum FAQs {
        public static let answer = "answer"
        public static let question = "question"
    }
    public enum DocumentLegals {
        public static let key = "key"
        public static let sortOrder = "sortOrder"
        public static let title = "title"
        public static let url = "url"
    }
    public enum DocumentStrings {
        public static let body = "body"
        public static let calendarNotes = "calendarNotes"
        public static let footer = "footer"
        public static let key = "key"
        public static let sortOrder = "sortOrder"
        public static let subTitle = "subTitle"
        public static let title = "title"
        public static let logoUrl = "logoUrl"
    }

    // MARK: - Class Factory methods -
    public static var documentType: DAODocument.Type = DAODocument.self
    public static var faqType: DAOFaq.Type = DAOFaq.self
    public static var faqSectionType: DAOFaqSection.Type = DAOFaqSection.self

    open class var document: DAODocument.Type { documentType }
    open class var faq: DAOFaq.Type { faqType }
    open class var faqSection: DAOFaqSection.Type { faqSectionType }

    open class func createDocument() -> DAODocument { document.init() }
    open class func createDocument(from object: DAODocument) -> DAODocument { document.init(from: object) }
    open class func createDocument(from data: DNSDataDictionary) -> DAODocument? { document.init(from: data) }

    open class func createFaq() -> DAOFaq { faq.init() }
    open class func createFaq(from object: DAOFaq) -> DAOFaq { faq.init(from: object) }
    open class func createFaq(from data: DNSDataDictionary) -> DAOFaq? { faq.init(from: data) }

    open class func createFaqSection() -> DAOFaqSection { faqSection.init() }
    open class func createFaqSection(from object: DAOFaqSection) -> DAOFaqSection { faqSection.init(from: object) }
    open class func createFaqSection(from data: DNSDataDictionary) -> DAOFaqSection? { faqSection.init(from: data) }

    let db = Firestore.firestore()

    // MARK: - Internal Work Methods
    override open func intDoLoad(for group: String,
                                 with progress: DNSPTCLProgressBlock?,
                                 and block: WKRPTCLCmsBlkAAny?,
                                 then resultBlock: DNSPTCLResultBlock?) {
        switch group {
        case WKRFirebaseCMS.Group.faqs:
            self.utilityLoadFAQsData(with: progress,
                                     and: block, then: resultBlock)
        case WKRFirebaseCMS.Group.legalDocuments:
            self.utilityLoadDocumentLegalsData(with: progress,
                                               and: block, then: resultBlock)
        case WKRFirebaseCMS.Group.stringsAboutUsDocuments:
            self.utilityLoadDocumentStringsData(path: WKRFirebaseCMS.Page.aboutUs,
                                                with: progress,
                                                and: block, then: resultBlock)
        default:
            let error = DNSError.Cms
                .invalidParameters(parameters: ["group"], .firebaseWorkers(self))
            block?(.failure(error))
            _ = resultBlock?(.failure(error))
        }
    }

    // Protocol Return Types
    public typealias WKRFirebaseCMSRtnADocument = [DAODocument]
    public typealias WKRFirebaseCMSRtnDataDictionary = DNSDataDictionary

    // Protocol Result Types
    public typealias WKRFirebaseCMSResADocument = Result<WKRFirebaseCMSRtnADocument, Error>
    public typealias WKRFirebaseCMSResDataDictionary = Result<WKRFirebaseCMSRtnDataDictionary, Error>

    // Protocol Block Types
    public typealias WKRFirebaseCMSBlkADocument = (WKRFirebaseCMSResADocument) -> Void
    public typealias WKRFirebaseCMSBlkDataDictionary = (WKRFirebaseCMSResDataDictionary) -> Void

    // MARK: - Utility methods -
    func utilityCleanupString(_ string: String) -> String {
        return string.replacingOccurrences(of: "\\r", with: "\r")
            .replacingOccurrences(of: "\\n", with: "\n")
    }
    func utilityLoadData(from path: String,
                         _ page: String = DNSCore.languageCode,
                         with progress: DNSPTCLProgressBlock?,
                         and block: WKRFirebaseCMSBlkDataDictionary?) {
        let dataRef = db.collection(path).document(page)
        dataRef.getDocument { (document, error) in
            DNSThread.run {
                if let error {
                    let dnsError = DNSError.WorkerBase.systemError(error: error, .firebaseWorkers(self))
                    DNSCore.reportError(dnsError)
                    block?(.failure(dnsError))
                    return
                }
                guard let document, document.exists else {
                    let dnsError = DNSError.WorkerBase.unknown(.firebaseWorkers(self))
                    DNSCore.reportError(dnsError)
                    block?(.failure(dnsError))
                    return
                }
                guard let data = document.data() else {
                    let dnsError = DNSError.WorkerBase
                        .notFound(field: "page", value: page, .firebaseWorkers(self))
                    DNSCore.reportError(dnsError)
                    block?(.failure(dnsError))
                    return
                }
                block?(.success(data))
            }
        }
    }
    func utilityLoadFAQsData(with progress: DNSPTCLProgressBlock?,
                             and block: WKRPTCLCmsBlkAAny?,
                             then resultBlock: DNSPTCLResultBlock?) {
        self.utilityLoadData(from: WKRFirebaseCMS.Group.faqs,
                             with: progress,
                             and: { result in
            if case .failure(let error) = result {
                block?(.failure(error))
                _ = resultBlock?(.error)
                return
            }
            if case .success(let data) = result {
                var retval: DNSDataArray = []
                guard let data = data as? [String: [String: DNSDataDictionary]] else {
                    let dnsError = DNSError.WorkerBase.unknown(.firebaseWorkers(self))
                    DNSCore.reportError(dnsError)
                    block?(.failure(dnsError))
                    _ = resultBlock?(.error)
                    return
                }
                let sectionData = data["sections"]! as [String: DNSDataDictionary]
                let sortedData = sectionData.sorted(by: {
                    let lhv = Self.xlt.int(from: $0.value[FAQSections.sortOrder] as Any?) ?? 9999
                    let rhv = Self.xlt.int(from: $1.value[FAQSections.sortOrder] as Any?) ?? 9999
                    return lhv < rhv
                })
                for (key, value) in sortedData {
                    let section: DNSDataDictionary = [
                        FAQSections.key: key,
                        FAQSections.iconKey: Self.xlt.string(from: value[FAQSections.iconKey] as Any?) ?? "",
                        FAQSections.items: Self.xlt.dataarray(from: value[FAQSections.items] as Any?),
                        FAQSections.title: Self.xlt.string(from: value[FAQSections.title] as Any?) ?? "",
                    ]
                    retval.append(section)
                }
                block?(.success(retval))
                _ = resultBlock?(.completed)
            }
        })
    }
    func utilityLoadDocumentLegalsData(with progress: DNSPTCLProgressBlock?,
                                       and block: WKRPTCLCmsBlkAAny?,
                                       then resultBlock: DNSPTCLResultBlock?) {
        self.utilityLoadDocuments(from: WKRFirebaseCMS.Group.legalDocuments,
                                  with: progress,
                                  and: block,
                                  then: resultBlock)
    }
    func utilityLoadDocumentStringsData(path: String,
                                        with progress: DNSPTCLProgressBlock?,
                                        and block: WKRPTCLCmsBlkAAny?,
                                        then resultBlock: DNSPTCLResultBlock?) {
        self.utilityLoadData(from: WKRFirebaseCMS.Page.strings,
                             path,
                             with: progress,
                             and: { result in
            if case .failure(let error) = result {
                block?(.failure(error))
                _ = resultBlock?(.error)
                return
            }
            if case .success(let data) = result {
                var retval: DNSDataArray = []
                guard let data = data as? [String: DNSDataDictionary] else {
                    let error = DNSError.WorkerBase.unknown(.firebaseWorkers(self))
                    DNSCore.reportError(error)
                    block?(.failure(error))
                    _ = resultBlock?(.error)
                    return
                }
                let sortedData = data
                    .sorted(by: {
                        let lhv = Self.xlt.int(from: $0.value[DocumentStrings.sortOrder] as Any?) ?? 9999
                        let rhv = Self.xlt.int(from: $1.value[DocumentStrings.sortOrder] as Any?) ?? 9999
                        return lhv < rhv
                    })
                for (key, value) in sortedData {
                    var document: DNSDataDictionary = [
                        DocumentStrings.key: key,
                        DocumentStrings.sortOrder:
                            Self.xlt.int(from: value[DocumentStrings.sortOrder] as Any?) ?? 9999,
                    ]

                    let body = Self.xlt.string(from: Self.xlt.localized(value[DocumentStrings.body])) ?? ""
                    document[DocumentStrings.body] = self.utilityCleanupString(body)

                    let calendarNotes = Self.xlt.string(from: Self.xlt.localized(value[DocumentStrings.calendarNotes])) ?? ""
                    document[DocumentStrings.calendarNotes] = self.utilityCleanupString(calendarNotes)

                    let footer = Self.xlt.string(from: Self.xlt.localized(value[DocumentStrings.footer])) ?? ""
                    document[DocumentStrings.footer] = self.utilityCleanupString(footer)

                    let subTitle = Self.xlt.string(from: Self.xlt.localized(value[DocumentStrings.subTitle])) ?? ""
                    document[DocumentStrings.subTitle] = self.utilityCleanupString(subTitle)

                    let title = Self.xlt.string(from: Self.xlt.localized(value[DocumentStrings.title])) ?? ""
                    document[DocumentStrings.title] = self.utilityCleanupString(title)

                    let logoUrl = Self.xlt.url(from: value[DocumentStrings.logoUrl] as Any?)
                    if logoUrl != nil {
                        document[DocumentStrings.logoUrl] = logoUrl
                    }
                    retval.append(document)
                }
                block?(.success(retval))
                _ = resultBlock?(.completed)
            }
        })
    }
    func utilityLoadDocuments(from path: String,
                              with progress: DNSPTCLProgressBlock?,
                              and block: WKRPTCLCmsBlkAAny?,
                              then resultBlock: DNSPTCLResultBlock?) {
        let documentsRef = self.db.collection(path)
        documentsRef.getDocuments { querySnapshot, error in
            DNSThread.run {
                if let error {
                    let dnsError = DNSError.WorkerBase.systemError(error: error, .firebaseWorkers(self))
                    DNSCore.reportError(dnsError)
                    block?(.failure(dnsError))
                    _ = resultBlock?(.error)
                    return
                }
                guard let documents = querySnapshot?.documents else {
                    let dnsError = DNSError.Systems.unknown(.firebaseWorkers(self))
                    DNSCore.reportError(dnsError)
                    block?(.failure(dnsError))
                    _ = resultBlock?(.error)
                    return
                }
                var results: [DAODocument] = documents
                    .compactMap { $0.data() }
                    .compactMap { Self.createDocument(from: $0) }
                block?(.success(results))
                _ = resultBlock?(.completed)
            }
        }
    }
    func utilityLoadDocumentsData(for group: String,
                                  with progress: DNSPTCLProgressBlock?,
                                  and block: WKRPTCLCmsBlkAAny?,
                                  then resultBlock: DNSPTCLResultBlock?) {
        self.utilityLoadData(from: group,
                             with: progress,
                             and: { result in
            if case .failure(let error) = result {
                block?(.failure(error))
                _ = resultBlock?(.error)
                return
            }
            if case .success(let data) = result {
                var retval: DNSDataArray = []
                guard let data = data as? [String: DNSDataDictionary] else {
                    let error = DNSError.WorkerBase.unknown(.firebaseWorkers(self))
                    DNSCore.reportError(error)
                    block?(.failure(error))
                    _ = resultBlock?(.error)
                    return
                }
                let sortedData = data
                    .sorted(by: {
                        ($0.value[DocumentLegals.sortOrder] as! Int) <      // swiftlint:disable:this force_cast
                            ($1.value[DocumentLegals.sortOrder] as! Int)    // swiftlint:disable:this force_cast
                    })
                for (key, value) in sortedData {
                    let document: DNSDataDictionary = [
                        DocumentLegals.key: key,
                        DocumentLegals.title: value[DocumentLegals.title]!,
                        // swiftlint:disable:next force_cast
                        DocumentLegals.url: URL(string: value[DocumentLegals.url] as! String)!,
                    ]
                    retval.append(document)
                }
                block?(.success(retval))
                _ = resultBlock?(.completed)
            }
        })
    }
}
