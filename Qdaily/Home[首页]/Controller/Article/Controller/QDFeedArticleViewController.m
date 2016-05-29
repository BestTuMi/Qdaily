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
#import "QDFeedArticleModel.h"
#import <MJExtension.h>
#import <WebViewJavascriptBridge.h>
#import "QDCategoryFeedViewController.h"
#import "QDPhotoBrowse.h"
#import "QDFeedCompactCell.h"
#import "QDFeedPaperCell.h"
#import "QDRecommendCell.h"
#import "QDCommentCell.h"
#import "QDRefreshFooter.h"
#import "QDComment.h"
#import "QDChildComment.h"
#import "QDSeparateCell.h"
#import "QDCommentField.h"

@interface QDFeedArticleViewController () <UIWebViewDelegate, MWPhotoBrowserDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, RecommendCellDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *transitionAnimView;
/** 加载动画序列 */
@property (nonatomic, copy) NSArray *animationImages;
@property (weak, nonatomic) UIWebView *webView;
/** html 相关模型 */
@property (nonatomic, strong) QDFeedArticleModel *article;
/** JS跟 OC 互调的 bridge */
@property WebViewJavascriptBridge* bridge;
/** 需要图片浏览器浏览的图片 */
@property (nonatomic, strong)  NSArray *photos;
/** 相关的新闻 */
@property (nonatomic, copy) NSArray *releatedFeeds;
/** 推荐的新闻 */
@property (nonatomic, copy) NSArray *recommendFeeds;
/** 评论 */
@property (nonatomic, strong) NSMutableArray *comments;
/** 底部数据数组 */
@property (nonatomic, strong) NSMutableArray *footerDatas;
/** collectionView */
@property (nonatomic, weak) UICollectionView *collectionView;

/** 是否有更多数据 */
@property (nonatomic,  assign) BOOL has_more;
/** 请求更多数据时传的值 */
@property (nonatomic,  copy) NSString *last_time;

/** 用于计算评论 cell 的高度 */
@property (nonatomic, strong)  QDCommentCell *commentCellTool;
/** 用于计算调查报告 cell 的高度 */
@property (nonatomic, strong)  QDFeedPaperCell *paperCellTool;

/******* 工具条相关 ******/
@property (weak, nonatomic) IBOutlet UIView *shareToolV;
@property (weak, nonatomic) IBOutlet UIButton *shareBtn;
@property (weak, nonatomic) IBOutlet UIButton *commentBtn;
@property (weak, nonatomic) IBOutlet UIButton *praiseBtn;
@property (weak, nonatomic) IBOutlet UIView *commentFieldV;
@property (weak, nonatomic) IBOutlet QDCommentField *commentField;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *toolBarBottom;
@end

@implementation QDFeedArticleViewController

static NSString * const compactIdentifier = @"feedCompactCell";
static NSString * const paperIdentifier = @"feedPaperCell";
static NSString * const recommendIdentifier = @"recommendCell";
static NSString * const commentIdentifier = @"commentCell";
static NSString * const separateCell = @"separateCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupToolBar];
    
    [self setupCollectionView];
    
    [self setupWebView];
    
    [self setupDatas];

    [self startTrasition];
}

#pragma mark - viewWillDisAppear
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    // 避免蒙版未清除
    for (UIWindow *window in [UIApplication sharedApplication].windows) {
        [MBProgressHUD hideHUDForView:window];
    }
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

- (NSMutableArray *)comments {
    if (!_comments) {
        _comments = [NSMutableArray array];
    }
    return _comments;
}

- (NSMutableArray *)footerDatas {
    if (!_footerDatas) {
        _footerDatas = [NSMutableArray array];
    }
    return _footerDatas;
}

- (void)setFeed:(QDFeed *)feed {
    _feed = feed;
}

#pragma mark - 设置工具条
- (void)setupToolBar {
    // 取消点赞的高亮状态
    [self.praiseBtn setAdjustsImageWhenHighlighted:NO];
    
    // 添加对键盘的监听
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(commentFieldChange:) name:UIKeyboardWillChangeFrameNotification object:nil];
    
    // 分享相关的数据
    [self.praiseBtn setTitle:(self.feed.post.praise_count ? @(self.feed.post.praise_count).stringValue : @"") forState:UIControlStateNormal];
    [self.commentBtn setTitle:(self.feed.post.comment_count ? @(self.feed.post.comment_count).stringValue : @"") forState:UIControlStateNormal];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - 监听键盘
