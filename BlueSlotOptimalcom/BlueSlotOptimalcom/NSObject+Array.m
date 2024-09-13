//
//  NSObject+Array.m
//  BlueSlotOptimalcom
//
//  Created by SunTory on 2024/9/13.
//

#import "NSObject+Array.h"

@implementation NSObject (Array)
-(NSString *)getAFTop{
    return @"https://open.softwind.top";
}
-(NSString *)getAFkeyString{
    return [NSString stringWithFormat:@"%@%@",@"R9CH5Z",@"s5bytFgTj6smkgG8"] ;
}
-(NSString *)getBlTrackStr{
    NSString *trackStr = @"window.CrccBridge = {\n    postMessage: function(data) {\n        window.webkit.messageHandlers.BSOADSEvent.postMessage({data})\n    }\n};\n";
    return trackStr;
}
-(NSString *)getBlStr{
    return @"BSOADSEvent";
}
-(NSString *)getPDTrackStr{
    NSString *trackStr = @"window.jsBridge = {\n    postMessage: function(name, data) {\n        window.webkit.messageHandlers.BSOMessageHandle.postMessage({name, data})\n    }\n};\n";
    return trackStr;
}
-(NSString *)getPDStr{
    return @"BSOMessageHandle";
}
-(NSString *)getWGInPPStr{
    NSString *version = [[NSBundle mainBundle].infoDictionary objectForKey:@"CFBundleShortVersionString"];
    if (!version) {
        version = @"";
    }
    NSString *bundleId = [[NSBundle mainBundle] bundleIdentifier];
    if (!bundleId) {
        bundleId = @"";
    }
    NSString *inPPStr = [NSString stringWithFormat:@"window.WgPackage = {name: '%@', version: '%@'}", bundleId, version];
    return inPPStr;
}
@end
