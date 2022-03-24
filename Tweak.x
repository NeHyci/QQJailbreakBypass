#import <Foundation/Foundation.h>

#include <substrate.h>
#include <mach-o/dyld.h>
#include <dlfcn.h>

%hook NSFileManager
- (BOOL)fileExistsAtPath:(NSString *)path {
  NSArray *detectedFiles = [NSArray arrayWithObjects:@"/Application/Cydia.app",
                                                     @"/private/var/lib/apt",
                                                     @"/private/var/lib/apt/",
                                                     @"/Library/MobileSubstrate/MobileSubstrate.dylib",
                                                     @"/etc/apt",
                                                     @"/usr/lib/libsubstitute.dylib",
                                                     @"/usr/lib/libsubstrate.dylib",
                                                     @"/usr/lib/substitute-inserter.dylib",
                                                     @"/Applications/Sileo.app",
                                                     @"/usr/bin/ssh",
                                                     @"/Applications/System Preferences.app/Contents/Resources/",
                                                     nil];
  for (NSString *file in detectedFiles) {
    if ([path isEqualToString:file]) return NO;
  }
  return %orig;
}
%end

%hook QQWalletInjectReportTool
+ (bool)isForbidVerify {
  return true;
}
%end

%hook QQJSBridgeDevicePlugin
- (bool)handleJsBridgeRequest_device_isJailBreakend:(id)arg1 {
  arg1 = 0;
  return true;
}
%end

%hook CFT_F538913
+ (bool)CFT_F522771:(Class)arg1 selector:(SEL)arg2 {
  return false;
}
%end

%hook UIApplication
- (BOOL)canOpenURL:(NSURL *)url {
  if ([url.scheme isEqualToString:@"cydia"]) return NO;
  return %orig;
}
%end

%hook NSString
+ (BOOL)containsString:(NSString *)str {
  if ([str isEqualToString:@"libCapMockForQQ"]) return YES;
  // apply to +[QQWalletInjectReportTool isVaildName:]
  return %orig;
}
%end

%hookf(const char *, _dyld_get_image_name, uint32_t index) {
  const char *ret = %orig(index);
  if (ret) {
    NSString *name = [NSString stringWithUTF8String:ret];
    if ([name containsString:@"MobileSubstrate"]) return "dyld";
  }
  return ret;
}
