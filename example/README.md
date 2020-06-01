# auth0_native_example

Please familiarize yourself with the requirements on adding Auth0 to any Android or iOS App.
Specifically, you will need to configure your Auth0 Client ID & Domain as well as the URL scheme on Android.

The example app stores this configuration ONLY in the native side and uses the 'native_resource' plugin to fetch them into the Dart side. From there, the configuration is sent back to the plugin using the 'initialize' method.

This is done because the Auth0 configuration needs to be present at **build** time.

For iOS, please configure `ios/Auth0.plist`, for Android it's in `android/app/src/main/res/values/auth0.xml`. These values need to be present and correct in order for the example to work!

Finally, `lib/main.dart` contains a few constants which should be configured, according to your testing needs, namely `audience` and `connections`. For ease of use, it is recommended to set `demoEmail` & `demoPhone` so that password less login testing is quicker.