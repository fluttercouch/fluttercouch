#import "FluttercouchPlugin.h"
#import <fluttercouch/fluttercouch-Swift.h>

@implementation FluttercouchPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFluttercouchPlugin registerWithRegistrar:registrar];
}
@end
