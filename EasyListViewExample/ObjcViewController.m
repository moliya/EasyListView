//
//  ObjcViewController.m
//  EasyListViewExample
//
//  Created by carefree on 2020/8/8.
//  Copyright © 2020 carefree. All rights reserved.
//

#import "ObjcViewController.h"
#import "EasyListViewExample-Swift.h"

@interface ObjcViewController ()<UIScrollViewDelegate>

@property (nonatomic, strong) EasyListView  *scrollView;

@end

@implementation ObjcViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = UIColor.whiteColor;
    EasyListView *scrollView = [[EasyListView alloc] init];
    scrollView.alwaysBounceVertical = YES;
    scrollView.frame = self.view.bounds;
    [self.view addSubview:scrollView];
    
    self.scrollView = scrollView;
    EasyListCoordinator *coordinator = [[EasyListCoordinator alloc] initWithScrollView:scrollView];
    coordinator.globalEdgeInsets = UIEdgeInsetsZero;
    coordinator.animationDuration = 0.4;
    coordinator.globalSpacing = 1;
    
    [scrollView easy_appendView:({
        UIView *view = [[UIView alloc] init];
        view.backgroundColor = UIColor.cyanColor;
        view.translatesAutoresizingMaskIntoConstraints = NO;
        [view.heightAnchor constraintEqualToConstant:40].active = YES;
        
        view;
    }) spacing:10];
    [scrollView easy_appendView:({
        UIView *view = [[UIView alloc] init];
        view.backgroundColor = UIColor.blueColor;
        view.translatesAutoresizingMaskIntoConstraints = NO;
        [view.heightAnchor constraintEqualToConstant:30].active = YES;
        
        view;
    }) forIdentifier:@"test" withInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
    
    [scrollView easy_insertView:UIView.new after:@"" withInsets:UIEdgeInsetsZero forIdentifier:@"" completion:^{
        
    }];
    
    [scrollView easy_batchDelete:^(UIScrollView * _Nonnull scrollView) {
        
    } completion:nil];
    [scrollView easy_getElementWithIdentifier:@""];
    
    NSArray *array = scrollView.easy_visibleReusableElements;
    UIView *reusableView = [scrollView easy_reusableViewWithMaker:^UIView * _Nonnull{
        UIView *view = [[UIView alloc] init];
        
        return view;
    }];
    
}

@end
