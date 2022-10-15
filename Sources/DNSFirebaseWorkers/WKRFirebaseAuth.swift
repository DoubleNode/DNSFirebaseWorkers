//
//  WKRFirebaseAuth.swift
//  SeaCadetsHelper
//
//  Created by Darren Ehlers on 9/10/22.
//

import AuthenticationServices
import CryptoKit
import DNSBlankWorkers
import DNSCore
import DNSCrashWorkers
import DNSDataObjects
import DNSError
import DNSProtocols
import FirebaseAuth
import Foundation

// Protocol Return Types
public typealias WKRFirebaseAuthRtnUserString = (User, String)

// Protocol Result Types
public typealias WKRFirebaseAuthResUserString = Result<WKRFirebaseAuthRtnUserString, Error>

// Protocol Block Types
public typealias WKRFirebaseAuthBlkUserString = (WKRFirebaseAuthResUserString) -> Void

open class WKRFirebaseAuthAccessData: WKRPTCLAuthAccessData, Codable, NSCopying {
    public enum CodingKeys: String, CodingKey {
        case accessToken, appleUserId, method, userId, userName, userEmail
    }
    
    public var accessToken: String = ""
    public var appleUserId: String = ""
    public var method: WKRFirebaseAuth.Method = .default
    public var userId: String = ""
    public var userName = PersonNameComponents()
    public var userEmail: String = ""
    
    // name formatted output
    public var nameAbbreviated: String { self.userName.dnsFormatName(style: .abbreviated) }
    public var nameMedium: String { self.userName.dnsFormatName(style: .medium) }
    public var nameLong: String { self.userName.dnsFormatName(style: .long) }
    public var nameShort: String { self.userName.dnsFormatName(style: .short) }

    required public init() { }
    
    // MARK: - DAO copy methods -
    required public init(from object: WKRFirebaseAuthAccessData) {
        self.update(from: object)
    }
    open func update(from object: WKRFirebaseAuthAccessData) {
        self.accessToken = object.accessToken
        self.appleUserId = object.appleUserId
        self.method = object.method
        self.userId = object.userId
        self.userName = object.userName
        self.userEmail = object.userEmail
    }

