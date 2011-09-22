//
//  Twitter.m
//  Note
//
//  Created by hongjun Kim on 7/1/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "NoteTwitter.h"
#import "Setting.h"


#define CONSUMER_KEY @"T1FhDQe8iaECsqo4mDlikg"
#define CONSUMER_SECRET @"mKhLpSrYlEmj9MKjywmJ4nkAyNb70oNfgvckAiJGU"
#define REQUEST_TOKEN_URL @"http://twitter.com/oauth/request_token"
#define SERVICE_URL @"http://twitter.com/"
#define AUTHORIZE_URL @"http://twitter.com/oauth/authorize"
#define ACCESS_TOKEN_URL @"http://twitter.com/oauth/access_token"
#define UPDATE_URL @"http://twitter.com/statuses/update.xml"


@implementation NoteTwitter


@synthesize delegate,username,password,oaRequestToken,oaAccessToken;

static NoteTwitter *_sharedNoteTwitter = nil;

+(NoteTwitter *)sharedNoteTwitter
{
	@synchronized([NoteTwitter class])
	{
		if (!_sharedNoteTwitter)
			[[self alloc] init];
		
		
		return _sharedNoteTwitter;
	}
	// to avoid compiler warning
	return nil;
}

+(id)alloc
{
	@synchronized([NoteTwitter class])
	{
		NSAssert(_sharedNoteTwitter == nil, @"Attempted to allocate a second instance of a singleton.");
		_sharedNoteTwitter = [super alloc];
		return _sharedNoteTwitter;
	}
	// to avoid compiler warning
	return nil;
}

- (id) init
{
	if (self = [super init]) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeusername:) name:@"Twitter account Username" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changepassword:) name:@"Twitter account Password" object:nil];
	}
	return self;
}

- (void) changeusername:(NSNotification*)noti
{
	NSLog(@"self.username %@",self.username);
	self.username = [noti object];
	//[self setUsername:[noti object] Password:self.password];
	
	[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:@"isChangingUserandPW"];
}
- (void) changepassword:(NSNotification*)noti
{
	self.password = [noti object];
	NSLog(@"self.password %@",self.password);
	[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:@"isChangingUserandPW"];
}

- (void) OAuthStart 
{
	NSUserDefaults *userdefaults = [NSUserDefaults standardUserDefaults];
	
	if ([[userdefaults objectForKey:@"HasAccessToken"] boolValue]) 
	{
		if (![[userdefaults objectForKey:@"isChangingUserandPW"] boolValue]) 
		{
			self.oaAccessToken = [[OAToken alloc] initWithUserDefaultsUsingServiceProviderName:@"Twitter" prefix:@"oaAccessToken"];
			OAuth = YES;
			return;
		}
	}	
	OAConsumer *consumer = [[OAConsumer alloc] initWithKey:CONSUMER_KEY	secret:CONSUMER_SECRET];
	NSURL *url = [[NSURL alloc] initWithString:REQUEST_TOKEN_URL];
	OAMutableURLRequest *request = [[OAMutableURLRequest alloc] initWithURL:url
																   consumer:consumer
																	  token:nil
																	  realm:SERVICE_URL
														  signatureProvider:nil];
	[request setOAuthParameterName:@"oauth_callback" withValue:@"oob"];
	
	OADataFetcher *fetcher = [[OADataFetcher alloc] init];
	[fetcher fetchDataWithRequest:request
						 delegate:self
				didFinishSelector:@selector(requestTokenTicket:didFinishWithData:)
				  didFailSelector:@selector(requestTokenTicket:didFailWithError:)];

	
}

- (void) setUsername:(NSString*)UN Password:(NSString*)PW
{
	self.username = UN;
	self.password = PW;
	
	[self OAuthStart];

}


#pragma mark -
#pragma mark OAuth

- (NSData *) requestOAuthEnticity_Token
{
	//authenicity_tokey 받아오기
	NSString *authorizeURL = [[NSString alloc] 
							  initWithFormat:@"%@?oauth_token=%@",
							  AUTHORIZE_URL,
							  [oaRequestToken.key URLEncodedString]];
	NSLog(@"%@",authorizeURL);
	NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:authorizeURL]];
	[authorizeURL release];
	
	NSData *urlData = [NSURLConnection sendSynchronousRequest:urlRequest
											returningResponse:nil	 error:nil];
	return urlData;
}

