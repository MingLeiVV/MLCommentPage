//
//  ViewController.m
//  MLCommentPage
//
//  Created by 吴明磊 on 2017/7/24.
//  Copyright © 2017年 吴明磊. All rights reserved.
//

#import "ViewController.h"
#import "MLCommentViewController.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    MLCommentViewController *comment = [[MLCommentViewController alloc] init];
    comment.servers = @"https://platform.sina.com.cn/sports_client/comment?";
    NSDictionary* param = [NSDictionary dictionaryWithObjectsAndKeys:@"json",@"format",@"ty",@"channel",@"2119896207-7e5b0c8f001002yrr",@"newsid",@(0),@"group",@(2923419926),@"app_key", nil];
    comment.parameter = param;
    
    [self.navigationController pushViewController:comment animated:YES];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
