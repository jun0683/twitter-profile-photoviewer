//
//  instagramViewController.h
//  instagram
//
//  Created by kim hongjun on 11. 9. 21..
//  Copyright 2011년 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SA_OAuthTwitterController.h"

@class SA_OAuthTwitterEngine;

@class InstagramView;


@interface instagramViewController : UIViewController <SA_OAuthTwitterControllerDelegate>
{
	InstagramView *instagramView;
	SA_OAuthTwitterEngine				*_engine;
	NSMutableSet *profileImageUrls;
	NSMutableSet *userText;
	NSMutableArray *profileImages;
	NSMutableDictionary *profileImageRequstIdentifier;
}

- (void)loadImageUrl;
- (void)loadImage;
- (void)newImageAdd;


@end
