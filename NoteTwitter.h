//
//  Twitter.h
//  Note
//
//  Created by hongjun Kim on 7/1/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OAuthConsumer.h"
@protocol TwitterDelegate
- (void)requestSucceeded;
- (void)requestFailed:(NSString *)ErrorMessage;
@end

typedef enum {
	requestError = -1,
	requestNone
} eElementType;



@interface NoteTwitter : NSObject <NSXMLParserDelegate>
{
	NSString *username;
	NSString *password;
	OAToken *oaRequestToken;
	OAToken *oaAccessToken;
	
	id delegate;
	
	eElementType elementType;
	NSMutableString *xmlValue;
	
	BOOL OAuth;
}

@property(nonatomic, retain) NSString	   *username;
@property(nonatomic, retain) NSString	   *password;
@property(nonatomic, retain) OAToken *oaRequestToken,*oaAccessToken;
@property (nonatomic, assign) id<TwitterDelegate> delegate;
+(NoteTwitter *)sharedNoteTwitter;
- (void)setUsername:(NSString*)UN Password:(NSString*)PW;
- (void)statuses_update:(NSString *)status;
//-(void)request:(NSURL *) url;

@end
