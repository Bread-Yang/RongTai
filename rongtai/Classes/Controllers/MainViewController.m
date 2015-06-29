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

#define SCREENWIDTH [UIScreen mainScreen].bounds.size.width
#define SCREENHEIGHT [UIScreen mainScreen].bounds.size.height

@interface MainViewController ()<SlideNavigationControllerDelegate,UITableViewDataSource, UITableViewDelegate, MassageRequestDelegate>
{
    UITableView* _table;
    NSMutableArray* _massageArr;
    MassageRequest* _massageRequest;
}
@end

@implementation MainViewController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    SlideNavigationController* s = (SlideNavigationController*)self.navigationController;
    s.view.layer.shadowColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3].CGColor;
    s.view.layer.shadowOffset = CGSizeMake(-0.5, 0);
    s.view.layer.shadowOpacity  = 1;
    s.view.layer.shadowRadius = 1;
    
    //
    _table = [[UITableView alloc]initWithFrame:CGRectMake(0, 64, SCREENWIDTH, SCREENHEIGHT-64) style:UITableViewStylePlain];
    _table.dataSource = self;
    _table.delegate = self;
    [self.view addSubview:_table];
    
    //
    _massageRequest = [[MassageRequest alloc]init];
    _massageRequest.delegate = self;
    NSString* uid = [[NSUserDefaults standardUserDefaults] objectForKey:@"uid"];
    [_massageRequest requestFavoriteMassageListByUid:uid Index:0 Size:100];
    
    _massageArr = [NSMutableArray new];
    // Do any additional setup after loading the view.
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
        cell.detailTextLabel.text = massage.description;
    }
    return cell;
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
    [[SlideNavigationController sharedInstance] openMenu:MenuLeft withCompletion:nil];
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
