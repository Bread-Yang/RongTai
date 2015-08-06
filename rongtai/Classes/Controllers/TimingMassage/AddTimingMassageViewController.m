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
#import "UIBarButtonItem+goBack.h"

@interface AddTimingMassageViewController () {
	
	id segment[7];
    __weak IBOutlet UISegmentedControl *_weekSC;
	BOOL isNotFirstInvokeDidLayoutSubviews;
	
}

@property (nonatomic, retain) NSArray *modeNameArray;

@property (nonatomic, retain) NSMutableArray *hourArray, *minuteArray;

@property (nonatomic, retain) NAPickerView *leftPickView, *rightPickView;

@property (nonatomic, retain) NSMutableArray *leftItems;

@property (nonatomic, retain) NSMutableArray *rightItems;

@end

@implementation AddTimingMassageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //导航栏返回按钮设置
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem goBackItemByTarget:self Action:@selector(goBack)];
	
	UIImageView *backgroundImageView = [[UIImageView alloc] initWithFrame:self.view.frame];
	backgroundImageView.image = [UIImage imageNamed:@"bg"];
	[self.view insertSubview:backgroundImageView atIndex:0];
	
    NSArray *segments = @[ @"日", @"一", @"二", @"三", @"四", @"五", @"六"];
	
	for (int i = 0; i < [segments count]; i++) {
		[self.weekDaySegmentControl insertSegmentWithTitle:[segments objectAtIndex:i] atIndex:i];
	}
	self.weekDaySegmentControl.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin;
	[self.weekDaySegmentControl setTintColor:[UIColor colorWithRed:82 / 255.0 green:203 / 255.0 blue:81 / 255.0 alpha:1]];
	
	self.modeNameArray = @[@"舒展活络", @"工作减压", @"运动恢复", @"消除疲劳", @"女性仟体按摩", @"韩式按摩", @"老年按摩", @"舒展活络"];
	
	self.hourArray = [NSMutableArray new];
	for (int i = 0; i < 24; i++) {
		[self.hourArray addObject:[NSString stringWithFormat:@"%d", i]];
	}
	
	self.minuteArray = [NSMutableArray new];
	for (int i = 0; i < 60; i++) {
		[self.minuteArray addObject:[NSString stringWithFormat:@"%d", i]];
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
		
		self.leftItems = [[NSMutableArray alloc] init];
		for (int i = 0; i < 24;  i++) {
			[self.leftItems addObject:[NSString stringWithFormat:@"%d", i]];
		}
		
		NSLog(@"width : %f, height : %f", [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
		
		self.leftPickView = [[NAPickerView alloc] initWithFrame:CGRectMake(size.width / 2 - 100, 0, 100, self.containView.frame.size.height) andItems:self.leftItems andDelegate:self];
		self.leftPickView.infiniteScrolling = YES;
		self.leftPickView.highlightBlock = ^(NALabelCell *cell) {
			cell.textView.textColor = [UIColor whiteColor];
			cell.textView.font = [UIFont systemFontOfSize:30];
//			cell.textView.font = [UIFont fontWithName:@"DBLCDTempBlack" size:30.0];
		};
		self.leftPickView.unhighlightBlock = ^(NALabelCell *cell) {
			cell.textView.textColor = [UIColor blackColor];
//			cell.textView.font = [UIFont fontWithName:@"DBLCDTempBlack" size:18.0];
			cell.textView.font = [UIFont systemFontOfSize:18];
		};
		[self.containView addSubview:self.leftPickView];
		
		self.rightItems = [[NSMutableArray alloc] init];
		for (int i = 0; i < 60;  i++) {
			[self.rightItems addObject:[NSString stringWithFormat:@"%d", i]];
		}
		
		self.rightPickView = [[NAPickerView alloc] initWithFrame:CGRectMake(size.width / 2, 0, 100, self.containView.frame.size.height) andItems:self.rightItems andDelegate:self];
		self.rightPickView.infiniteScrolling = YES;
		self.rightPickView.highlightBlock = ^(NALabelCell *cell) {
			cell.textView.textColor = [UIColor whiteColor];
			cell.textView.font = [UIFont systemFontOfSize:30];
		};
		self.rightPickView.unhighlightBlock = ^(NALabelCell *cell) {
			cell.textView.textColor = [UIColor blackColor];
			cell.textView.font = [UIFont systemFontOfSize:18];
		};
		[self.containView addSubview:self.rightPickView];
	}
}

#pragma mark - 返回
-(void)goBack
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)segmentedControl:(id)sender {
	//do some thing
	[self changeColor];
}

- (void)changeColor {
	for (int i = 0; i < 7; i++) {
		[segment[i] setTintColor:[UIColor lightGrayColor]];
	}
	NSInteger select = _weekSC.selectedSegmentIndex;
	
	NSLog(@"当前的index : %li", (long)_weekSC.selectedSegmentIndex);
	
	[segment[6 - select] setTintColor:[UIColor colorWithRed:82 / 255.0 green:203 / 255.0 blue:81 / 255.0 alpha:1]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Action

- (IBAction)saveAction:(id)sender {
    TimingPlan *timePlan = [TimingPlan MR_createEntity];
	NSInteger hour = [[self.leftPickView getHighlightItemString] intValue];
	NSInteger minute = [[self.rightPickView getHighlightItemString] intValue];
	timePlan.massageName = self.modeNameArray[self.collectionView.currentSelectItemIndex];
	NSString *message = [NSString stringWithFormat:@"%@", timePlan.massageName];
	
    [timePlan setLocalNotificationByHour:hour Minute:minute Week:[self.weekDaySegmentControl selectedIndexes] Message:message];
	
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
	
	[self.navigationController popViewControllerAnimated:YES];
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
	cell.imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"mode_%li", indexPath.row + 1]];
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
	NSLog(@"currentRow : %zd", row);
	[[pickerView.subviews objectAtIndex:1] setHidden:TRUE];
	[[pickerView.subviews objectAtIndex:2] setHidden:TRUE];
	if (pickerView.tag == 0) {
		return self.hourArray[row];
	} else {
		return self.minuteArray[row];
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
	NSLog(@"currentHighlightItem执行了, indexPath.row : %zd, indexPath.section : %zd", indexPath.row, indexPath.section);
	self.modeLabel.text = [self.modeNameArray objectAtIndex:indexPath.row];
	[self.modeLabel setNeedsDisplay];
}

#pragma mark - NAPickerViewDelegate

- (void)didSelectedItemAtIndex:(NAPickerView *)pickerView andIndex:(NSInteger)index {
	NSLog(@"当前选择的index : %zd", index);
	NSLog(@"highlightIndex : %zd", pickerView.getHighlightIndex);
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
