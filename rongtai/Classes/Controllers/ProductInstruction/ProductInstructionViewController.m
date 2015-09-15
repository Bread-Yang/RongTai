//
//  ProductInstructionViewController.m
//  rongtai
//
//  Created by yoghourt on 6/14/15.
//  Copyright (c) 2015 William-zhang. All rights reserved.
//

#import "ProductInstructionViewController.h"
#import "UIBarButtonItem+goBack.h"

@interface ProductInstructionViewController ()

@end

@implementation ProductInstructionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem goBackItemByTarget:self Action:@selector(back)];
    // Do any additional setup after loading the view.
}

#pragma mark - 返回按钮方法
-(void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
