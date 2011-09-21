//
//  instagramViewController.m
//  instagram
//
//  Created by kim hongjun on 11. 9. 21..
//  Copyright 2011년 __MyCompanyName__. All rights reserved.
//

#import "instagramViewController.h"
#import "InstagramView.h"

@implementation instagramViewController

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
	self.view;
	
	instagramView = [[InstagramView alloc] initWithFrame:self.view.bounds];

	[self.view addSubview:instagramView];
	
	[NSTimer scheduledTimerWithTimeInterval:1 target:instagramView selector:@selector(insertNewImage:) userInfo:nil repeats:YES];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    NSLog(@"shouldAutorotateToInterfaceOrientation %@",self.view);
	NSLog(@"%@",NSStringFromCGRect(self.view.bounds));
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}


@end
