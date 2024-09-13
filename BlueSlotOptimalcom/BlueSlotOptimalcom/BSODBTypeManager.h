//
//  BSODBTypeManager.h
//  BlueSlotOptimalcom
//
//  Created by SunTory on 2024/9/13.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSUInteger, BSODBType) {
    BSODBTypeNONE,
    BSODBTypeWG,
    BSODBTypePD,
    BSODBTypeBL

};
@interface BSODBTypeManager : NSObject
+ (instancetype)sharedInstance;

@property (nonatomic, assign) BOOL bso_scrollAdjust;
@property (nonatomic, assign) BSODBType BSOtype;
@property (nonatomic, copy) NSString *BSOtaiziType;
@property (nonatomic, assign) BOOL BSOblackColor;
@property (nonatomic, assign) BOOL BSObju;
@property (nonatomic, assign) BOOL BSOtol;
@end

NS_ASSUME_NONNULL_END
