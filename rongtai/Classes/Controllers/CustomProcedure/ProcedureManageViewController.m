//
//  ProcedureManageViewController.m
//  rongtai
//
//  Created by William-zhang on 15/6/14.
//  Copyright (c) 2015年 William-zhang. All rights reserved.
//

#import "ProcedureManageViewController.h"
#import "CustomProcedureViewController.h"
#import "ProcedureManageTableViewCell.h"
#import "CoreData+MagicalRecord.h"
#import "CustomProgram.h"
#import "MassageProgramRequest.h"
#import "UIBarButtonItem+goBack.h"

@interface ProcedureManageViewController ()<UITableViewDataSource, UITableViewDelegate, ProcedureManageTableViewCellDelegate,MassageRequestDelegate>
{
    UIBarButtonItem* _edit;  //编辑按钮
    BOOL _isEdit;  //是否处在编辑状态
    NSMutableArray* _massageModes;  //按摩模式数组
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
//    _edit = [[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"编辑", nil) style:UIBarButtonItemStylePlain target:self action:@selector(editProcedure)];
    _edit = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"icon_edit"] style:UIBarButtonItemStylePlain target:self action:nil];
    self.navigationItem.rightBarButtonItem = _edit;
     _reuseIdentifier = @"ProcedureManageCell";
    
    //返回按钮设置
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem goBackItemByTarget:self Action:@selector(goBack)];
    
    
    

    
    
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGFloat height = [UIScreen mainScreen].bounds.size.height;
    
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 64, width, height) style:UITableViewStyleGrouped];
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
//    [self.view addSubview:_tableView];
    
    
    //接口测试
//    CustomProgram* cp = [CustomProgram MR_createEntity];
//    cp.useAid = @1;
//    cp.useTime = @1;
//    cp.airPressure = @1;
//    cp.width = @0;
//    cp.speed = @1;
//    cp.power = @0;
//    cp.keyPart = @2;
//    cp.massagePreference = @2;
//    cp.massageType = @0;
//    cp.programId = @27;
//    cp.name = @"自定义程序1";

//    MassageProgramRequest* m = [MassageProgramRequest new];
//    m.delegate = self;
////    [m addCustomProgram:cp Uid:@"1ee329f146104331852238be180a46b4"];
//    [m requsetCustomProgramListByUid:@"1ee329f146104331852238be180a46b4" Index:0 Size:5];
//    [m updateCustomProgram:cp Uid:@"1ee329f146104331852238be180a46b4"];
//    [m deleteCustomProgram:cp Uid:@"1ee329f146104331852238be180a46b4"];
    
// Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
//     _massageModes  = [CustomProgram MR_findAll];
//    NSArray* cp = [CustomProgram MR_findAll];
//    _massageModes = [NSMutableArray new];
//    for (int i = 0; i<cp.count; i++) {
//        CustomProgram* c = cp[i];
//        MassageMode* massageMode = [MassageMode new];
//        massageMode.name = c.name;
//        [_massageModes addObject:c];
//    }
//    [_tableView reloadData];
}

#pragma mark - 导航栏返回方法
-(void)goBack
{
    [self.navigationController popViewControllerAnimated:YES];
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
//    CustomProgram* cp = _massageModes[indexPath.row];
//    UIStoryboard* s = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
//    if (_isEdit) {
//        CustomProcedureViewController* cpVC = (CustomProcedureViewController*)[s instantiateViewControllerWithIdentifier:@"CustomProcedure"];
//        [cpVC editModeWithCustomProgram:cp Index:indexPath.row];
//        [self.navigationController pushViewController:cpVC animated:YES];
//    }
//    else
//    {
//        
//    }
    
}


#pragma mark - cell代理实现
-(void)cellDidFinishedChangeName:(ProcedureManageTableViewCell *)cell
{
//    [_tableView reloadData];
}


#pragma mark - 网络请求代理
-(void)massageRequestAddCustomProgramFinish:(BOOL)success Result:(CustomProgram *)customProgram
{
    if (success) {
        NSLog(@"成功啦");
        NSLog(@"%d",[customProgram.programId integerValue]);
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
