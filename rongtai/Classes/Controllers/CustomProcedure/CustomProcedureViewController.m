//
//  CustomProcedureViewController.m
//  rongtai
//
//  Created by William-zhang on 15/6/14.
//  Copyright (c) 2015年 William-zhang. All rights reserved.
//

#define SCREENWIDTH [UIScreen mainScreen].bounds.size.width
#define SCREENHEIGHT [UIScreen mainScreen].bounds.size.height

#import "CustomProcedureViewController.h"
#import "ProcedureManageViewController.h"
#import "RFSegmentView.h"
#import "WLCheckButton.h"
#import "CustomProgram.h"
#import "CoreData+MagicalRecord.h"
#import "UIBarButtonItem+goBack.h"
#import "SegmentTableViewCell.h"
#import "ProgramDownloadViewController.h"

@interface CustomProcedureViewController ()<UITableViewDataSource,UITableViewDelegate,SegmentTableViewCellDelegate>
{
    //按摩对象
    CustomProgram* _cp;
    
    //名称textField
    UITextField* _nameField;
    
    //开始按摩按钮
    __weak IBOutlet UIButton *_stastMassageBtn;
    __weak IBOutlet UITableView *_tableView;
    
    //是否是编辑页面
    BOOL _isEdit;
    
    //一级选项名称
    NSArray* _firstLevelItems;
    
    //二级选项（通过一级选项名称作为key来获取二级选项数组）
    NSDictionary* _secondLevelItems;
    
    //各个选项的单元格
    NSMutableArray* _cells;
    
}
@end

@implementation CustomProcedureViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    self.title = NSLocalizedString(@"自定义程序", nil);
    self.view.backgroundColor = [UIColor clearColor];
    
    //一级选择
    _firstLevelItems = @[NSLocalizedString(@"使用时机", nil),NSLocalizedString(@"使用目的", nil),NSLocalizedString(@"重点部位", nil),NSLocalizedString(@"按摩手法", nil),NSLocalizedString(@"技术偏好", nil),NSLocalizedString(@"速度", nil),NSLocalizedString(@"气压", nil)];
    
    //二级选择
    _secondLevelItems = @{NSLocalizedString(@"使用时机", nil):@[NSLocalizedString(@"工作后", nil),NSLocalizedString(@"运动后", nil),NSLocalizedString(@"出差后", nil),NSLocalizedString(@"逛街后", nil)],
                          NSLocalizedString(@"使用目的", nil):@[NSLocalizedString(@"缓解疲劳", nil),NSLocalizedString(@"肌肉放松", nil),NSLocalizedString(@"改善睡眠", nil),NSLocalizedString(@"日常保健", nil)],
                          NSLocalizedString(@"重点部位", nil):@[NSLocalizedString(@"肩部", nil),NSLocalizedString(@"背部", nil),NSLocalizedString(@"腰部", nil),NSLocalizedString(@"臀部", nil)],
                          NSLocalizedString(@"按摩手法", nil):@[NSLocalizedString(@"泰式", nil),NSLocalizedString(@"日式", nil),NSLocalizedString(@"中式", nil)],
                          NSLocalizedString(@"技术偏好", nil):@[NSLocalizedString(@"揉捏", nil),NSLocalizedString(@"推拿", nil),NSLocalizedString(@"敲打", nil),NSLocalizedString(@"组合", nil)],
                          NSLocalizedString(@"速度", nil):@[NSLocalizedString(@"偏慢", nil),NSLocalizedString(@"偏快", nil)],
                          NSLocalizedString(@"气压", nil):@[NSLocalizedString(@"偏大", nil),NSLocalizedString(@"偏小", nil)]};
    
    //添加导航栏右边按钮
    UIBarButtonItem* select = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"icon_collect"] style:UIBarButtonItemStylePlain target:self action:@selector(selectEsxistingProcedure)];
    self.navigationItem.rightBarButtonItem = select;
    
    //返回按钮设置
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem goBackItemByTarget:self Action:@selector(goBack)];
    
    //初始化数据
    _isEdit = NO;
    
    //tableView
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    //
    float scales[5] = {0.8,0.92,0.8,0.6,0.8};
    
    _cells = [NSMutableArray new];
    for (int i = 0 ; i < _firstLevelItems.count; i++) {
        SegmentTableViewCell* cell = [[SegmentTableViewCell alloc]initWithFrame:CGRectMake(0, i*85, SCREENWIDTH, 85)];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        NSString* title = _firstLevelItems[i];
        NSArray* names = [_secondLevelItems objectForKey:title];
        cell.title = title;
        cell.names = names;
        if (names.count > 2) {
            cell.segmentViewScale = scales[i];
        }
        cell.tag = 2300+i;
        cell.delegate = self;
        cell.itemFont = [UIFont systemFontOfSize:14];
        cell.backgroundColor = [UIColor clearColor];
        [_cells addObject:cell];
    }
}

#pragma mark - tableView代理
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _firstLevelItems.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return _cells[indexPath.row];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString* title = _firstLevelItems[indexPath.row];
    NSArray* names = [_secondLevelItems objectForKey:title];
    if (names.count > 2) {
        return MAX(SCREENHEIGHT*0.13, 70) ;
    }
    else
    {
        return MAX(SCREENHEIGHT*0.1, 54);
    }
}

