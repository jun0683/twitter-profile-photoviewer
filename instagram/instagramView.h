//
//  instagramView.h
//  instagram
//
//  Created by kim hongjun on 11. 9. 21..
//  Copyright 2011년 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InstagramView : UIView
{
	
}
- (UIImage*)imageWithrandomColor;
- (UIImage *)imageWithColor:(UIColor *)color;
- (void)insertNewImages:(NSArray*)images;
- (void)insertNewImage:(id)image;
@end
