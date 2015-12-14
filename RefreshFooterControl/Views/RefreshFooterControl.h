//
//  RefreshFooterControl.h
//  RefreshFooterControl
//
//  Created by Thomson on 15/12/2.
//  Copyright © 2015年 KEMI. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RACSignal;
@class RACCommand;

typedef NS_ENUM(NSUInteger, RefreshFooterControlState) {
    RefreshFooterControlStateNormal = 1,
    RefreshFooterControlStatePulling = 2,
    RefreshFooterControlStateRefreshing = 3
};

@interface RefreshFooterControl : UIView

@property (nonatomic, readonly, getter=isRefreshing) BOOL refreshing;
@property (nonatomic, readonly) RefreshFooterControlState state;
@property (nonatomic, readonly) RACSignal *controlStateSignal;

@property (nonatomic, strong) RACCommand *rac_command;

+ (instancetype)footerControlWithTableView:(UITableView *)tableView;

@end
