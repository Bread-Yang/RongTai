//
//  LineCollectionView.h
//  rongtai
//
//  Created by yoghourt on 7/23/15.
//  Copyright (c) 2015 William-zhang. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "LineUICollectionViewFlowLayout.h"

@protocol LineUICollectionViewDelegate <NSObject>

- (void)currentHighlightItemIndex:(NSIndexPath *)indexPath;

@end

@interface LineCollectionView : UICollectionView<LineUICollectionViewFlowLayoutDelegate>

@property(assign, nonatomic) id<LineUICollectionViewDelegate> delegate;

@property(assign, nonatomic) NSInteger currentSelectItemIndex;

- (CGSize)getCellSize;

@end
