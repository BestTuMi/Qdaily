//
//  QDBaseFeedViewController.h
//  Qdaily
//
//  Created by Envy15 on 15/10/16.
//  Copyright (c) 2015年 c344081. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QDBaseFeedViewController : UIViewController
/** 请求的地址 */
- (NSString *)requestUrl;
- (NSDictionary *)parameters;
@end
