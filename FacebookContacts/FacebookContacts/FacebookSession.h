//
//  FacebookSession.h
//  FacebookContacts
//
//  Created by Rashdan Natiq on 3/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Facebook.h"

typedef enum {
    RequestTypeUserInformation,
    RequestTypePublishOnWall
}   RequestType;


@protocol FacebookSessionDelegate <NSObject>
- (void)didRecieveResult:(id)result;
@end

@interface FacebookSession : NSObject    <FBSessionDelegate, FBRequestDelegate>  {
	NSArray *permissions;
    RequestType requestType;
}

@property (nonatomic, retain) Facebook *facebook;
@property (nonatomic, assign) id <FacebookSessionDelegate> delegate;

+ (void)login;

//+ (void)setDelegate:(id<FacebookSessionDelegate>)delegate;

+ (FacebookSession *)getSession;

- (NSString *)accessToken;
+ (NSString *)accessToken;
- (void)getFacebookFriends;

@end
