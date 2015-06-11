//
//  AddTimingMassageViewController.m
//  rongtai
//
//  Created by yoghourt on 6/10/15.
//  Copyright (c) 2015 William-zhang. All rights reserved.
//

#import "AddTimingMassageViewController.h"

#import "AddTimingMassageViewController.h"
#import "LineUICollectionViewFlowLayout.h"
#import "LineUICollectionViewCell.h"

@interface AddTimingMassageViewController () {
	
	NSArray* modeNameArray;
	NSMutableArray* hourArray;
	NSMutableArray* minuteArray;

}

@end

@implementation AddTimingMassageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
	
	modeNameArray = @[@"舒展活络", @"工作减压", @"运动恢复", @"模式4", @"模式5"];
	
	hourArray = [NSMutableArray new];
	for (int i = 0; i < 24; i++) {
		[hourArray addObject:[NSString stringWithFormat:@"%d", i]];
	}
	
	minuteArray = [NSMutableArray new];
	for (int i = 0; i < 60; i++) {
		[minuteArray addObject:[NSString stringWithFormat:@"%d", i]];
	}
	
	LineUICollectionViewFlowLayout* lineLayout = [[LineUICollectionViewFlowLayout alloc] init];
	[lineLayout setItemSize:CGSizeMake(self.collectionView.bounds.size.height * 0.7, self.collectionView.bounds.size.height * 0.7)];
	self.collectionView.collectionViewLayout = lineLayout;
	
	[self.collectionView registerClass:[LineUICollectionViewCell class] forCellWithReuseIdentifier:@"MY_CELL"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Action

- (IBAction)saveAction:(id)sender {
	TimingMassageModel *model = [[TimingMassageModel alloc] init];
	model.loopDate = @"hahah";
	if (self.returnTimingMassageBlock) {
		self.returnTimingMassageBlock(model);
		[self.navigationController popViewControllerAnimated:TRUE];
	}
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
	return 10;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
	LineUICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MY_CELL" forIndexPath:indexPath];
	if (indexPath.row < [modeNameArray count]) {
		cell.label.text = modeNameArray[indexPath.item];
	} else {
		cell.label.text = [NSString stringWithFormat:@"%ld",indexPath.item];
	}
	if (indexPath.row == 0) {
		cell.hidden = YES;
	} else {
		cell.hidden = FALSE;
	}
	return cell;
}

#pragma mark - UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
	return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
	if (pickerView.tag == 0) {  // 小时
		return 24;
	} else { // 分
		return 60;
	}
}

#pragma mark - UIPickerViewDelegate

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
	[[pickerView.subviews objectAtIndex:1] setHidden:TRUE];
	[[pickerView.subviews objectAtIndex:2] setHidden:TRUE];
	if (pickerView.tag == 0) {
		return hourArray[row];
	} else {
		return minuteArray[row];
	}
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
