import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

enum PasswordlessType {
  code,
  androidLink,
  webLink,
}

class Auth0Native {
  static Auth0Native _instance;

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

  /// Observe the credentials as they pass through the system.
  final Stream<Map<String, dynamic>> observeCredentials;

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

  Future<void> logout({
    String audience,
    String scheme,
  }) async {
    await _methodChannel.invokeMethod<void>('logout', {
      'audience': audience,
      'scheme': scheme,
    });
  }

  Future<bool> hasCredentials() async {
    return await _methodChannel.invokeMethod<bool>('hasCredentials');
  }

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

  Future<Map<String, dynamic>> loginWithPhoneNumber(
    String phone,
    String code, {
    String connection,
    String audience,
    String scope,
    Map<String, dynamic> parameters,
  }) async {
    return await _methodChannel
        .invokeMapMethod<String, dynamic>('loginWithPhoneNumber', {
      'phone': phone,
      'code': code,
      'connection': connection,
      'audience': audience,
      'scope': scope,
      'parameters': parameters,
    });
  }

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

  Future<Map<String, dynamic>> loginWithEmail(
    String email,
    String code, {
    String connection,
    String audience,
    String scope,
    Map<String, dynamic> parameters,
  }) async {
    return await _methodChannel
        .invokeMapMethod<String, dynamic>('loginWithEmail', {
      'email': email,
      'code': code,
      'connection': connection,
      'audience': audience,
      'scope': scope,
      'parameters': parameters,
    });
  }

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
