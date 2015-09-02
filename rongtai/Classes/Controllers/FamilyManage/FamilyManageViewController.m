//
//  FamilyManageViewController.m
//  rongtai
//
//  Created by William-zhang on 15/6/12.
//  Copyright (c) 2015年 William-zhang. All rights reserved.
//

#import "FamilyManageViewController.h"
#import "FamilyCollectionViewCell.h"
#import "UserInformationViewController.h"

#import "AFHTTPRequestOperationManager.h"
#import "AFURLResponseSerialization.h"
#import "CoreData+MagicalRecord.h"
#import "Member.h"
#import "RongTaiConstant.h"
#import "MemberRequest.h"
#import "CoreData+MagicalRecord.h"
#import "MBProgressHUD.h"
#import "AppDelegate.h"

@interface FamilyManageViewController ()<UICollectionViewDataSource,UICollectionViewDelegate, MemberRequestDelegate> {
    UICollectionView* _collectView;
    CGFloat _matgin;
    NSInteger _countInRow;
    NSString* _reuseIdentifier;
    AFNetworkReachabilityManager* _reachability;
    MBProgressHUD* _loading;
    MemberRequest* _mr;
    NSString* _uid;
}

@property(nonatomic, strong) NSArray *memberArray;
@property(nonatomic, strong) AFHTTPRequestOperationManager *httpRequestManager;

@end

@implementation FamilyManageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = NSLocalizedString(@"家庭成员", nil);
    
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem goBackItemByTarget:self Action:@selector(goBack)];
	
	self.httpRequestManager = [AFHTTPRequestOperationManager manager];
    
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGFloat height = [UIScreen mainScreen].bounds.size.height;
    _matgin = width*0.8*0.05;
    _countInRow = 2;
    _reuseIdentifier = @"FamilyCell";
    UICollectionViewFlowLayout *flowLayout = [UICollectionViewFlowLayout new];
    CGFloat cellWidth = (width*0.8- _countInRow* _matgin) / 2;
    CGFloat cellHeight = (height - 3*_matgin)/3;
    cellHeight = MIN(cellHeight, 170);
    flowLayout.itemSize = CGSizeMake(cellWidth, cellHeight);
    flowLayout.minimumInteritemSpacing = _matgin;
    flowLayout.minimumLineSpacing = _matgin;
    
    _collectView = [[UICollectionView alloc]initWithFrame:CGRectMake(0.1*width, 30+64, width*0.8, height -64-30) collectionViewLayout:flowLayout];
    _collectView.backgroundColor = [UIColor clearColor];
    [_collectView registerClass:[FamilyCollectionViewCell class] forCellWithReuseIdentifier:_reuseIdentifier];
    _collectView.dataSource = self;
    _collectView.delegate = self;
    _collectView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:_collectView];
    
    //添加成员按钮
    UIBarButtonItem* add = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addMember:)];
    self.navigationItem.rightBarButtonItem = add;
    
    //MBProgressHUD
    _loading = [[MBProgressHUD alloc]initWithView:self.view];
    _loading.labelText = NSLocalizedString(@"读取中...", nil);
    [self.view addSubview:_loading];
    
    //
    _mr = [MemberRequest new];
    _mr.overTime = 30;
    _mr.delegate = self;
    
    //
    _uid = [[NSUserDefaults standardUserDefaults] objectForKey:@"uid"];
    // Do any additional setup after loading the view.
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    //读取家庭成员
    _reachability = [AFNetworkReachabilityManager sharedManager];
    if (_reachability.reachable) {
        //网络请求
        _loading.labelText = NSLocalizedString(@"读取中...", nil);
        [_loading show:YES];
        
        NSLog(@"请求成员");
        [_mr requestMemberListByIndex:0 Size:20 success:^(NSArray *members) {
            [Member updateLocalDataByNetworkData:members];
            
            _memberArray = [Member MR_findByAttribute:@"uid" withValue:_uid andOrderBy:@"memberId" ascending:YES];
            [_collectView reloadData];
            [_loading hide:YES];

        } failure:^(id responseObject) {
            NSLog(@"有网，本地记录读取成员");
            _memberArray = [Member MR_findByAttribute:@"uid" withValue:_uid andOrderBy:@"memberId" ascending:YES];
            [_collectView reloadData];
            [_loading hide:YES];
        }];
    }
    else
    {
        NSLog(@"没网，本地记录读取成员");
        _memberArray = [Member MR_findByAttribute:@"uid" withValue:_uid andOrderBy:@"memberId" ascending:YES];
        [_collectView reloadData];
    }
}

#pragma mark - MemberRequest代理
-(void)requestTimeOut:(MemberRequest *)request
{
    [_loading hide:YES];
    [self showProgressHUDByString:NSLocalizedString(@"请求超时，请检测网络", nil)];
}

#pragma mark - 返回
-(void)goBack
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - collectionView代理
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _memberArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    FamilyCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:_reuseIdentifier forIndexPath:indexPath];
    Member* user = _memberArray[indexPath.row];
    cell.member = user;
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    UIStoryboard* s = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
    UserInformationViewController *uVC = (UserInformationViewController *)[s instantiateViewControllerWithIdentifier:@"UserInformation"];
    Member* user = _memberArray[indexPath.row];
    [uVC editMode:user WithIndex:indexPath.row];
    [self.navigationController pushViewController:uVC animated:YES];

}

#pragma mark - 添加成员方法
-(void)addMember:(id)sender
{
    UIStoryboard* s = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
    UserInformationViewController *uVC = (UserInformationViewController *)[s instantiateViewControllerWithIdentifier:@"UserInformation"];
    uVC.title = NSLocalizedString(@"添加成员", nil);
    [self.navigationController pushViewController:uVC animated:YES];
}

#pragma mark - 快速提示
-(void)showProgressHUDByString:(NSString*)message
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.labelText = message;
    hud.margin = 10.f;
    hud.removeFromSuperViewOnHide = YES;
    [hud hide:YES afterDelay:0.7];
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
