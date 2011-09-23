//
//  instagramViewController.m
//  instagram
//
//  Created by kim hongjun on 11. 9. 21..
//  Copyright 2011년 __MyCompanyName__. All rights reserved.
//

#import "instagramViewController.h"
#import "InstagramView.h"
#import "SA_OAuthTwitterEngine.h"


#define kOAuthConsumerKey				@"9Ys4WJXwgmkgmm8xdA19sw"		//REPLACE ME
#define kOAuthConsumerSecret			@"MCsFJV5VYh1VaddJDakulaE1HngtgWJsC6PnbfLkQ0"		//REPLACE ME


@implementation instagramViewController
@synthesize profileImageUrls;
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
	
	
	instagramView = [[InstagramView alloc] initWithFrame:self.view.bounds];
	[self.view addSubview:instagramView];
	
}



- (void)viewDidAppear:(BOOL)animated
{
	if (_engine) return;
	_engine = [[SA_OAuthTwitterEngine alloc] initOAuthWithDelegate: self];
	_engine.consumerKey = kOAuthConsumerKey;
	_engine.consumerSecret = kOAuthConsumerSecret;
	
	userText = [[NSMutableSet alloc] init];
	profileImageUrls = [[NSMutableSet alloc] init];
	profileImages = [[NSMutableArray alloc] init];
	profileImageRequstIdentifier = [[NSMutableDictionary alloc] init];
	[NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(newImageAdd) userInfo:nil repeats:YES];
	[NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(loadImageUrl) userInfo:nil repeats:YES];
	[NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(loadImage) userInfo:nil repeats:YES];
	
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
			if (i>=10) {
				break;
			}
		}
		
	}
}


- (void)newImageAdd
{
	if ([profileImages count]) {
		
		[instagramView insertNewImage:[profileImages lastObject]];
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
	//	NSLog(@"%@",statuses);
	for (NSDictionary *status in statuses) {
		NSString* url =		[[status valueForKey:@"user"] valueForKey:@"profile_image_url"];
		NSString* text = [status valueForKey:@"text"]; 
		[profileImageUrls addObject:url];
		[userText addObject:text];
		
	}
	NSLog(@"profileImageUrls == %d",[profileImageUrls count]);
	NSLog(@"userText == %d",[userText count]);
	
}

- (void)imageReceived:(UIImage *)image forRequest:(NSString *)connectionIdentifier
{
	
	[profileImageUrls removeObject:[profileImageRequstIdentifier valueForKey:connectionIdentifier]];
	[profileImageRequstIdentifier removeObjectForKey:connectionIdentifier];
	[profileImages insertObject:image atIndex:0];
	
	NSLog(@"profileImageUrls count %d",[profileImageUrls count]);
	NSLog(@"profileImageRequstIdentifier count %d",[profileImageRequstIdentifier count]);
	NSLog(@"profileImage count %d",[profileImages count]);
}


@end
