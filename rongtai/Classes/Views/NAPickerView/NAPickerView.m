//
//  NAPickerView.m
//  NAPickerView
//
//  Created by iNghia on 8/4/13.
//  Copyright (c) 2013 nghialv. All rights reserved.
//

#import "NAPickerView.h"
#import <QuartzCore/QuartzCore.h>

#define INFINITE_SCROLLING_COUNT 5

@interface NAPickerView() <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) NSArray *items;
@property (strong, nonatomic) NSString *cellClassName;
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSIndexPath *currentIndex;
@property (strong, nonatomic) UIView *overlay;

@end

@implementation NAPickerView
@synthesize showOverlay = mShowOverlay;

- (id)initWithFrame:(CGRect)frame
		   andItems:(NSArray *)items
		andDelegate:(id)delegate {
	self = [super initWithFrame:frame];
	if (self) {
		// Initialization code
		[self configWithFrame:frame
					 andItems:items
			 andCellClassName:@"NALabelCell"
				  andDelegate:delegate];
	}
	return self;
}

- (id)initWithFrame:(CGRect)frame
           andItems:(NSArray *)items
   andCellClassName:(NSString *)className
        andDelegate:(id)delegate {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self configWithFrame:frame
                     andItems:items
             andCellClassName:className
                  andDelegate:delegate];
    }
    return self;
}

- (void)configWithFrame:(CGRect)frame
               andItems:(NSArray *)items
       andCellClassName:(NSString *)className
            andDelegate:(id)delegate {
    self.items = items;
    self.delegate = delegate;
    self.cellClassName = className;
	
	self.backgroundColor = [UIColor clearColor];
    self.tableView = [[UITableView alloc] initWithFrame:self.bounds style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.showsHorizontalScrollIndicator = NO;
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.allowsSelection = NO;
    self.tableView.backgroundColor = [UIColor clearColor];
    [self addSubview:self.tableView];
    
    self.currentIndex = [NSIndexPath indexPathForRow:0 inSection:0];
    
    mShowOverlay = NO;
    self.showOverlay = YES;
    
    self.configureBlock = ^(NALabelCell *cell, NSString *item) {
        [cell.textView setText:item];
        cell.textView.textAlignment = UITextAlignmentCenter;
        cell.textView.font = [UIFont systemFontOfSize:30];
        cell.textView.backgroundColor = [UIColor clearColor];
        cell.textView.textColor = [UIColor grayColor];
    };
    
    self.highlightBlock = ^(NALabelCell *cell) {
        cell.textView.textColor = [UIColor greenColor];
    };
    
    self.unhighlightBlock = ^(NALabelCell *cell) {
        cell.textView.textColor = [UIColor grayColor];
    };
}

- (CGFloat)headerHeight {
    return self.bounds.size.height / 2 - [self cellHeight] / 2;
}

- (CGFloat)cellHeight {
    return [NSClassFromString(self.cellClassName) cellHeight];
}

- (void)setBorderWidth:(CGFloat)borderWidth {
    self.layer.borderWidth = borderWidth;
}

- (void)setBorderColor:(UIColor *)borderColor {
    [self.layer setBorderColor:[borderColor CGColor]];
}

- (void)setCornerRadius:(CGFloat)cornerRadius {
    self.layer.cornerRadius = cornerRadius;
    self.layer.masksToBounds = YES;
}

- (void)setIndex:(NSInteger)index {
	if (self.infiniteScrolling) {
		if (index < self.items.count - 2) {
			self.currentIndex = [NSIndexPath indexPathForItem:index + self.items.count inSection:0];
//			NSLog(@"self.current : %i", self.currentIndex.row);
		}
	} else {
		self.currentIndex = [NSIndexPath indexPathForItem:index inSection:0];
	}
    [self.tableView scrollToRowAtIndexPath:self.currentIndex
                          atScrollPosition:UITableViewScrollPositionMiddle
                                  animated:NO];
}

- (void)setShowOverlay:(BOOL)showOverlay {
    if (showOverlay != mShowOverlay) {
        mShowOverlay = showOverlay;
        [self setOverlayView];
    }
}

- (void)setOverlayView
{
    if (self.showOverlay) {
        self.overlay = [[UIView alloc] initWithFrame:CGRectMake(0,
                                                                self.frame.size.height/2 - [self cellHeight]/2,
                                                                self.frame.size.width,
                                                                [self cellHeight])];
//        self.overlay.backgroundColor = [UIColor grayColor];
        self.overlay.alpha = 0.5;
        self.overlay.userInteractionEnabled = NO;
        [self addSubview:self.overlay];
    } else {
        [self.overlay removeFromSuperview];
    }
}

#pragma mark - UITableView delegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	if (self.infiniteScrolling) {
		return 0;
	}
    return [self headerHeight];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *emptyHeader = [[UIView alloc] initWithFrame:CGRectMake(0,
                                                                   0,
                                                                   self.tableView.frame.size.width,
                                                                   [self headerHeight])];
    emptyHeader.backgroundColor = [UIColor clearColor];
    return emptyHeader;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
	if (self.infiniteScrolling) {
		return 0;
	}
    return [self headerHeight];
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *emptyHeader = [[UIView alloc] initWithFrame:CGRectMake(0,
                                                                   0,
                                                                   self.tableView.frame.size.width,
                                                                   [self headerHeight])];
    emptyHeader.backgroundColor = [UIColor clearColor];
    return emptyHeader;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return [self cellHeight];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if (self.infiniteScrolling && self.items.count >= 3) {
		return self.items.count * 2;
	} else {
		return [self.items count];
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"NACellIdentifier";
    NAPickerCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if(!cell) {
        cell = [[NSClassFromString(self.cellClassName) alloc] initWithStyle:UITableViewCellStyleDefault
                                                            reuseIdentifier:cellIdentifier
                                                                  cellWidth:self.tableView.bounds.size.width];
    }
	
	
    self.configureBlock(cell, [self.items objectAtIndex:indexPath.row % self.items.count]);
    if(indexPath.row == self.currentIndex.row) {
        self.highlightBlock(cell);
    } else {
        self.unhighlightBlock(cell);
    }
    return cell;
}

