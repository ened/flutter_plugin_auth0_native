@JS('auth0')
library auth0;

import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:js/js.dart';

@JS('auth0Initialize')
external auth0Initialize(clientId, domain);

@JS('isAuthenticated')
external isAuthenticated();

@JS('databaseLogin')
external databaseLogin();

@JS('passwordlessWithSMS')
external passwordlessWithSMS();

@JS('loginWithPhoneNumber')
external loginWithPhoneNumber();

@JS('passwordlessWithEmail')
external passwordlessWithEmail();

@JS('loginWithEmail')
external loginWithEmail();

class Auth0NativePlugin {
  static void registerWith(Registrar registrar) {
    final MethodChannel channel = MethodChannel('asia.ivity.flutter/auth0_native/methods',
        const StandardMethodCodec(), registrar.messenger);
    final Auth0NativePlugin instance = Auth0NativePlugin();
    channel.setMethodCallHandler(instance.handleMethodCall);
  }

  Future<dynamic> handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case "initialize":
        handleInitialize(call);
        break;
      case "login":
        handleLogin(call);
        break;
      case "logout":
        handleLogout(call);
        break;
      case "getCredentials":
        handleGetCredentials();
        break;
      case "hasCredentials":
        handleHasCredentials();
        break;
      case "passwordlessWithSMS":
        handlePasswordlessWithSMS(call);
        break;
      case "loginWithPhoneNumber":
        handleLoginWithPhoneNumber(call);
        break;
      case "passwordlessWithEmail":
        handlePasswordlessWithEmail(call);
        break;
      case "loginWithEmail":
        handleLoginWithEmail(call);
        break;
    }
  }

  handleInitialize(call) {
    auth0Initialize(call.arguments['clientId'], call.arguments['domain']);
  }

  handleLogin(call) {
    databaseLogin();
  }

  handleLogout(call) {
    logOut();
  }

  handleGetCredentials() {}

  handleHasCredentials() {
    isAuthenticated();
  }

  handlePasswordlessWithSMS(call) {}

  handleLoginWithPhoneNumber(call) {}

  handlePasswordlessWithEmail(call) {}

  handleLoginWithEmail(call) {}

  result(FlutterMethodNotImplemented) {}
}
