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

@interface FamilyManageViewController ()<UICollectionViewDataSource,UICollectionViewDelegate> {
    UICollectionView* _collectView;
    CGFloat _matgin;
    NSInteger _countInRow;
    NSString* _reuseIdentifier;
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
	
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	self.navigationController.navigationBarHidden = NO;
    
//    _users = [NSMutableArray new];
	
//	manager.responseSerializer = [AFHTTPResponseSerializer serializer]; // 设置这句, 可以成功返回,不过返回的数据要转码
//	self.httpRequestManager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];  // 这句是关键
//	
//	NSString *requestURL = [RongTaiDefaultDomain stringByAppendingString:@"loadMember"];
//	NSDictionary *parameters = @{@"uid": @"15521377721"};
//	
//	[self.httpRequestManager POST:requestURL parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
////		NSLog(@"success return json : %@", responseObject);
//		NSDictionary *jsonDictionary = (NSDictionary *)responseObject;
//		
//		if ([jsonDictionary[@"responseCode"] intValue] == 200) {
//			self.memberArray = jsonDictionary[@"result"];
//			
//			for (int i = 0; i < [self.memberArray count]; i++) {
//				NSDictionary *itemDictionary = self.memberArray[i];
//				Member *user = [Member MR_createEntity];
//				user.name = itemDictionary[@"name"];
//				user.imageURL = itemDictionary[@"imageUrl"];
//				[_users addObject:user];
//			}
//			[_collectView reloadData];
//		}
//	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//		NSLog(@"Error: %@", error);
//	}];
	
    _memberArray = [Member MR_findAll];
    [_collectView reloadData];
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
