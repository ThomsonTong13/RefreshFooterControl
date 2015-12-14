//
//  ViewController.m
//  RefreshFooterControl
//
//  Created by Thomson on 15/12/2.
//  Copyright © 2015年 KEMI. All rights reserved.
//

#import "ViewController.h"
#import "RefreshFooterControl.h"

#import "ReactiveCocoa.h"

@interface ViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) RefreshFooterControl *footerControl;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *itemsArray;

@end

@implementation ViewController

#pragma mark - Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    for (NSInteger index = 0; index < 20; index ++)
    {
        [self.itemsArray addObject:@(index)];
    }

    [self.tableView reloadData];

    self.footerControl = [RefreshFooterControl footerControlWithTableView:self.tableView];
    self.footerControl.rac_command = [[RACCommand alloc]
                                       initWithSignalBlock:^RACSignal *(id input) {

                                           return [RACSignal
                                                   createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {

                                                       dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{

                                                           NSInteger count = [_itemsArray count];

                                                           for (NSInteger index = count; index < count+20; index ++)
                                                               [_itemsArray addObject:@(index)];

                                                           [self.tableView reloadData];

                                                           [subscriber sendCompleted];
                                                       });

                                                       return nil;
                                                   }];
                                       }];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_itemsArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellIdentifier"];

    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cellIdentifier"];
    }

    cell.textLabel.text = [NSString stringWithFormat:@"The row number: %@", _itemsArray[indexPath.row]];

    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Getters & Setters

- (NSMutableArray *)itemsArray
{
    if (!_itemsArray)
    {
        _itemsArray = [[NSMutableArray alloc] initWithCapacity:0];
    }

    return _itemsArray;
}

@end
