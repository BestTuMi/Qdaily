//
//  AppDelegate.m
//  Qdaily
//
//  Created by Envy15 on 15/10/4.
//  Copyright (c) 2015年 c344081. All rights reserved.
//

#import "AppDelegate.h"
#import "QDMainRootViewController.h"
#import "QDNavigationController.h"
#import "QDNewFeaturesViewController.h"
#import "QDNewFeaturesFlowLayout.h"
#import "UMSocial.h"
#import "UMSocialSinaHandler.h"

@interface AppDelegate ()
/** 新特性界面 */
@property (nonatomic, strong)  QDNewFeaturesViewController *featuresVc;
/** 导航控制器 */
@property (nonatomic, strong)  QDNavigationController *navi;
/// 判断是否是新版本
- (BOOL)isNewVersion;
@end

@implementation AppDelegate

+ (AppDelegate *)sharedAppdelegate {
    return [UIApplication sharedApplication].delegate;
}

#pragma mark - lazyload
- (QDNewFeaturesViewController *)featuresVc {
    if (!_featuresVc) {
        _featuresVc = [QDNewFeaturesViewController featuresVc];
    }
    return _featuresVc;
}

- (QDNavigationController *)navi {
    if (!_navi) {
        QDMainRootViewController *mainRootViewController = [[QDMainRootViewController alloc] init];
       
        QDNavigationController *navi = [[QDNavigationController alloc] initWithRootViewController:mainRootViewController];
        
        _navi = navi;
    }
    return _navi;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
    // 监听需要改变根控制器的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeRootVc:) name:QDChangeRootVCNotification object:nil];
    
    // 选择根控制器
    [self selectRootVc];

    [self.window makeKeyAndVisible];
    
    // 设置友盟的APPKEY
    [UMSocialData setAppKey:@"562bc1f6e0f55a4374003244"];
    
    // 打开新浪微博的SSO开关
    [UMSocialSinaHandler openSSOWithRedirectURL:@"http://sns.whalecloud.com/sina2/callback"];
    
    return YES;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

/// 检查是否是新版本
- (BOOL)isNewVersion {
    // 如果是新版本存储偏好设置
    if ([QDCurrentVersion compare:QDLocalVersion options:NSForcedOrderingSearch] == NSOrderedDescending) {
        // 是新版本,存储版本号
        [[NSUserDefaults standardUserDefaults] setObject:QDCurrentVersion forKey:QDVersionKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
        return YES;
    } else {
        
        return NO;
    }
}

/// 选择根控制器
- (void)selectRootVc {
    if (self.isNewVersion) { // 是新版本
        self.window.rootViewController = self.featuresVc;
    } else {
        self.window.rootViewController = self.navi;
    }
}

- (void)changeRootVc: (NSNotification *)note {

    // 进入这个方法表示第一次运行,需要显示新手引导
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:QDShowMainUserGuideKey];
    QDLogVerbose(@"%d", QDShouldShowMainUserGuide);
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:QDShowSideBarUserGuideKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    // 更改窗口根控制器
    self.window.rootViewController = self.navi;

}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    return  [UMSocialSnsService handleOpenURL:url];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return  [UMSocialSnsService handleOpenURL:url];
}

@end
