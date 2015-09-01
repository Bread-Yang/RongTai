//
//  AddTimingMassageViewController.m
//  rongtai
//
//  Created by yoghourt on 6/10/15.
//  Copyright (c) 2015 William-zhang. All rights reserved.
//

#import "AddOrEditTimingMassageViewController.h"
#import "LineUICollectionViewCell.h"
#import <MagicalRecord.h>
#import "UIBarButtonItem+goBack.h"
#import "TimingPlanRequest.h"
#import "MBProgressHUD.h"
#import "AppDelegate.h"

@interface AddOrEditTimingMassageViewController () <TimingPlanDelegate>{
	id segment[7];
    __weak IBOutlet UISegmentedControl *_weekSC;
	BOOL isNotFirstInvokeDidLayoutSubviews;
	TimingPlanRequest *_timingPlanRequest;
	MBProgressHUD *_loadingHUD;
}

@property (nonatomic, retain) NSArray *modeNameArray;

@property (nonatomic, retain) NSMutableArray *hourArray, *minuteArray;

@property (nonatomic, retain) NAPickerView *leftPickView, *rightPickView;

@property (nonatomic, retain) NSMutableArray *leftItems;

@property (nonatomic, retain) NSMutableArray *rightItems;

@end

@implementation AddOrEditTimingMassageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //导航栏返回按钮设置
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem goBackItemByTarget:self Action:@selector(goBack)];
	
	UIImageView *backgroundImageView = [[UIImageView alloc] initWithFrame:self.view.frame];
	backgroundImageView.image = [UIImage imageNamed:@"bg"];
	[self.view insertSubview:backgroundImageView atIndex:0];
	
    NSArray *segments = @[NSLocalizedString(@"日", nil), NSLocalizedString(@"一", nil), NSLocalizedString(@"二", nil), NSLocalizedString(@"三", nil), NSLocalizedString(@"四", nil), NSLocalizedString(@"五", nil), NSLocalizedString(@"六", nil)];
	
	for (int i = 0; i < [segments count]; i++) {
		[self.weekDaySegmentControl insertSegmentWithTitle:[segments objectAtIndex:i] atIndex:i];
	}
	self.weekDaySegmentControl.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin;
	[self.weekDaySegmentControl setTintColor:[UIColor colorWithRed:82 / 255.0 green:203 / 255.0 blue:81 / 255.0 alpha:1]];
	
	self.modeNameArray = @[NSLocalizedString(@"运动恢复", nil),
						   NSLocalizedString(@"舒展活络", nil),
						   NSLocalizedString(@"休憩促眠", nil),
						   NSLocalizedString(@"工作减压", nil),
						   NSLocalizedString(@"肩颈重点", nil),
						   NSLocalizedString(@"腰椎舒缓", nil),
						   NSLocalizedString(@"云养程序一", nil),
						   NSLocalizedString(@"云养程序二", nil),
						   NSLocalizedString(@"云养程序三", nil),
						   NSLocalizedString(@"云养程序四", nil),];
	
	self.modeLabel.text = [self.modeNameArray objectAtIndex:0];
	
	self.hourArray = [NSMutableArray new];
	for (int i = 0; i < 24; i++) {
		[self.hourArray addObject:[NSString stringWithFormat:@"%02zd", i]];
	}
	
	self.minuteArray = [NSMutableArray new];
	for (int i = 0; i < 60; i++) {
		[self.minuteArray addObject:[NSString stringWithFormat:@"%02zd", i]];
	}
	
	self.collectionView.delegate = self;
	
	[self.collectionView registerClass:[LineUICollectionViewCell class] forCellWithReuseIdentifier:@"MY_CELL"];
	
	[self.collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"Header"];
	
	[self.collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"Footer"];
	
	[_weekSC addTarget:self
				action:@selector(segmentedControl:)
	  forControlEvents:UIControlEventValueChanged];
	
	for (int i = 0; i < 7; i++) {
		segment[i] = [[_weekSC subviews] objectAtIndex:i];
	}
    
    //
    _timingPlanRequest = [TimingPlanRequest new];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	if (self.timingPlan) {
		NSArray *timeArray = [self.timingPlan.ptime componentsSeparatedByString:@":"];
		NSInteger hour = [timeArray[0] integerValue];
		NSInteger minute = [timeArray[1] integerValue];
		
		[_leftPickView setIndex:hour];
		[_rightPickView setIndex:minute];
	}
}

