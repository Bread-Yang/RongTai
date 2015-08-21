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
#import "CustomMassageViewController.h"
#import "CustomProgram.h"
#import "CoreData+MagicalRecord.h"
#import "UIBarButtonItem+goBack.h"
#import "SegmentTableViewCell.h"

@interface CustomProcedureViewController ()<UITableViewDataSource,UITableViewDelegate>
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
                          NSLocalizedString(@"按摩手法", nil):@[NSLocalizedString(@"日式", nil),NSLocalizedString(@"泰式", nil),NSLocalizedString(@"中式", nil)],
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
}

#pragma mark - tableView代理
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _firstLevelItems.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SegmentTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"sCell"];
    if (!cell) {
        cell = [[SegmentTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"sCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    NSString* title = _firstLevelItems[indexPath.row];
    NSArray* names = [_secondLevelItems objectForKey:title];
    cell.title = title;
    cell.names = names;
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString* title = _firstLevelItems[indexPath.row];
    NSArray* names = [_secondLevelItems objectForKey:title];

        if (names.count > 2) {
            return 85;
        }
        else
        {
            return 70;
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
    UIStoryboard* s = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
    CustomMassageViewController* c = (CustomMassageViewController*)[s instantiateViewControllerWithIdentifier:@"CustomMassageVC"];
    [self.navigationController pushViewController:c animated:YES];
}


#pragma mark - 编辑模式
-(void)editModeWithCustomProgram:(CustomProgram*)customProgram Index:(NSUInteger)index;
{
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"编辑";
    _isEdit = YES;
    _cp = customProgram;
    UIBarButtonItem* save = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveMassageMode)];
    self.navigationItem.rightBarButtonItem = save;
    
    [_stastMassageBtn setTitle:@"删除" forState:UIControlStateNormal];
    _stastMassageBtn.backgroundColor = [UIColor colorWithRed:1 green:0 blue:0 alpha:0.6];

    
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

@end
