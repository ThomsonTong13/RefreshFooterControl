//
//  RefreshFooterControl.m
//  RefreshFooterControl
//
//  Created by Thomson on 15/12/2.
//  Copyright © 2015年 KEMI. All rights reserved.
//

#import "RefreshFooterControl.h"
#import "ReactiveCocoa.h"
#import "Masonry.h"

#define kScreenHeight ([UIScreen mainScreen].bounds.size.height)
#define kScreenWidth  ([UIScreen mainScreen].bounds.size.width)

static CGFloat const kDefaultDistance = 44.f;

@interface RefreshFooterControl ()

@property (nonatomic, readwrite, getter=isRefreshing) BOOL refreshing;
@property (nonatomic, readwrite) RefreshFooterControlState state;

@property (nonatomic, strong) UILabel *moreLabel;
@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, assign) UIEdgeInsets contentInset;

@property (nonatomic, strong) RACSubject *successSubject;
@property (nonatomic, strong) RACSignal *successSignal;
@property (nonatomic, readwrite) RACSignal *controlStateSignal;
@property (nonatomic, strong) RACSubject *controlStateSubject;

@end

@implementation RefreshFooterControl

+ (instancetype)footerControlWithTableView:(UITableView *)tableView
{
    return [[self alloc] initWithTableView:tableView];
}

- (instancetype)initWithTableView:(UITableView *)tableView
{
    if (self = [super init])
    {
        _tableView = tableView;

        _state = RefreshFooterControlStateNormal;
        [self.controlStateSubject sendNext:@(RefreshFooterControlStateNormal)];

        [self setupLoaderView];
        [self setupActionsBind];
        [self observeOfTableView];
    }

    return self;
}

- (void)setupLoaderView
{
    self.frame = CGRectMake(0, 0, kScreenWidth, kDefaultDistance);
    self.backgroundColor = self.tableView.backgroundColor;
    self.tableView.tableFooterView = self;

    [self addSubview:self.indicatorView];
    [self addSubview:self.moreLabel];

    @weakify(self);
    [self.moreLabel mas_makeConstraints:^(MASConstraintMaker *make) {

        @strongify(self);

        make.top.equalTo(self.mas_top);
        make.bottom.equalTo(self.mas_bottom);
        make.centerX.equalTo(self.mas_centerX);
    }];

    [self.indicatorView mas_makeConstraints:^(MASConstraintMaker *make) {

        @strongify(self);
        make.centerY.equalTo(self.mas_centerY);
        make.left.equalTo(self.moreLabel.mas_left).with.offset(-(self.indicatorView.frame.size.width + 5));
    }];
}

- (void)setupActionsBind
{
    @weakify(self);
    [self.successSignal subscribeNext:^(NSNumber *success) {
        @strongify(self);

        if (success.boolValue) [self endRefreshing];
    }];
}

- (void)observeOfTableView
{
    @weakify(self);
    [RACObserve(self.tableView, contentOffset) subscribeNext:^(NSValue *contentOffset) {
        @strongify(self);

        if (!self.refreshing)
        {
            CGRect  frame = self.tableView.frame;
            CGSize  contentSize = self.tableView.contentSize;
            CGPoint contentOffset = self.tableView.contentOffset;

            CGFloat offsetY = frame.size.height + contentOffset.y - contentSize.height;
            if (offsetY > 0)
            {
                self.state = RefreshFooterControlStatePulling;
                [self.controlStateSubject sendNext:@(RefreshFooterControlStatePulling)];
                [self startRefreshing];
            }
        }
    }];
}

- (void)startRefreshing
{
    [self startAnimating];
    
    @weakify(self);
    [UIView animateWithDuration:0.6f
                          delay:0.f
         usingSpringWithDamping:0.6f
          initialSpringVelocity:0.2f
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{

                     } completion:^(BOOL finished) {

                         @strongify(self);

                         self.refreshing = YES;
                         self.state = RefreshFooterControlStateRefreshing;
                         [self.controlStateSubject sendNext:@(RefreshFooterControlStateRefreshing)];

                         if (self.rac_command) {
                             [[self.rac_command execute:nil] subscribeCompleted:^{
                                 [self.successSubject sendNext:@(YES)];
                             }];
                         }
                     }];
}

- (void)endRefreshing
{
    @weakify(self);
    [UIView animateWithDuration:0.8f
                          delay:0.f
         usingSpringWithDamping:0.4f
          initialSpringVelocity:0.8f
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{

                     } completion:^(BOOL finished) {
                         @strongify(self);

                         self.refreshing = NO;
                         self.state = RefreshFooterControlStateNormal;
                         [self.controlStateSubject sendNext:@(RefreshFooterControlStateNormal)];

                         [self endAnimating];
                     }];
}

- (void)startAnimating
{
    [self.indicatorView startAnimating];
}

- (void)endAnimating
{
    [self.indicatorView stopAnimating];
}

#pragma mark - getters and setters

- (RACSignal *)successSignal
{
    if (!self.successSubject)
    {
        self.successSubject = [RACSubject new];
    }

    return self.successSubject;
}

- (RACSignal *)controlStateSignal
{
    if (_controlStateSubject)
    {
        _controlStateSubject = [RACSubject new];
    }

    return _controlStateSubject;
}

- (UIActivityIndicatorView *)indicatorView
{
    if (!_indicatorView)
    {
        _indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _indicatorView.hidesWhenStopped = NO;
    }

    return _indicatorView;
}

- (UILabel *)moreLabel
{
    if (!_moreLabel)
    {
        _moreLabel = [UILabel new];
        _moreLabel.font = [UIFont systemFontOfSize:15.f];
        _moreLabel.textColor = [UIColor blackColor];
        _moreLabel.backgroundColor = [UIColor clearColor];
        _moreLabel.textAlignment = NSTextAlignmentLeft;
        _moreLabel.text = @"Loading...";
    }

    return _moreLabel;
}

@end
