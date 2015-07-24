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
	
	NSArray *modeNameArray;
	NSMutableArray *hourArray;
	NSMutableArray *minuteArray;
	id segment[7];
    __weak IBOutlet UISegmentedControl *_weekSC;
	NAPickerView *leftPickView, *rightPickView;
	BOOL isNotFirstInvokeDidLayoutSubviews;
}

@end

@implementation AddTimingMassageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
	
	UIImageView *backgroundImageView = [[UIImageView alloc]initWithFrame:self.view.frame];
	backgroundImageView.image = [UIImage imageNamed:@"bg"];
	[self.view insertSubview:backgroundImageView atIndex:0];
	
    NSArray *segments = @[@"一", @"二", @"三", @"四", @"五", @"六", @"日"];
	
	for (int i = 0; i < [segments count]; i++) {
		[self.weekDaySegmentControl insertSegmentWithTitle:[segments objectAtIndex:i] atIndex:i];
	}
	self.weekDaySegmentControl.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin;
	[self.weekDaySegmentControl setTintColor:[UIColor colorWithRed:82 / 255.0 green:203 / 255.0 blue:81 / 255.0 alpha:1]];
	
	modeNameArray = @[@"舒展活络", @"工作减压", @"运动恢复", @"消除疲劳", @"女性仟体按摩", @"韩式按摩", @"老年按摩", @"舒展活络"];
	
	hourArray = [NSMutableArray new];
	for (int i = 0; i < 24; i++) {
		[hourArray addObject:[NSString stringWithFormat:@"%d", i]];
	}
	
	minuteArray = [NSMutableArray new];
	for (int i = 0; i < 60; i++) {
		[minuteArray addObject:[NSString stringWithFormat:@"%d", i]];
	}
	
	self.collectionView.delegate = self;
	
	[self.collectionView registerClass:[LineUICollectionViewCell class] forCellWithReuseIdentifier:@"MY_CELL"];
	
	[self.collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"Header"];
	
	[self.collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"Footer"];
	
	[_weekSC addTarget:self
				action:@selector(segmentedControl:)
	  forControlEvents:UIControlEventAllEvents];
	
	for (int i = 0; i < 7; i++) {
		segment[i] = [[_weekSC subviews] objectAtIndex:i];
	}
}

