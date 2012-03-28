//
//  FacebookSession.m
//  FacebookContacts
//
//  Created by Rashdan Natiq on 3/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FacebookSession.h"


static FacebookSession *fbobject;

@interface FacebookSession (Private)
- (void)getUserInfo;
@end


@implementation FacebookSession
@synthesize facebook;
@synthesize delegate;

- (id)init {
    self = [super init];
    if (self) {
        permissions = [[NSArray alloc] initWithObjects:@"publish_stream, read_friendlists",nil];
	//	self.facebook = [[[Facebook alloc] initWithAppId:kApplicationID andDelegate:self] autorelease];
		
		if ([[NSUserDefaults standardUserDefaults] objectForKey:@"AccessToken"] != nil)	{
			facebook.accessToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"AccessToken"];
		}
		
		if ([[NSUserDefaults standardUserDefaults] objectForKey:@"ExpirationDate"] != nil)	{
			facebook.expirationDate = (NSDate *)[[NSUserDefaults standardUserDefaults] objectForKey:@"ExpirationDate"];
		}
		//[(TNGAppDelegate *)[[UIApplication sharedApplication] delegate] setFacebook:facebook];
    }
    return self;
}

+ (FacebookSession *)getSession {
    @synchronized(self) {
        if (fbobject == nil)  {
            fbobject = [[FacebookSession alloc] init];
        }
    }
    return fbobject;
}

- (void)login   {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:@"FBAccessTokenKey"] 
        && [defaults objectForKey:@"FBExpirationDateKey"]) {
        facebook.accessToken = [defaults objectForKey:@"FBAccessTokenKey"];
        facebook.expirationDate = [defaults objectForKey:@"FBExpirationDateKey"];
    }
    if (!facebook.isSessionValid) {
        facebook.sessionDelegate = self;
        [facebook authorize:permissions];
    }   else    {
        [self getFacebookFriends];
    }
}



+ (void)login   {
    [(FacebookSession *)[FacebookSession getSession] login];
}

- (void)logout  {
//    [delegate facebookDidLoggedOut];
}

+ (void)logout  {
    [(FacebookSession *)[FacebookSession getSession] logout];
}

- (NSString *)accessToken   {
    return facebook.accessToken;
}

+ (NSString *)accessToken   {
    return [(FacebookSession *)[FacebookSession getSession] accessToken];
}

- (BOOL)isLoggedIn	{
	return self.facebook.isSessionValid;
}


- (void)getFacebookFriends {
    NSMutableDictionary *variables = [[NSMutableDictionary alloc] init];
    [variables setObject:@"picture,id,name" forKey:@"fields"];
    
    [facebook requestWithGraphPath:@"me/friends" andParams:variables andDelegate:self];
}


- (void)getUserInfo	{
    requestType = RequestTypeUserInformation;
	NSMutableDictionary * params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
									@"SELECT uid, name, pic FROM user WHERE uid = me() ", @"query",
									nil];
	[facebook requestWithMethodName:@"fql.query"
						  andParams:params
					  andHttpMethod:@"POST"
						andDelegate:self];
}


#pragma mark FBRequestDelegate

- (void)request:(FBRequest *)request didReceiveResponse:(NSURLResponse *)response {
	NSLog(@"received response");
}

- (void)request:(FBRequest *)request didLoad:(id)result {
	NSLog(@"FB Result: %@", result);
    [delegate didRecieveResult:result];
}

- (void)request:(FBRequest *)request didFailWithError:(NSError *)error {
	NSLog(@"Error: %@", [error localizedDescription]);
}


#pragma mark - FBSessionDelegate

- (void)fbDidLogin  {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[facebook accessToken] forKey:@"FBAccessTokenKey"];
    [defaults setObject:[facebook expirationDate] forKey:@"FBExpirationDateKey"];
    [defaults synchronize];
    [self getFacebookFriends];
}

- (void)fbDidNotLogin:(BOOL)cancelled   {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:@"FBAccessTokenKey"]) {
        [defaults removeObjectForKey:@"FBAccessTokenKey"];
        [defaults removeObjectForKey:@"FBExpirationDateKey"];
        [defaults synchronize];
        
        facebook.accessToken = nil;
        facebook.expirationDate = nil;
    }
}

- (void)fbDidLogout {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:@"FBAccessTokenKey"]) {
        [defaults removeObjectForKey:@"FBAccessTokenKey"];
        [defaults removeObjectForKey:@"FBExpirationDateKey"];
        [defaults synchronize];
                
        facebook.accessToken = nil;
        facebook.expirationDate = nil;
    }
    
}

@end
