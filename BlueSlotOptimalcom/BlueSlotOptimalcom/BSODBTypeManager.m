//
//  BSODBTypeManager.m
//  BlueSlotOptimalcom
//
//  Created by SunTory on 2024/9/13.
//

#import "BSODBTypeManager.h"

@implementation BSODBTypeManager
+ (instancetype)sharedInstance {
    static BSODBTypeManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

// 初始化方法
- (instancetype)init {
    self = [super init];
    if (self) {
        // 初始化代码
        self.BSOtaiziType = @"wg";
    }
    return self;
}

- (void)setBSOtaiziType:(NSString *)taiziType
{
    _BSOtaiziType = taiziType;
    if ([taiziType isEqualToString:@"wg"]) {
        self.BSOtype = BSODBTypeWG;
    } else if ([taiziType isEqualToString:@"pd"]) {
        self.BSOtype = BSODBTypePD;
    }else if ([taiziType isEqualToString:@"bl"]) {
        self.BSOtype = BSODBTypeBL;
    }
}
@end
