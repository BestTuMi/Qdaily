//
//  QDFavouriteViewController.m
//  Qdaily
//
//  Created by Envy15 on 15/10/7.
//  Copyright (c) 2015年 c344081. All rights reserved.
//

#import "QDFavouriteViewController.h"

@interface QDFavouriteViewController ()

@end

@implementation QDFavouriteViewController

- (NSString *)requestUrl {
    return @"/app/users/praises";
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blueColor];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    QDLogFunc;
}
@end
