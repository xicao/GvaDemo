//
//  GameKitManager.m
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

#import "GameKitManager.h"

@implementation GameKitManager

@synthesize dataDelegate = _dataDelegate;
@synthesize viewController = _viewController;
@synthesize sessionID = _sessionID;
@synthesize session = _session;
@synthesize isConnected = _isConnected;

#define DO_DATA_CALLBACK(X, Y) if (self.dataDelegate && [self.dataDelegate respondsToSelector:@selector(X)]) [self.dataDelegate performSelector:@selector(X) withObject:Y];
#define showAlert(format, ...) myShowAlert(__LINE__, (char *)__FUNCTION__, format, ##__VA_ARGS__)
#define BARBUTTON(TITLE, SELECTOR) 	[[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR]

// Simple Alert Utility
void myShowAlert(int line, char *functname, id formatstring,...) {
	va_list arglist;
	if (!formatstring) return;
	va_start(arglist, formatstring);
	id outstring = [[NSString alloc] initWithFormat:formatstring arguments:arglist];
	va_end(arglist);
	
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:outstring message:nil delegate:nil cancelButtonTitle:@"OK"otherButtonTitles:nil];
	[av show];
}

#pragma mark Shared Instance

static GameKitManager *sharedInstance = nil;

+ (GameKitManager *)sharedInstance {
	if(!sharedInstance) sharedInstance = [[self alloc] init];
    return sharedInstance;
}

#pragma mark Data Sharing

- (void) sendDataToPeers:(NSData *) data {
	NSError *error;
	BOOL didSend = [self.session sendDataToAllPeers:data withDataMode:GKSendDataReliable error:&error];
	if (!didSend)
		NSLog(@"Error sending data to peers: %@", [error localizedDescription]);
	DO_DATA_CALLBACK(sentData:, (didSend ? nil : [error localizedDescription]));
}

- (void)receiveData:(NSData *)data fromPeer:(NSString *)peer inSession: (GKSession *)session context:(void *)context {
	DO_DATA_CALLBACK(receivedData:, data);
}

#pragma mark Connections

- (void) startConnection {
	if (!self.isConnected) {
        GKPeerPickerController* picker = [[GKPeerPickerController alloc] init];
        picker.delegate = self;
        picker.connectionTypesMask = GKPeerPickerConnectionTypeOnline | GKPeerPickerConnectionTypeNearby;
        
        [picker show];
	}
}

// Dismiss the peer picker on cancel
- (void) peerPickerControllerDidCancel: (GKPeerPickerController *)picker {
	picker.delegate = nil;
}

- (void)peerPickerController:(GKPeerPickerController *)picker didConnectPeer:(NSString *)peerID toSession: (GKSession *) session{
	[picker dismiss];
	[self.session setDataReceiveHandler:self withContext:nil];
	self.isConnected = YES;
	DO_DATA_CALLBACK(connectionEstablished, nil);
}

- (GKSession *)peerPickerController:(GKPeerPickerController *)picker sessionForConnectionType:(GKPeerPickerConnectionType)type {
    
    // from Apple - Game Kit Programmiing Guide: Finding Peers with Peer Picker
    if (type == GKPeerPickerConnectionTypeOnline) {
		picker.delegate = nil;
		[picker dismiss];
		
        if (!self.session) {
            self.session = [[GKSession alloc] initWithSessionID:(self.sessionID ? self.sessionID : @"Sample Session")
                                                    displayName:nil
                                                    sessionMode:GKSessionModePeer];
            self.session.delegate = self;
            self.session.available = YES;
            [self.session setDataReceiveHandler:self withContext:nil];
        }
	}
    
	return self.session;
}

#pragma mark Session Handling

- (void) disconnect {
	[self.session disconnectFromAllPeers];
	self.session = nil;
}

- (void)session:(GKSession *)session peer:(NSString *)peerID didChangeState:(GKPeerConnectionState)state {
    
    switch (state) {
		case GKPeerStateAvailable:
			[session connectToPeer:peerID withTimeout:10];
			break;
			
		case GKPeerStateConnected:
			break;
            
		case GKPeerStateDisconnected:
            self.isConnected = NO;
            showAlert(@"You are no longer connected to another device.");
            [self disconnect];
            if (self.viewController)
                self.viewController.navigationItem.rightBarButtonItem = BARBUTTON(@"Connect", @selector(startConnection));
            DO_DATA_CALLBACK(connectionLost, nil);
            
		default:
			break;
	}
}

- (void) assignViewController: (UIViewController *) aViewController {
	self.viewController = aViewController;
}

#pragma mark Class utility methods

+ (void) connect {
	[[self sharedInstance] startConnection];
}

+ (void) disconnect {
	[[self sharedInstance] disconnect];
}

+ (void) sendData: (NSData *) data {
	[[self sharedInstance] sendDataToPeers:data];
}

+ (void) assignViewController: (UIViewController *) aViewController {
	[[self sharedInstance] assignViewController:aViewController];
}
@end
