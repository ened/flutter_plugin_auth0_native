//
//  Mappers.swift
//  Auth0
//
//  Created by Sebastian Roth on 08/04/2020.
//

import Auth0
import Foundation

func mapCredentials(_ credentials: Credentials?) -> [String:Any]? {
    guard let credentials = credentials else {
        return nil
    }
    
    var res: [String:Any] = [:]
    
    res["accessToken"] = credentials.accessToken
    res["idToken"] = credentials.idToken
    res["refreshToken"] = credentials.refreshToken
    res["scope"] = credentials.scope
    res["type"] = credentials.tokenType
    
    if let expiresAt = credentials.expiresIn {
        res["expiresAt"] = expiresAt.timeIntervalSince1970 * 1000
    } else {
        res["expiresAt"] = nil
    }
    
    return res
}

func parsePasswordlessType(_ string: String?) -> PasswordlessType? {
    switch string {
    case "code":
        return .Code
    case "android_link":
        return .AndroidLink
    case "web_link":
        return .WebLink
    case "ios_link":
        return .iOSLink
    default:
        return nil
    }
}

func mapError(_ error: Error) -> FlutterError {
    return FlutterError(code: "invalid-api", message: "\(error)", details: nil)
}
