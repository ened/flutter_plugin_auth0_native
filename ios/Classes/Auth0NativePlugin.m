#import "Auth0NativePlugin.h"
#if __has_include(<auth0_native/auth0_native-Swift.h>)
#import <auth0_native/auth0_native-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "auth0_native-Swift.h"
#endif

@implementation Auth0NativePlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftAuth0NativePlugin registerWithRegistrar:registrar];
}
@end