#pragma mark - SegmentTabelViewCell代理
-(void)segmentTableViewCell:(SegmentTableViewCell *)cell Clicked:(NSUInteger)index
{
    NSInteger cellTag = cell.tag - 2300;
    switch (cellTag) {
        case 0:  //使用时机
            [self useTimeSelected:index];
            break;
        case 1:  //使用目的
            [self usePurposeSelected:index];
            break;
        case 2:  //重点部位
            [self importantPartSelected:index];
            break;
        case 3: //按摩手法
            [self massageWaySelected:index];
            break;
        case 4: //技术偏好
            [self skillPreferenceSelected:index];
            break;
        case 5:  //速度
            if (index == 0)
            {   //偏快
                
            }
            else
            {   //偏慢
                
            }
            break;
        case 6:  //气压
            if (index == 0)
            {  //偏大
                
            }
            else
            {   //偏小
                
            }
            break;
        default:
            break;
    }
}

#pragma mark - 使用时机选项方法
-(void)useTimeSelected:(NSUInteger)index
{
    switch (index) {
        case 0: //工作后
            
            break;
        case 1: //运动后
            
            break;
        case 2: //出差后
            
            break;
        case 3: //逛街后
            
            break;
        default:
            break;
    }
}

#pragma mark - 使用目的选项方法
-(void)usePurposeSelected:(NSUInteger)index
{
    switch (index) {
        case 0: //缓解疲劳
            
            break;
        case 1: //肌肉放松
            
            break;
        case 2: //改善睡眠
            
            break;
        case 3: //日常护理
            
            break;
        default:
            break;
    }
}

#pragma mark - 重点部位选项方法
-(void)importantPartSelected:(NSUInteger)index
{
    switch (index) {
        case 0: //肩部
            
            break;
        case 1: //背部
            
            break;
        case 2: //腰部
            
            break;
        case 3: //臀部
            
            break;
        default:
            break;
    }
}

#pragma mark - 按摩手法选项方法
-(void)massageWaySelected:(NSUInteger)index
{
    switch (index) {
        case 0: //泰式
            
            break;
        case 1: //日式
            
            break;
        case 2: //中式
            
            break;
        default:
            break;
    }
}

#pragma mark - 技术偏好选项方法
-(void)skillPreferenceSelected:(NSUInteger)index
{
    switch (index) {
        case 0: //揉捏
            
            break;
        case 1: //推拿
            
            break;
        case 2: //敲打
            
            break;
        case 3: //组合
            
            break;
        default:
            break;
    }
}

#pragma mark - 导航栏返回方法
-(void)goBack
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - 选择已有程序
-(void)selectEsxistingProcedure
{
    [self.navigationController pushViewController:[ProcedureManageViewController new] animated:YES];
}

#pragma mark - 开始按摩按钮
- (IBAction)startMassage:(UIButton *)sender {
    if ([RTBleConnector shareManager].currentConnectedPeripheral == nil || ![RTBleConnector isBleTurnOn]) {
        [[RTBleConnector shareManager] showConnectDialog];
        return;
    }
	UIStoryboard *s = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
	ProgramDownloadViewController *pVC = (ProgramDownloadViewController*)[s instantiateViewControllerWithIdentifier:@"ProgramDownloadVC"];
	pVC.isDownloadCustomProgram = YES;
	[self.navigationController pushViewController:pVC animated:YES];
}


#pragma mark - 编辑模式
-(void)editModeWithCustomProgram:(CustomProgram*)customProgram Index:(NSUInteger)index;
{
    self.view.backgroundColor = [UIColor clearColor];
    self.title = NSLocalizedString(@"编辑", nil);
    _isEdit = YES;
    _cp = customProgram;
    UIBarButtonItem* save = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"icon_delete"] style:UIBarButtonItemStylePlain target:self action:@selector(deleteMassage)];
    self.navigationItem.rightBarButtonItem = save;
    [_stastMassageBtn setTitle:NSLocalizedString(@"保存", nil) forState:UIControlStateNormal];
}

#pragma mark - 保存按摩模式
-(void)saveMassageMode
{
    CustomProgram* _customProgram;
    if (_isEdit) {
        _customProgram = [CustomProgram MR_findByAttribute:@"name" withValue:_cp.name][0];
    }
    else
    {
        _customProgram = [CustomProgram MR_createEntity];
    }
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - 删除按摩模式
-(void)deleteMassage
{
    
}

#pragma mark - 根据CustomProgram更新界面选项
-(void)updateUIByCustomProgram:(CustomProgram*)customprogram
{
    _cp = customprogram;
    for (int i = 0; i< _cells.count; i++) {
        SegmentTableViewCell* cell = _cells[i];
        cell.selectedIndex = [_cp valueByIndex:i];
    }
}

#pragma mark - 保存界面选项到CustomProgram对象中
-(void)saveSelectedItemToCustomProgram
{
    for (int i = 0; i<_cells.count; i++) {
        SegmentTableViewCell* cell = _cells[i];
        [_cp setValue:cell.selectedIndex ByIndex:i];
    }
}


@end
