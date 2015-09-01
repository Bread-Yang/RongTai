//
//  ProcedureManageViewController.m
//  rongtai
//
//  Created by William-zhang on 15/6/14.
//  Copyright (c) 2015年 William-zhang. All rights reserved.
//

#import "ProcedureManageViewController.h"
#import "CustomProcedureViewController.h"
#import "ProcedureManageCollectionViewCell.h"
#import "ProcedureManageTableViewCell.h"
#import "CoreData+MagicalRecord.h"
#import "CustomProgram.h"
#import "MassageProgramRequest.h"

@interface ProcedureManageViewController ()<UITableViewDataSource, UITableViewDelegate, ProcedureManageTableViewCellDelegate,MassageRequestDelegate>
{
    UIBarButtonItem* _edit;  //编辑按钮
    BOOL _isEdit;  //是否处在编辑状态
    NSMutableArray* _massageModes;  //按摩模式数组
    UICollectionView* _collectionView;
    CGFloat _matgin;
    NSInteger _countInRow;
    NSString* _reuseIdentifier;
    
    UITableView* _tableView;
    
}
@end

@implementation ProcedureManageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"已有程序", nil);
    self.view.backgroundColor = [UIColor whiteColor];
    _isEdit = NO;
    _edit = [[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"编辑", nil) style:UIBarButtonItemStylePlain target:self action:@selector(editProcedure)];
    self.navigationItem.rightBarButtonItem = _edit;
     _reuseIdentifier = @"ProcedureManageCell";
    
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGFloat height = [UIScreen mainScreen].bounds.size.height;
    
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 64, width, height) style:UITableViewStyleGrouped];
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_tableView];
    
    
    //接口测试
    CustomProgram* cp = [CustomProgram MR_createEntity];
    cp.useAid = @1;
    cp.useTime = @1;
    cp.airPressure = @1;
    cp.width = @0;
    cp.speed = @1;
    cp.power = @0;
    cp.keyPart = @2;
    cp.massagePreference = @2;
    cp.massageType = @0;
    cp.programId = @27;
    cp.name = @"自定义程序1";

    MassageProgramRequest* m = [MassageProgramRequest new];
    m.delegate = self;
//    [m addCustomProgram:cp Uid:@"1ee329f146104331852238be180a46b4"];
    [m requsetCustomProgramListByUid:@"1ee329f146104331852238be180a46b4" Index:0 Size:5];
//    [m updateCustomProgram:cp Uid:@"1ee329f146104331852238be180a46b4"];
//    [m deleteCustomProgram:cp Uid:@"1ee329f146104331852238be180a46b4"];
    
    
    
//    _matgin = width*0.8*0.05;
//    _countInRow = 2;
//
//    UICollectionViewFlowLayout *flowLayout = [UICollectionViewFlowLayout new];
//    CGFloat cellWidth = (width*0.8- _countInRow* _matgin) / 2;
//    //    CGFloat cellHeight = (_collectView.frame.size.height - 3*_matgin)/3;
//    flowLayout.itemSize = CGSizeMake(cellWidth, cellWidth);
//    flowLayout.minimumInteritemSpacing = _matgin;
//    flowLayout.minimumLineSpacing = _matgin;
//    
//    _collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0.1*width, 30, width*0.8, height -64-30) collectionViewLayout:flowLayout];
//    _collectionView.backgroundColor = [UIColor clearColor];
//    [_collectionView registerClass:[ProcedureManageCollectionViewCell class] forCellWithReuseIdentifier:_reuseIdentifier];
//    _collectionView.dataSource = self;
//    _collectionView.delegate = self;
//    [self.view addSubview:_collectionView];
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
//     _massageModes  = [CustomProgram MR_findAll];
    NSArray* cp = [CustomProgram MR_findAll];
    _massageModes = [NSMutableArray new];
    for (int i = 0; i<cp.count; i++) {
        CustomProgram* c = cp[i];
        MassageMode* massageMode = [MassageMode new];
        massageMode.name = c.name;
        [_massageModes addObject:c];
    }
    [_tableView reloadData];
}


#pragma mark - 编辑/完成 按钮方法
-(void)editProcedure
{
    _isEdit = !_isEdit;
    if (_isEdit) {
        _edit.title = NSLocalizedString(@"完成", nil);
    }
    else
    {
        _edit.title = NSLocalizedString(@"编辑", nil);
    }
    [_tableView reloadData];
}

#pragma mark - tableView的代理
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//    return 3;
    return _massageModes.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ProcedureManageTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:_reuseIdentifier];
    if (!cell) {
        cell = [[ProcedureManageTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:_reuseIdentifier];
    }
    CustomProgram* c = _massageModes[indexPath.row];
    cell.customProgram = c;
    cell.isEdit = _isEdit;
    cell.delegate = self;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.0001;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    CustomProgram* c = _massageModes[indexPath.row];
    CustomProgram* cp = _massageModes[indexPath.row];
    UIStoryboard* s = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
    if (_isEdit) {
        CustomProcedureViewController* cpVC = (CustomProcedureViewController*)[s instantiateViewControllerWithIdentifier:@"CustomProcedure"];
        [cpVC editModeWithCustomProgram:cp Index:indexPath.row];
        [self.navigationController pushViewController:cpVC animated:YES];
    }
    else
    {
        
    }
    
}


#pragma mark - cell代理实现
-(void)cellDidFinishedChangeName:(ProcedureManageTableViewCell *)cell
{
    [_tableView reloadData];
}





///待删除

#pragma mark - collectionView代理
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
//    return _massageModes.count;
    return 3;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ProcedureManageCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:_reuseIdentifier forIndexPath:indexPath];
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    UIStoryboard* s = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
    if (_isEdit)
    {
        CustomProcedureViewController* c = (CustomProcedureViewController*)[s instantiateViewControllerWithIdentifier:@"CustomProcedure"];
//        [c editModeWithMassageMode:nil Index:0];
        [self.navigationController pushViewController:c animated:YES];
    }
    else
    {
        
    }
}

#pragma mark - 网络请求代理
-(void)massageRequestAddCustomProgramFinish:(BOOL)success Result:(CustomProgram *)customProgram
{
    if (success) {
        NSLog(@"成功啦");
        NSLog(@"%ld",[customProgram.programId integerValue]);
    }
    else
    {
        NSLog(@"失败");
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
