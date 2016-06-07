//
//  QDPhotoBrowse.m
//  Qdaily
//
//  Created by Envy15 on 15/11/15.
//  Copyright (c) 2015年 c344081. All rights reserved.
//

#import "QDPhotoBrowse.h"
#import "Masonry.h"
#import <MWPhotoBrowserPrivate.h>

@interface QDPhotoBrowse ()
/** label */
@property (nonatomic, weak) UILabel *label;
@end

@implementation QDPhotoBrowse

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupToolBar];
    
    self.safe_navigationBarHidden = YES;
}

- (void)setupToolBar {
    UIView *toolBar = [[UIView alloc] init];
    [self.view addSubview:toolBar];
    [toolBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.view.mas_leading);
        make.trailing.equalTo(self.view.mas_trailing);
        make.bottom.equalTo(self.view.mas_bottom).offset(-20);
        make.height.equalTo(@(30));
    }];
    
    UILabel *label = [[UILabel alloc] init];
    label.textColor = QDRGBWhiteColor(1, 1);
    [toolBar addSubview:label];
    self.label = label;
    self.label.x = 15;
    
    UIButton *downloadBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [downloadBtn setImage:[UIImage imageNamed:@"article_detaile_shoBigImage_down"] forState:UIControlStateNormal];
    [downloadBtn addTarget:self action:@selector(savePhoto) forControlEvents:UIControlEventTouchUpInside];
    [toolBar addSubview:downloadBtn];
    [downloadBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(toolBar.mas_trailing).offset(-15);
        make.centerY.equalTo(toolBar.mas_centerY);
    }];
}

- (void)setLabelTitle:(NSString *)labelTitle {
    _labelTitle = labelTitle;
    self.label.text = labelTitle;
    [self.label sizeToFit];
}

- (void)savePhoto {
    id <MWPhoto> photo = [self photoAtIndex:self.currentIndex];
    if ([photo underlyingImage]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
        [self performSelector:@selector(showProgressHUDWithMessage:) withObject:@"正在保存..."];
        [self performSelector:@selector(actuallySavePhoto:) withObject:photo afterDelay:0];
#pragma clang diagnostic pop
    }
}

- (void)actuallySavePhoto:(id<MWPhoto>)photo {
    if ([photo underlyingImage]) {
        UIImageWriteToSavedPhotosAlbum([photo underlyingImage], self,
                                       @selector(image:didFinishSavingWithError:contextInfo:), nil);
    }
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    [self performSelector:@selector(showProgressHUDCompleteMessage:) withObject:error ? @"保存失败" : @"保存成功"];
#pragma clang diagnostic pop
    [self hideControlsAfterDelay];
}

@end
