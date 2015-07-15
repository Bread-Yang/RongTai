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

@interface CustomProcedureViewController ()
{
    //按摩对象
    CustomProgram* _cp;
    
    //名称textField
    UITextField* _nameField;
    
    //开始按摩按钮
    __weak IBOutlet UIButton *_stastMassageBtn;
    __weak IBOutlet UITableView *_tableView;
    
    BOOL _isEdit;
    
}
@end

@implementation CustomProcedureViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    self.title = NSLocalizedString(@"自定义程序", nil);
    self.view.backgroundColor = [UIColor clearColor];
    
    //添加导航栏右边按钮
    UIBarButtonItem* select = [[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"选择已有程序", nil) style:UIBarButtonItemStylePlain target:self action:@selector(selectEsxistingProcedure)];
    self.navigationItem.rightBarButtonItem = select;
    
    _isEdit = NO;
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

#pragma mark - 选择以后程序
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
