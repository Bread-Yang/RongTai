//
//  NAPickerView.h
//  NAPickerView
//
//  Created by iNghia on 8/4/13.
//  Copyright (c) 2013 nghialv. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NALabelCell.h"

@class NAPickerView;
@protocol NAPickerViewDelegate <NSObject>

typedef void (^NACellConfigureBlock)(id, id);
typedef void (^NACellHighlightConfigureBlock)(id);
typedef void (^NACellUnHighlightConfigureBlock)(id);

- (void)didSelectedItemAtIndex:(NAPickerView *) pickerView andIndex:(NSInteger)index;

@end

@interface NAPickerView : UIView

@property (weak, nonatomic) id delegate;
@property (assign, nonatomic) BOOL infiniteScrolling;
@property (assign, nonatomic) BOOL onSound;
@property (assign, nonatomic) BOOL showOverlay;


@property (copy, nonatomic) NACellConfigureBlock configureBlock;
@property (copy, nonatomic) NACellHighlightConfigureBlock highlightBlock;
@property (copy, nonatomic) NACellUnHighlightConfigureBlock unhighlightBlock;

// backgroud color
@property (assign, nonatomic) CGFloat borderWidth;
@property (strong, nonatomic) UIColor *borderColor;
@property (assign, nonatomic) CGFloat cornerRadius;
@property (strong, nonatomic) UIImage *overlayLeftImage;
@property (strong, nonatomic) NSString *overlayRightString;
@property (strong, nonatomic) UIColor *overlayColor;

- (id)initWithFrame:(CGRect)frame
		   andItems:(NSArray *)items
   andCellClassName:(NSString *)className
		andDelegate:(id)delegate;

- (id)initWithFrame:(CGRect)frame
		   andItems:(NSArray *)items
		andDelegate:(id)delegate;

- (NSInteger)getHighlightIndex;

- (void)setIndex:(NSInteger)index;

@end
