//
//  ManualMassageViewController.m
//  rongtai
//
//  Created by yoghourt on 6/15/15.
//  Copyright (c) 2015 William-zhang. All rights reserved.
//

#import "ManualMassageViewController.h"

#import "VerticalSlider.h"
#import "CircleButton.h"

@interface ManualMassageViewController ()

@end

@implementation ManualMassageViewController {
	BOOL notFirstLayout;
	UIView *selectTimeView;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	// Do any additional setup after loading the view.
	NSLog(@"viewDidLoad");
	
	UIEdgeInsets edgeInsets = UIEdgeInsetsMake(5, 10, 5, 10);
	self.minus5MinutesButton.contentEdgeInsets = edgeInsets;
	self.plus5MinutesButton.contentEdgeInsets = edgeInsets;
	
	selectTimeView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
	selectTimeView.backgroundColor = [UIColor blackColor];
	selectTimeView.alpha = 0.8;
	
	[[UIApplication sharedApplication].keyWindow addSubview:selectTimeView];
	
	
	CircleButton *tenMinutesButton = [[CircleButton alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width / 2 - 160, [UIScreen mainScreen].bounds.size.height / 2 - 45, 90, 90)];
	[tenMinutesButton setTitle:@"10分钟" forState:UIControlStateNormal];
	[tenMinutesButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
	
	[tenMinutesButton setBackgroundColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[tenMinutesButton setBackgroundColor:[UIColor yellowColor] forState:UIControlStateHighlighted];
	
	[selectTimeView addSubview:tenMinutesButton];
	
	CircleButton *twentyMinutesButton = [[CircleButton alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width / 2 - 45, [UIScreen mainScreen].bounds.size.height / 2 - 45, 90, 90)];
	[twentyMinutesButton setTitle:@"20分钟" forState:UIControlStateNormal];
	[twentyMinutesButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
	
	[twentyMinutesButton setBackgroundColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[twentyMinutesButton setBackgroundColor:[UIColor yellowColor] forState:UIControlStateHighlighted];
	
	[selectTimeView addSubview:twentyMinutesButton];
	
	CircleButton *thirtyMinutesButton = [[CircleButton alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width / 2 + 70, [UIScreen mainScreen].bounds.size.height / 2 - 45, 90, 90)];
	[thirtyMinutesButton setTitle:@"30分钟" forState:UIControlStateNormal];
	[thirtyMinutesButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
	
	[thirtyMinutesButton setBackgroundColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[thirtyMinutesButton setBackgroundColor:[UIColor yellowColor] forState:UIControlStateHighlighted];
	
	[selectTimeView addSubview:thirtyMinutesButton];
	
	CircleButton *closeButton = [[CircleButton alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width / 2 - 22.5, [UIScreen mainScreen].bounds.size.height / 2 + 90, 45, 45)];
	[closeButton setTitle:@"x" forState:UIControlStateNormal];
	[closeButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
	
	[closeButton setBackgroundColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[closeButton setBackgroundColor:[UIColor yellowColor] forState:UIControlStateHighlighted];
	
	[closeButton addTarget:self action:(@selector(dismissTimeSelectBackground)) forControlEvents:UIControlEventTouchUpInside];
	
	[selectTimeView addSubview:closeButton];
}

- (void)viewDidLayoutSubviews {
	[super viewDidLayoutSubviews];
	NSLog(@"viewDidLayoutSubviews");
	
	if (!notFirstLayout) {
		notFirstLayout = YES;
		
//		self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width * 2, self.scrollView.frame.size.height);
		
		//
		//		UIView *page1 = [self.scrollView viewWithTag:100];
		//
		//		page1.frame = CGRectMake(0, 0, self.scrollView.frame.size.width, self.scrollView.frame.size.height);
		//		page1.backgroundColor = [UIColor blueColor];
		
		//		[self.scrollView addSubview:page1];
		
		//		[page1 setNeedsDisplay];
		
		//		UIView *page2 = [self.scrollView viewWithTag:101];
		//		page2.frame = CGRectMake(self.scrollView.frame.size.width, 0, self.scrollView.frame.size.width, self.scrollView.frame.size.height);
		//		page2.backgroundColor = [UIColor blackColor];
		
		//		[self.scrollView addSubview:page2];
		
		//		[page2 setNeedsDisplay];
		
	}
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	NSLog(@"viewWillAppear");
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	NSLog(@"viewDidAppear");
	
	self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, self.scrollView.frame.size.height);
	self.scrollView.contentInset = UIEdgeInsetsMake(0, self.scrollView.frame.size.width, 0, 0);
	self.scrollView.contentOffset = CGPointMake(-self.scrollView.frame.size.width, 0);
	
	self.scrollView.delaysContentTouches = NO;
	
	UIView *page2 = [self.scrollView viewWithTag:2];
	
	VerticalSlider *slider1 = [[VerticalSlider alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width / 2 - 120, 20, 60, 250)];
	[slider1 setMinimumValueImage:[self imageFromText:@"速度"]];
	
	[page2 addSubview:slider1];
	
	VerticalSlider *slider2 = [[VerticalSlider alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width / 2 - 60, 20, 60, 250)];
	[slider2 setMinimumValueImage:[self imageFromText:@"气压"]];
	
	[page2 addSubview:slider2];
	
	VerticalSlider *slider3 = [[VerticalSlider alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width / 2, 20, 60, 250)];
	[slider3 setMinimumValueImage:[self imageFromText:@"宽度"]];
	
	[page2 addSubview:slider3];
	
	VerticalSlider *slider4 = [[VerticalSlider alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width / 2 + 60, 20, 60, 250)];
	[slider4 setMinimumValueImage:[self imageFromText:@"力度"]];
	
	[page2 addSubview:slider4];
	
//	UIView *page1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.scrollView.frame.size.width, self.scrollView.frame.size.height)];
//	page1.backgroundColor = [UIColor blueColor];
//	
//	[self.scrollView addSubview:page1];
//	
//	UIView *page2 = [[UIView alloc] initWithFrame:CGRectMake(self.scrollView.frame.size.width, 0, self.scrollView.frame.size.width, self.scrollView.frame.size.height)];
//	page2.backgroundColor = [UIColor blackColor];
//	
//	[self.scrollView addSubview:page2];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */
	 
#pragma mark - Action

- (IBAction)showTimeSelectBackground:(id)sender {
		[[UIApplication sharedApplication].keyWindow addSubview:selectTimeView];
}

- (void)dismissTimeSelectBackground {
	[selectTimeView removeFromSuperview];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	CGFloat pageWidth = CGRectGetWidth(self.scrollView.bounds);
	CGFloat pageFraction = self.scrollView.contentOffset.x / pageWidth;
	self.pageControl.currentPage = roundf(pageFraction);
}

-(UIImage *)imageFromText:(NSString *)text {
	// set the font type and size
	UIFont *font = [UIFont systemFontOfSize:18.0];
	CGSize size  = [text sizeWithFont:font];
	
	// check if UIGraphicsBeginImageContextWithOptions is available (iOS is 4.0+)
	if (&UIGraphicsBeginImageContextWithOptions != NULL) {
		UIGraphicsBeginImageContextWithOptions(size,NO,0.0);
	} else {
		// iOS is < 4.0
//		UIGraphicsBeginImageContext(size);
	}
	// optional: add a shadow, to avoid clipping the shadow you should make the context size bigger
	//
	// CGContextRef ctx = UIGraphicsGetCurrentContext();
	// CGContextSetShadowWithColor(ctx, CGSizeMake(1.0, 1.0), 5.0, [[UIColor grayColor] CGColor]);
	
	// draw in context, you can use also drawInRect:withFont:
	[text drawAtPoint:CGPointMake(0.0, 0.0) withFont:font];
	
	// transfer image
	UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	return image;
}

@end
