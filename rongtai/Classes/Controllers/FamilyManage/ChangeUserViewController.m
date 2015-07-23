//
//  ChangeUserViewController.m
//  rongtai
//
//  Created by William-zhang on 15/7/13.
//  Copyright (c) 2015年 William-zhang. All rights reserved.
//

#import "ChangeUserViewController.h"
#import "CoreData+MagicalRecord.h"
#import "Member.h"
#import "RongTaiConstant.h"
#import "BasicTableViewCell.h"

@interface ChangeUserViewController ()<UITableViewDataSource, UITableViewDelegate>
{
    NSArray* _users;  //用户数据，数据从本地读取
    UITableView* _table;
    NSInteger _selectIndex;
    CGFloat _rowHeight;
}
@end

@implementation ChangeUserViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"切换用户", nil);
    
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem goBackItemByTarget:self Action:@selector(goBack)];
    
    _rowHeight = 60;
    _table = [[UITableView alloc]initWithFrame:CGRectMake(0, 64, SCREENWIDTH, SCREENHEIGHT-64)];
    _table.backgroundColor = [UIColor clearColor];
    _table.dataSource = self;
    _table.delegate = self;
    _table.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_table];
    
    
    _selectIndex = 0;
    
    //查询用户
    _users = [Member MR_findAll];
    [_table reloadData];
    
    
    //测试用
//    NSMutableArray* _arr = [NSMutableArray new];
//    for (int i =0 ; i<5; i++) {
//        Member* m = [Member MR_createEntity];
//        m.name = @"用户名";
//        m.imageURL = @"userIcon.jpg";
//        [_arr addObject:m];
//    }
//    _users = _arr;
//    [_table reloadData];
    
    // Do any additional setup after loading the view.
}

#pragma mark - 返回
-(void)goBack
{
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - tableView代理现实
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BasicTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"userCell"];
    if (!cell) {
        cell = [[BasicTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"userCell"];
        cell.imageViewScale = 0.7;
        UIView* line = [[UIView alloc]initWithFrame:CGRectMake(0, _rowHeight-1, SCREENWIDTH, 1)];
        line.backgroundColor = [UIColor grayColor];
        line.alpha = 0.2;
        [cell addSubview:line];
    }
    Member* m = _users[indexPath.row];
    cell.textLabel.text = m.name;
    cell.textLabel.textColor = BLACK;
    cell.backgroundColor = [UIColor clearColor];
    cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
    cell.imageView.image = [UIImage imageNamed:m.imageURL];
    cell.imageView.layer.cornerRadius = 21;
    cell.imageView.clipsToBounds = YES;
    cell.imageView.layer.borderColor = [UIColor whiteColor].CGColor;
    cell.imageView.layer.borderWidth = 2;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (indexPath.row == _selectIndex) {
        cell.accessoryView = [self selectedView];
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    for (UITableViewCell* cell in tableView.visibleCells) {
        cell.accessoryView = nil;
    }
    UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryView = [self selectedView];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _users.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return _rowHeight;
}

#pragma mark - 生成一个打钩的View
-(UIImageView*)selectedView
{
    UIImageView* select = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"user_list_select"]];
    return select;
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