#pragma mark - ScrollViewDelegate
- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView
                     withVelocity:(CGPoint)velocity
              targetContentOffset:(inout CGPoint *)targetContentOffset {
    GLfloat rowHeight = [self cellHeight];
    CGFloat floatVal = targetContentOffset -> y / rowHeight;
	NSInteger rounded = (NSInteger)(lround(floatVal));
	targetContentOffset -> y = rounded * rowHeight;
	if(self.delegate && [self.delegate respondsToSelector:@selector(didSelectedItemAtIndex:)]) {
		[self.delegate didSelectedItemAtIndex:rounded % (self.items.count - 1)];
	}
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	if (self.infiniteScrolling) {
		CGFloat currentOffsetX = scrollView.contentOffset.x;
		CGFloat currentOffSetY = scrollView.contentOffset.y;
		CGFloat contentHeight = scrollView.contentSize.height;
		
		
		if (currentOffSetY < ((CGFloat)contentHeight / self.items.count * 2)) {
			scrollView.contentOffset = CGPointMake(currentOffsetX, (currentOffSetY + (contentHeight / 2)));
		}
		if (currentOffSetY > (((CGFloat)contentHeight * (self.items.count * 2 - INFINITE_SCROLLING_COUNT)) / (self.items.count * 2))) {
			scrollView.contentOffset = CGPointMake(currentOffsetX, (currentOffSetY - (contentHeight / 2)));
		}
	}
	
    NSArray *visibleIndex = [self.tableView indexPathsForVisibleRows];
    NSArray *visibleIndexSorted = [visibleIndex sortedArrayUsingComparator:^NSComparisonResult(id a, id b){
        CGRect r1 = [self.tableView rectForRowAtIndexPath:(NSIndexPath *)a];
        CGRect r2 = [self.tableView rectForRowAtIndexPath:(NSIndexPath *)b];
        CGFloat y1 = fabsf(r1.origin.y + r1.size.height/2 - self.tableView.contentOffset.y - self.tableView.center.y);
        CGFloat y2 = fabsf(r2.origin.y + r2.size.height/2 - self.tableView.contentOffset.y - self.tableView.center.y);
        if (y1 > y2) {
            return NSOrderedDescending;
        }
        return NSOrderedAscending;
    }];
    
    NSIndexPath *middleIndex = [visibleIndexSorted objectAtIndex:0];
    if (!self.currentIndex) {
        self.currentIndex = middleIndex;
    }
    if (self.currentIndex.row == middleIndex.row) {
        return;
    }
    
    NAPickerCell *currentCell = (NAPickerCell *)[self.tableView cellForRowAtIndexPath:self.currentIndex];
    self.unhighlightBlock(currentCell);
    NAPickerCell *middleCell = (NAPickerCell *)[self.tableView cellForRowAtIndexPath:middleIndex];
    self.highlightBlock(middleCell);
    self.currentIndex = middleIndex;
}


- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
	
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
	NSLog(@"scrollViewDidEndDragging");
}

- (void)setInfiniteScrolling:(BOOL)infiniteScrolling {
	if (_items.count >= INFINITE_SCROLLING_COUNT) {
		_infiniteScrolling = infiniteScrolling;
	} else {
		_infiniteScrolling = NO;
	}
}

@end
