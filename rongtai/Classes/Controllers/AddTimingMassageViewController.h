//
//  AddTimingMassageViewController.h
//  rongtai
//
//  Created by yoghourt on 6/10/15.
//  Copyright (c) 2015 William-zhang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddTimingMassageViewController : UIViewController<UICollectionViewDataSource, UIPickerViewDataSource, UIPickerViewDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@end
