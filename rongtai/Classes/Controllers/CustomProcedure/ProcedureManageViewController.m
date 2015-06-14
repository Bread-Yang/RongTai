//
//  ProcedureManageViewController.m
//  rongtai
//
//  Created by William-zhang on 15/6/14.
//  Copyright (c) 2015年 William-zhang. All rights reserved.
//

#import "ProcedureManageViewController.h"
#import "CustomProcedureViewController.h"
#import "ProcedureManageCollectionViewCell.h"

@interface ProcedureManageViewController ()<UICollectionViewDataSource,UICollectionViewDelegate>
{
    UIBarButtonItem* _edit;  //编辑按钮
    BOOL _isEdit;  //是否处在编辑状态
    NSMutableArray* _massageModes;  //按摩模式数组
    UICollectionView* _collectionView;
    CGFloat _matgin;
    NSInteger _countInRow;
    NSString* _reuseIdentifier;
    
}
@end

@implementation ProcedureManageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"自定义程序", nil);
    self.view.backgroundColor = [UIColor whiteColor];
    _isEdit = NO;
    _edit = [[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"编辑", nil) style:UIBarButtonItemStylePlain target:self action:@selector(editProcedure)];
    self.navigationItem.rightBarButtonItem = _edit;
    
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGFloat height = [UIScreen mainScreen].bounds.size.height;
    _matgin = width*0.8*0.05;
    _countInRow = 2;
    _reuseIdentifier = @"ProcedureManageCell";
    UICollectionViewFlowLayout *flowLayout = [UICollectionViewFlowLayout new];
    CGFloat cellWidth = (width*0.8- _countInRow* _matgin) / 2;
    //    CGFloat cellHeight = (_collectView.frame.size.height - 3*_matgin)/3;
    flowLayout.itemSize = CGSizeMake(cellWidth, cellWidth);
    flowLayout.minimumInteritemSpacing = _matgin;
    flowLayout.minimumLineSpacing = _matgin;
    
    _collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0.1*width, 30, width*0.8, height -64-30) collectionViewLayout:flowLayout];
    _collectionView.backgroundColor = [UIColor clearColor];
    [_collectionView registerClass:[ProcedureManageCollectionViewCell class] forCellWithReuseIdentifier:_reuseIdentifier];
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    [self.view addSubview:_collectionView];
    // Do any additional setup after loading the view.
}


#pragma mark - collectionView代理
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
//    return _massageModes.count;
    return 3;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ProcedureManageCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:_reuseIdentifier forIndexPath:indexPath];
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    UIStoryboard* s = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
    if (_isEdit)
    {
        CustomProcedureViewController* c = (CustomProcedureViewController*)[s instantiateViewControllerWithIdentifier:@"CustomProcedure"];
        [c editModeWithMassageMode:nil Index:0];
        [self.navigationController pushViewController:c animated:YES];
    }
    else
    {
        
    }
}

#pragma mark - 编辑/完成 按钮方法
-(void)editProcedure
{
    _isEdit = !_isEdit;
    if (_isEdit) {
        _edit.title = NSLocalizedString(@"完成", nil);
    }
    else
    {
        _edit.title = NSLocalizedString(@"编辑", nil);
    }
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