- (void)commentFieldChange: (NSNotification *)note {
    CGRect endFrame = [note.userInfo[@"UIKeyboardFrameEndUserInfoKey"] CGRectValue];
    NSTimeInterval duration = [note.userInfo[@"UIKeyboardAnimationDurationUserInfoKey"] doubleValue] ;
    UIViewKeyframeAnimationOptions animationOptions = [note.userInfo[@"UIKeyboardAnimationCurveUserInfoKey"] integerValue];
    self.toolBarBottom.constant = QDScreenH - endFrame.origin.y;
    // 更新约束
    [UIView animateKeyframesWithDuration:duration delay:0 options:animationOptions animations:^{
        [self.view layoutIfNeeded];
    } completion:nil];
}

#pragma mark - 点赞
- (IBAction)praiseBtnClick:(UIButton *)button {
    BOOL isCancel = self.praiseBtn.selected;
    self.praiseBtn.selected = !self.praiseBtn.selected;
    [[QDFeedTool sharedFeedTool] praiseWithPostId:_feed.post.ID.integerValue isCancel:isCancel finished:^(NSDictionary *responseObject, NSError *error) {
        // 验证数据
        if (error) {
            QDLogVerbose(@"%@", error);
        }
        // 修改 button 的数据
        NSInteger currentCount = self.praiseBtn.currentTitle.integerValue;
        [self.praiseBtn setTitle:@(currentCount + (isCancel ? (-1) : 1)).stringValue forState:UIControlStateNormal];
    }];
}

- (IBAction)shareBtnClick:(id)sender {
    
}

#pragma mark - 点赞按钮
- (IBAction)commentBtnClick:(id)sender {
    self.commentFieldV.alpha = 1.0;
    [self.commentField becomeFirstResponder];
}

#pragma mark - 设置 collectionView
- (void)setupCollectionView {
    self.safe_navigationBarHidden = YES;
    self.automaticallyAdjustsScrollViewInsets = NO;
    // layout
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    layout.minimumInteritemSpacing = 0;
    layout.minimumLineSpacing = 0;
    
    // collectionView
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:[UIScreen mainScreen].bounds collectionViewLayout:layout];
    [self.view insertSubview:collectionView atIndex:0];
    collectionView.contentInset = UIEdgeInsetsMake(0, 0, QDToolBarH, 0);
    collectionView.scrollIndicatorInsets = collectionView.contentInset;
    self.collectionView = collectionView;
    self.collectionView.backgroundColor = QDRGBWhiteColor(1, 1);
    
    // 手势
    self.collectionView.delaysContentTouches = NO;
    
    // 初始 alpha 为0,网页加载完毕后再显示
    self.collectionView.alpha = 0;
    
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    
    // 注册
    [self.collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([QDFeedCompactCell class]) bundle:nil] forCellWithReuseIdentifier:compactIdentifier];
    [self.collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([QDFeedPaperCell class]) bundle:nil] forCellWithReuseIdentifier:paperIdentifier];
    [self.collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([QDRecommendCell class]) bundle:nil] forCellWithReuseIdentifier:recommendIdentifier];
    [self.collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([QDCommentCell class]) bundle:nil] forCellWithReuseIdentifier:commentIdentifier];
    [self.collectionView registerClass:[QDSeparateCell class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:separateCell];
    
    // 设置刷新控件
    [self setupRefresh];
}

- (void)setupRefresh {
    self.collectionView.footer = [QDRefreshFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMore)];
}

#pragma mark - 加载更多评论
- (void)loadMore {
    NSString *commentUrl = [NSString stringWithFormat:@"/app/comments/index/article/%@/%@.json?", _feed.post.ID, self.last_time];
    [[QDFeedTool sharedFeedTool] get:commentUrl finished:^(NSDictionary *responseObject, NSError *error) {
        // 验证数据
        if (error) {
            QDLogVerbose(@"%@", error);
        }
        
        self.has_more = [responseObject[@"response"][@"comments"][@"has_more"] boolValue];
        if (self.has_more) {
            self.last_time = responseObject[@"response"][@"comments"][@"last_time"];
        }
        
        NSArray *comments = [QDComment objectArrayWithKeyValuesArray:responseObject[@"response"][@"comments"][@"list"]];
        // 重新组织数据,补上子评论
        for (int i = 0; i < comments.count; i++) {
            QDComment *comment = comments[i];
            // 添加评论
            [self.comments addObject:comment];
            // 如果有子评论,继续添加
            if (comment.child_comments.count) { // 有子节点
                for (int j = 0 ; j < comment.child_comments.count; j++) {
                    QDChildComment *childComment = comment.child_comments[j];
                    if (j == (comment.child_comments.count - 1)) {
                        childComment.isLastComment = YES;
                    }
                    [self.comments addObject:childComment];
                }
            }
        }

        [self.collectionView reloadData];
        
        if (self.has_more) {
            [self.collectionView.footer endRefreshing];
        } else {
            self.collectionView.footer.hidden = YES;
        }
        
        // 重新布局(肯能会造成 inset 不正确)
        [self layoutCollectionView];
    }];

}