    // MARK: - Codable protocol methods -
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        accessToken = try container.decode(String.self, forKey: .accessToken)
        appleUserId = try container.decode(String.self, forKey: .appleUserId)
        method = WKRFirebaseAuth.Method(rawValue: try container.decode(String.self, forKey: .method)) ?? .default
        userId = try container.decode(String.self, forKey: .userId)
        userName = try container.decode(PersonNameComponents.self, forKey: .userName)
        userEmail = try container.decode(String.self, forKey: .userEmail)
    }
    open func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(accessToken, forKey: .accessToken)
        try container.encode(appleUserId, forKey: .appleUserId)
        try container.encode(method.rawValue, forKey: .method)
        try container.encode(userId, forKey: .userId)
        try container.encode(userName, forKey: .userName)
        try container.encode(userEmail, forKey: .userEmail)
    }
    
    // MARK: - NSCopying protocol methods -
    open func copy(with zone: NSZone? = nil) -> Any {
        let copy = WKRFirebaseAuthAccessData(from: self)
        return copy
    }
    open func isDiffFrom(_ rhs: Any?) -> Bool {
        guard let rhs = rhs as? WKRFirebaseAuthAccessData else { return true }
        let lhs = self
        return lhs.accessToken != rhs.accessToken ||
            lhs.appleUserId != rhs.appleUserId ||
            lhs.method != rhs.method ||
            lhs.userId != rhs.userId ||
            lhs.userName != rhs.userName ||
            lhs.userEmail != rhs.userEmail
    }

    // MARK: - Equatable protocol methods -
    static public func !=(lhs: WKRFirebaseAuthAccessData, rhs: WKRFirebaseAuthAccessData) -> Bool {
        lhs.isDiffFrom(rhs)
    }
    static public func ==(lhs: WKRFirebaseAuthAccessData, rhs: WKRFirebaseAuthAccessData) -> Bool {
        !lhs.isDiffFrom(rhs)
    }
}
open class WKRFirebaseAuth: WKRBlankAuth, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    public typealias AccessData = WKRFirebaseAuthAccessData

    public enum Method: String, CaseIterable {
        case apple = "apple.com"
        case `default`
        case email = "password"
    }
    
    fileprivate var accessData = AccessData()

    // Unhashed nonce.
    fileprivate var appleFlowCurrentNonce: String?
    fileprivate var appleFlowBlock: WKRPTCLAuthBlkBoolAccessData?
    fileprivate var appleFlowUsername: String?
    fileprivate var appleFlowPassword: String?
    fileprivate var appleFlowResultBlock: DNSPTCLResultBlock?

    // MARK: - Workers -
    public var wkrKeychain: WKRPTCLCache = WKRCrashCache()

    override open func configure() {
        self.utilityAccessDataLoad()
    }

    // MARK: - Internal Work Methods
    override open func intDoCheckAuth(using parameters: DNSDataDictionary,
                                      with progress: DNSPTCLProgressBlock?,
                                      and block: WKRPTCLAuthBlkBoolBoolAccessData?,
                                      then resultBlock: DNSPTCLResultBlock?) {
        let systemStateSystem = DNSAppConstants.Systems.auth
        let systemStateEndPoint = DNSAppConstants.Systems.Auth.EndPoints.checkAuth
        let systemStateSendDebug = DNSAppConstants.Systems.Auth.sendDebug

        var authorized = false
        let expired = false

        self.utilityGetIDToken { [weak self] result in
            guard let self else { return }
            if case .failure(let error) = result {
                self.utilityReportSystemFailure(sendDebug: systemStateSendDebug,
                                                debugString: error.localizedDescription,
                                                and: "???",
                                                for: systemStateSystem, and: systemStateEndPoint)
                block?(.failure(error))
                _ = resultBlock?(.failure(error))
                return
            }
            let (_, idToken) = try! result.get() // swiftlint:disable:this force_try
            self.accessData.accessToken = idToken
            self.utilityAccessDataSave()
            authorized = true
            self.utilityReportSystemSuccess(for: systemStateSystem, and: systemStateEndPoint)
            block?(.success((authorized, expired, self.accessData)))
            _ = resultBlock?(.completed)
        }
    }
    override open func intDoLinkAuth(from username: String,
                                     and password: String,
                                     using parameters: DNSDataDictionary,
                                     with progress: DNSPTCLProgressBlock?,
                                     and block: WKRPTCLAuthBlkBoolAccessData?,
                                     then resultBlock: DNSPTCLResultBlock?) {
        let systemStateSystem = DNSAppConstants.Systems.auth
        let systemStateEndPoint = DNSAppConstants.Systems.Auth.EndPoints.linkAuth
        let systemStateSendDebug = DNSAppConstants.Systems.Auth.sendDebug

        var authorized = false

        var parameters = parameters
        parameters["method"] = WKRFirebaseAuth.Method.apple
        intDoSignIn(from: username, and: password, using: parameters,
                    with: nil,
                    and: { [weak self] result in
            guard let self else { return }
            if case .failure(let error) = result {
                self.utilityReportSystemFailure(sendDebug: systemStateSendDebug,
                                                debugString: error.localizedDescription,
                                                and: "???",
                                                for: systemStateSystem, and: systemStateEndPoint)
                block?(.failure(error))
                _ = resultBlock?(.failure(error))
                return
            }
            if case .success((let authenticated, _)) = result {
                guard authenticated else {
                    let error = DNSError.Auth.unknown(.firebaseWorkers(self))
                    DNSCore.reportError(error)
                    self.utilityReportSystemFailure(sendDebug: systemStateSendDebug,
                                                    debugString: error.localizedDescription,
                                                    and: "???",
                                                    for: systemStateSystem, and: systemStateEndPoint)
                    block?(.failure(error))
                    _ = resultBlock?(.failure(error))
                    return
                }
                guard let currentUser = Auth.auth().currentUser else {
                    let error = DNSError.Auth.notFound(field: "user", value: "currentUser", .firebaseWorkers(self))
                    DNSCore.reportError(error)
                    self.utilityReportSystemFailure(sendDebug: systemStateSendDebug,
                                                    debugString: error.localizedDescription,
                                                    and: "???",
                                                    for: systemStateSystem, and: systemStateEndPoint)
                    block?(.failure(error))
                    _ = resultBlock?(.failure(error))
                    return
                }
                let emailCredential = EmailAuthProvider.credential(withEmail: username,
                                                                   password: password)
                currentUser.link(with: emailCredential) { [weak self] authResult, error in
                    guard let self else { return }
                    if let error {
                        DNSCore.reportError(error)
                        self.utilityReportSystemFailure(sendDebug: systemStateSendDebug,
                                                        debugString: error.localizedDescription,
                                                        and: "???",
                                                        for: systemStateSystem, and: systemStateEndPoint)
                        block?(.failure(error))
                        _ = resultBlock?(.failure(error))
                        return
                    }
                    self.utilityGetIDToken { [weak self] result in
                        guard let self else { return }
                        if case .failure(let error) = result {
                            self.utilityReportSystemFailure(sendDebug: systemStateSendDebug,
                                                            debugString: error.localizedDescription,
                                                            and: "???",
                                                            for: systemStateSystem, and: systemStateEndPoint)
                            block?(.failure(error))
                            _ = resultBlock?(.failure(error))
                            return
                        }
                        let (_, idToken) = try! result.get() // swiftlint:disable:this force_try
                        self.accessData.accessToken = idToken
                        self.utilityAccessDataSave()
                        authorized = true
                        self.utilityReportSystemSuccess(for: systemStateSystem, and: systemStateEndPoint)
                        block?(.success((authorized, self.accessData)))
                        _ = resultBlock?(.completed)
                    }
                }
            }
        }, then: resultBlock)
    }
    override open func intDoPasswordResetStart(from username: String?,
                                               using parameters: DNSDataDictionary,
                                               with progress: DNSPTCLProgressBlock?,
                                               and block: WKRPTCLAuthBlkVoid?,
                                               then resultBlock: DNSPTCLResultBlock?) {
        let systemStateSystem = DNSAppConstants.Systems.auth
        let systemStateEndPoint = DNSAppConstants.Systems.Auth.EndPoints.signIn
//        let systemStateSendDebug = DNSAppConstants.Systems.Auth.sendDebug

        self.utilityReportSystemSuccess(for: systemStateSystem, and: systemStateEndPoint)
        block?(.success)
        _ = resultBlock?(.completed)
    }
    override open func intDoSignIn(from username: String?,
                                   and password: String?,
                                   using parameters: DNSDataDictionary,
                                   with progress: DNSPTCLProgressBlock?,
                                   and block: WKRPTCLAuthBlkBoolAccessData?,
                                   then resultBlock: DNSPTCLResultBlock?) {
        let systemStateSystem = DNSAppConstants.Systems.auth
        let systemStateEndPoint = DNSAppConstants.Systems.Auth.EndPoints.signIn
        let systemStateSendDebug = DNSAppConstants.Systems.Auth.sendDebug

        self.utilityAccessDataClear()

        guard let method = parameters["method"] as? Method else {
            let error = DNSError.Auth.invalidParameters(parameters: ["method"], .firebaseWorkers(self))
            self.utilityReportSystemFailure(sendDebug: systemStateSendDebug,
                                            debugString: error.localizedDescription,
                                            and: "\(error.nsError.code)",
                                            for: systemStateSystem, and: systemStateEndPoint)
            block?(.failure(error))
            _ = resultBlock?(.failure(error))
            return
        }
        switch method {
        case .apple:
            self.utilitySignInWithAppleFlow(from: username,
                                            and: password,
                                            with: block,
                                            then: resultBlock)
        case .email:
            guard let username else {
                let error = DNSError.Auth.invalidParameters(parameters: ["username"], .firebaseWorkers(self))
                self.utilityReportSystemFailure(sendDebug: systemStateSendDebug,
                                                debugString: error.localizedDescription,
                                                and: "\(error.nsError.code)",
                                                for: systemStateSystem, and: systemStateEndPoint)
                block?(.failure(error))
                _ = resultBlock?(.failure(error))
                return
            }
            guard !username.isEmpty else {
                let error = DNSError.Auth.invalidParameters(parameters: ["username"], .firebaseWorkers(self))
                self.utilityReportSystemFailure(sendDebug: systemStateSendDebug,
                                                debugString: error.localizedDescription,
                                                and: "\(error.nsError.code)",
                                                for: systemStateSystem, and: systemStateEndPoint)
                block?(.failure(error))
                _ = resultBlock?(.failure(error))
                return
            }
            guard let password else {
                let error = DNSError.Auth.invalidParameters(parameters: ["password"], .firebaseWorkers(self))
                self.utilityReportSystemFailure(sendDebug: systemStateSendDebug,
                                                debugString: error.localizedDescription,
                                                and: "\(error.nsError.code)",
                                                for: systemStateSystem, and: systemStateEndPoint)
                block?(.failure(error))
                _ = resultBlock?(.failure(error))
                return
            }
            guard !password.isEmpty else {
                let error = DNSError.Auth.invalidParameters(parameters: ["password"], .firebaseWorkers(self))
                self.utilityReportSystemFailure(sendDebug: systemStateSendDebug,
                                                debugString: error.localizedDescription,
                                                and: "\(error.nsError.code)",
                                                for: systemStateSystem, and: systemStateEndPoint)
                block?(.failure(error))
                _ = resultBlock?(.failure(error))
                return
            }
            self.utilitySignInWithEmailFlow(from: username,
                                            and: password,
                                            with: block,
                                            then: resultBlock)
        default:
            let error = DNSError.Auth.invalidParameters(parameters: ["method"], .firebaseWorkers(self))
            self.utilityReportSystemFailure(sendDebug: systemStateSendDebug,
                                            debugString: error.localizedDescription,
                                            and: "\(error.nsError.code)",
                                            for: systemStateSystem, and: systemStateEndPoint)
            block?(.failure(error))
            _ = resultBlock?(.failure(error))
            return
        }
    }
    override open func intDoSignOut(using parameters: DNSDataDictionary,
                                    with progress: DNSPTCLProgressBlock?,
                                    and block: WKRPTCLAuthBlkVoid?,
                                    then resultBlock: DNSPTCLResultBlock?) {
        let systemStateSystem = DNSAppConstants.Systems.auth
        let systemStateEndPoint = DNSAppConstants.Systems.Auth.EndPoints.signOut
        let systemStateSendDebug = DNSAppConstants.Systems.Auth.sendDebug

        do {
            try Auth.auth().signOut()
        } catch let error as NSError {
            self.utilityReportSystemFailure(sendDebug: systemStateSendDebug,
                                            debugString: "Error signing out: \(error.localizedDescription)",
                                            and: "\(error.code)",
                                            for: systemStateSystem, and: systemStateEndPoint)
            block?(.failure(error))
            _ = resultBlock?(.failure(error))
            return
        }

        self.utilityAccessDataClear()

        self.utilityReportSystemSuccess(for: systemStateSystem, and: systemStateEndPoint)
        block?(.success)
        _ = resultBlock?(.completed)
    }
    override open func intDoSignUp(from user: DAOUser?,
                                   and password: String?,
                                   using parameters: DNSDataDictionary,
                                   with progress: DNSPTCLProgressBlock?,
                                   and block: WKRPTCLAuthBlkBoolAccessData?,
                                   then resultBlock: DNSPTCLResultBlock?) {
        let systemStateSystem = DNSAppConstants.Systems.auth
        let systemStateEndPoint = DNSAppConstants.Systems.Auth.EndPoints.signUp
        let systemStateSendDebug = DNSAppConstants.Systems.Auth.sendDebug

        guard let user else {
            let error = DNSError.Auth.invalidParameters(parameters: ["user"], .firebaseWorkers(self))
            self.utilityReportSystemFailure(sendDebug: systemStateSendDebug,
                                            debugString: error.localizedDescription,
                                            and: "\(error.nsError.code)",
                                            for: systemStateSystem, and: systemStateEndPoint)
            block?(.failure(error))
            _ = resultBlock?(.failure(error))
            return
        }
        guard let password else {
            let error = DNSError.Auth.invalidParameters(parameters: ["password"], .firebaseWorkers(self))
            self.utilityReportSystemFailure(sendDebug: systemStateSendDebug,
                                            debugString: error.localizedDescription,
                                            and: "\(error.nsError.code)",
                                            for: systemStateSystem, and: systemStateEndPoint)
            block?(.failure(error))
            _ = resultBlock?(.failure(error))
            return
        }
        guard !password.isEmpty else {
            let error = DNSError.Auth.invalidParameters(parameters: ["password"], .firebaseWorkers(self))
            self.utilityReportSystemFailure(sendDebug: systemStateSendDebug,
                                            debugString: error.localizedDescription,
                                            and: "\(error.nsError.code)",
                                            for: systemStateSystem, and: systemStateEndPoint)
            block?(.failure(error))
            _ = resultBlock?(.failure(error))
            return
        }
        Auth.auth().createUser(withEmail: user.email,
                               password: password) { [weak self] authResult, error in
            guard let self else { return }
            if let error {
                let error = self.utilityTranslateAuthError(AuthErrorCode.Code(rawValue: error._code),
                                                           with: user.email, and: error)
                self.utilityReportSystemFailure(sendDebug: systemStateSendDebug,
                                                debugString: error.localizedDescription,
                                                and: "???",
                                                for: systemStateSystem, and: systemStateEndPoint)
                block?(.failure(error))
                _ = resultBlock?(.failure(error))
                return
            }
            self.utilityGetIDToken { [weak self] result in
                guard let self else { return }
                if case .failure(let error) = result {
                    self.utilityReportSystemFailure(sendDebug: systemStateSendDebug,
                                                    debugString: error.localizedDescription,
                                                    and: "???",
                                                    for: systemStateSystem, and: systemStateEndPoint)
                    block?(.failure(error))
                    _ = resultBlock?(.failure(error))
                    return
                }
                let (currentUser, idToken) = try! result.get() // swiftlint:disable:this force_try
                // User is signed in to Firebase with Apple.
                let data = Self.AccessData()
                data.accessToken = idToken
                data.method = .email
                data.userId = currentUser.uid
                data.userEmail = user.email
                self.accessData = data
                self.utilityAccessDataSave()

                self.utilityReportSystemSuccess(for: systemStateSystem, and: systemStateEndPoint)
                block?(.success((true, self.accessData)))
                _ = resultBlock?(.completed)
            }
        }
    }

    // MARK: - ASAuthorizationControllerDelegate protocol methods -
    public func authorizationController(controller: ASAuthorizationController,
                                        didCompleteWithAuthorization authorization: ASAuthorization) {
        let systemStateSystem = DNSAppConstants.Systems.auth
        let systemStateEndPoint = DNSAppConstants.Systems.Auth.EndPoints.signIn
        let systemStateSendDebug = DNSAppConstants.Systems.Auth.sendDebug

        if let passwordCredential = authorization.credential as? ASPasswordCredential {
            // Get user data using an existing iCloud Keychain credential
            let appleUsername = passwordCredential.user
            let applePassword = passwordCredential.password
            // Write your code here
            print("Apple Username: \(appleUsername)")
            print("Apple Password: \(applePassword)")
        } else if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            let appleUserId = appleIDCredential.user
            let userName = appleIDCredential.fullName
            let userEmail = appleIDCredential.email ?? ""
            print("Apple User ID: \(appleUserId)")
            print("User Name: \(userName?.debugDescription ?? "<none>")")
            print("User Email: \(userEmail)")
            guard let nonce = appleFlowCurrentNonce else {
                let error = DNSError.Auth.invalidParameters(parameters: ["appleFlowCurrentNonce"],
                                                            .firebaseWorkers(self))
                self.utilityReportSystemFailure(sendDebug: systemStateSendDebug,
                                                debugString: error.localizedDescription,
                                                and: "\(error.nsError.code)",
                                                for: systemStateSystem, and: systemStateEndPoint)
                appleFlowBlock?(.failure(error))
                _ = appleFlowResultBlock?(.failure(error))
                return
            }
            guard let appleIDToken = appleIDCredential.identityToken else {
                let error = DNSError.Auth.notFound(field: "appleIDToken", value: "any", .firebaseWorkers(self))
                self.utilityReportSystemFailure(sendDebug: systemStateSendDebug,
                                                debugString: error.localizedDescription,
                                                and: "\(error.nsError.code)",
                                                for: systemStateSystem, and: systemStateEndPoint)
                appleFlowBlock?(.failure(error))
                _ = appleFlowResultBlock?(.failure(error))
                return
            }
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                let error = DNSError.Auth.invalidParameters(parameters: ["appleIDToken"], .firebaseWorkers(self))
                self.utilityReportSystemFailure(sendDebug: systemStateSendDebug,
                                                debugString: error.localizedDescription,
                                                and: "\(error.nsError.code)",
                                                for: systemStateSystem, and: systemStateEndPoint)
                appleFlowBlock?(.failure(error))
                _ = appleFlowResultBlock?(.failure(error))
                return
            }
            if userEmail.isEmpty {
                // Initialize a Firebase credential.
                let credential = OAuthProvider.credential(withProviderID: "apple.com",
                                                          idToken: idTokenString,
                                                          rawNonce: nonce)
                Auth.auth().signIn(with: credential) { [weak self] authResult, error in
                    guard let self else { return }
                    if let error {
                        self.utilityReportSystemFailure(sendDebug: systemStateSendDebug,
                                                        debugString: error.localizedDescription,
                                                        and: "???",
                                                        for: systemStateSystem, and: systemStateEndPoint)
                        self.appleFlowBlock?(.failure(error))
                        _ = self.appleFlowResultBlock?(.failure(error))
                        return
                    }
                    self.utilityGetIDToken { [weak self] result in
                        guard let self else { return }
                        if case .failure(let error) = result {
                            self.utilityReportSystemFailure(sendDebug: systemStateSendDebug,
                                                            debugString: error.localizedDescription,
                                                            and: "???",
                                                            for: systemStateSystem, and: systemStateEndPoint)
                            self.appleFlowBlock?(.failure(error))
                            _ = self.appleFlowResultBlock?(.failure(error))
                            return
                        }
                        let (currentUser, idToken) = try! result.get() // swiftlint:disable:this force_try
                        // User is signed in to Firebase with Apple.
                        let data = Self.AccessData()
                        data.accessToken = idToken
                        data.appleUserId = appleUserId
                        data.method = .apple
                        data.userId = currentUser.uid
                        data.userName = userName ?? self.accessData.userName
                        data.userEmail = userEmail
                        self.accessData = data
                        self.utilityAccessDataSave()
                        
                        self.utilityReportSystemSuccess(for: systemStateSystem, and: systemStateEndPoint)
                        self.appleFlowBlock?(.success((true, self.accessData)))
                        _ = self.appleFlowResultBlock?(.completed)
                    }
                }
                return
            }
            Auth.auth().fetchSignInMethods(forEmail: userEmail) { [weak self] methods, error in
                guard let self else { return }
                if let error {
                    let error = self.utilityTranslateAuthError(AuthErrorCode.Code(rawValue: error._code),
                                                               with: userEmail, and: error)
                    self.utilityReportSystemFailure(sendDebug: systemStateSendDebug,
                                                    debugString: error.localizedDescription,
                                                    and: "???",
                                                    for: systemStateSystem, and: systemStateEndPoint)
                    self.appleFlowBlock?(.failure(error))
                    _ = self.appleFlowResultBlock?(.failure(error))
                    return
                }
                let containsApple = methods?.contains(Method.apple.rawValue) ?? false
                let containsEmail = methods?.contains(Method.email.rawValue) ?? false
                if !containsApple && containsEmail {
                    self.intDoSignIn(from: self.appleFlowUsername, and: self.appleFlowPassword,
                                     using: [ "method": Method.email ],
                                     with: nil, and: { result in
                        if case .failure(let error) = result {
                            self.appleFlowBlock?(.failure(error))
                            _ = self.appleFlowResultBlock?(.failure(error))
                            return
                        }
                        guard let currentUser = Auth.auth().currentUser else {
                            let error = DNSError.Auth.notFound(field: "user", value: "currentUser", .firebaseWorkers(self))
                            self.appleFlowBlock?(.failure(error))
                            _ = self.appleFlowResultBlock?(.failure(error))
                            return
                        }
                        // Initialize a Firebase credential.
                        let credential = OAuthProvider.credential(withProviderID: "apple.com",
                                                                  idToken: idTokenString,
                                                                  rawNonce: nonce)
                        currentUser.link(with: credential) { [weak self] authResult, error in
                            guard let self else { return }
                            if let error {
                                self.utilityReportSystemFailure(sendDebug: systemStateSendDebug,
                                                                debugString: error.localizedDescription,
                                                                and: "???",
                                                                for: systemStateSystem, and: systemStateEndPoint)
                                self.appleFlowBlock?(.failure(error))
                                _ = self.appleFlowResultBlock?(.failure(error))
                                return
                            }
                            self.utilityGetIDToken { [weak self] result in
                                guard let self else { return }
                                if case .failure(let error) = result {
                                    self.utilityReportSystemFailure(sendDebug: systemStateSendDebug,
                                                                    debugString: error.localizedDescription,
                                                                    and: "???",
                                                                    for: systemStateSystem, and: systemStateEndPoint)
                                    self.appleFlowBlock?(.failure(error))
                                    _ = self.appleFlowResultBlock?(.failure(error))
                                    return
                                }
                                let (currentUser, idToken) = try! result.get() // swiftlint:disable:this force_try
                                // User is signed in to Firebase with Apple.
                                let data = Self.AccessData()
                                data.accessToken = idToken
                                data.appleUserId = appleUserId
                                data.method = .apple
                                data.userId = currentUser.uid
                                data.userName = userName ?? self.accessData.userName
                                data.userEmail = userEmail
                                self.accessData = data
                                self.utilityAccessDataSave()
                                
                                self.utilityReportSystemSuccess(for: systemStateSystem, and: systemStateEndPoint)
                                self.appleFlowBlock?(.success((true, self.accessData)))
                                _ = self.appleFlowResultBlock?(.completed)
                            }
                        }
                    },
                                     then: nil)
                    return
                }
                // Initialize a Firebase credential.
                let credential = OAuthProvider.credential(withProviderID: "apple.com",
                                                          idToken: idTokenString,
                                                          rawNonce: nonce)
                // Sign in with Firebase.
                Auth.auth().signIn(with: credential) { [weak self] authResult, error in
                    guard let self else { return }
                    if let error {
                        let error = self.utilityTranslateAuthError(AuthErrorCode.Code(rawValue: error._code),
                                                                   with: userEmail, and: error)
                        self.utilityReportSystemFailure(sendDebug: systemStateSendDebug,
                                                        debugString: error.localizedDescription,
                                                        and: "???",
                                                        for: systemStateSystem, and: systemStateEndPoint)
                        self.appleFlowBlock?(.failure(error))
                        _ = self.appleFlowResultBlock?(.failure(error))
                        return
                    }
                    self.utilityGetIDToken { [weak self] result in
                        guard let self else { return }
                        if case .failure(let error) = result {
                            self.utilityReportSystemFailure(sendDebug: systemStateSendDebug,
                                                            debugString: error.localizedDescription,
                                                            and: "???",
                                                            for: systemStateSystem, and: systemStateEndPoint)
                            self.appleFlowBlock?(.failure(error))
                            _ = self.appleFlowResultBlock?(.failure(error))
                            return
                        }
                        let (currentUser, idToken) = try! result.get() // swiftlint:disable:this force_try
                        // User is signed in to Firebase with Apple.
                        let data = Self.AccessData()
                        data.accessToken = idToken
                        data.appleUserId = appleUserId
                        data.method = .apple
                        data.userId = currentUser.uid
                        data.userName = userName ?? self.accessData.userName
                        data.userEmail = userEmail
                        self.accessData = data
                        self.utilityAccessDataSave()
                        
                        self.utilityReportSystemSuccess(for: systemStateSystem, and: systemStateEndPoint)
                        self.appleFlowBlock?(.success((true, self.accessData)))
                        _ = self.appleFlowResultBlock?(.completed)
                    }
                }
            }
        }
    }
    public func authorizationController(controller: ASAuthorizationController,
                                        didCompleteWithError error: Error) {
        let systemStateSystem = DNSAppConstants.Systems.auth
        let systemStateEndPoint = DNSAppConstants.Systems.Auth.EndPoints.signIn
        let systemStateSendDebug = DNSAppConstants.Systems.Auth.sendDebug

        self.utilityReportSystemFailure(sendDebug: systemStateSendDebug,
                                        debugString: "Error signing in: \(error.localizedDescription)",
                                        and: "???",
                                        for: systemStateSystem, and: systemStateEndPoint)
        appleFlowBlock?(.failure(error))
        _ = appleFlowResultBlock?(.failure(error))
    }
    
    // MARK: - ASAuthorizationControllerPresentationContextProviding protocol methods -
    public func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        guard let firstScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            fatalError("No Scene Found")
        }
        guard let firstWindow = firstScene.windows.first else {
            fatalError("No Window Found")
        }
        return firstWindow
    }

    // MARK: - Utility methods -
    func utilityAccessDataClear() {
        let data = Self.AccessData()
        self.accessData = data
        self.utilityAccessDataSave()
    }
    func utilityAccessDataLoad() {
        let envelope = DNSSubscriberEnvelope()
        let subscriber = self.wkrKeychain.doReadObject(for: DNSAppConstants.Auth.accessData)
            .sink(receiveCompletion: { _ in
            }) { value in
                guard let value = value as? Data else { return }
                do {
                    self.accessData = try JSONDecoder().decode(AccessData.self, from: value)
                } catch {
                    print(error.localizedDescription)
                }
                envelope.close()
            }
        envelope.open(with: subscriber)
    }
    func utilityAccessDataSave() {
        do {
            let data = try JSONEncoder().encode(self.accessData)
            let envelope = DNSSubscriberEnvelope()
            let subscriber = self.wkrKeychain.doUpdate(object: data,
                                                       for: DNSAppConstants.Auth.accessData)
                .replaceError(with: ())
                .sink { _ in
                    envelope.close()
                }
            envelope.open(with: subscriber)
        } catch {
            print(error.localizedDescription)
        }
    }
    // Adapted from https://auth0.com/docs/api-auth/tutorials/nonce#generate-a-cryptographically-random-nonce
    private func utilityRandomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length

        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError(
                        "Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)"
                    )
                }
                return random
            }
            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        return result
    }
    private func utilitySha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()
        return hashString
    }
    func utilitySignInWithAppleFlow(from username: String?,
                                    and password: String?,
                                    with block: WKRPTCLAuthBlkBoolAccessData?,
                                    then resultBlock: DNSPTCLResultBlock?) {
        let nonce = utilityRandomNonceString()
        appleFlowCurrentNonce = nonce
        appleFlowBlock = block
        appleFlowUsername = username
        appleFlowPassword = password
        appleFlowResultBlock = resultBlock

        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = utilitySha256(nonce)

        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    func utilityGetIDToken(with block: WKRFirebaseAuthBlkUserString?) {
        guard let currentUser = Auth.auth().currentUser else {
            let error = DNSError.Auth.notFound(field: "user", value: "currentUser", .firebaseWorkers(self))
            block?(.failure(error))
            return
        }
        currentUser.getIDToken { idToken, error in
            if let error {
                block?(.failure(error))
                return
            }
            guard let idToken else {
                let error = DNSError.Auth.notFound(field: "idToken", value: "currentToken", .firebaseWorkers(self))
                block?(.failure(error))
                return
            }
            block?(.success((currentUser, idToken)))
        }
    }
    func utilitySignInWithEmailFlow(from username: String,
                                    and password: String,
                                    with block: WKRPTCLAuthBlkBoolAccessData?,
                                    then resultBlock: DNSPTCLResultBlock?) {
        let systemStateSystem = DNSAppConstants.Systems.auth
        let systemStateEndPoint = DNSAppConstants.Systems.Auth.EndPoints.signIn
        let systemStateSendDebug = DNSAppConstants.Systems.Auth.sendDebug

        Auth.auth().signIn(withEmail: username, password: password) { [weak self] authResult, error in
            guard let self else { return }
            if let error {
                let error = self.utilityTranslateAuthError(AuthErrorCode.Code(rawValue: error._code),
                                                           with: username, and: error)
                self.utilityReportSystemFailure(sendDebug: systemStateSendDebug,
                                                debugString: error.localizedDescription,
                                                and: "???",
                                                for: systemStateSystem, and: systemStateEndPoint)
                block?(.failure(error))
                _ = resultBlock?(.failure(error))
                return
            }
            self.utilityGetIDToken { [weak self] result in
                guard let self else { return }
                if case .failure(let error) = result {
                    self.utilityReportSystemFailure(sendDebug: systemStateSendDebug,
                                                    debugString: error.localizedDescription,
                                                    and: "???",
                                                    for: systemStateSystem, and: systemStateEndPoint)
                    block?(.failure(error))
                    _ = resultBlock?(.failure(error))
                    return
                }
                let (currentUser, idToken) = try! result.get() // swiftlint:disable:this force_try
                // User is signed in to Firebase with Apple.
                let data = Self.AccessData()
                data.accessToken = idToken
                data.method = .email
                data.userId = currentUser.uid
                data.userEmail = username
                self.accessData = data
                self.utilityAccessDataSave()

                self.utilityReportSystemSuccess(for: systemStateSystem, and: systemStateEndPoint)
                block?(.success((true, self.accessData)))
                _ = resultBlock?(.completed)
            }
        }
    }
    func utilityTranslateAuthError(_ authError: AuthErrorCode.Code?,
                                   with email: String,
                                   and error: Error) -> DNSError {
        guard let authError else {
            return DNSError.Auth.unknown(.firebaseWorkers(self))
        }
        var retError: DNSError
        switch authError {
        case .emailAlreadyInUse, .accountExistsWithDifferentCredential, .providerAlreadyLinked,
                .credentialAlreadyInUse:
            retError = DNSError.Auth.existingAccount(.firebaseWorkers(self))
        case .invalidCredential:
            retError = DNSError.NetworkBase.forbidden(.firebaseWorkers(self))
        case .userDisabled, .operationNotAllowed:
            retError = DNSError.Auth.lockedOut(.firebaseWorkers(self))
        case .invalidEmail, .missingEmail:
            retError = DNSError.Auth.invalidParameters(parameters: ["email"], .firebaseWorkers(self))
        case .wrongPassword, .tooManyRequests, .invalidUserToken, .userTokenExpired, .invalidAPIKey,
                .userMismatch, .appNotAuthorized:
            retError = DNSError.NetworkBase.unauthorized(.firebaseWorkers(self))
        case .userNotFound:
            retError = DNSError.Auth.notFound(field: "user", value: email, .firebaseWorkers(self))
        case .requiresRecentLogin:
            retError = DNSError.NetworkBase.forbidden(.firebaseWorkers(self))
        case .noSuchProvider:
            retError = DNSError.Auth.failure(error: error, .firebaseWorkers(self))
        case .networkError:
            let nsError = error as NSError
            let underlyingError = nsError.userInfo[NSUnderlyingErrorKey] as? Error ?? error
            retError = DNSError.NetworkBase.networkError(error: underlyingError, .firebaseWorkers(self))
        case .weakPassword:
            retError = DNSError.Auth.invalidParameters(parameters: ["password"], .firebaseWorkers(self))
        default:
            retError = DNSError.NetworkBase.lowerError(error: error, .firebaseWorkers(self))
        }
        return retError
    }
}
