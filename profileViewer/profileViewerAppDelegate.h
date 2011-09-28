//
//  profileViewerAppDelegate.h
//  profileViewer
//
//  Created by kim hongjun on 11. 9. 21..
//  Copyright 2011년 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class profileViewerController;

@interface profileViewerAppDelegate : NSObject <UIApplicationDelegate>

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain) IBOutlet profileViewerController *viewController;

@end
