//
//  MainViewController.m
//  rongtai
//
//  Created by William-zhang on 15/6/8.
//  Copyright (c) 2015年 William-zhang. All rights reserved.
//

#import "MainViewController.h"
#import "SlideNavigationController.h"
#import "MassageRequest.h"
#import "WLWeatherView.h"
#import "MenuViewController.h"
#import "ManualMassageViewController.h"
#import "CustomProcedureViewController.h"
#import "ProgramDownloadTableViewController.h"

#define SCREENWIDTH [UIScreen mainScreen].bounds.size.width
#define SCREENHEIGHT [UIScreen mainScreen].bounds.size.height

@interface MainViewController ()<SlideNavigationControllerDelegate,UITableViewDataSource, UITableViewDelegate, MassageRequestDelegate,UITabBarDelegate, MenuViewControllerDelegate>
{
    UITableView* _table;
    NSMutableArray* _massageArr;
    MassageRequest* _massageRequest;
    WLWeatherView* _weatherView;
}
@end

@implementation MainViewController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"荣泰", nil);
    self.navigationController.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];
    
    //
    SlideNavigationController* slideNav = (SlideNavigationController*)self.navigationController;
    MenuViewController* menu = (MenuViewController*)slideNav.leftMenu;
    menu.delegate = self;
    
    //天气预报
    _weatherView = [[WLWeatherView alloc]initWithFrame:CGRectMake(0, 0, 90, 44)];
    UIBarButtonItem* right = [[UIBarButtonItem alloc]initWithCustomView:_weatherView];
    self.navigationItem.rightBarButtonItem  = right;
    
    //菜单按钮
    UIBarButtonItem* left = [[UIBarButtonItem alloc]initWithTitle:nil style:UIBarButtonItemStylePlain target:self action:@selector(slideMenuAppear:)];
    UIButton* image = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 34, 34)];
    [image setImage:[UIImage imageNamed:@"userDefaultIcon.jpg"] forState:UIControlStateNormal];
    [image addTarget:self action:@selector(slideMenuAppear:) forControlEvents:UIControlEventTouchUpInside];
    image.layer.cornerRadius = 17;
    left.customView = image;
    image.layer.borderColor = [UIColor whiteColor].CGColor;
    image.layer.borderWidth = 1;
    image.clipsToBounds = YES;
//    self.navigationItem.leftBarButtonItem = left;
    
    SlideNavigationController* s = (SlideNavigationController*)self.navigationController;
    s.leftBarButtonItem = left;
    

    //侧滑菜单
    s.view.layer.shadowColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.35].CGColor;
    s.view.layer.shadowOffset = CGSizeMake(-0.5, 0);
    s.view.layer.shadowOpacity  = 5;
    s.view.layer.shadowRadius = 10;
 
    
    //
    _table = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT-49) style:UITableViewStylePlain];
    _table.dataSource = self;
    _table.delegate = self;
    [self.view addSubview:_table];
    
    //
    _massageRequest = [[MassageRequest alloc]init];
    _massageRequest.delegate = self;
    NSString* uid = [[NSUserDefaults standardUserDefaults] objectForKey:@"uid"];
    [_massageRequest requestMassageListByUid:uid Index:0 Size:100];
    
    _massageArr = [NSMutableArray new];
    
    //
    UITabBar* bar = [[UITabBar alloc]initWithFrame:CGRectMake(0, SCREENHEIGHT-49, SCREENWIDTH, 50)];
    bar.barTintColor = [UIColor colorWithRed:48/255.0 green:65/255.0 blue:77/255.0 alpha:1.0];
    bar.tintColor = [UIColor whiteColor];
    UITabBarItem* item1 = [[UITabBarItem alloc]initWithTitle:@"负离子" image:[UIImage imageNamed:@"icon_set"] tag:0];
    UITabBarItem* item2 = [[UITabBarItem alloc]initWithTitle:@"手动" image:[UIImage imageNamed:@"icon_hand"] tag:1];
    UITabBarItem* item3 = [[UITabBarItem alloc]initWithTitle:@"自定义" image:[UIImage imageNamed:@"icon_user"] tag:2];
    UITabBarItem* item4 = [[UITabBarItem alloc]initWithTitle:@"下载" image:[UIImage imageNamed:@"icon_set"] tag:3];
    bar.items = @[item1,item2,item3,item4];
    bar.selectedItem = item1;
    bar.delegate = self;
    [self.view addSubview:bar];
    
    // Do any additional setup after loading the view.
}

#pragma mark - menuController代理
-(void)switchChange:(BOOL)isOn
{
    if (isOn) {
        _weatherView.hidden = NO;
        [_weatherView updateWeather];
    }
    else
    {
        _weatherView.hidden = YES;
        [_weatherView cancelUpdate];
    }
}

#pragma mark - tabBar代理
-(void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{
    
//    NSLog(@"tabBar:%ld",item.tag);
    if (item.tag == 1) {
        //手动按摩
        UIStoryboard* s = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        ManualMassageViewController* mVC = (ManualMassageViewController*)[s instantiateViewControllerWithIdentifier:@"ManualMassageVC"];
        [self.navigationController pushViewController:mVC animated:YES];
    }
    else if (item.tag == 2)
    {
        //自定义
        UIStoryboard* s = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
        CustomProcedureViewController* cVC= (CustomProcedureViewController*)[s instantiateViewControllerWithIdentifier:@"CustomProcedure"];
        [self.navigationController pushViewController:cVC animated:YES];
    }
    else if (item.tag == 3)
    {
        //下载
        UIStoryboard* s = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        ProgramDownloadTableViewController* pVC = (ProgramDownloadTableViewController*)[s instantiateViewControllerWithIdentifier:@"ProgramDownloadVC"];
        [self.navigationController pushViewController:pVC animated:YES];

    }
}

#pragma mark - tableView代理
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _massageArr.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
    }
    Massage* massage = _massageArr[indexPath.row];
    if (massage) {
        cell.textLabel.text = massage.name;
        cell.detailTextLabel.text = massage.mDescription;
    }
    cell.imageView.image = [UIImage imageNamed:@"mode_1"];
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

#pragma mark - massageRequest代理
-(void)massageRequestMassageListFinish:(BOOL)success Result:(NSDictionary *)dic
{
    if (success) {
        NSArray* arr = [dic objectForKey:@"result"];
        NSLog(@"用户下载列表:%@",arr);
        if (arr.count>0) {
            for (int i = 0; i<arr.count; i++) {
                Massage* massage = [[Massage alloc]initWithJSON:arr[i]];
                [_massageArr addObject:massage];
            }
            [_table reloadData];
        }
    }
}

#pragma mark - 侧滑菜单代理
-(BOOL)slideNavigationControllerShouldDisplayLeftMenu
{
    return YES;
}

#pragma mark - 侧滑菜单出现
- (IBAction)slideMenuAppear:(id)sender {
    [[SlideNavigationController sharedInstance] toggleLeftMenu];
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
