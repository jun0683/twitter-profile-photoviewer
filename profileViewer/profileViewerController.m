//
//  profileViewerViewController.m
//  profileViewer
//
//  Created by kim hongjun on 11. 9. 21..
//  Copyright 2011년 __MyCompanyName__. All rights reserved.
//

#import "profileViewerController.h"
#import "profileViewerView.h"
#import "SA_OAuthTwitterEngine.h"


#define kOAuthConsumerKey				@"UG0kng3kD8HCd1uplUQAnw"		//REPLACE ME
#define kOAuthConsumerSecret			@"Q0FmmKV47XjOnYTiiAPI8BW58jwWzWAUEf0Hc6KxM"		//REPLACE ME


@implementation profileViewerController
@synthesize profileImageUrls,profileImages;
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
	firstTimeLoadImageUrl = YES;
	firstTimeLoadImage = YES;
	firstTimeinsertImage = YES;
	
	profileviewerView = [[profileViewerView alloc] initWithFrame:self.view.bounds];
	[self.view addSubview:profileviewerView];
	
}



- (void)viewDidAppear:(BOOL)animated
{
	if (_engine) return;
	_engine = [[SA_OAuthTwitterEngine alloc] initOAuthWithDelegate: self];
	_engine.consumerKey = kOAuthConsumerKey;
	_engine.consumerSecret = kOAuthConsumerSecret;
	
	profileImageUrls = [[NSMutableSet alloc] init];
	profileImages = [[NSMutableArray alloc] init];
	profileImageRequstIdentifier = [[NSMutableDictionary alloc] init];
	
	
	
	UIViewController			*controller = [SA_OAuthTwitterController controllerToEnterCredentialsWithTwitterEngine: _engine delegate: self];
	controller.modalPresentationStyle = UIModalPresentationPageSheet;
	
	
	if (controller) 
		[self presentModalViewController: controller animated: YES];
	else {
		[self loadImageUrl];
	}
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

- (void)settingFirstTimeLoadImageUrl
{
	[_engine getHomeTimelineSinceID:0 startingAtPage:0 count:100];
}

- (void)settingFirstTimeLoadImage
{
	for (NSString* url in profileImageUrls) {
		[profileImageRequstIdentifier setValue:url forKey:[_engine getImageAtURL:url]];
	}
}

- (void)settingFistTimeImage
{
	[profileviewerView insertNewImages:profileImages];
	[NSTimer scheduledTimerWithTimeInterval:10.0f target:self selector:@selector(loadImageUrl) userInfo:nil repeats:YES];
	[NSTimer scheduledTimerWithTimeInterval:5.0f target:self selector:@selector(loadImage) userInfo:nil repeats:YES];
	[NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(setNewImageWithAnimation) userInfo:nil repeats:YES];

}

- (void)loadImageUrl
{
	if ([profileImageUrls count] < 10 && [_engine isAuthorized]) 
	{
		[_engine getHomeTimelineSinceID:0 startingAtPage:0 count:100];
	}
}

- (void)loadImage
{
	if ([profileImages count] < 10 && [profileImageUrls count]) 
	{
		
		int i = 0;
		for (NSString* url in profileImageUrls) {
			[profileImageRequstIdentifier setValue:url forKey:[_engine getImageAtURL:url]];
			i++;
			if (i>=50) {
				break;
			}
		}
		
	}
}


- (void)setNewImageWithAnimation
{
	if ([profileImages count]) {
		
		[profileviewerView insertNewImage:[profileImages lastObject]];
		[profileImages removeLastObject];
	}
}



//=============================================================================================================================
#pragma mark SA_OAuthTwitterEngineDelegate
- (void) storeCachedTwitterOAuthData: (NSString *) data forUsername: (NSString *) username {
	NSUserDefaults			*defaults = [NSUserDefaults standardUserDefaults];	
	[defaults setObject: data forKey: @"authData"];
	[defaults synchronize];
}

- (NSString *) cachedTwitterOAuthDataForUsername: (NSString *) username {
	return [[NSUserDefaults standardUserDefaults] objectForKey: @"authData"];
}

//=============================================================================================================================
#pragma mark TwitterEngineDelegate
- (void) requestSucceeded: (NSString *) requestIdentifier {
	//	NSLog(@"Request %@ succeeded", requestIdentifier);
	
	
}

- (void) requestFailed: (NSString *) requestIdentifier withError: (NSError *) error {
	NSLog(@"Request %@ failed with error: %@", requestIdentifier, error);
}

- (void)statusesReceived:(NSArray *)statuses forRequest:(NSString *)connectionIdentifier
{

	for (NSDictionary *status in statuses) {
		NSString* url =	[[status valueForKey:@"user"] valueForKey:@"profile_image_url"];
		[profileImageUrls addObject:url];
		
	}
	
	if (firstTimeLoadImageUrl) {
		firstTimeLoadImageUrl = NO;
		[self settingFirstTimeLoadImage];
	}
	
}

- (void)imageReceived:(UIImage *)image forRequest:(NSString *)connectionIdentifier
{
	
	[profileImageUrls removeObject:[profileImageRequstIdentifier valueForKey:connectionIdentifier]];
	[profileImageRequstIdentifier removeObjectForKey:connectionIdentifier];
	[profileImages insertObject:image atIndex:0];
	
	if ([profileImageRequstIdentifier count] == 0 && firstTimeLoadImage) {
		firstTimeLoadImage = NO;
		[self settingFistTimeImage];
	}
}


@end
