//
//  AddTimingMassageViewController.h
//  rongtai
//
//  Created by yoghourt on 6/10/15.
//  Copyright (c) 2015 William-zhang. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LineUICollectionViewFlowLayoutDelegate <NSObject>

- (void)currentHighlightItem:(NSIndexPath *)indexPath;

@end

@interface LineUICollectionViewFlowLayout : UICollectionViewFlowLayout

@property(assign, nonatomic) id<LineUICollectionViewFlowLayoutDelegate> delegate;

@end
