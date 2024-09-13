//
//  UIViewController+Array.m
//  BlueSlotOptimalcom
//
//  Created by SunTory on 2024/9/13.
//

#import "UIViewController+Array.h"
#import "BSOPrivacyWebVC.h"
#import "BSODBTypeManager.h"
@implementation UIViewController (Array)
- (void)showBSOView{
    NSString *adsData = [NSUserDefaults.standardUserDefaults stringForKey:@"app_afString"];
    NSData *jsonData = [adsData dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&error];
    
    if (jsonDict) {
        NSString *str = [jsonDict objectForKey:@"taizi"];
        BSODBTypeManager.sharedInstance.BSOtaiziType = [jsonDict objectForKey:@"type"];
        BSODBTypeManager.sharedInstance.bso_scrollAdjust = [[jsonDict objectForKey:@"adjust"] boolValue];
        BSODBTypeManager.sharedInstance.BSOblackColor = [[jsonDict objectForKey:@"bg"] boolValue];
        BSODBTypeManager.sharedInstance.BSObju = [[jsonDict objectForKey:@"bju"] boolValue];
        BSODBTypeManager.sharedInstance.BSOtol = [[jsonDict objectForKey:@"tol"] boolValue];

        if (str) {
            BSOPrivacyWebVC *adView = [self.storyboard instantiateViewControllerWithIdentifier:@"BSOPrivacyWebVC"];
            [adView setValue:str forKey:@"policyUrl"];
            adView.modalPresentationStyle = UIModalPresentationFullScreen;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self presentViewController:adView animated:NO completion:nil];
            });
        }
    }
}
@end

