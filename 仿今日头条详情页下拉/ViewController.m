//
//  ViewController.m
//  仿今日头条详情页下拉
//
//  Created by ryan on 16/7/20.
//  Copyright © 2016年 ryan. All rights reserved.
//

#define viewSize self.view.frame.size
#define viewWidth viewSize.width
#define viewHeight viewSize.height
#define entry_bottomHeight  30

#import "ViewController.h"
#import "UIView+Extension.h"

@interface ViewController ()<UIWebViewDelegate,UITableViewDelegate,UITableViewDataSource,UIScrollViewDelegate>{
    int state;
}

@property (nonatomic, strong) UIWebView *webView;

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIView *bottomView;// webView下面的View,tag,观看人数,用户头像


@end

enum scollStatus {
    XTTableViewScoll = 1,
    XTWebViewScoll = 2
};


@implementation ViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    state = XTTableViewScoll;
    [self setUI];
    [self loadHtml];
}
#pragma mark Func
- (void)setUI{
    UIView * headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, viewWidth, self.view.height)];
    headerView.clipsToBounds = YES;
    [headerView addSubview:self.webView];
    [self.webView.scrollView addSubview:self.bottomView];
    self.tableView.tableHeaderView = headerView;
    [self.view addSubview:_tableView];
}

#pragma mark WebView
- (void)loadHtml{
    
    NSString *htmlPath = [[NSBundle mainBundle] pathForResource:@"details" ofType:@"html"];
    NSString *htmlString = [NSString stringWithContentsOfFile:htmlPath encoding:NSUTF8StringEncoding error:nil];
    NSURL *baseURL = [NSURL fileURLWithPath:htmlPath];
    [_webView loadHTMLString:htmlString baseURL:baseURL];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    CGFloat scrollHeight = [[webView stringByEvaluatingJavaScriptFromString:@"document.body.scrollHeight"] floatValue];
    _webView.scrollView.contentSize = CGSizeMake(0, scrollHeight + entry_bottomHeight);
    self.bottomView.y = scrollHeight;
    
}



#pragma mark tableViewDelegate DataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 30;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *cellId = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    
    cell.textLabel.text = [NSString stringWithFormat:@"%d",arc4random() % 100];
    
    return cell;
    
}

#pragma mark scrollview delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    CGFloat top = scrollView.contentOffset.y;
    CGFloat webBottomY = _webView.scrollView.contentSize.height - self.view.height;
     if (scrollView == _webView.scrollView) {
        if (top >= webBottomY) {
            state = XTTableViewScoll;
        }else{
            state = XTWebViewScoll;
        }
        if (top > 100) {
            _webView.scrollView.bounces = NO;
        }else{
            _webView.scrollView.bounces = YES;
        }
    }else if([scrollView isKindOfClass:[UITableView class]]){
        if (top > (_tableView.contentSize.height - viewHeight - 100)) {
            _tableView.bounces = YES;
        }else{
            _tableView.bounces = NO;
        }
        if (top <= 0) {
            state = XTWebViewScoll;
        }else{
            state = XTTableViewScoll;
        }
    }
    if (_tableView.isScrollEnabled) {
        _tableView.scrollEnabled = (state == XTTableViewScoll);
    }
    if (_webView.scrollView.isScrollEnabled) {
        _webView.scrollView.scrollEnabled = (state == XTWebViewScoll);
    }

    BOOL isWebViewBottom = (scrollView == _webView.scrollView) && (top == webBottomY);
    BOOL isTableViewTop = (scrollView == _tableView) && (top == 0);
    if (isTableViewTop || isWebViewBottom){
        _tableView.scrollEnabled = YES;
        _webView.scrollView.scrollEnabled = YES;
        _tableView.showsVerticalScrollIndicator = NO;
        _webView.scrollView.showsVerticalScrollIndicator = NO;
    }else{
        _tableView.showsVerticalScrollIndicator = YES;
        _webView.scrollView.showsVerticalScrollIndicator = YES;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - lazyLoad
- (UIWebView *)webView{
    if (!_webView) {
        _webView = [[UIWebView alloc] init];
        _webView.frame = CGRectMake(0, 0, viewWidth, self.view.height);
        _webView.delegate = self;
        _webView.scrollView.delegate = self;
    }
    return _webView;
}
- (UIView *)bottomView {
    if (!_bottomView) {
        _bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, 667, self.view.width, entry_bottomHeight)];
        _bottomView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    }
    return _bottomView;
}

- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] init];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        
        _tableView.bounces = NO;
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.scrollEnabled = NO;
        _tableView.frame = CGRectMake(0, 0, viewWidth, viewHeight);
    }
    return _tableView;
}

@end
