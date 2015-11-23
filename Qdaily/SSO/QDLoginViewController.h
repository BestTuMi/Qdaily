//
//  QDLoginViewController.h
//  Qdaily
//
//  Created by Envy15 on 15/10/26.
//  Copyright (c) 2015年 c344081. All rights reserved.
//

#import <UIKit/UIKit.h>
@class QDLoginViewController;

@protocol LoginViewControllerDelegate <NSObject>
@required
- (void)loginViewControllerDidLogin: (QDLoginViewController *)loginVc;
@end

@interface QDLoginViewController : UIViewController
/** 代理 */
@property (nonatomic, weak) id<LoginViewControllerDelegate> delegate;
@end
