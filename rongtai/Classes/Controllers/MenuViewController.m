//
//  MenuViewController.m
//  rongtai
//
//  Created by William-zhang on 15/6/8.
//  Copyright (c) 2015年 William-zhang. All rights reserved.
//

#import "MenuViewController.h"
#import "LoginViewController.h"
#import "SlideNavigationController.h"
#import "DataCenterViewController.h"
#import "FamilyManageViewController.h"
#import "TimingMassageTableViewController.h"
#import "ProductInstructionViewController.h"
#import "BuyRTProductTableViewController.h"
#import "RongTaiConstant.h"
#import "ChangeUserViewController.h"
#import "RTBleConnector.h"

//测试
#import "FinishMassageViewController.h"


@interface MenuViewController ()<UITableViewDataSource, UITableViewDelegate>
{
    NSArray* _menuName;  //菜单名字
    UITableView* _menu;  //菜单列表
    NSArray* _menuIcons; //菜单列表图标
    UISwitch* _weatherSwitch;  //天气开关

    int _rowHeight;
}
@end

@implementation MenuViewController

-(instancetype)init
{
    if (self = [super init]) {
        [self setUp];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = GRAY;
    [self.view addSubview:_menu];
    
    //横线
    UIView* V_line = [[UIView alloc]initWithFrame:CGRectMake(0, 63, SCREENWIDTH, 0.5)];
    [self V_LineStyle:V_line];
    [self.view addSubview:V_line];
    
    //切换按摩椅
    CGFloat unit = 0.7*SCREENWIDTH/2;
    CGFloat y = SCREENHEIGHT - unit*0.5-SCREENWIDTH*0.034;
    UIButton* change = [[UIButton alloc]initWithFrame:CGRectMake(0, y, unit, unit*0.4)];
    change.titleLabel.font =[UIFont systemFontOfSize:13];
    [change setTitle:NSLocalizedString(@"切换按摩椅",nil) forState:UIControlStateNormal];
    [change setImage:[UIImage imageNamed:@"menu_icon_device"] forState:UIControlStateNormal];
    [change setTitleEdgeInsets:UIEdgeInsetsMake(0, 5, 0, 0)];
    [change setTitleColor:BLACK forState:UIControlStateNormal];
    [change addTarget:self action:@selector(changeMessageChair) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:change];
    
    //竖线
    UIView* H_line = [[UIView alloc]initWithFrame:CGRectMake(unit, y+unit*0.05, 1, unit*0.3)];
    H_line.backgroundColor = [UIColor grayColor];
    H_line.alpha = 0.5;
    [self.view addSubview:H_line];
    
    //注销
    UIButton* logout = [[UIButton alloc]initWithFrame:CGRectMake(unit+1, y, unit, unit*0.4)];
    logout.titleLabel.font =[UIFont systemFontOfSize:13];
    [logout setTitle:NSLocalizedString(@"注销",nil) forState:UIControlStateNormal];
    [logout setTitleColor:BLACK forState:UIControlStateNormal];
    [logout setImage:[UIImage imageNamed:@"menu_icon_logout"] forState:UIControlStateNormal];
    [logout setTitleEdgeInsets:UIEdgeInsetsMake(0, 5, 0, 0)];
    [logout addTarget:self action:@selector(Logout) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:logout];
    
    // Do any additional setup after loading the view.
}

#pragma mark - 对象初始化
-(void)setUp
{
    //行高
    _rowHeight = SCREENHEIGHT*0.085;
    
    //菜单数组
    _menuName = @[NSLocalizedString(@"切换用户",nil),NSLocalizedString(@"家庭成员管理",nil), NSLocalizedString(@"数据中心",nil), NSLocalizedString(@"定时计划",nil), NSLocalizedString(@"首页天气预报",nil) ,NSLocalizedString(@"我要反馈",nil) ,NSLocalizedString(@"使用帮助",nil) ,NSLocalizedString(@"我要购买",nil)];
    
    //菜单图标
    _menuIcons = @[@"menu_icon_user",@"menu_icon_member",@"menu_icon_data",@"menu_icon_plan",@"menu_icon_weather",@"menu_icon_message",@"menu_icon_help",@"menu_icon_shop"];
    
    
    //菜单列表
    _menu = [[UITableView alloc]initWithFrame:CGRectMake(0, 64, 0.71*SCREENWIDTH, _menuName.count*_rowHeight) style:UITableViewStyleGrouped];
    _menu.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    _menu.tag = 2002;
    _menu.backgroundColor = [UIColor clearColor];
    _menu.dataSource = self;
    _menu.delegate = self;
    _menu.scrollEnabled = NO;
    _menu.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    //天气开关
    _weatherSwitch = [[UISwitch alloc]initWithFrame:CGRectMake(0, -4, 300, 100)];
    _weatherSwitch.on = YES;
    [_weatherSwitch addTarget:self action:@selector(switchChangeValue:) forControlEvents:UIControlEventValueChanged];
}

#pragma mark - 天气开关
-(void)switchChangeValue:(UISwitch*)aSwitch
{
    if ([self.delegate respondsToSelector:@selector(switchChange:)]) {
        [self.delegate switchChange:aSwitch.isOn];
    }
}

#pragma mark - tableView代理实现
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _menuName.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* menuCell = [tableView dequeueReusableCellWithIdentifier:@"menucell"];
    
    if (!menuCell) {
        menuCell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"menucell"];
        UIView* line = [[UIView alloc]initWithFrame:CGRectMake(0, _rowHeight-1, 0.71*SCREENWIDTH, 0.5)];
        [self V_LineStyle:line];
        [menuCell addSubview:line];
    }
    menuCell.textLabel.textColor = BLACK;
    menuCell.textLabel.text = _menuName[indexPath.row];
    if ([_menuName[indexPath.row] isEqualToString:NSLocalizedString(@"首页天气预报",nil)]) {
        menuCell.accessoryView = _weatherSwitch;
    }
    else
    {
        menuCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    NSString* icon = _menuIcons[indexPath.row];
    menuCell.imageView.image = [UIImage imageNamed:icon];
    menuCell.selectionStyle  = UITableViewCellSelectionStyleNone;
    menuCell.backgroundColor = [UIColor clearColor];
    return menuCell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
     SlideNavigationController* sl = [SlideNavigationController sharedInstance];
    if (indexPath.row == 0) {
        //切换用户
        ChangeUserViewController* cVC = [ChangeUserViewController new];
        [sl pushViewController:cVC animated:YES];
    }
    else if (indexPath.row == 1) {
        //家庭成员管理
        FamilyManageViewController* fVC = [[FamilyManageViewController alloc]init];
        [sl pushViewController:fVC animated:YES];
    }
    else if (indexPath.row == 2)
    {
        //数据中心
        DataCenterViewController* dataVC = [[DataCenterViewController alloc]init];
        [sl pushViewController:dataVC animated:YES];
    }
    else if (indexPath.row == 3)
    {
        //定时计划
        UIStoryboard* s = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        TimingMassageTableViewController* tVC = [s instantiateViewControllerWithIdentifier:@"TimingMassageVC"];
        [sl pushViewController:tVC animated:YES];
    }
    else if (indexPath.row == 5)
    {
        //我要反馈
        
        //测试，跳转到按摩结束
        UIStoryboard* s = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
        FinishMassageViewController* fVC = [s instantiateViewControllerWithIdentifier:@"FinishMassageVC"];
//        [fVC saveMode];
        [sl pushViewController:fVC animated:YES];
        
    }
    else if (indexPath.row == 6)
    {
        //使用帮助
        UIStoryboard* s = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        ProductInstructionViewController* pVC = [s instantiateViewControllerWithIdentifier:@"ProductInstructionVC"];
        [sl pushViewController:pVC animated:YES];
    }
    else if (indexPath.row == 7)
    {
        //我要购买
        UIStoryboard* s = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        BuyRTProductTableViewController* bVC = [s instantiateViewControllerWithIdentifier:@"BuyRTProductVC"];
        [sl pushViewController:bVC animated:YES];
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return _rowHeight;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.000001;
}

#pragma mark - 注销
-(void)Logout
{
    
}

#pragma mark - 切换按摩椅
-(void)changeMessageChair {
	UIStoryboard *secondStoryBoard = [UIStoryboard storyboardWithName:@"Second" bundle:[NSBundle mainBundle]];
	UIViewController *viewController = [secondStoryBoard instantiateViewControllerWithIdentifier:@"ScanVC"];
	[[SlideNavigationController sharedInstance] pushViewController:viewController animated:YES];
}

#pragma mark - 横线样式
-(void)V_LineStyle:(UIView*)line
{
    line.backgroundColor = [UIColor grayColor];
    line.alpha = 0.2;
//    line.layer.shadowOffset = CGSizeMake(0, 1);
//    line.layer.shadowOpacity = 0.4;
//    line.layer.shadowColor = [UIColor grayColor].CGColor;
//    line.layer.shadowRadius = 1;
//    
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