- (NSString *) parsingAuthEnticity_token: (NSData *) urlData 
{
	//authenicity_token 파싱
	NSString *urlString = [[[NSString alloc] initWithData:urlData encoding:NSUTF8StringEncoding] autorelease];
	NSRange tokeyrange = [urlString rangeOfString:@"authenticity_token"];		
	NSString *authenicity_token = [urlString substringWithRange:NSMakeRange(tokeyrange.location+41,40)];
	return authenicity_token;
}

- (NSString *)requestOAuthPin:(NSString*)authenicity_token
{
	//pin 받아오기
	NSString *pinpost =[[NSString alloc]
						//initWithFormat:@"oauth_token=%@&authenicity_token=%@&session[username_or_email]=%@&session[password]=%@",
						initWithFormat:@"authenticity_token=%@&oauth_token=%@&session[username_or_email]=%@&session[password]=%@",
						authenicity_token,
						[oaRequestToken.key URLEncodedString],
						[username stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
						[password stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
	
	NSData *postData = [pinpost dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
	[pinpost release];
	NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
	NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] init] autorelease];
	[request setURL:[NSURL URLWithString:AUTHORIZE_URL]];
	[request setHTTPMethod:@"POST"];
	[request setValue:postLength forHTTPHeaderField:@"Content-Length"];
	[request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
	[request setHTTPBody:postData];
	NSData *urlData=[NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
	NSString *pinHtmlstring=[[NSString alloc]initWithData:urlData encoding:NSUTF8StringEncoding];
	//NSLog(@"%@",pinHtmlstring);
	return pinHtmlstring;
}

- (NSString*)parsingOAuthPin:(NSString *)pinHtmlstring
{
	//파싱
	NSRange pinrange = [pinHtmlstring rangeOfString:@"oauth_pin" options:NSBackwardsSearch range:NSMakeRange(0,[pinHtmlstring length])];
	NSString *oauthPIN = [pinHtmlstring substringWithRange:NSMakeRange(pinrange.location+11,7)];
	//NSLog(@"%@",oauthPIN);
	return oauthPIN;
}

- (void)requestTokenTicket:(OAServiceTicket *)ticket didFinishWithData:(NSData *)data {
	if (ticket.didSucceed) {
		NSString *responseBody = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
		//NSLog(@"%@",responseBody);
		self.oaRequestToken = [[OAToken alloc] initWithHTTPResponseBody:responseBody];
		[responseBody release];
		
		NSData *urlData = [self requestOAuthEnticity_Token];
		NSString *authenicity_token = [self parsingAuthEnticity_token:urlData];
		NSString *pinHtmlstring = [self requestOAuthPin:authenicity_token];
		NSString *oauthPIN = [self parsingOAuthPin:pinHtmlstring];
		
		OAConsumer *consumer = [[OAConsumer alloc] initWithKey:CONSUMER_KEY	 secret:CONSUMER_SECRET];
		NSURL *url = [[NSURL alloc] initWithString:ACCESS_TOKEN_URL];
		OAMutableURLRequest *oauthrequest = [[OAMutableURLRequest alloc] initWithURL:url
																			consumer:consumer	
																			   token:self.oaRequestToken
																			   realm:SERVICE_URL
																   signatureProvider:nil];
		
		[oauthrequest setOAuthParameterName:@"oauth_verifier" withValue:[NSString stringWithFormat:@"%@",oauthPIN]];
		OADataFetcher *fetcher = [[OADataFetcher alloc] init];
		
		[fetcher fetchDataWithRequest:oauthrequest
							 delegate:self
					didFinishSelector:@selector(accessTokenTicket:didFinishWithData:)
					  didFailSelector:@selector(accessTokenTicket:didFailWithError:)];
	}
	else {
		NSLog(@"Finish but did not succeed.");
		[delegate requestFailed:@"Auth error"];
	}
}

- (void)requestTokenTicket:(OAServiceTicket *)ticket didFailWithError:(NSError *)error {
	NSLog(@"Error: %@", [error localizedDescription]);
	[delegate requestFailed:@"Auth error"];
	OAuth = NO;
}

- (void)accessTokenTicket:(OAServiceTicket *)ticket didFinishWithData:(NSData *)data {
	if (ticket.didSucceed) {
		NSString *responseBody = [[NSString alloc] initWithData:data
													   encoding:NSUTF8StringEncoding];
		
		self.oaAccessToken = [[OAToken alloc] initWithHTTPResponseBody:responseBody];
		
		NSLog(@"Got Access Token [key:%@, secret:%@]", oaAccessToken.key, oaAccessToken.secret);
		
		[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:@"HasAccessToken"];
		[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:@"isChangingUserandPW"];
		[oaAccessToken storeInUserDefaultsWithServiceProviderName:@"Twitter" prefix:@"oaAccessToken"];
		OAuth = YES;
		[responseBody release];
		
		
		
	}
	else 
	{
		NSLog(@"Finish but did not succeed.");
		[delegate requestFailed:@"Auth error"];
		OAuth = NO;
	}
}

- (void)accessTokenTicket:(OAServiceTicket *)ticket didFailWithError:(NSError *)error {
	NSLog(@"Error: %@", [error localizedDescription]);
	[delegate requestFailed:@"Auth error"];
	OAuth = NO;
}


#pragma mark -
#pragma mark Twitting

-(void)statuses_update:(NSString *)status
{
	NSLog(@"%@",[[Setting sharedSetting] valueForKey:@"Twitter account Username"]);
	NSLog(@"%@",[[Setting sharedSetting] valueForKey:@"Twitter account Password"]);
	NSLog(@"%d",[[[Setting sharedSetting] valueForKey:@"Twitter account Username"] isEqualToString:@""]);
	NSLog(@"%d",[[[Setting sharedSetting] valueForKey:@"Twitter account Password"] isEqualToString:@""]);
	if ([[[Setting sharedSetting] valueForKey:@"Twitter account Username"] isEqualToString:@""]||
		 [[[Setting sharedSetting] valueForKey:@"Twitter account Password"] isEqualToString:@""]) 
	{
		UIAlertView *alertView = [[UIAlertView alloc] 
								  initWithTitle: @"Input Twitter account"
								  message:@"Settings > Twitter"
								  delegate:self
								  cancelButtonTitle:nil
								  otherButtonTitles:@"OK", nil];
		
		[alertView show];
		return;
	}
	[self setUsername:[[Setting sharedSetting] valueForKey:@"Twitter account Username"]
			 Password:[[Setting sharedSetting] valueForKey:@"Twitter account Password"]];
	if (!OAuth) {
		return;
	}
	
	
	OAConsumer *consumer = [[OAConsumer alloc] initWithKey:CONSUMER_KEY
													secret:CONSUMER_SECRET];
	
	NSURL *url = [[NSURL alloc] initWithString:UPDATE_URL];
	OAMutableURLRequest *request = [[OAMutableURLRequest alloc] initWithURL:url
																   consumer:consumer
																	  token:self.oaAccessToken
																	  realm:SERVICE_URL
														  signatureProvider:nil];
	
	NSString *post =[[NSString alloc] initWithFormat:@"status=%@",status];
	NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
	[post release];
	[request setHTTPMethod:@"POST"];
	NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
	[request setValue:postLength forHTTPHeaderField:@"Content-Length"];
	[request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
	[request setHTTPBody:postData];
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
	OAAsynchronousDataFetcher *fetcher = [OAAsynchronousDataFetcher
										  asynchronousFetcherWithRequest:request
										  delegate:self
										  didFinishSelector:@selector(updateStatusTicket:didFinishWithData:)
										  didFailSelector:@selector(updateStatusTicket:didFailWithError:)];
	[fetcher start];
}

- (void)updateStatusTicket:(OAServiceTicket*)ticket didFinishWithData:(NSData*)data
{
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	NSLog(@"data: %@", [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease]);
	elementType = requestNone;
	
	NSXMLParser *parser = [[NSXMLParser alloc] initWithData:data];
	[parser setDelegate:self];
	[parser parse];
	[parser release];
	
	if (elementType == requestError) 
		[delegate requestFailed:xmlValue];
	else
		[delegate requestSucceeded];
	
}
- (void)updateStatusTicket:(OAServiceTicket *)ticket didFailWithError:(NSError *)error 
{
	NSLog(@"Error: %@", [error localizedDescription]);
	[delegate requestFailed:@"updateStatus error"];
}

#pragma mark -
#pragma mark XMLParse delegate methods

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
	
	//static int count = 0;
	//NSLog(@"%d",++count);
	if ([elementName isEqualToString:@"error"]) 
		elementType = requestError;
	
	[xmlValue setString:@""];
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
	if (elementType == requestError) {
		[xmlValue appendString:string];
	}
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	[alertView release];
	
}

@end
