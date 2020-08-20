//
//  ObjCTestController.m
//  EasyListViewExample
//
//  Created by carefree on 2020/8/18.
//  Copyright © 2020 carefree. All rights reserved.
//

#import "ObjCTestController.h"
#import "EasyListViewExample-Swift.h"

@interface ObjCTestController ()

@end

@implementation ObjCTestController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    EasyListView *listView = [[EasyListView alloc] init];
    [listView easy_beginUpdates];
    [listView easy_endUpdatesWithCompletion:nil];
}

@end
