//
//  ChangeUserViewController.m
//  rongtai
//
//  Created by William-zhang on 15/7/13.
//  Copyright (c) 2015年 William-zhang. All rights reserved.
//

#import "ChangeUserViewController.h"
#import "CoreData+MagicalRecord.h"
#import "Member.h"
#import "RongTaiConstant.h"
#import "BasicTableViewCell.h"
#import "MemberRequest.h"
#import "CoreData+MagicalRecord.h"
#import "MBProgressHUD.h"
#import "UIImage+ImageBlur.h"
#import "UIImageView+AFNetworking.h"

@interface ChangeUserViewController ()<UITableViewDataSource, UITableViewDelegate, MemberRequestDelegate>
{
    NSArray* _users;  //用户数据，数据从本地读取
    UITableView* _table;
    CGFloat _rowHeight;
    AFNetworkReachabilityManager* _reachability;
    MBProgressHUD* _loading;
    NSString* _currentMemberId;
}
@end

@implementation ChangeUserViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"切换用户", nil);
    
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem goBackItemByTarget:self Action:@selector(goBack)];
    
    _rowHeight = 60;
    _table = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT-64)];
    _table.backgroundColor = [UIColor clearColor];
    _table.dataSource = self;
    _table.delegate = self;
    _table.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_table];
    
    //
    _loading = [[MBProgressHUD alloc]initWithView:self.view];
    _loading.labelText = NSLocalizedString(@"读取中...", nil);
    [self.view addSubview:_loading];
    
    //
    _currentMemberId = [[NSUserDefaults standardUserDefaults] objectForKey:@"currentMemberId"];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    _reachability = [AFNetworkReachabilityManager sharedManager];
    if (_reachability.reachable) {
        //网络请求
        [_loading show:YES];
        
        NSLog(@"请求成员");
        MemberRequest* mr = [MemberRequest new];
        mr.overTime = 30;
        mr.delegate = self;
        [mr requestMemberListByIndex:0 Size:20 success:^(NSArray *members) {
            [Member updateLocalDataByNetworkData:members];
            
            _users = [Member MR_findByAttribute:@"uid" withValue:self.uid andOrderBy:@"memberId" ascending:YES];
            [self setDefaultsUser:_users[0]];
            [_table reloadData];
            [_loading hide:YES];
            
        } failure:^(id responseObject) {
            NSLog(@"有网，本地记录读取成员");
            _users = [Member MR_findByAttribute:@"uid" withValue:self.uid andOrderBy:@"memberId" ascending:YES];
            [self setDefaultsUser:_users[0]];

            [_table reloadData];
            [_loading hide:YES];
        }];
    }
    else
    {
        NSLog(@"没网，本地记录读取成员");
        _users = [Member MR_findByAttribute:@"uid" withValue:self.uid andOrderBy:@"memberId" ascending:YES];
        [self setDefaultsUser:_users[0]];
        [_table reloadData];
    }
}

#pragma mark - 设置默认用户
-(void)setDefaultsUser:(Member*)user
{
    if (_currentMemberId.length <1) {
        NSLog(@"设置默认用户");
        NSString* mid = [NSString stringWithFormat:@"%d",[user.memberId intValue]];
        _currentMemberId = mid;
        [[NSUserDefaults standardUserDefaults] setObject:mid forKey:@"currentMemberId"];
    }
}

#pragma mark - MemberRequest
-(void)requestTimeOut:(MemberRequest *)request
{
    [_loading hide:YES];
    
    MBProgressHUD *alert = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    alert.mode = MBProgressHUDModeText;
    alert.labelText = NSLocalizedString(@"请求超时，请检测网络", nil);
    alert.margin = 10.f;
    alert.removeFromSuperViewOnHide = YES;
    [alert hide:YES afterDelay:0.7];
}

#pragma mark - 返回
-(void)goBack
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - tableView代理现实
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BasicTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"userCell"];
    if (!cell) {
        cell = [[BasicTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"userCell"];
        cell.imageViewScale = 0.7;
        cell.backgroundColor = [UIColor clearColor];
        cell.imageView.layer.cornerRadius = _rowHeight*0.35;
        cell.imageView.clipsToBounds = YES;
        cell.imageView.layer.borderColor = [UIColor whiteColor].CGColor;
        cell.imageView.layer.borderWidth = 2;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        UIView* line = [[UIView alloc]initWithFrame:CGRectMake(0, _rowHeight-1, SCREENWIDTH, 1)];
        line.backgroundColor = [UIColor grayColor];
        line.alpha = 0.2;
        [cell addSubview:line];
    }
    Member* m = _users[indexPath.row];
    cell.textLabel.text = m.name;
    cell.textLabel.textColor = BLACK;
    if ([m.memberId integerValue] == [_currentMemberId integerValue]) {
        cell.accessoryView = [self selectedView];
    }
    if ([m.imageURL isEqualToString:@"default"]) {
        //空的用默认头像
        cell.imageView.image = [UIImage imageNamed:@"userIcon"];
    }
    else
    {
        //先使用本地图片，若本地读不到图片则使用网络请求
        UIImage* img = [UIImage imageInLocalByName:[NSString stringWithFormat:@"%@.jpg",m.imageURL]];
        cell.imageView.image  = img;
        //网络请求  //[NSString isBlankString:member.imageURL]
        if (!img) {
            NSLog(@"网络读取头像");
            NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://recipe.xtremeprog.com/file/g/%@",m.imageURL]];
            NSURLRequest *request = [NSURLRequest requestWithURL:url];
            UIImage *placeholderImage = [UIImage imageNamed:@"placeholder"];
            __weak BasicTableViewCell* weakCell = cell;
            [cell.imageView setImageWithURLRequest:request
                                 placeholderImage:placeholderImage
                                          success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                              weakCell.imageView.image = image;
                                              [image saveImageByName:[NSString stringWithFormat:@"%@.jpg",m.imageURL]];
                                          } failure:nil];
        }
        
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    for (UITableViewCell* cell in tableView.visibleCells) {
        cell.accessoryView = nil;
    }
    UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryView = [self selectedView];

    //更改当前用户mid
    Member* m = _users[indexPath.row];
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSString* mid = [NSString stringWithFormat:@"%ld",[m.memberId integerValue]];
    [defaults setObject:mid forKey:@"currentMemberId"];
    NSLog(@"切换用户:%@",m.name);
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _users.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return _rowHeight;
}

#pragma mark - 生成一个打钩的View
-(UIImageView*)selectedView
{
    UIImageView* select = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"user_list_select"]];
    return select;
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
