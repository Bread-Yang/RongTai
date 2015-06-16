//
//  ManualMassageViewController.h
//  rongtai
//
//  Created by yoghourt on 6/15/15.
//  Copyright (c) 2015 William-zhang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ManualMassageViewController : UIViewController<UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;

@property (weak, nonatomic) IBOutlet UIButton *minus5MinutesButton;

@property (weak, nonatomic) IBOutlet UIButton *plus5MinutesButton;


@end
