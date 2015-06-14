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

@interface FamilyManageViewController ()<UICollectionViewDataSource,UICollectionViewDelegate>
{
    NSMutableArray* _users;  //用户数组
    UICollectionView* _collectView;
    CGFloat _matgin;
    NSInteger _countInRow;
    NSString* _reuseIdentifier;
}
@end

@implementation FamilyManageViewController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = NSLocalizedString(@"家庭成员", nil);
    CGFloat width = [UIScreen mainScreen].bounds.size.width*0.8;
    CGFloat height = [UIScreen mainScreen].bounds.size.height;
    _matgin = width*0.05;
    _countInRow = 2;
    _reuseIdentifier = @"doughnutCell";
    UICollectionViewFlowLayout *flowLayout = [UICollectionViewFlowLayout new];
    CGFloat cellWidth = (width- _countInRow* _matgin) / 2;
//    CGFloat cellHeight = (_collectView.frame.size.height - 3*_matgin)/3;
    flowLayout.itemSize = CGSizeMake(cellWidth, cellWidth);
    flowLayout.minimumInteritemSpacing = _matgin;
    flowLayout.minimumLineSpacing = _matgin;
    
    _collectView = [[UICollectionView alloc]initWithFrame:CGRectMake(0.1*width, 30, width, height -64-30) collectionViewLayout:flowLayout];
    _collectView.backgroundColor = [UIColor clearColor];
    [_collectView registerClass:[FamilyCollectionViewCell class] forCellWithReuseIdentifier:_reuseIdentifier];
    _collectView.dataSource = self;
    _collectView.delegate = self;
    [self.view addSubview:_collectView];

    _users = [NSMutableArray new];
    for (int i = 0; i < 3; i++) {
        User* user = [User new];
        user.name = @"爸爸";
        user.imageUrl = @"userIcon.jpg";
        [_users addObject:user];
    }
    // Do any additional setup after loading the view.
}



#pragma mark - collectionView代理
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _users.count+1;  //最后是返回按钮
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    FamilyCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:_reuseIdentifier forIndexPath:indexPath];
    if (indexPath.row >= _users.count) {
        cell.isAdd = YES;
    }
    else
    {
        cell.isAdd = NO;
        User* user = _users[indexPath.row];
        cell.user = user;
    }
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    UIStoryboard* s = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
    UserInformationViewController* uVC = (UserInformationViewController*)[s instantiateViewControllerWithIdentifier:@"UserInformation"];
    if (indexPath.row < _users.count) {
        User* user = _users[indexPath.row];
        [uVC editMode:user WithIndex:indexPath.row];
        [self.navigationController pushViewController:uVC animated:YES];
    }
    else
    {
        uVC.title = NSLocalizedString(@"添加成员", nil);
        [self.navigationController pushViewController:uVC animated:YES];
    }
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
