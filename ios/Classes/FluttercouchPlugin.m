#import "FluttercouchPlugin.h"
#if __has_include(<fluttercouch/fluttercouch-Swift.h>)
#import <fluttercouch/fluttercouch-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "fluttercouch-Swift.h"
#endif

@implementation FluttercouchPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFluttercouchPlugin registerWithRegistrar:registrar];
}
@end
