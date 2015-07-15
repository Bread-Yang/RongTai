//
//  AddTimingMassageViewController.m
//  rongtai
//
//  Created by yoghourt on 6/10/15.
//  Copyright (c) 2015 William-zhang. All rights reserved.
//

#import "AddTimingMassageViewController.h"

#import "AddTimingMassageViewController.h"
#import "LineUICollectionViewCell.h"
#import <MagicalRecord.h>
#import "TimingPlan.h"

@interface AddTimingMassageViewController () {
	
	NSArray* modeNameArray;
	NSMutableArray* hourArray;
	NSMutableArray* minuteArray;
	id segment[7];
    __weak IBOutlet UISegmentedControl *_weekSC;
}

@end

@implementation AddTimingMassageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
	
	UIImageView *backgroundImageView = [[UIImageView alloc]initWithFrame:self.view.frame];
	backgroundImageView.image = [UIImage imageNamed:@"bg"];
	[self.view insertSubview:backgroundImageView atIndex:0];
	
	modeNameArray = @[@"舒展活络", @"工作减压", @"运动恢复", @"模式4", @"模式5"];
	
	hourArray = [NSMutableArray new];
	for (int i = 0; i < 24; i++) {
		[hourArray addObject:[NSString stringWithFormat:@"%d", i]];
	}
	
	minuteArray = [NSMutableArray new];
	for (int i = 0; i < 60; i++) {
		[minuteArray addObject:[NSString stringWithFormat:@"%d", i]];
	}
	
	LineUICollectionViewFlowLayout *lineLayout = [[LineUICollectionViewFlowLayout alloc] init];
	[lineLayout setItemSize:CGSizeMake(self.collectionView.bounds.size.height / 3 * 2, self.collectionView.bounds.size.height / 3 * 2)];
	lineLayout.delegate = self;
	self.collectionView.collectionViewLayout = lineLayout;
	
	[self.collectionView registerClass:[LineUICollectionViewCell class] forCellWithReuseIdentifier:@"MY_CELL"];
	
	[_weekSC addTarget:self
				action:@selector(segmentedControl:)
	  forControlEvents:UIControlEventAllEvents];
	
	for (int i = 0; i < 7; i++) {
		segment[i] = [[_weekSC subviews] objectAtIndex:i];
	}
}

- (void)segmentedControl:(id)sender {
	//do some thing
	[self changeColor];
}

- (void)changeColor{
	for (int i = 0; i < 7; i++) {
		[segment[i] setTintColor:[UIColor lightGrayColor]];
	}
	int select = _weekSC.selectedSegmentIndex;
	NSLog(@"当前的index : %li", (long)_weekSC.selectedSegmentIndex);
	[segment[6 - select] setTintColor:[UIColor colorWithRed:82 / 255.0 green:203 / 255.0 blue:81 / 255.0 alpha:1]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Action

- (IBAction)saveAction:(id)sender {
//	TimingMassageModel *model = [[TimingMassageModel alloc] init];
//	model.loopDate = @"hahah";
//	if (self.returnTimingMassageBlock) {
//		self.returnTimingMassageBlock(model);
//		[self.navigationController popViewControllerAnimated:TRUE];
//	}
    TimingPlan* timePlan = [TimingPlan MR_createEntity];
    [timePlan setLocalNotificationByHour:[_leftPickerView selectedRowInComponent:0] Minute:[_rightPickerView selectedRowInComponent:0] Week:_weekSC.selectedSegmentIndex+1  Message:[NSString stringWithFormat:@"舒展活络 定时计划:每周%ld %02ld:%02ld",_weekSC.selectedSegmentIndex,[_leftPickerView selectedRowInComponent:0],[_rightPickerView selectedRowInComponent:0]]];
    timePlan.massageId = [NSNumber numberWithInt:123456];
    timePlan.massageName = @"舒展活络";
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
	return 10;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
	LineUICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MY_CELL" forIndexPath:indexPath];
	UIImage *icon;
	switch (indexPath.row) {
  		case 0:
			break;
		case 1:
			icon = [UIImage imageNamed:@"mode_1"];
			break;
		case 2:
			icon = [UIImage imageNamed:@"mode_2"];
			break;
		case 3:
			icon = [UIImage imageNamed:@"mode_3"];
			break;
		case 4:
			icon = [UIImage imageNamed:@"mode_4"];
			break;
		case 5:
			icon = [UIImage imageNamed:@"mode_5"];
			break;
		case 6:
			icon = [UIImage imageNamed:@"mode_6"];
			break;
		case 7:
			icon = [UIImage imageNamed:@"mode_7"];
			break;
		case 8:
			icon = [UIImage imageNamed:@"mode_8"];
			break;
		case 9:
			break;
	}
	cell.imageView.image = icon;
	if (indexPath.row == 0 || indexPath.row == 9) {
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

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
	[[pickerView.subviews objectAtIndex:1] setHidden:TRUE];
	[[pickerView.subviews objectAtIndex:2] setHidden:TRUE];
	if (pickerView.tag == 0) {
		return hourArray[row];
	} else {
		return minuteArray[row];
	}
}

#pragma mark - LineUICollectionViewFlowLayoutDelegate

- (void)currentHighlightItem:(NSIndexPath *)indexPath {
	NSLog(@"currentHighlightItem执行了");
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
