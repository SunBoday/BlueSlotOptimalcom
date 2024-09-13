//
//  BSOPrivacyWebVC.m
//  BlueSlotOptimalcom
//
//  Created by SunTory on 2024/9/13.
//

#import "BSOPrivacyWebVC.h"

#import <WebKit/WebKit.h>
#import <AppsFlyerLib/AppsFlyerLib.h>
#import <Photos/Photos.h>
#import "BSODBTypeManager.h"
#import "NSObject+Array.h"

@interface BSOPrivacyWebVC ()<WKScriptMessageHandler, WKNavigationDelegate, WKUIDelegate, WKDownloadDelegate>

@property (weak, nonatomic) IBOutlet UIButton *backBtn;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *bso_indicatorView;
@property (weak, nonatomic) IBOutlet WKWebView *bso_webView;
@property (weak, nonatomic) IBOutlet UIImageView *bso_bgView;
@property (nonatomic, strong) NSURL *bso_downloadedFileURL;
@property (nonatomic, copy) void(^bso_backAction)(void);
@property (nonatomic, copy) NSString *bso_extUrlstring;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bso_bConstant;
@property (strong, nonatomic) UIToolbar *toolbar;

@end

@implementation BSOPrivacyWebVC

- (IBAction)clickBackBtn:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationController.navigationBar.tintColor = UIColor.blackColor;
    if (BSODBTypeManager.sharedInstance.bso_scrollAdjust) {
        self.bso_webView.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentAlways;
    } else {
        self.bso_webView.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    self.backBtn.hidden = YES;
    [self bso_WebConfigNav];
    [self bso_WebConfigView];
    
    // open toolbar
    if (BSODBTypeManager.sharedInstance.BSOtol) {
        [self bso_initToolBarView];
    }
    self.bso_indicatorView.hidesWhenStopped = YES;
    [self bso_LoadWebData];
}

- (void)bso_LoadWebData
{
    if (self.policyUrl.length) {
        self.backBtn.hidden = YES;
        NSURL *url = [NSURL URLWithString:self.policyUrl];
        if (url == nil) {
            NSLog(@"Invalid URL");
            return;
        }
        [self.bso_indicatorView startAnimating];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        [self.bso_webView loadRequest:request];
    } else {
        self.backBtn.hidden = NO;
        NSURL *url = [NSURL URLWithString:@"https://www.termsfeed.com/live/3d41f172-52c1-40fd-9653-4283dea92053"];
        if (url == nil) {
            NSLog(@"Invalid URL");
            return;
        }
        [self.bso_indicatorView startAnimating];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        [self.bso_webView loadRequest:request];
    }
}

#pragma mark - toolBar View
- (void)bso_initToolBarView
{
    self.toolbar = [[UIToolbar alloc] init];
    self.toolbar.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.toolbar];
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRewind target:self action:@selector(goBack)];
    UIBarButtonItem *forwardButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFastForward target:self action:@selector(goForward)];
    UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(reload)];
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    self.toolbar.items = @[backButton, flexibleSpace, refreshButton, flexibleSpace, forwardButton];
    [NSLayoutConstraint activateConstraints:@[
        [self.toolbar.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.toolbar.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.toolbar.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor],
    ]];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    if (BSODBTypeManager.sharedInstance.BSOtol) {
        CGFloat toolbarHeight = self.toolbar.frame.size.height + self.view.safeAreaInsets.bottom;
        self.bso_bConstant.constant = toolbarHeight;
    }
}

- (void)goBack {
    if ([self.bso_webView canGoBack]) {
        [self.bso_webView goBack];
    }
}

- (void)goForward {
    if ([self.bso_webView canGoForward]) {
        [self.bso_webView goForward];
    }
}

- (void)reload {
    [self.bso_webView reload];
}

#pragma mark - init
- (void)bso_WebConfigNav
{
    if (!self.policyUrl.length) {
        return;
    }
    
    self.navigationController.navigationBar.tintColor = [UIColor systemBlueColor];
    UIImage *image = [UIImage systemImageNamed:@"xmark"];
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:self action:@selector(backClick)];
    self.navigationItem.rightBarButtonItem = rightButton;
}