- (void)viewDidLayoutSubviews {
	if (!isNotFirstInvokeDidLayoutSubviews) {
		isNotFirstInvokeDidLayoutSubviews = true;
		
		CGSize size = [UIScreen mainScreen].bounds.size;
		
		NSMutableArray *leftItems = [[NSMutableArray alloc] init];
		for (int i = 0; i < 30;  i++) {
			[leftItems addObject:[NSString stringWithFormat:@"%d", i]];
		}
		
		NSLog(@"width : %f, height : %f", [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
		
		leftPickView = [[NAPickerView alloc] initWithFrame:CGRectMake(size.width / 2 - 100, 0, 100, self.containView.frame.size.height) andItems:leftItems andDelegate:self];
		leftPickView.infiniteScrolling = YES;
		leftPickView.highlightBlock = ^(NALabelCell *cell) {
			cell.textView.textColor = [UIColor whiteColor];
//			cell.textView.font = [UIFont systemFontOfSize:30];
			cell.textView.font = [UIFont fontWithName:@"DBLCDTempBlack" size:30.0];
		};
		leftPickView.unhighlightBlock = ^(NALabelCell *cell) {
			cell.textView.textColor = [UIColor blackColor];
			        cell.textView.font = [UIFont fontWithName:@"DBLCDTempBlack" size:18.0];
//			cell.textView.font = [UIFont systemFontOfSize:18];
		};
		[self.containView addSubview:leftPickView];
		
		NSMutableArray *rightItems = [[NSMutableArray alloc] init];
		for (int i = 0; i < 60;  i++) {
			[rightItems addObject:[NSString stringWithFormat:@"%d", i]];
		}
		
		rightPickView = [[NAPickerView alloc] initWithFrame:CGRectMake(size.width / 2, 0, 100, self.containView.frame.size.height) andItems:rightItems andDelegate:self];
		rightPickView.infiniteScrolling = YES;
		rightPickView.highlightBlock = ^(NALabelCell *cell) {
			cell.textView.textColor = [UIColor whiteColor];
			cell.textView.font = [UIFont systemFontOfSize:30];
		};
		rightPickView.unhighlightBlock = ^(NALabelCell *cell) {
			cell.textView.textColor = [UIColor blackColor];
			cell.textView.font = [UIFont systemFontOfSize:18];
		};
		[self.containView addSubview:rightPickView];
	}
}

- (void)viewDidAppear:(BOOL)animated {
	
}

- (void)segmentedControl:(id)sender {
	//do some thing
	[self changeColor];
}

- (void)changeColor {
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
    TimingPlan* timePlan = [TimingPlan MR_createEntity];
//    [timePlan setLocalNotificationByHour:[_leftPickerView selectedRowInComponent:0] Minute:[_rightPickerView selectedRowInComponent:0] Week:_weekSC.selectedSegmentIndex+1  Message:[NSString stringWithFormat:@"舒展活络 定时计划:每周%ld %02ld:%02ld",_weekSC.selectedSegmentIndex,[_leftPickerView selectedRowInComponent:0],[_rightPickerView selectedRowInComponent:0]]];
	
    timePlan.massageId = [NSNumber numberWithInt:123456];
    timePlan.massageName = @"舒展活络";
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
	return 8;
}

// Header和Footer的样式
//- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
//    NSString *reuseIdentifier;
//	if ([kind isEqualToString: UICollectionElementKindSectionFooter ]) {
//		reuseIdentifier = @"Footer";
//	}else{
//		reuseIdentifier = @"Header";
//	}
//	UICollectionReusableView *view =  [collectionView dequeueReusableSupplementaryViewOfKind :kind   withReuseIdentifier:reuseIdentifier   forIndexPath:indexPath];
//	
//	if (!view) {
//		view = [[UICollectionReusableView alloc] init];
//	}
//	if (kind == UICollectionElementKindSectionHeader) {
//		
//	} else if ([kind isEqualToString:UICollectionElementKindSectionFooter]) {
//
//	}
//	view.backgroundColor = [UIColor blackColor];
//	view.layer.borderWidth = .5f;
//	return view;
//}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
	LineUICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MY_CELL" forIndexPath:indexPath];
	UIImage *icon;
	switch (indexPath.row) {
		case 0:
			icon = [UIImage imageNamed:@"mode_1"];
			break;
		case 1:
			icon = [UIImage imageNamed:@"mode_2"];
			break;
		case 2:
			icon = [UIImage imageNamed:@"mode_3"];
			break;
		case 3:
			icon = [UIImage imageNamed:@"mode_4"];
			break;
		case 4:
			icon = [UIImage imageNamed:@"mode_5"];
			break;
		case 5:
			icon = [UIImage imageNamed:@"mode_6"];
			break;
		case 6:
			icon = [UIImage imageNamed:@"mode_7"];
			break;
		case 7:
			icon = [UIImage imageNamed:@"mode_8"];
			break;
	}
	cell.imageView.image = icon;
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
	NSLog(@"currentRow : %i", row);
	[[pickerView.subviews objectAtIndex:1] setHidden:TRUE];
	[[pickerView.subviews objectAtIndex:2] setHidden:TRUE];
	if (pickerView.tag == 0) {
		return hourArray[row];
	} else {
		return minuteArray[row];
	}
}

//- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
//	UILabel * label = [[UILabel alloc] init];
//	NSUInteger selectedRow = [pickerView selectedRowInComponent:component];
//	NSLog(@"selectedRow : %i, currentRow : %i", selectedRow, row);
//	
//	for (int i = 0; i < [hourArray count]; i++) {
//		if (i == selectedRow) {
//			label.attributedText = [[NSAttributedString alloc] initWithString:hourArray[i]
//																   attributes:@
//									{
//									NSForegroundColorAttributeName:[UIColor redColor]
//									}];
//			continue;
//		}
//		UILabel *label = [pickerView viewWithTag:i];
//		if (label && [label respondsToSelector:@selector(setAttributedText:)]) {
//			NSLog(@"里面执行了");
//			label.attributedText = [[NSAttributedString alloc] initWithString:hourArray[i]
//																   attributes:@
//									{
//									NSForegroundColorAttributeName:[UIColor blackColor]
//									}];
//		}
//	}
//	
//	NSAttributedString *attribute;
//	if (selectedRow == row) {
//		attribute = [[NSAttributedString alloc] initWithString:hourArray[row] attributes:@ {
//		NSForegroundColorAttributeName:[UIColor redColor]
//		}];
//	} else {
//		attribute = [[NSAttributedString alloc] initWithString:hourArray[row] attributes:@ {
//		NSForegroundColorAttributeName:[UIColor blackColor]
//		}];
//	}
//	label.attributedText = attribute;
//	label.tag = row;
//	return label;
//}

#pragma mark - LineCollectionViewDelegate

- (void)currentHighlightItemIndex:(NSIndexPath *)indexPath {
	NSLog(@"currentHighlightItem执行了, indexPath.row : %i, indexPath.section : %i", indexPath.row, indexPath.section);
	self.modeLabel.text = [modeNameArray objectAtIndex:indexPath.row];
	[self.modeLabel setNeedsDisplay];
}

#pragma mark - NAPickerViewDelegate

- (void)didSelectedItemAtIndex:(NAPickerView *)pickerView andIndex:(NSInteger)index {
	NSLog(@"当前选择的index : %i", index);
	NSLog(@"highlightIndex : %i", pickerView.getHighlightIndex);
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
