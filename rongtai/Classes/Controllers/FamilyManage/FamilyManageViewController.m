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

@interface FamilyManageViewController ()<UICollectionViewDataSource,UICollectionViewDelegate> {
    UICollectionView* _collectView;
    CGFloat _matgin;
    NSInteger _countInRow;
    NSString* _reuseIdentifier;
    AFNetworkReachabilityManager* _reachability;
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
    
    //更新数据库
    
	
    // Do any additional setup after loading the view.
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    _reachability = [AFNetworkReachabilityManager sharedManager];
    if (_reachability.reachable) {
        //网络请求
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        hud.labelText = @"读取中...";
        [hud show:YES];
        
        NSLog(@"请求成员");
        NSString* uid = [[NSUserDefaults standardUserDefaults] objectForKey:@"uid"];
        NSMutableArray* arr = [NSMutableArray new];
        MemberRequest* mr = [MemberRequest new];
        [mr requestMemberListByUid:uid Index:0 Size:20 success:^(NSArray *members) {
            for (NSDictionary* dic in members) {
                Member* m = [self updateMemberDB:dic];
                [arr addObject:m];
            }
            _memberArray = [NSArray arrayWithArray:arr];
            [_collectView reloadData];
            [hud hide:YES];

        } failure:^(id responseObject) {
            NSLog(@"有网，本地记录读取成员");
            _memberArray = [Member MR_findAllSortedBy:@"memberId" ascending:YES];
            [_collectView reloadData];
            [hud hide:YES];
        }];
    }
    else
    {
        NSLog(@"没网，本地记录读取成员");
        _memberArray = [Member MR_findAllSortedBy:@"memberId" ascending:YES];
        [_collectView reloadData];
    }
}

-(void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	self.navigationController.navigationBarHidden = NO;
}

#pragma mark - 根据一条Member的Json数据更新数据库
-(Member*)updateMemberDB:(NSDictionary*)dic
{
    NSString* mid = [dic valueForKey:@"memberId"];
    NSNumber* memberId = [NSNumber numberWithInteger:[mid integerValue]];
    NSArray* arr = [Member MR_findByAttribute:@"memberId" withValue:memberId];
    Member* m;
    if (arr.count == 0) {
        m = [Member MR_createEntity];
    }
    else
    {
        m = arr[0];
    }
    [m setValueBy:dic];
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
    return m;
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
//    [uVC setEditUserInformation:self.memberArray[indexPath.row]];
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
