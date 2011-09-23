//
//  profileViewerImageAnimationView.m
//  profileViewer
//
//  Created by kim hongjun on 11. 9. 21..
//  Copyright 2011년 __MyCompanyName__. All rights reserved.
//
#define TRANSITION_DURATION 0.75
#import "profileViewerImageAnimationView.h"
@interface UIColor(Random)
+(UIColor *)randomColor;
@end

@implementation UIColor(Random)
+(UIColor *)randomColor
{
	CGFloat red =  (CGFloat)arc4random()/(CGFloat)RAND_MAX;
	CGFloat blue = (CGFloat)arc4random()/(CGFloat)RAND_MAX;
	CGFloat green = (CGFloat)arc4random()/(CGFloat)RAND_MAX;
	return [UIColor colorWithRed:red green:green blue:blue alpha:1.0];
}
@end

@implementation profileViewerImageAnimationView

@synthesize newImageView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
		self.clipsToBounds = YES;
		newImageView = [[UIImageView alloc] initWithFrame:self.bounds];
		newImageView.backgroundColor = [UIColor whiteColor];
		newImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		[newImageView setImage:[self imageWithrandomColor]];
		[self addSubview:newImageView];
		
		originImageView = [[UIImageView alloc] initWithFrame:self.bounds];
		originImageView.backgroundColor = [UIColor whiteColor];
		originImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		[originImageView setImage:[self imageWithrandomColor]];
        [self addSubview:originImageView];
		
		
		
    }
    return self;
}

- (UIImage *)imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
	
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
	
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
	
    return image;
}


- (UIImage*)imageWithrandomColor
{
	return [self imageWithColor:[UIColor randomColor]];
}

- (void)fadeAni
{
	// Set alpha value to 0 initially:
	[self bringSubviewToFront:newImageView];
	[newImageView setAlpha:0.0];
	[originImageView setAlpha:1.0];
	
	
	[UIView animateWithDuration:TRANSITION_DURATION delay:0.0 options:UIViewAnimationCurveEaseInOut animations:^(void) {
		[newImageView setAlpha:1.0];
		[originImageView setAlpha:0.0];
	} completion:^(BOOL finished) {
		[newImageView setAlpha:1.0];
		[originImageView setAlpha:1.0];
		[self animationDid];
		
	}];
	
}

- (void)TransImageAnimation:(CGRect)Frame  {
	
	[UIView animateWithDuration:TRANSITION_DURATION delay:0.0 options:UIViewAnimationCurveEaseInOut animations:^(void) 
	 {
		 [newImageView setFrame:Frame];
		 
	 } completion:^(BOOL finished) {
		 [self animationDid];
	 }];
	
}

- (void)leftinAni
{
	[self bringSubviewToFront:newImageView];
	CGRect Frame = newImageView.frame;
	[newImageView setFrame:CGRectMake(Frame.origin.x-Frame.size.width,Frame.origin.y,Frame.size.width , Frame.size.height)];
	
	[self TransImageAnimation: Frame];
}

- (void)rightinAni
{
	[self bringSubviewToFront:newImageView];
	CGRect Frame = newImageView.frame;
	[newImageView setFrame:CGRectMake(Frame.origin.x+Frame.size.width,Frame.origin.y,Frame.size.width , Frame.size.height)];
	
	[self TransImageAnimation: Frame];
}

- (void)topinAni
{
	[self bringSubviewToFront:newImageView];
	CGRect Frame = newImageView.frame;
	[newImageView setFrame:CGRectMake(Frame.origin.x,Frame.origin.y-Frame.size.height,Frame.size.width , Frame.size.height)];
	
	[self TransImageAnimation: Frame];
}

- (void)bottominAni
{
	[self bringSubviewToFront:newImageView];
	CGRect Frame = newImageView.frame;
	[newImageView setFrame:CGRectMake(Frame.origin.x,Frame.origin.y+Frame.size.height,Frame.size.width , Frame.size.height)];
	
	[self TransImageAnimation: Frame];
}


-(void)performTransition
{
	SEL array[] = {@selector(fadeAni),@selector(leftinAni),@selector(rightinAni),@selector(topinAni),@selector(bottominAni)};
	SEL message = array[arc4random()%5];
	[self performSelector:message];
}

-(void)animationDid
{
	UIImageView *tmp = newImageView;
	newImageView = originImageView;
	originImageView = tmp;
}

@end
