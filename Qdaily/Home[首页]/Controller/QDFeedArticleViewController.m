//
//  QDFeedArticleViewController.m
//  Qdaily
//
//  Created by Envy15 on 15/10/16.
//  Copyright (c) 2015年 c344081. All rights reserved.
//

#import "QDFeedArticleViewController.h"
#import "MBProgressHUD+Message.h"
#import "QDFeed.h"
#import "QDPost.h"

@interface QDFeedArticleViewController () <UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *transitionAnimView;
/** 加载动画序列 */
@property (nonatomic, copy) NSArray *animationImages;
@property (weak, nonatomic) IBOutlet UIWebView *webView;
/** webView 的尾部控件 */
@property (nonatomic, weak)  UIView *webViewFooter;
@end

@implementation QDFeedArticleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBarHidden = YES;
    self.webView.scrollView.contentInset = UIEdgeInsetsZero;
    
    [self setupWebView];

    [self startTrasition];
}

#pragma mark - lazyload
- (NSArray *)animationImages {
    if (!_animationImages) {
        int count = 93;
        NSMutableArray *arrayM = [NSMutableArray arrayWithCapacity:count];
        for (int i = 0; i < 93; i++) {
            NSString *imageName = [NSString stringWithFormat:@"Loading_%05d", i];
            NSString *filePath = [[NSBundle mainBundle] pathForResource:imageName ofType:@"png"];
            UIImage *image = [UIImage imageWithContentsOfFile:filePath];
            [arrayM addObject:image];
        }
        _animationImages = [arrayM copy];
    }
    return _animationImages;
}

- (void)setFeed:(QDFeed *)feed {
    _feed = feed;
}

#pragma mark - 设置 WebView
- (void)setupWebView {
    self.webView.scalesPageToFit = YES;
    
    NSURL *url = [NSURL URLWithString:_feed.post.appview];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:request];
    
    // 添加对 webView ScrollView 的 contentSize 的监听
    [self addObserverForWebViewContentSize];
}

#pragma mark - 设置 WebView尾部
- (void)setupWebViewFooter {
    UIView *webViewFooter = [[UIView alloc] init];
    [self.webView.scrollView addSubview:webViewFooter];
    self.webViewFooter = webViewFooter;
    
    [self layoutWebViewFooter];
}

- (void)addObserverForWebViewContentSize {
    [self.webView addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)removeObserverForWebViewContentSize {
    [self.webView removeObserver:self forKeyPath:@"contentSize"];
}

- (void)dealloc {
    [self removeObserverForWebViewContentSize];
}

#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    // 监听到 webView 的 contentSize 变化后,重新布局尾部
    [self layoutWebViewFooter];
}

#pragma mark - 开始转场动画
- (void)startTrasition {
    self.transitionAnimView.animationImages = self.animationImages;
    self.transitionAnimView.animationRepeatCount = MAXFLOAT;
    self.transitionAnimView.animationDuration = 93 / 30;
    [self.transitionAnimView startAnimating];
}

- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - 布局 webView 的 footer
- (void)layoutWebViewFooter {
    // 取消对 webview的 contentSize的监听
    // 避免无限递归
    [self removeObserverForWebViewContentSize];
    
    self.webViewFooter.backgroundColor = QDRandomColor;
    
    // 获取当前 WebView 中 ScrollView 的 contentSize
    CGSize newContentSize = self.webView.scrollView.contentSize;
    self.webViewFooter.height = 300;
    self.webViewFooter.y = newContentSize.height + QDCommonMargin;
    self.webViewFooter.width = 320;
    self.webViewFooter.x = 0;
    
    // 设置新的 contentSize
    newContentSize.height += self.webViewFooter.height + QDWebViewToolBarH + QDCommonMargin;
    self.webView.scrollView.contentSize = newContentSize;
    
    // 重新添加监听
    [self addObserverForWebViewContentSize];
}

#pragma mark - webView delegate
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [MBProgressHUD showMessage:@"加载失败"];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        for (UIWindow *window in [UIApplication sharedApplication].windows) {
            [MBProgressHUD hideHUDForView:window];
        }
        // pop
        [self.navigationController popViewControllerAnimated:YES];
    });
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    // 为 webView 添加 footer
    [self setupWebViewFooter];
    
    [UIView animateWithDuration:0.25 animations:^{
        self.transitionAnimView.alpha = 0;
        self.webView.alpha = 1.0;
    }];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    QDLogVerbose(@"%@", request);
    return YES;
}

@end
