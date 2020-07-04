# auth0_native

Auth0 integration for Flutter, using the official Auth0 iOS & Android SDKs.

This plugin allows for a integration of the Auth0 login system into a Flutter App.

## Note on Native SDK usage

The plugin utilizes the native SDKs, written in Java & Swift, under the hood.

This is meant as a easy way to debug problems if they occur. Developers may open this plugins code and find familiar function calls that match the Auth0 documentation.


##  Installation

1. Depend on it
    Add this to your package's pubspec.yaml file:


dependencies:
    auth0_native: ^0.1.0

2. Install it
    You can install packages from the command line:

    $ flutter pub get

    Alternatively, your editor might support flutter pub get. Check the docs for your editor to learn more.

3. Set up Application in Auth0

    - Create a Native application
    - Get Domain
    - Get Client ID
    - Follow the Auth0 Steps to setup the callback and logout URLs
        - Set up iOS callback/logout
           example - com.company.myapp://company.auth0.com/ios/com.company.myapp/callback
        - Set up Android
           example -  demo://company.auth0.com/android/YOUR_APP_PACKAGE_NAME/callback
    - Set Grant Types
        - this is under Advanced Settings
        - if you are using Passwordless you will need to add Passwordless OTP grant type


4. Set up your Flutter project (See the example project folder)
    ---Android---
    - Add auth0.xml to the values directory
        Path - android=>app=>src=>main=>res=>values

        <?xml version="1.0" encoding="utf-8"?>
        <resources>
        <string name="com_auth0_client_id">Add Auth0 Client Id</string>
        <string name="com_auth0_domain">Add Auth0 Domain</string>
        <string name="com_auth0_scheme">Add Auth0 Scheme</string>
        </resources>

    - Add activity to AndroidManifest.xml
        Path - android=>app=>src=>main

        <activity
        android:name="com.auth0.android.provider.WebAuthActivity"
        />
        <activity
        android:name="com.auth0.android.provider.RedirectActivity"
        >
        <intent-filter>
        <action android:name="android.intent.action.VIEW" />
        <category android:name="android.intent.category.DEFAULT" />
        <category android:name="android.intent.category.BROWSABLE" />
        <data
        android:host="@string/com_auth0_domain"
        android:pathPrefix="/android/${applicationId}/callback"
        android:scheme="@string/com_auth0_scheme" />
        </intent-filter>
        </activity>

    - Add dependency to build.gradle
        Path - android=>app=>src

        implementation 'com.auth0.android:auth0:1.+'


    ---iOS---

    - Add Auth0.plist
       Path - ios=>Runner

        <?xml version="1.0" encoding="UTF-8"?>
        <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
        <plist version="1.0">
        <dict>
        	<key>ClientId</key>
        	<string>Add Auth0 Client Id</string>
        	<key>Domain</key>
        	<string>Add Auth0 Domain</string>
        </dict>
        </plist>

    - Update Info.plist - this is a key/value pair file and this can be added after the last pair
        Path - ios=>Runner

       <key>CFBundleURLTypes</key>
        <array>
            <dict>
                <key>CFBundleTypeRole</key>
                <string>None</string>
                <key>CFBundleURLName</key>
                <string>auth0</string>
                <key>CFBundleURLSchemes</key>
                <array>
                    <string>com.comunli-flutter</string>
                </array>
            </dict>
        </array>


    - Update Podfile
        If you are receiving an error about Auth0 requiring a higher minimum version.  Uncomment (#) platform definition.

        Path - ios

        # Uncomment this line to define a global platform for your project
        From - #platform :ios, '12.0'
        To - platform :ios, '12.0'

    ----Web---
    - Add SDK to your index.html file.  This needs to be before the main.dart.js file.
        // Add these two lines
        <script src="JSAuth0NativePlugin.js"></script>
        // the main.dart.js file that is created on web build.
        <script src="main.dart.js" type="application/javascript"></script>

    - Create Credentials file
       - This file needs to be in the web directory with the index.html file

       {
         "domain": "company.auth0.com",
         "clientId": "Add Your Client Id",
         "redirectUri": "https://YOUR_APP/callback",
         "audience": "YOUR_API_Identifier"
       }

    NOTE - If you are using the universal login, you will need to handle the callback.  From the Auth0 docs, after the user authenticates, it will redirect to your application callback URL passing the Access Token and ID Token in the address location.hash.
    NOTE - oidc flag does not work on web. This will use the OIDC compliant flow.



4. Initialize Auth0
    - Import package into, most likely, main.dart.
       - import 'package:auth0_native/auth0_native.dart';

    - Initialize Auth0
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

    - Initialize Parameters
        clientID =  Your Auth0 Client Id
        domain =  Your Auth0 Domain
        oidc = This will determine the OIDC comformant flow.  Auth0 defaults this to True where this package defaults to false.  This changes the endpoints used for validation.
            - Passwordless
                - oidc = true will validate on endpoint /oauth/token
                - oidc = false will validate on endpoint /oauth/ro
        loggingEnabled = Logs to console


5. Package Breakdown
    - Standard Login
        - call login()

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

    - Logout
        - call Logout()
        - If you do not have the Allowed Logout URLs set properly, you may receive an error.

        /// Logs the current user out.
          Future<void> logout({
            /// When set to `true`, the login will only affect the local credentials storage.
            ///
            /// Else, it will clear the stored universal login session. This may prompt a
            /// web view to popup briefly.
            bool localOnly,
            String audience,
            String scheme,
          }) async {
            await _methodChannel.invokeMethod<void>('logout', {
              'localOnly': localOnly,
              'audience': audience,
              'scheme': scheme,
            });
          }

    - Has Credentials
        - call hasCredentials()
        - this will return a boolean on if there are credentials stored

        /// Utility method which informs whether credentials are available (e.g. the
          /// user has logged in).
        Future<bool> hasCredentials() async {
            return await _methodChannel.invokeMethod<bool>('hasCredentials');
          }

    - current Credentials
        -  property currentCredentials
        -  this will return a JSON response with the idToken, accessToken

        Future<Map<String, dynamic>> get currentCredentials {
            return _methodChannel.invokeMapMethod<String, dynamic>('getCredentials');
          }


    -  Passwordless Login Flow
        - This is comprised of two steps, request a otp code and submitting the code for a token.
        - The code request can be completed via SMS or Email
        - NOTE - you must set up a SMS or Email service inside of Auth0]

       - Passwordless with SMS
            - Step one
                - Call passwordlessWithSMS()

              /// Initiates a passwordless login flow by sending a SMS with a OTP.
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

              - Parameters
                - phone = the login phone number to use, must have + and countrycode (+13143143114)
                - type = Enum PasswordlessType - use code for SMS
                    enum PasswordlessType {
                      code,
                      androidLink,
                      webLink,
                    }
                - connection = Optional - this will default to 'sms'

            - Step two
                - Call loginWithPhoneNumber()

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

                - Parameters
                    phone = same phone number as in passwordlessWithSMS
                    code =  the code sent via SMS
                    connection = Optional - this will default to 'sms'
                    audience =  Optional - This other applications (APIs) that you need access too.  This would be the API if your applcation needs a datasource.
                    scope = Optional - this is only necessary if you have scoped defined in Auth0
                    device = Optional - This is for a device specific flow and can be left out.


       - Passwordless with Email
            - Step one
                - call passwordlessWithEmail()

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

                - Parameters
                    email = the users email
                    - type = Enum PasswordlessType - use code for SMS
                        enum PasswordlessType {
                          code,
                          androidLink,
                          webLink,
                        }
                    - connection = Optional - this will default to 'email'

            - Step two
                - call loginWithEmail()

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

                - Parameters
                    email = same email as in passwordlessWithEmail
                    code =  the code sent via SMS
                    connection = Optional - this will default to 'email'
                    audience =  Optional - This other applications (APIs) that you need access too.  This would be the API if your applcation needs a datasource.
                    scope = Optional - this is only necessary if you have scoped defined in Auth0
                    device = Optional - This is for a device specific flow and can be left out.


    - Sign in with Apple
        - call signInWithApple
        - You must have Apple sign in configured in Auth0

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