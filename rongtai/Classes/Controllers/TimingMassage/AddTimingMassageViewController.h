//
//  AddTimingMassageViewController.h
//  rongtai
//
//  Created by yoghourt on 6/10/15.
//  Copyright (c) 2015 William-zhang. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TimingMassageModel.h"

typedef void (^ReturnTimingMassageBlock)(TimingMassageModel *entity);

@interface AddTimingMassageViewController : UIViewController<UICollectionViewDataSource, UIPickerViewDataSource, UIPickerViewDelegate>

@property (weak, nonatomic) IBOutlet UIPickerView *leftPickerView;

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (weak, nonatomic) IBOutlet UIPickerView *rightPickerView;


@property (nonatomic, copy) ReturnTimingMassageBlock returnTimingMassageBlock;

- (void)setReturnTimingMassageBlock:(ReturnTimingMassageBlock)returnTimingMassageBlock;

@end