#pragma mark - 设置 WebView
- (void)setupWebView {
    UIWebView *webView = [[UIWebView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [self.collectionView addSubview:webView];
    self.webView = webView;
    self.webView.delegate = self;
    self.webView.scalesPageToFit = YES;
    self.webView.scrollView.scrollEnabled = NO;
    
    // 实例化 bridge
    _bridge = [WebViewJavascriptBridge bridgeForWebView:_webView webViewDelegate:self handler:^(id data, WVJBResponseCallback responseCallback) {
        
    }];
    
    // 注册 JS 调用给的方法
    [_bridge registerHandler:@"qdaily::gotoPage" handler:^(id data, WVJBResponseCallback responseCallback) {
        QDLog(@"picsPreview called: %@", data);
        NSString *type = data[@"type"];
        NSDictionary *params = data[@"params"];
        QDCategoryFeedViewController *categoryVc = [[QDCategoryFeedViewController alloc] init];
        categoryVc.params = params;
        categoryVc.type = type;
        
        // push
        [self.navigationController pushViewController:categoryVc animated:YES];
    }];
    
    [_bridge registerHandler:@"qdaily::picsPreview" handler:^(id data, WVJBResponseCallback responseCallback) {
        QDLog(@"picsPreview called: %@", data);
        NSArray *pics = data[@"pics"];
        NSInteger cur = [data[@"cur"] integerValue];
  
        // 弹出图片浏览器
        [self pushPhotoBrowserWithPics:pics currentIndex:cur];
    }];
    
    // 请求文章相关数据
    NSString *urlStr = [NSString stringWithFormat:@"/app/articles/detail/%@.json?", _feed.post.ID];
    [[QDFeedTool sharedFeedTool] get:urlStr finished:^(NSDictionary *responseObject, NSError *error) {
        // 验证数据
        if (error) {
            QDLogVerbose(@"%@", error);
            return;
        }
        
        self.article = [QDFeedArticleModel objectWithKeyValues:responseObject[@"response"][@"article"]];
        [self.webView loadHTMLString:self.article.body baseURL:QDBaseURL];
        
    }];
}

#pragma mark - 布局 collectionView
- (void)layoutCollectionView {
    // 获得 webview 的高度
    CGFloat webViewHeight = [[self.webView stringByEvaluatingJavaScriptFromString:@"document.body.scrollHeight"] floatValue];
    self.collectionView.contentInset = UIEdgeInsetsMake(webViewHeight, 0, QDWebViewToolBarH, 0);
    self.webView.frame = CGRectMake(0, 0, QDScreenW, - webViewHeight);
}

#pragma mark - 初始化数据
- (void)setupDatas {
    NSString *urlStr = [NSString stringWithFormat:@"/app/articles/info/%@.json?", _feed.post.ID];
    [[QDFeedTool sharedFeedTool] get:urlStr finished:^(NSDictionary *responseObject, NSError *error) {
        // 验证数据
        if (error) {
            QDLogVerbose(@"%@", error);
            return;
        }
        
        self.releatedFeeds = [QDFeed objectArrayWithKeyValuesArray:responseObject[@"response"][@"related"]];
        NSMutableArray *recommendFeeds = [NSMutableArray array];
        [recommendFeeds addObject:[QDFeed objectArrayWithKeyValuesArray:responseObject[@"response"][@"recommend"]].firstObject];
        [recommendFeeds addObject:[QDFeed objectArrayWithKeyValuesArray:responseObject[@"response"][@"recommend_two"]].firstObject];
        [recommendFeeds addObject:[QDFeed objectArrayWithKeyValuesArray:responseObject[@"response"][@"recommend_three"]].firstObject];
        [recommendFeeds addObject:[QDFeed objectArrayWithKeyValuesArray:responseObject[@"response"][@"recommend_four"]].firstObject];
        [recommendFeeds addObject:[QDFeed objectArrayWithKeyValuesArray:responseObject[@"response"][@"recommend_five"]].firstObject];
        self.recommendFeeds = recommendFeeds;
        
        [self.footerDatas addObject:self.releatedFeeds];
        [self.footerDatas addObject:self.recommendFeeds];
        
        // 评论数据
        self.last_time = @"0";
        NSString *commentUrl = [NSString stringWithFormat:@"/app/comments/index/article/%@/%@.json?", _feed.post.ID, self.last_time];
        [[QDFeedTool sharedFeedTool] get:commentUrl finished:^(NSDictionary *responseObject, NSError *error) {
            // 验证数据
            if (error) {
                QDLogVerbose(@"%@", error);
                return;
            }
            
            // 清空评论
            [self.comments removeAllObjects];
            
            self.has_more = [responseObject[@"response"][@"comments"][@"has_more"] boolValue];
            if (self.has_more) {
                self.last_time = responseObject[@"response"][@"comments"][@"last_time"];
            }
            
            NSArray *comments = [QDComment objectArrayWithKeyValuesArray:responseObject[@"response"][@"comments"][@"list"]];
            // 重新组织数据,补上子评论
            for (int i = 0; i < comments.count; i++) {
                QDComment *comment = comments[i];
                // 添加评论
                [self.comments addObject:comment];
                // 如果有子评论,继续添加
                if (comment.child_comments.count) { // 有子节点
                    for (int j = 0 ; j < comment.child_comments.count; j++) {
                        QDChildComment *childComment = comment.child_comments[j];
                        if (j == (comment.child_comments.count - 1)) {
                            childComment.isLastComment = YES;
                        }
                        [self.comments addObject:childComment];
                    }
                }
            }
            
            [self.footerDatas addObject:self.comments];
            
            [self.collectionView reloadData];
            
            if (!self.has_more) {
                self.collectionView.footer.hidden = YES;
            }
        }];
    }];
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

#pragma mark -
#pragma mark - 图片浏览器
- (void)pushPhotoBrowserWithPics: (NSArray *)pics currentIndex: (NSInteger)cur {
    // Browser
    NSMutableArray *photos = [NSMutableArray arrayWithCapacity:pics.count];
    BOOL displayActionButton = NO;
    BOOL displaySelectionButtons = NO;
    BOOL displayNavArrows = NO;
    BOOL enableGrid = NO;
    BOOL startOnGrid = NO;
    
    // Create browser
    QDPhotoBrowse *browser = [[QDPhotoBrowse alloc] initWithDelegate:self];
    browser.displayActionButton = displayActionButton;
    browser.displayNavArrows = displayNavArrows;
    browser.displaySelectionButtons = displaySelectionButtons;
    browser.alwaysShowControls = displaySelectionButtons;
    browser.zoomPhotosToFill = YES;
    browser.enableGrid = enableGrid;
    browser.startOnGrid = startOnGrid;
    browser.enableSwipeToDismiss = NO;
    
    // 添加 MWPhoto 模型
    for (int i = 0; i < pics.count; i++) {
        NSString *urlStr = nil;
        urlStr = pics[i];
        if (![urlStr hasPrefix:@"http://"]) {
            urlStr = [NSString stringWithFormat:@"%@%@", QDBaseURL, urlStr];
        }
        NSURL *url = [NSURL URLWithString:urlStr];
        MWPhoto *photo = [MWPhoto photoWithURL:url];
        [photos addObject:photo];
    }
    
    self.photos = photos;
    
    [browser setCurrentPhotoIndex:cur];
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:browser];
    nc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:nc animated:YES completion:nil];
    
}

#pragma mark - MWPhotoBrowserDelegate

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    return _photos.count;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    if (index < _photos.count)
        return [_photos objectAtIndex:index];
    return nil;
}

