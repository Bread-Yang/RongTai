//
//  AddTimingMassageViewController.h
//  rongtai
//
//  Created by yoghourt on 6/10/15.
//  Copyright (c) 2015 William-zhang. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TimingMassageModel.h"
#import "THSegmentedControl.h"
#import "NAPickerView.h"
#import "LineCollectionView.h"
#import "TimingPlan.h"
#import "BasicViewController.h"

typedef void (^ReturnTimingMassageBlock)(TimingMassageModel *entity);

@interface AddOrEditTimingMassageViewController : BasicViewController<UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIPickerViewDataSource, UIPickerViewDelegate, LineUICollectionViewDelegate, NAPickerViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *containView;

@property (weak, nonatomic) IBOutlet LineCollectionView *collectionView;

@property (weak, nonatomic) IBOutlet UILabel *modeLabel;

@property (weak, nonatomic) IBOutlet THSegmentedControl *weekDaySegmentControl;

@property (nonatomic, retain) TimingPlan *timingPlan;

@property (nonatomic, copy) ReturnTimingMassageBlock returnTimingMassageBlock;

- (void)setReturnTimingMassageBlock:(ReturnTimingMassageBlock)returnTimingMassageBlock;

@end
