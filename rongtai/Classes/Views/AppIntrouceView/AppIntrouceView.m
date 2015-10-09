//
//  IntroView.m
//  DrawPad
//
//  Created by Adam Cooper on 2/4/15.
//  Copyright (c) 2015 Adam Cooper. All rights reserved.
//

#import "AppIntrouceView.h"

@interface AppIntrouceView () <UIScrollViewDelegate>

@property (strong, nonatomic)  UIScrollView *scrollView;
@property (strong, nonatomic)  UIPageControl *pageControl;
@property UIView *holeView;
@property UIView *circleView;
@property UIButton *doneButton;

@end

@implementation AppIntrouceView

- (instancetype)initWithFrame:(CGRect)frame{
    //第一次启动先清除通知
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    
    self = [super initWithFrame:frame];
    
    if(self){
        
//        UIImageView *backgroundImageView = [[UIImageView alloc] initWithFrame:self.frame];
//        backgroundImageView.image = [UIImage imageNamed:@"Intro_Screen_Background"];
//        [self addSubview:backgroundImageView];
		
        self.scrollView = [[UIScrollView alloc] initWithFrame:self.frame];
        self.scrollView.pagingEnabled = YES;
		self.scrollView.backgroundColor = [UIColor whiteColor];
		self.scrollView.showsHorizontalScrollIndicator = NO;
        [self addSubview:self.scrollView];
        
        self.pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, self.frame.size.height * .8, self.frame.size.width, 10)];
		self.pageControl.pageIndicatorTintColor = [UIColor whiteColor];
        self.pageControl.currentPageIndicatorTintColor = [UIColor colorWithRed:0.153 green:0.533 blue:0.796 alpha:1.000];
        [self addSubview:self.pageControl];
        
        [self createViewOne];
        [self createViewTwo];
        [self createViewThree];
//        [self createViewFour];
		
        
        //Done Button
        self.doneButton = [[UIButton alloc] initWithFrame:CGRectMake(self.frame.size.width / 4, self.frame.size.height * 0.9, self.frame.size.width * 0.5, 40)];
        [self.doneButton setTintColor:[UIColor whiteColor]];
        [self.doneButton setTitle:NSLocalizedString(@"立即体验", nil) forState:UIControlStateNormal];
        [self.doneButton.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Thin" size:18.0]];
        self.doneButton.backgroundColor = [UIColor colorWithRed:0.153 green:0.533 blue:0.796 alpha:1.000];
        self.doneButton.layer.borderColor = [UIColor colorWithRed:0.153 green:0.533 blue:0.796 alpha:1.000].CGColor;
        [self.doneButton addTarget:self action:@selector(onFinishedIntroButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        self.doneButton.layer.borderWidth =.5;
        self.doneButton.layer.cornerRadius = 15;
        [self addSubview:self.doneButton];
        
        
        self.pageControl.numberOfPages = 3;
        self.scrollView.contentSize = CGSizeMake(self.frame.size.width * 3, self.scrollView.frame.size.height);
        
        //This is the starting point of the ScrollView
        CGPoint scrollPoint = CGPointMake(0, 0);
        [self.scrollView setContentOffset:scrollPoint animated:YES];
    }
    return self;
}

- (void)onFinishedIntroButtonPressed:(id)sender {
    [self.delegate onDoneButtonPressed];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    CGFloat pageWidth = CGRectGetWidth(self.bounds);
    CGFloat pageFraction = self.scrollView.contentOffset.x / pageWidth;
    self.pageControl.currentPage = roundf(pageFraction);
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    //    CGFloat pageWidth = CGRectGetWidth(self.bounds);
    //    CGFloat pageFraction = self.scrollView.contentOffset.x / pageWidth;
    //    self.pageControl.currentPage = roundf(pageFraction);
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    //    CGFloat pageWidth = CGRectGetWidth(self.bounds);
    //    CGFloat pageFraction = self.scrollView.contentOffset.x / pageWidth;
    //    self.pageControl.currentPage = roundf(pageFraction);
    
}


-(void)createViewOne{
    
    UIView *view = [[UIView alloc] initWithFrame:self.frame];
	
	UIImageView *imageview = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
	imageview.contentMode = UIViewContentModeScaleAspectFit;
	imageview.image = [UIImage imageNamed:@"guide2"];
	imageview.contentMode = UIViewContentModeScaleToFill;
	[view addSubview:imageview];
	
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.frame.size.height*.05, self.frame.size.width*.8, 60)];
    titleLabel.center = CGPointMake(self.center.x, self.frame.size.height*.1);
    titleLabel.text = [NSString stringWithFormat:@"Pixifly"];
    titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:40.0];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.textAlignment =  NSTextAlignmentCenter;
    titleLabel.numberOfLines = 0;
//    [view addSubview:titleLabel];
	
    UILabel *descriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width*.1, self.frame.size.height*.7, self.frame.size.width*.8, 60)];
    descriptionLabel.text = [NSString stringWithFormat:@"Description for First Screen."];
    descriptionLabel.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:18.0];
    descriptionLabel.textColor = [UIColor whiteColor];
    descriptionLabel.textAlignment =  NSTextAlignmentCenter;
    descriptionLabel.numberOfLines = 0;
    [descriptionLabel sizeToFit];
