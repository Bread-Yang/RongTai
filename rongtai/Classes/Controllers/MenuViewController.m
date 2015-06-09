//
//  MenuViewController.m
//  rongtai
//
//  Created by William-zhang on 15/6/8.
//  Copyright (c) 2015年 William-zhang. All rights reserved.
//

#define SCREENWIDTH [UIScreen mainScreen].bounds.size.width
#define SCREENHEIGHT [UIScreen mainScreen].bounds.size.height

#import "MenuViewController.h"

@interface MenuViewController ()<UITableViewDataSource, UITableViewDelegate>
{
    NSArray* _menuName;  //菜单名字
    UITableView* _menu;  //菜单列表
    
    UITableView* _userList;  //用户列表
    NSMutableArray* _users;  //用户数组
    
    UISwitch* _weatherSwitch;  //天气开关
    
    int _currentUserIndex;  //当前用户标记
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
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_userList];
    [self.view addSubview:_menu];
    
    //切换按摩椅
    CGFloat unit = 0.7*SCREENWIDTH/3;
    UIButton* change = [[UIButton alloc]initWithFrame:CGRectMake(unit/3, SCREENHEIGHT - unit*0.5-SCREENWIDTH*0.034, unit, unit*0.4)];
    change.titleLabel.font =[UIFont systemFontOfSize:13];
    [change setTitle:NSLocalizedString(@"切换按摩椅",nil) forState:0];
    [change setTintColor:[UIColor blackColor]];
    change.backgroundColor = [UIColor colorWithRed:0 green:0 blue:1 alpha:0.6];
    [change addTarget:self action:@selector(changeMessageChair) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:change];
    
    //注销
    UIButton* logout = [[UIButton alloc]initWithFrame:CGRectMake(unit*5/3.0, SCREENHEIGHT - unit*0.5-SCREENWIDTH*0.034, unit, unit*0.4)];
    logout.titleLabel.font =[UIFont systemFontOfSize:13];
    [logout setTitle:NSLocalizedString(@"注销",nil) forState:0];
    [logout setTintColor:[UIColor blackColor]];
    logout.backgroundColor = [UIColor colorWithRed:0 green:0 blue:1 alpha:0.6];
    [logout addTarget:self action:@selector(Logout) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:logout];
    
    // Do any additional setup after loading the view.
}

#pragma mark - 根据数组个数更新菜单位置
-(void)updatTableViewFrame
{
    if (_users.count<3) {
        _userList.scrollEnabled = NO;
        _userList.frame = CGRectMake(0, 20, 0.71*SCREENWIDTH, _users.count*_rowHeight+20);
    }
    else
    {
        _userList.scrollEnabled = YES;
        _userList.frame = CGRectMake(0, 20, 0.71*SCREENWIDTH, 3*_rowHeight+20);
    }
    _menu.frame = CGRectMake(0, _userList.frame.size.height, 0.71*SCREENWIDTH, _menuName.count*_rowHeight);
}

#pragma mark - 对象初始化
-(void)setUp
{
    //行高
    _rowHeight = SCREENHEIGHT*0.085;
    
    //用户数组
    _users = [NSMutableArray new];
    [_users addObject:@"黄晓明"];   //以后换成用户的数据模型
    [_users addObject:@"爸爸"];
//    [_users addObject:@"妈妈"];
    
    //用户列表
    _userList = [[UITableView alloc]initWithFrame:CGRectMake(0, 20, 0.71*SCREENWIDTH, _users.count*_rowHeight+20) style:UITableViewStylePlain];
    _userList.tag = 2001;
    _userList.backgroundColor = [UIColor clearColor];
    _userList.dataSource = self;
    _userList.delegate = self;
    _userList.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    _currentUserIndex = 0;
    
    
    //菜单数组
    _menuName = @[NSLocalizedString(@"家庭成员管理",nil), NSLocalizedString(@"数据中心",nil), NSLocalizedString(@"定时计划",nil), NSLocalizedString(@"首页天气预报",nil) ,NSLocalizedString(@"我要反馈",nil) ,NSLocalizedString(@"使用帮助",nil) ,NSLocalizedString(@"我要购买",nil)];
    
    //菜单列表
    _menu = [[UITableView alloc]initWithFrame:CGRectMake(0, _userList.frame.size.height, 0.71*SCREENWIDTH, _menuName.count*_rowHeight) style:UITableViewStyleGrouped];
    _menu.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    _menu.tag = 2002;
    _menu.backgroundColor = [UIColor cyanColor];
    _menu.dataSource = self;
    _menu.delegate = self;
    _menu.scrollEnabled = NO;
    
    //天气开关
    _weatherSwitch = [[UISwitch alloc]initWithFrame:CGRectMake(0, 0, 300, 100)];
    
    [self updatTableViewFrame];
}


#pragma mark - tableView代理实现
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView.tag == 2001) {
        return _users.count;
    }
    else if (tableView.tag == 2002)
    {
        return _menuName.count;
    }
    else
        return 0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.tag == 2001) {
        UITableViewCell* userCell = [tableView dequeueReusableCellWithIdentifier:@"usercell"];
        
        if (!userCell) {
            userCell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"usercell"];
        }
        userCell.textLabel.text = _users[indexPath.row];
        userCell.selectionStyle = UITableViewCellSelectionStyleNone;
        if (_users.count > 1) {
            //用户大于1，才显示当前用户
            if (indexPath.row == _currentUserIndex) {
                userCell.accessoryView = [self currentLabel];
            }
            else
            {
                userCell.accessoryView = nil;
            }
        }
        return userCell;
    }
    else if (tableView.tag == 2002)
    {
        UITableViewCell* menuCell = [tableView dequeueReusableCellWithIdentifier:@"menucell"];
        
        if (!menuCell) {
            menuCell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"menucell"];
        }
        menuCell.textLabel.text = _menuName[indexPath.row];
        if ([_menuName[indexPath.row] isEqualToString:NSLocalizedString(@"首页天气预报",nil)]) {
            menuCell.accessoryView = _weatherSwitch;
        }
        else
        {
            menuCell.accessoryView = nil;
        }
        return menuCell;
    }
    else
        return nil;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.tag == 2001) {
        if (_users.count > 1) {
            NSIndexPath* currentIndexPath = [NSIndexPath indexPathForRow:_currentUserIndex inSection:0];
            UITableViewCell* userCell = [tableView cellForRowAtIndexPath:currentIndexPath];
            userCell.accessoryView = nil;
            userCell = [tableView cellForRowAtIndexPath:indexPath];
            userCell.accessoryView = [self currentLabel];
            _currentUserIndex = indexPath.row;
        }
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return _rowHeight;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.000001;
}

#pragma mark - 当前用户
-(UILabel*)currentLabel
{
    UILabel*  currentUser = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 40)];
    currentUser.text = NSLocalizedString(@"当前用户",nil);
    return currentUser;
}

#pragma mark - 注销
-(void)Logout
{
    
}

#pragma mark - 切换按摩椅
-(void)changeMessageChair
{
    
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
