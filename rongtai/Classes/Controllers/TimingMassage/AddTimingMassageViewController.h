//
//  AddTimingMassageViewController.h
//  rongtai
//
//  Created by yoghourt on 6/10/15.
//  Copyright (c) 2015 William-zhang. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TimingMassageModel.h"
#import "LineUICollectionViewFlowLayout.h"
#import "THSegmentedControl.h"

typedef void (^ReturnTimingMassageBlock)(TimingMassageModel *entity);

@interface AddTimingMassageViewController : UIViewController<UICollectionViewDataSource, UIPickerViewDataSource, UIPickerViewDelegate, LineUICollectionViewFlowLayoutDelegate>

@property (weak, nonatomic) IBOutlet UIView *containView;

@property (weak, nonatomic) IBOutlet THSegmentedControl *weekDaySegmentControl;

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (nonatomic, copy) ReturnTimingMassageBlock returnTimingMassageBlock;

- (void)setReturnTimingMassageBlock:(ReturnTimingMassageBlock)returnTimingMassageBlock;

@end
