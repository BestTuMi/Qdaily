//
//  Macro.h
//  Qdaily
//
//  Created by Envy15 on 16/6/7.
//  Copyright © 2016年 c344081. All rights reserved.
//

#ifndef Macro_h
#define Macro_h


#define QDWeakSelf __weak typeof(self) weakSelf = self
/** Base Url */
#define QDBaseURL [NSURL URLWithString: @"http://app.qdaily.com"]

// 颜色
#define QDRGBAColor(r, g, b, a) [UIColor colorWithRed:(r) / 255.0 green:(g) / 255.0 blue:(b) / 255.0 alpha:(a) / 1.0]
#define QDRGBColor(r, g, b) QDRGBAColor((r), (g), (b), 1.0)
#define QDRGBWhiteColor(white, a) [UIColor colorWithWhite:(white) alpha:(a)]
#define QDRandomColor QDRGBColor(arc4random_uniform(256), arc4random_uniform(256), arc4random_uniform(256))
// 标准色
#define QDNormalColor QDRGBColor(89, 89, 89)
#define QDHighlightColor QDRGBColor(254, 190, 30)
#define QDLightGrayColor QDRGBColor(237, 237, 237)

// 宽高
/** 屏幕宽 */
#define QDScreenW [UIScreen mainScreen].bounds.size.width
/** 屏幕高 */
#define QDScreenH [UIScreen mainScreen].bounds.size.height

/** 非0最小浮点数 */
#define MINFLOAT 0x1.fffffep-2f

/**  新特性相关 */
#define QDCurrentVersion [[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"]
#define QDLocalVersion [[NSUserDefaults standardUserDefaults] objectForKey:QDVersionKey] == nil ? @"0.0" : [[NSUserDefaults standardUserDefaults] objectForKey:QDVersionKey]

#define QDShouldShowMainUserGuide [[NSUserDefaults standardUserDefaults] boolForKey:QDShowMainUserGuideKey]
#define QDShouldShowSideBarUserGuide [[NSUserDefaults standardUserDefaults] boolForKey:QDShowSideBarUserGuideKey]

// 自定义 Log
#ifdef __OBJC__
#ifdef DEBUG // 调试阶段
#define QDLog(...) NSLog(__VA_ARGS__)
#define QDLogFunc NSLog(@"%s", __func__)
#define QDLogVerbose(...) NSLog(@"%s--%d\n%@\n", __func__, __LINE__, [NSString stringWithFormat:__VA_ARGS__])
#else // 发布阶段
#define QDLog(...)
#define QDLogFunc
#define QDLogVerbose(...)
#endif
#endif

#endif /* Macro_h */
