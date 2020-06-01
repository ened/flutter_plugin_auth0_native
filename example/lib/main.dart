import 'dart:io';

import 'package:auth0_native_example/example_app.dart';
import 'package:flutter/material.dart';

import 'package:auth0_native/auth0_native.dart';
import 'package:native_resource/native_resource.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

const String audience = '';
const String demoEmail = '';
const String demoPhone = '';

final List<String> connections = <String>[
  'google-oauth2',
  'amazon',
  'facebook',
];

const String emailConnection = 'email';
const String smsConnection = 'sms';

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: FutureBuilder<dynamic>(
        future: readConfig().then((config) {
          /// Need to initialize the Auth0 SDK first.
          return Auth0Native()
              .initialize(
                config['clientId'],
                config['domain'],
                oidc: true,
                loggingEnabled: true,
              )
              .then((value) => config);
        }),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Scaffold(
              body: Center(child: Text('error: ${snapshot.error}')),
            );
          }
          if (!snapshot.hasData) {
            return Scaffold(
              body: Center(child: Text('Getting ready')),
            );
          }

          return ExampleApp(
            audience: audience,
            scheme: snapshot.data['scheme'],
            connections: connections,
            emailConnection: emailConnection,
            smsConnection: smsConnection,
            initialEmail: demoEmail,
            initialPhone: demoPhone,
          );
        },
      ),
    );
  }

  Future<Map<String, String>> readConfig() async {
    return {
      'clientId': await NativeResource().read(
        androidResourceName: 'com_auth0_client_id',
        iosPlistKey: 'ClientId',
        iosPlistFile: 'Auth0',
      ),
      'domain': await NativeResource().read(
        androidResourceName: 'com_auth0_domain',
        iosPlistKey: 'Domain',
        iosPlistFile: 'Auth0',
      ),
      'scheme': Platform.isAndroid
          ? await NativeResource().read(
              androidResourceName: 'com_auth0_scheme',
              iosPlistKey: null,
            )
          : '',
    };
  }
}
