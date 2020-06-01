import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Refer to Auth0 documentation for details.
enum PasswordlessType {
  code,
  androidLink,
  webLink,
}

/// Singleton class to handle all auth0 related tasks.
///
/// The class uses the native Auth0 SDKs under the hood. Refer to the detailed
/// documentation at https://www.auth0.com for details.
class Auth0Native {
  static Auth0Native _instance;

  /// Default constructor which initializes or returns a singleton instance.
  ///
  /// You must call [initialize] before calling any other methods.
  factory Auth0Native() {
    return _instance ??= Auth0Native.private(
      const MethodChannel('asia.ivity.flutter/auth0_native/methods'),
      const EventChannel('asia.ivity.flutter/auth0_native/credentials'),
    );
  }

  @visibleForTesting
  Auth0Native.private(this._methodChannel, EventChannel eventChannel)
      : observeCredentials = eventChannel.receiveBroadcastStream().map((event) {
          if (event != null) {
            return Map<String, dynamic>.from(event);
          } else {
            return null;
          }
        });

  final MethodChannel _methodChannel;

  /// Retrieve the current login credentials.
  Future<Map<String, dynamic>> get currentCredentials {
    return _methodChannel.invokeMapMethod<String, dynamic>('getCredentials');
  }

  /// Observe the credentials as they pass through the system.
  final Stream<Map<String, dynamic>> observeCredentials;

  /// Utility method which informs whether credentials are available (e.g. the
  /// user has logged in).
  Future<bool> hasCredentials() async {
    return await _methodChannel.invokeMethod<bool>('hasCredentials');
  }

  /// Required to initialize the SDK once.
  Future<void> initialize(
    String clientId,
    String domain, {
    bool oidc = false,
    bool loggingEnabled = true,
  }) async {
    await _methodChannel.invokeMethod('initialize', {
      'clientId': clientId,
      'domain': domain,
      'oidc': oidc,
      'loggingEnabled': loggingEnabled,
    });
  }

  /// Starts web auth login with the specified parameters.
  Future<Map<String, dynamic>> login({
    String audience,
    String scheme,

    /// Will default to `null` which shows the login page.
    String connection,
    String scope,
    Map<String, String> parameters,
  }) async {
    return await _methodChannel.invokeMapMethod<String, dynamic>('login', {
      'audience': audience,
      'connection': connection,
      'scheme': scheme,
      'scope': scope,
      'parameters': parameters,
    });
  }

  /// Logs the current user out.
  Future<void> logout({
    String audience,
    String scheme,
  }) async {
    await _methodChannel.invokeMethod<void>('logout', {
      'audience': audience,
      'scheme': scheme,
    });
  }

  /// Initiates a passwordless login flow by sending a SMS with a OTP.
  ///
  /// Call [loginWithPhoneNumber] afterwards to confirm the login.
  Future<void> passwordlessWithSMS(
    String phone,
    PasswordlessType type, {
    String connection,
  }) async {
    await _methodChannel.invokeMethod<void>('passwordlessWithSMS', {
      'phone': phone,
      'type': _mapPasswordlessType(type),
      'connection': connection,
    });
  }

  /// Logs in the user by phone & OTP as created in [passwordlessWithSMS].
  Future<Map<String, dynamic>> loginWithPhoneNumber(
    String phone,
    String code, {
    String connection,
    String audience,
    String scope,
    String device,
    Map<String, dynamic> parameters,
  }) async {
    return await _methodChannel
        .invokeMapMethod<String, dynamic>('loginWithPhoneNumber', {
      'phone': phone,
      'code': code,
      'connection': connection,
      'audience': audience,
      'scope': scope,
      'device': device,
      'parameters': parameters,
    });
  }

  /// Initiates a passwordless login flow by sending a eMail with a OTP.
  ///
  /// Call [loginWithEmail] afterwards to confirm the login.
  Future<void> passwordlessWithEmail(
    String email,
    PasswordlessType type, {
    String connection,
  }) async {
    await _methodChannel.invokeMethod<void>('passwordlessWithEmail', {
      'email': email,
      'type': _mapPasswordlessType(type),
      'connection': connection,
    });
  }

  /// Logs in the user by email & OTP as created in [passwordlessWithEmail].
  Future<Map<String, dynamic>> loginWithEmail(
    String email,
    String code, {
    String connection,
    String audience,
    String scope,
    String device,
    Map<String, dynamic> parameters,
  }) async {
    return await _methodChannel
        .invokeMapMethod<String, dynamic>('loginWithEmail', {
      'email': email,
      'code': code,
      'connection': connection,
      'audience': audience,
      'scope': scope,
      'device': device,
      'parameters': parameters,
    });
  }

  /// Attempts a native login via Sign in With Apple. (iOS only).
  Future<Map<String, dynamic>> signInWithApple({
    String audience,
    String scope,
  }) async {
    return await _methodChannel
        .invokeMapMethod<String, dynamic>('signInWithApple', {
      'audience': audience,
      'scope': scope,
    });
  }
}

String _mapPasswordlessType(PasswordlessType type) {
  switch (type) {
    case PasswordlessType.code:
      return 'code';
    case PasswordlessType.androidLink:
      return 'android_link';
    case PasswordlessType.webLink:
      return 'web_link';
  }

  throw 'Unknown passwordless type: $type';
}
