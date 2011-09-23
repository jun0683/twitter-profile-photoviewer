//
//  instagramView.m
//  instagram
//
//  Created by kim hongjun on 11. 9. 21..
//  Copyright 2011년 __MyCompanyName__. All rights reserved.
//

#import "InstagramView.h"
#import "instagramImageAnimationView.h"

#define row 6
#define column 8

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

@implementation profileViewerView


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
		self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		
		for (int i = 0; i<row; i++) 
		{
			for (int j = 0; j<column; j++)
			{
				float width = self.bounds.size.width/column;
				float height = self.bounds.size.height/row;
				
				CGRect viewframe = CGRectMake( j*width, i*height, width, height);
				

				profileViewerImageAnimationView *imageview = [[profileViewerImageAnimationView alloc] initWithFrame:viewframe];
				[imageview setBackgroundColor:[UIColor redColor]];
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
- (void)insertNewImages:(NSArray*)images
{
	for (int i = 0; i<[self.subviews count]; i++) {
		profileViewerImageAnimationView *view = [self.subviews objectAtIndex:i];
		[view.newImageView  setImage:[images objectAtIndex:i]];
		[view performTransition];
	}
}

- (void)insertNewImage:(id)image
{

	
	int choiceviewindex = arc4random()%[self.subviews count];
	profileViewerImageAnimationView *imageview = [self.subviews objectAtIndex:choiceviewindex];
	[imageview.newImageView setImage:image];
	[imageview performTransition];
	
	
	
}

@end