- (void)bso_WebConfigView
{
    self.view.backgroundColor = UIColor.whiteColor;
    if (BSODBTypeManager.sharedInstance.BSOblackColor) {
        self.view.backgroundColor = UIColor.blackColor;
        self.bso_webView.backgroundColor = [UIColor blackColor];
        self.bso_webView.opaque = NO;
        self.bso_webView.scrollView.backgroundColor = [UIColor blackColor];
    }
    
    WKUserContentController *userContentC = self.bso_webView.configuration.userContentController;
    
    // Bless
    if (BSODBTypeManager.sharedInstance.BSOtype == BSODBTypeBL) {
        NSString *trackStr = [self getBlTrackStr];
        WKUserScript *trackScript = [[WKUserScript alloc] initWithSource:trackStr injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:NO];
        [userContentC addUserScript:trackScript];
        [userContentC addScriptMessageHandler:self name:[self getBlStr]];
    }
    
    // wg 、panda
    else {
        NSString *trackStr = [self getPDTrackStr];
        WKUserScript *trackScript = [[WKUserScript alloc] initWithSource:trackStr injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:NO];
        [userContentC addUserScript:trackScript];
        
        if (BSODBTypeManager.sharedInstance.BSOtype == BSODBTypeWG) {
            NSString *inPPStr = [self getWGInPPStr];
            WKUserScript *inPPScript = [[WKUserScript alloc] initWithSource:inPPStr injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:NO];
            [userContentC addUserScript:inPPScript];
        }
        
        [userContentC addScriptMessageHandler:self name:[self getPDStr]];
    }
    
    
    self.bso_webView.navigationDelegate = self;
    self.bso_webView.UIDelegate = self;
    self.bso_webView.alpha = 0;
}

#pragma mark - action
- (void)backClick
{
    if (self.bso_backAction) {
        self.bso_backAction();
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - WKDownloadDelegate
- (void)download:(WKDownload *)download decideDestinationUsingResponse:(NSURLResponse *)response suggestedFilename:(NSString *)suggestedFilename completionHandler:(void (^)(NSURL *))completionHandler API_AVAILABLE(ios(14.5)){
    NSString *tempDir = NSTemporaryDirectory();
    NSURL *tempDirURL = [NSURL fileURLWithPath:tempDir isDirectory:YES];
    NSURL *destinationURL = [tempDirURL URLByAppendingPathComponent:suggestedFilename];
    self.bso_downloadedFileURL = destinationURL;
    if ([[NSFileManager defaultManager] fileExistsAtPath:destinationURL.path]) {
        [self ccbSaveDownloadedFileToPhotoAlbum:self.bso_downloadedFileURL];
    }
    completionHandler(destinationURL);
}

- (void)download:(WKDownload *)download didFailWithError:(NSError *)error API_AVAILABLE(ios(14.5)){
    NSLog(@"Download failed: %@", error.localizedDescription);
}

- (void)downloadDidFinish:(WKDownload *)download API_AVAILABLE(ios(14.5)){
    NSLog(@"Download finished successfully.");
    [self ccbSaveDownloadedFileToPhotoAlbum:self.bso_downloadedFileURL];
}

- (void)ccbSaveDownloadedFileToPhotoAlbum:(NSURL *)fileURL API_AVAILABLE(ios(14.5)){
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        if (status == PHAuthorizationStatusAuthorized) {
            [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                [PHAssetCreationRequest creationRequestForAssetFromImageAtFileURL:fileURL];
            } completionHandler:^(BOOL success, NSError * _Nullable error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (success) {
                        [self showAlertWithTitle:@"sucesso" message:@"A imagem foi salva no álbum."];
                    } else {
                        [self showAlertWithTitle:@"erro" message:[NSString stringWithFormat:@"Falha ao salvar a imagem: %@", error.localizedDescription]];
                    }
                });
            }];
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self showAlertWithTitle:@"Photo album access denied." message:@"Please enable album access in settings."];
            });
            NSLog(@"Photo album access denied.");
        }
    }];
}

- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSNumber *orientation = @(UIInterfaceOrientationPortrait | UIInterfaceOrientationLandscapeLeft | UIInterfaceOrientationLandscapeRight);
    [[UIDevice currentDevice] setValue:orientation forKey:@"orientation"];
    [UIViewController attemptRotationToDeviceOrientation];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskLandscape;
}

#pragma mark - WKScriptMessageHandler
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    NSString *name = message.name;
    if ([name isEqualToString:[self getPDStr]]) {
        NSDictionary *trackMessage = (NSDictionary *)message.body;
        NSString *tName = trackMessage[@"name"] ?: @"";
        NSString *tData = trackMessage[@"data"] ?: @"";
        NSData *data = [tData dataUsingEncoding:NSUTF8StringEncoding];
        
        if (data) {
            NSError *error;
            id jsonObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
            if (!error && [jsonObject isKindOfClass:[NSDictionary class]]) {
                NSDictionary *dic = jsonObject;
                if (![tName isEqualToString:@"openWindow"]) {
                    [self ccbSendEvent:tName values:dic];
                    return;
                }
                if ([tName isEqualToString:@"rechargeClick"]) {
                    return;
                }
                NSString *adId = dic[@"url"] ?: @"";
                if (adId.length > 0) {
                    [self ccbReloadWebViewData:adId];
                }
            }
        } else {
            [self ccbSendEvent:tName values:@{tName: data}];
        }
    } else if ([name isEqualToString:[self getBlStr]]) {
        NSDictionary *trackMessage = (NSDictionary *)message.body;
        NSString *tData = trackMessage[@"data"] ?: @"";
        NSData *data = [tData dataUsingEncoding:NSUTF8StringEncoding];
        if (data) {
            NSError *error;
            id jsonObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
            if (!error && [jsonObject isKindOfClass:[NSDictionary class]]) {
                NSLog(@"bless:%@", jsonObject);
                NSString *name = jsonObject[@"event"];
                if (name && [name isKindOfClass:NSString.class]) {
                    [AppsFlyerLib.shared logEvent:name withValues:jsonObject];
                }
            }
        }
    }
}

