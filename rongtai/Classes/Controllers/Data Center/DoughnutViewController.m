//
//  DoughnutViewController.m
//  rongtai
//
//  Created by William-zhang on 15/6/11.
//  Copyright (c) 2015年 William-zhang. All rights reserved.
//

#import "DoughnutViewController.h"
#import "DoughnutCollectionViewCell.h"
#import "UILabel+WLAttributedString.h"
#import "RongTaiConstant.h"
#import "CoreData+MagicalRecord.h"
#import "DataCenterViewController.h"
#import "MBProgressHUD.h"

@interface DoughnutViewController ()<UICollectionViewDataSource,UICollectionViewDelegate>
{
    __weak IBOutlet UICollectionView *_collectView;
    CGFloat _matgin;
    NSInteger _countInRow;
    NSString* _reuseIdentifier;
    UIFont* _font;
    NSArray* _colors;  //颜色数组
    NSUInteger _totalCount;
    __weak DataCenterViewController* _dataCenterVC;
}
@end

@implementation DoughnutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if ([UIScreen mainScreen].bounds.size.width > 320) {
        _font = [UIFont fontWithName:@"Helvetica-Light" size:40];
    }
    else
    {
        _font = [UIFont fontWithName:@"Helvetica-Light" size:30];
    }
    _colors = @[BLUE, LIGHTGREEN, ORANGE];
    
    // Do any additional setup after loading the view.
}

#pragma mark - 请求数据
-(void)requestData:(DataCenterViewController*)vc
{
    _dataCenterVC = vc;
    [vc showHUD];
    NSString* uid = [[NSUserDefaults standardUserDefaults] objectForKey:@"uid"];
    NSArray* counts = [ProgramCount MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"(unUpdateCount > 0) AND (uid == %@)",uid]];
    BOOL b = counts.count>0;
    [ProgramCount synchroUseCountDataFormServer:b Success:^{
        
        _progarmCounts = [ProgramCount MR_findByAttribute:@"uid" withValue:uid andOrderBy:@"useCount" ascending:NO];
        [self totalUseCount];
        [_collectView reloadData];
        [vc hideHUD];
    } Fail:^(NSDictionary * dic) {
        _progarmCounts = [ProgramCount MR_findByAttribute:@"uid" withValue:uid andOrderBy:@"useCount" ascending:NO];
        //因为未同步成功，所以需要重新排序
        NSMutableArray* arr = [NSMutableArray arrayWithArray:_progarmCounts];
        for (int i = 0; i<arr.count; i++) {
            ProgramCount* c = arr[i];
            NSUInteger count1 = [c.useCount integerValue]+[c.unUpdateCount integerValue];
            for (int j = i+1; j<arr.count; j++) {
                ProgramCount* pc = arr[j];
                NSUInteger count2 = [pc.useCount integerValue]+[pc.unUpdateCount integerValue];
                if (count1<count2) {
                    [arr exchangeObjectAtIndex:i withObjectAtIndex:j];
                }
            }
        }
        [self totalUseCount];
        [_collectView reloadData];
        [vc hideHUD];
        [self showProgressHUDByString:@"读取数据失败，请检测网络"];
    }];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self setUp];
}

-(void)setProgarmCounts:(NSArray *)progarmCounts
{
    _progarmCounts = progarmCounts;
    if (_collectView.delegate) {
        [_collectView reloadData];
    }
}

#pragma mark - 计算总使用次数
-(void)totalUseCount
{
    _totalCount = 0;
    for (int i = 0; i<_progarmCounts.count; i++) {
        ProgramCount* p = _progarmCounts[i];
        _totalCount += [p.useCount integerValue]+[p.unUpdateCount integerValue];
    }
}

#pragma mark - 初始化
-(void)setUp
{
    CGFloat width = _collectView.frame.size.width;
    _matgin = width*0.03;
    _countInRow = 2;
    _reuseIdentifier = @"doughnutCell";
    [_collectView registerClass:[DoughnutCollectionViewCell class] forCellWithReuseIdentifier:_reuseIdentifier];
    UICollectionViewFlowLayout *flowLayout = [UICollectionViewFlowLayout new];
    
    CGFloat cellWidth = _collectView.frame.size.width/ 2;
    CGFloat cellHeight = (_collectView.frame.size.height - 2*_matgin)/3;
    flowLayout.itemSize = CGSizeMake(cellWidth, cellHeight);
    flowLayout.minimumInteritemSpacing = 0;
    flowLayout.minimumLineSpacing = _matgin;
    _collectView.collectionViewLayout = flowLayout;
    
    _collectView.dataSource = self;
    _collectView.delegate = self;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (_progarmCounts.count%2 == 0) {
        return _progarmCounts.count;
    }
    else
    {
        return _progarmCounts.count+1;
    }
    
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    DoughnutCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:_reuseIdentifier forIndexPath:indexPath];
    if (indexPath.row < _progarmCounts.count) {
        ProgramCount* program = _progarmCounts[indexPath.row];
        cell.nameLabel.text = program.name;
        NSNumber* c = program.useCount;
        NSNumber* unC = program.unUpdateCount;
        NSUInteger count = [c integerValue]+[unC integerValue];
        cell.count = count;
        cell.doughnut.percent = count/(float)_totalCount;
//        [cell addLineBorder];
        cell.isHiddenDougnut = NO;
        cell.countLabel.font = _font;
        cell.doughnut.finishColor = _colors[(indexPath.row/2)%3];
        [cell.countLabel setNumebrByFont:_font Color:_colors[(indexPath.row/2)%3]];
    }
    else
    {
        cell.isHiddenDougnut = YES;
//        [cell addLineBorder];
    }
    return cell;
}

#pragma mark - 快速提示
-(void)showProgressHUDByString:(NSString*)message
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.labelText = message;
    hud.margin = 10.f;
    hud.removeFromSuperViewOnHide = YES;
    [hud hide:YES afterDelay:0.7];
}

@end
