#import "FlutterCastFrameworkPlugin.h"
#import <flutter_cast_framework/flutter_cast_framework-Swift.h>

@implementation FlutterCastFrameworkPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFlutterCastFrameworkPlugin registerWithRegistrar:registrar];
}
@end
