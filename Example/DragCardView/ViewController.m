//
//  NoneViewController.m
//  DragCardView
//
//  Created by huangyq0810 on 07/27/2018.
//  Copyright (c) 2018 huangyq0810. All rights reserved.
//

#import "ViewController.h"
#import <DragCardView/DragCardView.h>

@interface ViewController () <DragCardViewDataSource>

@property (nonatomic, strong) DragCardView *dragView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.dragView = [[DragCardView alloc] init];
    self.dragView.dataSource = self;
    [self.view addSubview:self.dragView];
    self.dragView.frame = self.view.bounds;
}

/* 发起网络请求，获得数据 */
- (NSMutableArray *)requestSourceData {
    // 模拟网络请求
    NSMutableArray *objectArray = [@[] mutableCopy];
    for (int i = 1; i <= 10; i++) {
        [objectArray addObject:@{@"number":[NSString stringWithFormat:@"%ld",self.dragView.page * 10 + i],@"image":[NSString stringWithFormat:@"%d.jpg",i]}];
    }
    return objectArray;
}

@end
