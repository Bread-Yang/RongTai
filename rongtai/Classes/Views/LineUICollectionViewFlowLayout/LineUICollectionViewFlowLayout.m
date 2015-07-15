//
//  AddTimingMassageViewController.h
//  rongtai
//
//  Created by yoghourt on 6/10/15.
//  Copyright (c) 2015 William-zhang. All rights reserved.
//

#import "LineUICollectionViewFlowLayout.h"

@implementation LineUICollectionViewFlowLayout

#define ACTIVE_DISTANCE self.itemSize.width
#define ZOOM_FACTOR 0.3

- (id)init {
    self = [super init];
    if (self) {
//        self.itemSize = CGSizeMake(ITEM_SIZE, ITEM_SIZE);
		
        self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        self.sectionInset = UIEdgeInsetsMake(0, 34, 0, 34);  // 此处为上方和下方各缩进200个point。由于cell的size已经定义了为200×200，因此屏幕上在缩进后就只有一排item的空间了
        self.minimumLineSpacing = 50.0;		// 这个定义了每个item在水平方向上的最小间距
    }
    return self;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)oldBounds {
    return YES; // 需要记得让-shouldInvalidateLayoutForBoundsChange:返回YES，这样当边界改变的时候，-invalidateLayout会自动被发送，才能让layout得到刷新
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {	// 当前item放大
    NSArray *array = [super layoutAttributesForElementsInRect:rect];
	
    CGRect visibleRect;
	
    visibleRect.origin = self.collectionView.contentOffset;
    visibleRect.size = self.collectionView.bounds.size;
    
    for (UICollectionViewLayoutAttributes *attributes in array) {
        if (CGRectIntersectsRect(attributes.frame, rect)) {
            CGFloat distance = CGRectGetMidX(visibleRect) - attributes.center.x;
            CGFloat normalizedDistance = distance / ACTIVE_DISTANCE;
            if (ABS(distance) < ACTIVE_DISTANCE) {
                CGFloat zoom = 1 + ZOOM_FACTOR * (1 - ABS(normalizedDistance));
                attributes.transform3D = CATransform3DMakeScale(zoom, zoom, 1.0);
                attributes.zIndex = 1;
            }
        }
    }
    return array;
}


- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity { 	// 自动对齐到网格
    CGFloat offsetAdjustment = MAXFLOAT;	// proposedContentOffset是没有对齐到网格时本来应该停下的位置
    CGFloat currentHorizontalSlideCenterOffset = proposedContentOffset.x + (CGRectGetWidth(self.collectionView.bounds) / 2.0);  
    
    CGRect targetRect = CGRectMake(proposedContentOffset.x, 0.0, self.collectionView.bounds.size.width, self.collectionView.bounds.size.height);
    NSArray *array = [super layoutAttributesForElementsInRect:targetRect]; //对当前屏幕中的UICollectionViewLayoutAttributes逐个与屏幕中心进行比较，找出最接近中心的一个
    
    for (UICollectionViewLayoutAttributes *layoutAttributes in array) {
        CGFloat itemHorizontalCenter = layoutAttributes.center.x;
        if (ABS(itemHorizontalCenter - currentHorizontalSlideCenterOffset) < ABS(offsetAdjustment)) {
            offsetAdjustment = itemHorizontalCenter - currentHorizontalSlideCenterOffset;
        }
    }
	NSLog(@"返回的偏移位置是 : %f : ", (proposedContentOffset.x + offsetAdjustment));
	CGFloat adjustItemOffset = proposedContentOffset.x + offsetAdjustment + (CGRectGetWidth(self.collectionView.bounds) / 2) - (self.itemSize.width / 4);
	CGRect centerItemRect = CGRectMake(adjustItemOffset, 0.0, self.itemSize.width / 4, self.itemSize.width);
	NSArray *itemArray = [super layoutAttributesForElementsInRect:centerItemRect];
	NSLog(@"itemArray count : %i", [itemArray count]);
	for (UICollectionViewLayoutAttributes *layoutAttributes in itemArray) {
		NSLog(@"index : %i", layoutAttributes.indexPath.row);
	}
	if (self.delegate && [self.delegate respondsToSelector:@selector(currentHighlightItem:)]) {
		[self.delegate currentHighlightItem:[NSIndexPath indexPathForRow:0 inSection:0]];
	}
    return CGPointMake(proposedContentOffset.x + offsetAdjustment, proposedContentOffset.y);
}

@end