import Auth0
import AuthenticationServices
import Flutter
import UIKit

public class SwiftAuth0NativePlugin: NSObject, FlutterPlugin {
    private var credentialsEventSink: FlutterEventSink? = nil
    
    private var loggingEnabled = false
    private var credentialsManager: NotifyingCredentialsManager? = nil
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "asia.ivity.flutter/auth0_native/methods", binaryMessenger: registrar.messenger())
        let credentialsEventChannel = FlutterEventChannel(name: "asia.ivity.flutter/auth0_native/credentials", binaryMessenger: registrar.messenger())
        
        let instance = SwiftAuth0NativePlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
        
        credentialsEventChannel.setStreamHandler(instance)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "initialize":
            handleInitialize(call, result)
            break
        case "login":
            handleLogin(call, result)
            break
        case "logout":
            handleLogout(call, result)
            break
        case "hasCredentials":
            handleHasCredentials(result)
            break
        case "passwordlessWithSMS":
            handlePasswordlessWithSMS(call, result)
            break
        case "loginWithPhoneNumber":
            handleLoginWithPhoneNumber(call, result)
            break
        case "passwordlessWithEmail":
            handlePasswordlessWithEmail(call, result)
            break
        case "loginWithEmail":
            handleLoginWithEmail(call, result)
            break
        case "signInWithApple":
            if #available(iOS 13.0, *) {
                handleSignInWithApple(call, result)
            } else {
                result(FlutterError(code: "unavailable", message: nil, details: nil))
            }
            break
        default:
            result(FlutterMethodNotImplemented)
            break
        }
    }
    
    private func handleInitialize(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        guard let map: [String: Any] = call.arguments as? [String:Any] else {
            result(FlutterError(code: "invalid-params", message: nil, details: nil))
            return
        }
        
        if let tmp = map["loggingEnabled"] as? Bool {
            self.loggingEnabled = tmp
        }
        
        self.credentialsManager = NotifyingCredentialsManager(
            authentication: Auth0.authentication(),
            listener: self
        )
        
        result(nil)
    }
    
    private func handleLogin(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        guard let map: [String: Any] = call.arguments as? [String:Any] else {
            result(FlutterError(code: "invalid-params", message: nil, details: nil))
            return
        }
        
        var webAuth = Auth0.webAuth().logging(enabled: loggingEnabled)
        
        if let audience = map["audience"] as? String {
            webAuth = webAuth.audience(audience)
        }
        
        if let connection = map["connection"] as? String {
            webAuth = webAuth.connection(connection)
        }
        
        if let scope = map["scope"] as? String {
            webAuth = webAuth.scope(scope)
        }

        webAuth.start { (auth0Result) in
            switch auth0Result {
            case .success(result: let c):
                self.credentialsManager?.store(credentials: c)
                result(mapCredentials(c))
                break
            case .failure(error: let e):
                result(mapError(e))
                break
            }
        }
    }
    
    private func handleLogout(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        guard let map: [String: Any] = call.arguments as? [String:Any] else {
            result(FlutterError(code: "invalid-params", message: nil, details: nil))
            return
        }
        
        var webAuth = Auth0.webAuth().logging(enabled: loggingEnabled)
        
        if let audience = map["audience"] as? String {
            webAuth = webAuth.audience(audience)
        }
        
        webAuth.clearSession(federated: true) { (successful) in
            self.credentialsManager?.clear()
            result(nil)
        }
    }
    
    private func handleHasCredentials(_ result: @escaping FlutterResult) {
        result(credentialsManager?.hasValid() ?? false)
    }
    
    private func handlePasswordlessWithSMS(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        guard let map: [String: Any] = call.arguments as? [String:Any] else {
            result(FlutterError(code: "invalid-params", message: nil, details: nil))
            return
        }
        
        guard let phone = map["phone"] as? String,
            let passwordlessType = parsePasswordlessType(map["type"] as? String),
            let connection = map["connection"] as? String else {
                result(FlutterError(code: "invalid-params", message: nil, details: nil))
                return
        }
        
        Auth0.authentication()
            .logging(enabled: self.loggingEnabled)
            .startPasswordless(phoneNumber: phone, type: passwordlessType, connection: connection)
            .start { (auth0Result) in
                switch auth0Result {
                case .success(result: _):
                    result(nil)
                case .failure(error: let error):
                    result(mapError(error))
                }
        }
    }
    
    private func handleLoginWithPhoneNumber(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        guard let map: [String: Any] = call.arguments as? [String:Any] else {
            result(FlutterError(code: "invalid-params", message: nil, details: nil))
            return
        }
        
        guard let phone = map["phone"] as? String,
            let code = map["code"] as? String else {
                result(FlutterError(code: "invalid-params", message: nil, details: nil))
                return
        }
        
        let audience = map["audience"] as? String
        let scope = map["scope"] as? String
        let parameters = map["parameters"] as? [String:Any] ?? [:]
        
        Auth0.authentication()
            .logging(enabled: self.loggingEnabled)
            .login(phoneNumber: phone, code: code, audience: audience, scope: scope, parameters: parameters)
            .start { (auth0Result) in
                switch auth0Result {
                case .success(result: let credentials):
                    self.credentialsManager?.store(credentials: credentials)
                    result(mapCredentials(credentials))
                case .failure(error: let error):
                    result(mapError(error))
                }
        }
    }
    
    private func handlePasswordlessWithEmail(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        guard let map: [String: Any] = call.arguments as? [String:Any] else {
            result(FlutterError(code: "invalid-params", message: nil, details: nil))
            return
        }
        
        guard let email = map["email"] as? String,
            let passwordlessType = parsePasswordlessType(map["type"] as? String),
            let connection = map["connection"] as? String else {
                result(FlutterError(code: "invalid-params", message: nil, details: nil))
                return
        }
        
        let parameters = map["parameters"] as? [String:Any] ?? [:]
        
        Auth0.authentication()
            .logging(enabled: self.loggingEnabled)
            .startPasswordless(email: email, type: passwordlessType, connection: connection, parameters: parameters)
            .start { (auth0Result) in
                switch auth0Result {
                case .success(result: _):
                    result(nil)
                case .failure(error: let error):
                    result(mapError(error))
                }
        }
    }
    
    private func handleLoginWithEmail(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        guard let map: [String: Any] = call.arguments as? [String:Any] else {
            result(FlutterError(code: "invalid-params", message: nil, details: nil))
            return
        }
        
        guard let email = map["email"] as? String,
            let code = map["code"] as? String else {
                result(FlutterError(code: "invalid-params", message: nil, details: nil))
                return
        }
        
        let audience = map["audience"] as? String
        let scope = map["scope"] as? String
        let parameters = map["scope"] as? [String:Any] ?? [:]
        
        Auth0.authentication()
            .logging(enabled: self.loggingEnabled)
            .login(email: email, code: code, audience: audience, scope: scope, parameters: parameters)
            .start { (auth0Result) in
                switch auth0Result {
                case .success(result: let credentials):
                    self.credentialsManager?.store(credentials: credentials)
                    result(mapCredentials(credentials))
                case .failure(error: let error):
                    result(mapError(error))
                }
        }
    }
    
    private var siwaCall: FlutterMethodCall? = nil
    private var siwaResult: FlutterResult? = nil
    
    @available(iOS 13.0, *)
    private func handleSignInWithApple(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        guard let _ : [String: Any] = call.arguments as? [String:Any] else {
            result(FlutterError(code: "invalid-params", message: nil, details: nil))
            return
        }
        
        siwaCall = call
        siwaResult = result
        
        // Create the authorization request
        let request = ASAuthorizationAppleIDProvider().createRequest()
        
        // Set scopes
        request.requestedScopes = [.email, .fullName]
        
        // Setup a controller to display the authorization flow
        let controller = ASAuthorizationController(authorizationRequests: [request])
        
        // Set delegates to handle the flow response.
        controller.delegate = self
        //        controller.presentationContextProvider = self
        
        // Action
        controller.performRequests()
    }
    
    public func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return Auth0.resumeAuth(url, options: options)
    }
}