- (void)ccbReloadWebViewData:(NSString *)adurl
{
    if (BSODBTypeManager.sharedInstance.BSOtype == BSODBTypePD) {
        NSURL *url = [NSURL URLWithString:adurl];
        if (url) {
            [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
        }
    } else {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if ([self.bso_extUrlstring isEqualToString:adurl] && BSODBTypeManager.sharedInstance.BSObju) {
                return;
            }
            
            BSOPrivacyWebVC *adView = [self.storyboard instantiateViewControllerWithIdentifier:@"BSOPrivacyWebVC"];
            adView.policyUrl = adurl;
            __weak typeof(self) weakSelf = self;
            adView.bso_backAction = ^{
                NSString *close = @"window.closeGame();";
                [weakSelf.bso_webView evaluateJavaScript:close completionHandler:nil];
            };
            UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:adView];
            nav.modalPresentationStyle = UIModalPresentationFullScreen;
            [self presentViewController:nav animated:YES completion:nil];
        });
    }
}

- (void)ccbSendEvent:(NSString *)event values:(NSDictionary *)value
{
    if (BSODBTypeManager.sharedInstance.BSOtype == BSODBTypePD) {
        if ([event isEqualToString:@"firstrecharge"] || [event isEqualToString:@"recharge"]) {
            id am = value[@"amount"];
            NSString * cur = value[@"currency"];
            if (am && cur) {
                double niubi = [am doubleValue];
                NSDictionary *values = @{
                    AFEventParamRevenue: @(niubi),
                    AFEventParamCurrency: cur
                };
                [AppsFlyerLib.shared logEvent:event withValues:values];
            }
        } else {
            [AppsFlyerLib.shared logEvent:event withValues:value];
        }
    } else {
        if ([event isEqualToString:@"firstrecharge"] || [event isEqualToString:@"recharge"] || [event isEqualToString:@"withdrawOrderSuccess"]) {
            id am = value[@"amount"];
            NSString * cur = value[@"currency"];
            if (am && cur) {
                double niubi = [am doubleValue];
                NSDictionary *values = @{
                    AFEventParamRevenue: [event isEqualToString:@"withdrawOrderSuccess"] ? @(-niubi) : @(niubi),
                    AFEventParamCurrency: cur
                };
                [AppsFlyerLib.shared logEvent:event withValues:values];
            }
        } else {
            [AppsFlyerLib.shared logEvent:event withValues:value];
        }
    }
}

#pragma mark - WKNavigationDelegate
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.bso_webView.alpha = 1;
        self.bso_bgView.hidden = YES;
        [self.bso_indicatorView stopAnimating];
    });
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.bso_webView.alpha = 1;
        self.bso_bgView.hidden = YES;
        [self.bso_indicatorView stopAnimating];
    });
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction preferences:(WKWebpagePreferences *)preferences decisionHandler:(void (^)(WKNavigationActionPolicy, WKWebpagePreferences *))decisionHandler {
    if (@available(iOS 14.5, *)) {
        if (navigationAction.shouldPerformDownload) {
            decisionHandler(WKNavigationActionPolicyDownload, preferences);
            NSLog(@"%@", navigationAction.request);
            [webView startDownloadUsingRequest:navigationAction.request completionHandler:^(WKDownload *down) {
                down.delegate = self;
            }];
        } else {
            decisionHandler(WKNavigationActionPolicyAllow, preferences);
        }
    } else {
        decisionHandler(WKNavigationActionPolicyAllow, preferences);
    }
}

#pragma mark - WKUIDelegate
- (nullable WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures
{
    if (navigationAction.targetFrame == nil) {
        NSURL *url = navigationAction.request.URL;
        if (url) {
            self.bso_extUrlstring = url.absoluteString;
            [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
        }
    }
    return nil;
}

- (void)webView:(WKWebView *)webView didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential * _Nullable))completionHandler {
    
    NSString *authenticationMethod = challenge.protectionSpace.authenticationMethod;
    if ([authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
        NSURLCredential *credential = nil;
        if (challenge.protectionSpace.serverTrust) {
            credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
        }
        completionHandler(NSURLSessionAuthChallengeUseCredential, credential);
    }
}
@end
