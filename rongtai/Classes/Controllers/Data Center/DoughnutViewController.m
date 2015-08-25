//
//  DoughnutViewController.m
//  rongtai
//
//  Created by William-zhang on 15/6/11.
//  Copyright (c) 2015年 William-zhang. All rights reserved.
//

#import "DoughnutViewController.h"
#import "DoughnutCollectionViewCell.h"
#import "UIView+AddBorder.h"
#import "UILabel+WLAttributedString.h"
#import "RongTaiConstant.h"
#import "ProgramCount.h"
#import "CoreData+MagicalRecord.h"

@interface DoughnutViewController ()<UICollectionViewDataSource,UICollectionViewDelegate>
{
    __weak IBOutlet UICollectionView *_collectView;
//    NSArray* _names;  //按摩种类
//    NSArray* _count;  //次数
//    NSArray* _percent; //比例
    CGFloat _matgin;
    NSInteger _countInRow;
    NSString* _reuseIdentifier;
    UIFont* _font;
    NSArray* _colors;  //颜色数组
    
    NSArray* _progarmCounts;
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
    _colors = @[BLUE, LIGHTGREEN,ORANGE];
    _progarmCounts = [ProgramCount MR_findAll];
    // Do any additional setup after loading the view.
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self setUp];
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
//    _names = @[@"工作减压",@"工作减压",@"工作减压",@"工作减压",@"工作减压",@"工作减压"];
//    _percent = @[@0.5,@0.7,@0.3,@0.9,@0.1,@0.6];
//    _count = @[@21,@35,@78,@98,@129,@6];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _progarmCounts.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    DoughnutCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:_reuseIdentifier forIndexPath:indexPath];
    ProgramCount* program = _progarmCounts[indexPath.row];
    cell.nameLabel.text = program.name;
    NSNumber* c = program.useCount;
    cell.count = [c integerValue];
    cell.doughnut.percent = [c integerValue]/100.0;
    [cell addLineBorder];
    cell.countLabel.font = _font;
    cell.doughnut.finishColor = _colors[indexPath.row/2];
    [cell.countLabel setNumebrByFont:_font Color:_colors[indexPath.row/2]];
    return cell;
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