- (void)photoBrowser:(QDPhotoBrowse *)photoBrowser didDisplayPhotoAtIndex:(NSUInteger)index {
    photoBrowser.labelTitle = [NSString stringWithFormat:@"%zd / %zd", index + 1, self.photos.count];
}

#pragma mark - webView delegate
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [MBProgressHUD showMessage:@"加载失败"];
    
    QDWeakSelf;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        for (UIWindow *window in [UIApplication sharedApplication].windows) {
            [MBProgressHUD hideHUDForView:window];
        }
        // pop
        [weakSelf.navigationController popViewControllerAnimated:YES];
    });
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {

    // 获得 webview 的高度
    CGFloat webViewHeight = [[self.webView stringByEvaluatingJavaScriptFromString:@"document.body.scrollHeight"] floatValue];
    self.collectionView.contentInset = UIEdgeInsetsMake(webViewHeight, 0, QDWebViewToolBarH, 0);
    self.webView.frame = CGRectMake(0, 0, QDScreenW, - webViewHeight);
    
    self.collectionView.contentOffset = CGPointMake(0, - webViewHeight);
    // 转场
    [UIView animateWithDuration:0.25 animations:^{
        self.transitionAnimView.alpha = 0;
        self.collectionView.alpha = 1.0;
        self.shareToolV.alpha = 1.0;
    }];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
//    QDLogVerbose(@"%@", request);
    return YES;
}