- (void)viewDidLayoutSubviews {
	if (!isNotFirstInvokeDidLayoutSubviews) {
		isNotFirstInvokeDidLayoutSubviews = true;
		
		CGSize size = [UIScreen mainScreen].bounds.size;
		
		self.leftItems = [[NSMutableArray alloc] init];
		for (int i = 0; i < 24;  i++) {
			[self.leftItems addObject:[NSString stringWithFormat:@"%02zd", i]];
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
			[self.rightItems addObject:[NSString stringWithFormat:@"%02zd", i]];
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
    if (self.timingPlan) {
        //保存信息到对象中
        [self.timingPlan cancelLocalNotification];
        self.timingPlan.localNotifications = nil;
        [self saveSelectedToTimingPlan];
        
        //对象不为空即是 编辑 定时计划
        NSInteger planId = [self.timingPlan.planId integerValue];
        if (planId == 0) {
            //id为0的话，即是未添加到服务器数据，使用 新增 方法
            [self addTimingPlan];
        }
        else
        {
            //id不为0，直接调用 编辑 方法
            [self updateTimingPlan];
        }
    }
    else {
        //对象为空既是 新增 定时计划
        self.timingPlan = [TimingPlan MR_createEntity];
        [self saveSelectedToTimingPlan];
        [self addTimingPlan];
    }
}

#pragma mark - 添加定时计划
-(void)addTimingPlan
{
    __weak MBProgressHUD *weakHUB = _loadingHUD;
    __weak AddOrEditTimingMassageViewController *weakSelf = self;
    [_timingPlanRequest addTimingPlan:self.timingPlan success:^(NSUInteger timingPlanId) {
        NSLog(@"定时计划 添加成功");
        //网络添加成功，要改变数据状态为0
        weakSelf.timingPlan.state = [NSNumber numberWithInteger:0];
        [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
        [weakHUB hide:YES];
        [weakSelf.navigationController popViewControllerAnimated:YES];
        
    } fail:^(NSDictionary *dic) {
        NSLog(@"定时计划 添加失败，改变本地数据状态");
        //网络添加失败，要改变数据状态为1
        weakSelf.timingPlan.state = [NSNumber numberWithInteger:1];
        [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
        [weakHUB hide:YES];
        [weakSelf.navigationController popViewControllerAnimated:YES];
    }];
}

#pragma mark - 编辑定时计划
-(void)updateTimingPlan
{
    __weak MBProgressHUD *weakHUB = _loadingHUD;
    __weak AddOrEditTimingMassageViewController *weakSelf = self;
    [_timingPlanRequest updateTimingPlan:self.timingPlan success:^(NSDictionary *dic) {
        NSLog(@"定时计划 编辑成功");
        //网络编辑成功，要改变数据状态为0
        weakSelf.timingPlan.state = [NSNumber numberWithInteger:0];
        [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
        [weakHUB hide:YES];
        [weakSelf.navigationController popViewControllerAnimated:YES];
        
    } fail:^(NSDictionary *dic) {
        NSLog(@"定时计划 编辑失败，改变本地数据状态");
        //网络编辑失败，要改变数据状态为2
        weakSelf.timingPlan.state = [NSNumber numberWithInteger:2];
        [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
        [weakHUB hide:YES];
        [weakSelf.navigationController popViewControllerAnimated:YES];
    }];
}

#pragma mark - 把界面选项保存到timingPlan对象中
-(void)saveSelectedToTimingPlan
{
    NSInteger hour = [[self.leftPickView getHighlightItemString] intValue];
    NSInteger minute = [[self.rightPickView getHighlightItemString] intValue];
    self.timingPlan.massageName = self.modeNameArray[self.collectionView.currentSelectItemIndex];
    self.timingPlan.ptime = [NSString stringWithFormat:@"%02zd:%02zd", hour, minute];
    self.timingPlan.isOn = [NSNumber numberWithBool:YES];
    self.timingPlan.massageProgamId = [NSNumber numberWithInteger:12345];
    
    NSOrderedSet *selectDays = [self.weekDaySegmentControl selectedIndexes];
    
    NSLog(@"selectedIndex : %@", [self.weekDaySegmentControl selectedIndexes]);
    
    if ([selectDays count] == 0) {
        self.timingPlan.days = @"0";
    } else {
        NSString *days = @"";
        for (int i = 0; i < [selectDays count]; i++) {
            if (i != [selectDays count] - 1) {
                days = [days stringByAppendingFormat:@"%zd,", [[selectDays objectAtIndex:i] integerValue]];
            } else {
                days = [days stringByAppendingFormat:@"%zd", [[selectDays objectAtIndex:i] integerValue]];
            }
        }
        self.timingPlan.days = days;
    }
    [self.timingPlan setLocalNotificationByHour:hour Minute:minute Week:selectDays Message:self.timingPlan.massageName];
    self.timingPlan.isOn = [NSNumber numberWithBool:YES];
    
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
	return [self.modeNameArray count];
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
	if (indexPath.row < 6) {
		
	} else {
		
	}
	cell.imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"mode_%li", indexPath.row + 1]];

	
	if (indexPath.row == 8) {
		cell.hidden = YES;
	} else {
		cell.hidden = NO;
	}
	return cell;
}

//- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
//	return 50.0;
//}
//
//#pragma mark --UICollectionViewDelegateFlowLayout  
//
//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
//	
//	if (indexPath.row == 8) {
//		return CGSizeZero;
//	} else {
//		return [((LineCollectionView *)collectionView) getCellSize];
//	}
//}


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

#pragma mark - TimingPlanDelegate代理

- (void)timingPlanRequestTimeOut:(TimingPlanRequest *)request {
	
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