//    [view addSubview:descriptionLabel];
	
    CGPoint labelCenter = CGPointMake(self.center.x, self.frame.size.height*.7);
    descriptionLabel.center = labelCenter;
    
    self.scrollView.delegate = self;
    [self.scrollView addSubview:view];
    
}


-(void)createViewTwo{
    
    CGFloat originWidth = self.frame.size.width;
    CGFloat originHeight = self.frame.size.height;
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(originWidth, 0, originWidth, originHeight)];
	
	UIImageView *imageview = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
	imageview.contentMode = UIViewContentModeScaleAspectFit;
	imageview.image = [UIImage imageNamed:@"guide3"];
	imageview.contentMode = UIViewContentModeScaleToFill;
	[view addSubview:imageview];
	
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.frame.size.height*.05, self.frame.size.width*.8, 60)];
    titleLabel.center = CGPointMake(self.center.x, self.frame.size.height*.1);
    titleLabel.text = [NSString stringWithFormat:@"DropShot"];
    titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:40.0];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.textAlignment =  NSTextAlignmentCenter;
    titleLabel.numberOfLines = 0;
//    [view addSubview:titleLabel];
	
    UILabel *descriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width*.1, self.frame.size.height*.7, self.frame.size.width*.8, 60)];
    descriptionLabel.text = [NSString stringWithFormat:@"Description for Second Screen."];
    descriptionLabel.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:18.0];
    descriptionLabel.textColor = [UIColor whiteColor];
    descriptionLabel.textAlignment =  NSTextAlignmentCenter;
    descriptionLabel.numberOfLines = 0;
    [descriptionLabel sizeToFit];
//    [view addSubview:descriptionLabel];
	
    CGPoint labelCenter = CGPointMake(self.center.x, self.frame.size.height*.7);
    descriptionLabel.center = labelCenter;
    
    self.scrollView.delegate = self;
    [self.scrollView addSubview:view];
    
}

-(void)createViewThree{
    
    CGFloat originWidth = self.frame.size.width;
    CGFloat originHeight = self.frame.size.height;
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(originWidth*2, 0, originWidth, originHeight)];
	
	UIImageView *imageview = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
	imageview.contentMode = UIViewContentModeScaleAspectFit;
	imageview.image = [UIImage imageNamed:@"guide4"];
	imageview.contentMode = UIViewContentModeScaleToFill;
	[view addSubview:imageview];
	
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.frame.size.height*.05, self.frame.size.width*.8, 60)];
    titleLabel.center = CGPointMake(self.center.x, self.frame.size.height*.1);
    titleLabel.text = [NSString stringWithFormat:@"Shaktaya"];
    titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:40.0];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.textAlignment =  NSTextAlignmentCenter;
    titleLabel.numberOfLines = 0;
//    [view addSubview:titleLabel];
	
    UILabel *descriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width*.1, self.frame.size.height*.7, self.frame.size.width*.8, 60)];
    descriptionLabel.text = [NSString stringWithFormat:@"Description for Third Screen."];
    descriptionLabel.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:18.0];
    descriptionLabel.textColor = [UIColor whiteColor];
    descriptionLabel.textAlignment =  NSTextAlignmentCenter;
    descriptionLabel.numberOfLines = 0;
    [descriptionLabel sizeToFit];
//    [view addSubview:descriptionLabel];
	
    CGPoint labelCenter = CGPointMake(self.center.x, self.frame.size.height*.7);
    descriptionLabel.center = labelCenter;
    
    self.scrollView.delegate = self;
    [self.scrollView addSubview:view];
    
}


-(void)createViewFour{
    
    CGFloat originWidth = self.frame.size.width;
    CGFloat originHeight = self.frame.size.height;
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(originWidth*3, 0, originWidth, originHeight)];
	
	UIImageView *imageview = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
	imageview.contentMode = UIViewContentModeScaleAspectFit;
	imageview.image = [UIImage imageNamed:@"guide4"];
	imageview.contentMode = UIViewContentModeScaleToFill;
	[view addSubview:imageview];
	
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.frame.size.height*.05, self.frame.size.width*.8, 60)];
    titleLabel.center = CGPointMake(self.center.x, self.frame.size.height*.1);
    titleLabel.text = [NSString stringWithFormat:@"Punctual"];
    titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:40.0];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.textAlignment =  NSTextAlignmentCenter;
    titleLabel.numberOfLines = 0;
//    [view addSubview:titleLabel];
	
    UILabel *descriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width*.1, self.frame.size.height*.7, self.frame.size.width*.8, 60)];
    descriptionLabel.text = [NSString stringWithFormat:@"Description for Fourth Screen."];
    descriptionLabel.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:18.0];
    descriptionLabel.textColor = [UIColor whiteColor];
    descriptionLabel.textAlignment =  NSTextAlignmentCenter;
    descriptionLabel.numberOfLines = 0;
    [descriptionLabel sizeToFit];
//    [view addSubview:descriptionLabel];
	
    CGPoint labelCenter = CGPointMake(self.center.x, self.frame.size.height*.7);
    descriptionLabel.center = labelCenter;
    
    self.scrollView.delegate = self;
    [self.scrollView addSubview:view];
    
}

@end