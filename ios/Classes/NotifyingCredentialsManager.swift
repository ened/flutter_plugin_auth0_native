//
//  NotifyingCredentialsManager.swift
//  Auth0
//
//  Created by Sebastian Roth on 08/04/2020.
//

import Auth0
import Foundation

protocol OnCredentialsChangedListener {
    func onCredentialsChanged(credentials: Credentials?)
}

struct NotifyingCredentialsManager {
    let credentialsManager: CredentialsManager
    
    let onCredentialsChangedListener: OnCredentialsChangedListener
    
    init(authentication: Authentication, listener: OnCredentialsChangedListener) {
        self.credentialsManager = CredentialsManager(authentication: authentication)
        self.onCredentialsChangedListener = listener
    }
    
    /// Store credentials instance in keychain
    ///
    /// - Parameter credentials: credentials instance to store
    /// - Returns: if credentials were stored
    @discardableResult
    public func store(credentials: Credentials) -> Bool {
        self.onCredentialsChangedListener.onCredentialsChanged(credentials: credentials)
        return credentialsManager.store(credentials: credentials)
    }
    
    /// Clear credentials stored in keychain
    ///
    /// - Returns: if credentials were removed
    @discardableResult
    public func clear() -> Bool {
        self.onCredentialsChangedListener.onCredentialsChanged(credentials: nil)
        return credentialsManager.clear()
    }
    
    /// Checks if a non-expired set of credentials are stored
    ///
    /// - Returns: if there are valid and non-expired credentials stored
    public func hasValid() -> Bool {
        return credentialsManager.hasValid()
    }
    
    /// Retrieve credentials from keychain and yield new credentials using refreshToken if accessToken has expired
    /// otherwise the retrieved credentails will be returned as they have not expired. Renewed credentials will be
    /// stored in the keychain.
    ///
    ///
    /// ```
    /// credentialsManager.credentials {
    ///    guard $0 == nil else { return }
    ///    print($1)
    /// }
    /// ```
    ///
    /// - Parameters:
    ///   - scope: scopes to request for the new tokens. By default is nil which will ask for the same ones requested during original Auth
    ///   - callback: callback with the user's credentials or the cause of the error.
    /// - Important: This method only works for a refresh token obtained after auth with OAuth 2.0 API Authorization.
    /// - Note: [Auth0 Refresh Tokens Docs](https://auth0.com/docs/tokens/refresh-token)
    public func credentials(withScope scope: String? = nil, callback: @escaping (CredentialsManagerError?, Credentials?) -> Void) {
        return credentialsManager.credentials(withScope: scope, callback: callback)
    }
}
