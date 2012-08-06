//
//  GameKitManager.h
//  GvaDemo
//
//  Created by Xi Cao on 6/08/12.
//  Copyright (c) 2012 xic. All rights reserved.
//

/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License
 */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <GameKit/GameKit.h>

@protocol GameKitManagerDataDelegate <NSObject>

@optional

- (void)connectionEstablished;
- (void)connectionLost;
- (void)sentData:(NSString *)errorMessage;
- (void)receivedData:(NSData *)data;

@end

@interface GameKitManager : NSObject <GKPeerPickerControllerDelegate, GKSessionDelegate>

@property (retain) id dataDelegate;
@property (retain) UIViewController *viewController;
@property (retain) NSString *sessionID;
@property (retain) GKSession *session;
@property (assign) BOOL isConnected;

+ (void) connect;
+ (void) disconnect;
+ (void) sendData: (NSData *) data;

+ (GameKitManager *) sharedInstance;

@end
