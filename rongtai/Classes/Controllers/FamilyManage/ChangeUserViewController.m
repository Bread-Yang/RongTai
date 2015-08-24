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
    NSInteger _selectIndex;
    CGFloat _rowHeight;
    AFNetworkReachabilityManager* _reachability;
    MBProgressHUD *_hud;
}
@end

@implementation ChangeUserViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"切换用户", nil);
    
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem goBackItemByTarget:self Action:@selector(goBack)];
    
    _rowHeight = 60;
    _table = [[UITableView alloc]initWithFrame:CGRectMake(0, 64, SCREENWIDTH, SCREENHEIGHT-64)];
    _table.backgroundColor = [UIColor clearColor];
    _table.dataSource = self;
    _table.delegate = self;
    _table.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_table];

    _selectIndex = 0;
    
    //
    _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    _hud.labelText = NSLocalizedString(@"读取中...", nil);
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    _reachability = [AFNetworkReachabilityManager sharedManager];
    if (_reachability.reachable) {
        //网络请求
       
        [_hud show:YES];
        
        NSLog(@"请求成员");
        NSMutableArray* arr = [NSMutableArray new];
        MemberRequest* mr = [MemberRequest new];
        mr.overTime = 30;
        mr.delegate = self;
        [mr requestMemberListByIndex:0 Size:20 success:^(NSArray *members) {
            for (NSDictionary* dic in members) {
                Member* m = [Member updateMemberDB:dic];
                [arr addObject:m];
            }
            _users = [NSArray arrayWithArray:arr];
            [_table reloadData];
            [_hud hide:YES];
            
        } failure:^(id responseObject) {
            NSLog(@"有网，本地记录读取成员");
            _users = [Member MR_findAllSortedBy:@"memberId" ascending:YES];
            [_table reloadData];
            [_hud hide:YES];
        }];
    }
    else
    {
        NSLog(@"没网，本地记录读取成员");
        _users = [Member MR_findAllSortedBy:@"memberId" ascending:YES];
        [_table reloadData];
    }
}

#pragma mark - MemberRequest
-(void)requestTimeOut:(MemberRequest *)request
{
    [_hud hide:YES];
    
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
    if ([m.imageURL isEqualToString:@"default"]) {
        //空的用默认头像
        cell.imageView.image = [UIImage imageNamed:@"userIcon.jpg"];
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
    
    
    if (indexPath.row == _selectIndex) {
        cell.accessoryView = [self selectedView];
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
