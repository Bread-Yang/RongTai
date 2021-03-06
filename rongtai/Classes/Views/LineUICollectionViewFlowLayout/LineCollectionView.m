//
//  LineCollectionView.m
//  rongtai
//
//  Created by yoghourt on 7/23/15.
//  Copyright (c) 2015 William-zhang. All rights reserved.
//

#import "LineCollectionView.h"
#import "LineUICollectionViewFlowLayout.h"

@implementation LineCollectionView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if (self) {
		[self initCollectionViewLayout];
	}
	return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
	self = [super initWithCoder:aDecoder];
	if (self ) {
		[self initCollectionViewLayout];
	}
	return self;
}

- (void)initCollectionViewLayout {
	LineUICollectionViewFlowLayout *lineLayout = [[LineUICollectionViewFlowLayout alloc] init];
	[lineLayout setItemSize:[self getCellSize]];
	lineLayout.headerReferenceSize = CGSizeMake([UIScreen mainScreen].bounds.size.width / 2 - lineLayout.itemSize.width / 2, lineLayout.itemSize.height);
	lineLayout.footerReferenceSize = CGSizeMake([UIScreen mainScreen].bounds.size.width / 2 - lineLayout.itemSize.width / 2, lineLayout.itemSize.height);
	lineLayout.delegate = self;
	
	self.collectionViewLayout = lineLayout;
}

- (CGSize)getCellSize {
	return CGSizeMake(self.bounds.size.height / 3 * 2, self.bounds.size.height / 3 * 2);
}

#pragma mark - LineUICollectionViewFlowLayoutDelegate

- (void)currentHighlightItem:(NSIndexPath *)indexPath {
	self.currentSelectItemIndex = indexPath.row;
	if (self.lineDelegate && [self.lineDelegate respondsToSelector:@selector(currentHighlightItemIndex:)]) {
		[self.lineDelegate currentHighlightItemIndex:indexPath];
	}
}

@end