@available(iOS 13.0, *)
extension SwiftAuth0NativePlugin : ASAuthorizationControllerDelegate {
    public func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        guard let call = siwaCall, let result = siwaResult else {
            // Nothing we can do.
            return
        }
        
        guard let map: [String: Any] = call.arguments as? [String:Any] else {
            result(FlutterError(code: "invalid-params", message: nil, details: nil))
            return
        }
        
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
            let authorizationCode = appleIDCredential.authorizationCode,
            let authCode = String(data: authorizationCode, encoding: .utf8) else {
                result(FlutterError(code: "apple-login", message: "", details: ""))
                return
        }
        
        let audience = map["audience"] as? String
        let scope = map["scope"] as? String
        
        // Auth0 Token Exchange
        Auth0
            .authentication()
            .login(appleAuthorizationCode: authCode, fullName: appleIDCredential.fullName, scope: scope, audience: audience)
            .start { result in
                switch result {
                case .success(let credentials):
                    self.credentialsManager?.store(credentials: credentials)
                    self.siwaResult?(mapCredentials(credentials))
                case .failure(let error):
                    self.siwaResult?(mapError(error))
                }
                self.siwaResult = nil
        }
    }
    
    // Handle authorization failure
    public func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        self.siwaResult?(mapError(error))
        self.siwaResult = nil
    }
}

extension SwiftAuth0NativePlugin : FlutterStreamHandler {
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        self.credentialsEventSink = events
        
        if let cm = self.credentialsManager {
            cm.credentials(withScope: nil) { (error, credentials) in
                events(mapCredentials(credentials))
            }
        }
        
        return nil
    }
    
    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        self.credentialsEventSink = nil
        return nil
    }
}

extension SwiftAuth0NativePlugin : OnCredentialsChangedListener {
    func onCredentialsChanged(credentials: Credentials?) {
        self.credentialsEventSink?(mapCredentials(credentials))
    }
}


