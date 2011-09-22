//
//  instagramImageAnimationView.h
//  instagram
//
//  Created by kim hongjun on 11. 9. 21..
//  Copyright 2011년 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface InstagramImageAnimationView : UIView
{
	UIImageView *originImageView;
	UIImageView *newImageView;
}

@property (nonatomic,readonly) UIImageView *newImageView;
- (UIImage*)imageWithrandomColor;
-(void)performTransition;
-(void)animationDid;
@end