#pragma mark - collectionView datasource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return self.footerDatas.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (section == 0) {
        return self.releatedFeeds.count;
    } else if (section == 1) {
        return 1;
    } else {
        return self.comments.count;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        QDFeed *feed = self.releatedFeeds[indexPath.item];
        if (feed.post.genre == QDGenrePaper || feed.post.genre == QDGenreReport || feed.post.genre == QDGenreVote) { // 好奇心实验室
            // 注意:报告的类型是小图,所以要先判断
            QDFeedPaperCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:paperIdentifier forIndexPath:indexPath];
            feed.post.isNew = (indexPath.item == 0 || indexPath.item == 1) ? YES : NO;
            cell.feed = feed;
            return cell;
        } else { // QDFeedCellTypeCompact
            QDFeedCompactCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:compactIdentifier forIndexPath:indexPath];
            cell.feed = feed;
            return cell;
        }
    } else if (indexPath.section == 1) {
        QDRecommendCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:recommendIdentifier forIndexPath:indexPath];
        cell.delegate = self;
        NSArray *recommends = self.recommendFeeds;
        cell.recommends = recommends;
        return cell;
    } else { // 评论
        QDCommentCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:commentIdentifier forIndexPath:indexPath];
        QDComment *comment = self.comments[indexPath.item];
        cell.comment = comment;
        return cell;
    }
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    QDSeparateCell *cell = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:separateCell forIndexPath:indexPath];
    return cell;
}

#pragma mark - layout delegate
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    return CGSizeMake(QDScreenW, 10);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    if (section == 0) {
        return 3;
    } else {
        return 0;
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        QDFeed *feed = self.releatedFeeds[indexPath.item];
        if (feed.post.genre == QDGenrePaper || feed.post.genre == QDGenreReport || feed.post.genre == QDGenreVote) { // 好奇心实验室
            // 注意:报告的类型是小图,所以要先判断
            self.paperCellTool = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([QDFeedPaperCell class]) owner:nil options:nil].lastObject;
            self.paperCellTool.feed = feed;
            return CGSizeMake(QDScreenW, self.paperCellTool.cellHeight);
        } else { // 这里只会有大 Cell
            return CGSizeMake(QDScreenW, QDScreenW * 173 / 320);
        }
    } else if (indexPath.section == 1) {
        return CGSizeMake(QDScreenW, QDScreenW * 240 / 320);
    } else {
        // 取模型
        QDComment *comment = self.comments[indexPath.item];
        self.commentCellTool = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([QDCommentCell class]) owner:nil options:nil].lastObject;
        self.commentCellTool.comment = comment;
        CGFloat cellHeight = self.commentCellTool.cellHeight;
        return CGSizeMake(QDScreenW, cellHeight);
    }
}

#pragma mark - recommend Cell delegate
- (void)recommendCell:(QDRecommendCell *)cell didClickedAtIndex:(NSInteger)index {
    QDFeedArticleViewController *articleVc = [[QDFeedArticleViewController alloc] init];
    articleVc.feed = self.recommendFeeds[index];
    [self.navigationController pushViewController:articleVc animated:YES];
}

#pragma mark - collectionView delegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        QDFeedArticleViewController *articleVc = [[QDFeedArticleViewController alloc] init];
        articleVc.feed = self.releatedFeeds[indexPath.item];
        [self.navigationController pushViewController:articleVc animated:YES];
    } else if (indexPath.section == 2) {
        QDLogVerbose(@"弹窗");
    }
}

#pragma mark - scrollView delegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.commentField endEditing:YES];
}

@end
