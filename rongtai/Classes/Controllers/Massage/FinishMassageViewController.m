//
//  FinishMassageViewController.m
//  rongtai
//
//  Created by William-zhang on 15/6/15.
//  Copyright (c) 2015年 William-zhang. All rights reserved.
//

#import "FinishMassageViewController.h"
#import "IQKeyboardManager.h"
#import "RongTaiConstant.h"

@interface FinishMassageViewController ()<UIAlertViewDelegate>
{
    
}
@end

@implementation FinishMassageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"按摩完毕", nil);
    
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem goBackItemByTarget:self Action:@selector(goBack)];
    
    UIBarButtonItem* share = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"icon_share"] style:UIBarButtonItemStylePlain target:self action:@selector(share)];
    self.navigationItem.rightBarButtonItem = share;
    // Do any additional setup after loading the view.
}

#pragma mark - 保存自定义程序
- (IBAction)save:(id)sender {
    IQKeyboardManager* key = [IQKeyboardManager sharedManager];
    [key setEnable:NO];
    UIAlertView* alert = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"自定义程序名称",nil) message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"取消", nil) otherButtonTitles:NSLocalizedString(@"保存", nil), nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alert show];
}


#pragma mark - 返回方法
-(void)goBack
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - 分享
-(void)share
{
    
}

-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    IQKeyboardManager* key = [IQKeyboardManager sharedManager];
    [key setEnable:YES];
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
