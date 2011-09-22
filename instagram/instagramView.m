//
//  instagramView.m
//  instagram
//
//  Created by kim hongjun on 11. 9. 21..
//  Copyright 2011년 __MyCompanyName__. All rights reserved.
//

#import "InstagramView.h"
#import "instagramImageAnimationView.h"

@interface UIColor(Random)
+(UIColor *)randomColor;
@end

@implementation UIColor(Random)
+(UIColor *)randomColor
{
	CGFloat red =  (CGFloat)random()/(CGFloat)RAND_MAX;
	CGFloat blue = (CGFloat)random()/(CGFloat)RAND_MAX;
	CGFloat green = (CGFloat)random()/(CGFloat)RAND_MAX;
	return [UIColor colorWithRed:red green:green blue:blue alpha:1.0];
}
@end

@implementation InstagramView


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
		self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		
		for (int i = 0; i<6; i++) 
		{
			for (int j = 0; j<8; j++)
			{
				float width = self.bounds.size.width/8;
				float height = self.bounds.size.height/6;
				
				CGRect viewframe = CGRectMake( j*width, i*height, width, height);
				
//				UIImageView *imageview = [[UIImageView alloc] initWithImage:[self imageWithColor:[UIColor randomColor]]];
				InstagramImageAnimationView *imageview = [[InstagramImageAnimationView alloc] initWithFrame:viewframe];
				[imageview setBackgroundColor:[UIColor redColor]];
//				[imageview.newImageView setImage:[self imageWithrandomColor]];
				imageview.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
				[self addSubview:imageview];
				
				
			}
		}
        
		
    }
    return self;
}

- (UIImage*)imageWithrandomColor
{
	return [self imageWithColor:[UIColor randomColor]];
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

- (void)insertNewImage:(id)image
{
//	NSLog(@"%@",image);
	int choiceviewindex = random()%[self.subviews count];
	InstagramImageAnimationView *imageview = [self.subviews objectAtIndex:choiceviewindex];
	[imageview.newImageView setImage:image];
	[imageview performTransition];
	
//	[UIView beginAnimations:nil context:nil];
//	[UIView setAnimationDuration:3];
//	[UIView setAnimationCurve:UIViewAnimationCurveLinear];
//	[imageview setImage:[self imageWithrandomColor]];
//	[UIView commitAnimations];
	
	
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
