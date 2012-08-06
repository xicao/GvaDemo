//
//  GvaViewViewController.m
//  GvaView
//
//  Created by Xi Cao on 3/08/12.
//  Copyright (c) 2012 xic. All rights reserved.
//

#import "GvaViewController.h"
#import "GvaView.h"

#define CALIBRATION                 22

#define STATUS_INFORMATION_BAR      CGRectMake(143,126-CALIBRATION,738,51)

#define VIDEO_FRAME                 CGRectMake(406.5,113-CALIBRATION,738,51)

#define TEXT_VIEW_FRAME             CGRectMake(143,126-CALIBRATION,738,51)

#define FUNCTION_BUTTON             CGRectMake(157.5,30-CALIBRATION,65,65)
#define FUNCTION_BUTTON_GAP         92

#define COMMON_TASK_BUTTON          CGRectMake(157.5,685-CALIBRATION,65,65)
#define COMMON_TASK_BUTTON_GAP      92

#define RECONFIGURABEL_BUTTON_LEFT  CGRectMake(66,185-CALIBRATION,63,60)
#define RECONFIGURABEL_BUTTON_RIGHT CGRectMake(895,185-CALIBRATION,63,60)
#define RECONFIGURABEL_BUTTON_GAP   68

#define COMPASS                     CGRectMake(248,185-CALIBRATION,103.6,110.4)

@interface GvaViewViewController ()

@property (nonatomic, weak) IBOutlet GvaView *gvaView;

@property (nonatomic,retain) UIImageView *compass;
@property (nonatomic,retain) UILabel *statusAndAlertInformationBar;

@property (nonatomic,retain) UIImageView *videoStreaming;
@end

@implementation GvaViewViewController

@synthesize mode = _mode;
@synthesize functionLabelNotifier = _functionLabelNotifier;
@synthesize gvaView = _gvaView;
@synthesize compass = _compass;
@synthesize locationManager = _locationManager;
@synthesize session = _session;
@synthesize peerID = _peerID;
@synthesize peerList = _peerList;
@synthesize videoStreaming = _videoStreaming;

# pragma mark - Lazy Instantiation

- (UIImageView *)videoStreaming {
    if (!_videoStreaming) {
        _videoStreaming = [[UIImageView alloc] initWithFrame:VIDEO_FRAME];
    }
    
    return _videoStreaming;
}

- (UIImageView *)compass {
    if (!_compass) {
        _compass = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"compass.png"]];
    }
    
    return _compass;
}

- (UILabel *)statusAndAlertInformationBar {
    if (!_statusAndAlertInformationBar) {
        _statusAndAlertInformationBar = [[UILabel alloc] initWithFrame:STATUS_INFORMATION_BAR];
    }
    
    return _statusAndAlertInformationBar;
}

# pragma mark - Helper Methods

#define showAlert(format, ...) myShowAlert(__LINE__, (char *)__FUNCTION__, format, ##__VA_ARGS__)
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

- (void)clearStatusAndAlertInformationBarText {
    self.statusAndAlertInformationBar.text = @"";
}

- (void)setStatusAndAlertInformationBarText:(NSString *)info {
    [self clearStatusAndAlertInformationBarText];
    self.statusAndAlertInformationBar.text = [self.statusAndAlertInformationBar.text stringByAppendingString:info];
}

#pragma mark - send and receive methods

- (void)receiveData:(NSData *)data fromPeer:(NSString *)peer inSession: (GKSession *)session context:(void *)context {
	if ([data length] < 1024) {// receive text
        NSLog(@"text received");
        
	} else {// receive image
		NSLog(@"image received");
		
        [self.videoStreaming performSelectorOnMainThread:@selector(setImage:)
                                         withObject:[UIImage imageWithData:data] waitUntilDone:YES];
	}
}

- (void)sentText:(NSString *)message {
    if (!self.session) {
        showAlert(@"You are not connecting to any device.");
        return;
    }
    
    NSError* error = nil;
	[self.session sendData:[message dataUsingEncoding:NSUTF8StringEncoding]
				   toPeers:[NSArray arrayWithObject:self.peerID]
			  withDataMode:GKSendDataReliable
					 error:&error];
    
	if (error) {
		showAlert(@"%@", error);
	}
}

- (void)sendImage:(UIImage *)image {
    NSError* error = nil;
	[self.session sendData:UIImageJPEGRepresentation(image, 0.5)
				   toPeers:[NSArray arrayWithObject:self.peerID]
			  withDataMode:GKSendDataReliable
					 error:&error];
    
	if (error) {
		NSLog(@"%@", error);
	}
}

# pragma mark - Connection Methods

- (void)connect {
    [self setStatusAndAlertInformationBarText:@"Start searching..."];
    
    GKPeerPickerController* picker = [[GKPeerPickerController alloc] init];
    picker.delegate = self;
    picker.connectionTypesMask = GKPeerPickerConnectionTypeOnline | GKPeerPickerConnectionTypeNearby;
    
    [picker show];
}

- (void)disconnect {
    //[self loadPeerList];
    
    [self.session disconnectFromAllPeers];
    self.session.available = NO;
    self.session.delegate = nil;
    
    if (self.session) {
        if ([self.mode.text isEqualToString:@"Controller"]) {
            [self setStatusAndAlertInformationBarText:[NSString stringWithFormat:@"Disconnected to %@.", @"Crew-point"]];
        } else {
            [self setStatusAndAlertInformationBarText:[NSString stringWithFormat:@"Disconnected to %@.", @"Controller"]];
        }
    } else {
        [self clearStatusAndAlertInformationBarText];
    }
    
}

- (void)loadPeerList {
    self.peerList = [[NSMutableArray alloc] initWithArray:[self.session peersWithConnectionState:GKPeerStateAvailable]];
}

# pragma mark - Game Kit Picker Methods

- (void)peerPickerController:(GKPeerPickerController *)picker didSelectConnectionType:(GKPeerPickerConnectionType)type {
    // from Apple - Game Kit Programmiing Guide: Finding Peers with Peer Picker
    if (type == GKPeerPickerConnectionTypeOnline) {
		picker.delegate = nil;
		[picker dismiss];
        
        self.session = [[GKSession alloc] initWithSessionID:nil
                                                displayName:self.mode.text
                                                sessionMode:GKSessionModePeer];
        self.session.delegate = self;
        [self.session setDataReceiveHandler:self withContext:nil];
        self.session.available = YES;
        
        showAlert(@"Local Wireless Connection is Availabel now.");
	}
}

- (void)peerPickerController:(GKPeerPickerController *)picker didConnectPeer:(NSString *)peerID toSession:(GKSession *)session {
    // from Apple - Game Kit Programmiing Guide: Finding Peers with Peer Picker
    
    self.session = session;
	session.delegate = self;
	[session setDataReceiveHandler:self withContext:nil];
	picker.delegate = nil;
	[picker dismiss];
}

- (void)peerPickerControllerDidCancel:(GKPeerPickerController *)picker {
	// from Apple - Game Kit Programmiing Guide: Finding Peers with Peer Picker;
	picker.delegate = nil;
    [self clearStatusAndAlertInformationBarText];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    [self setStatusAndAlertInformationBarText:[NSString stringWithFormat:@"Connected to %@.", [alertView buttonTitleAtIndex:buttonIndex]]];
}

#pragma mark - session methods

- (void)session:(GKSession *)session peer:(NSString *)peerID didChangeState:(GKPeerConnectionState)state {
    
    switch (state) {
		case GKPeerStateAvailable:
            [self loadPeerList];
            
            NSLog(@"Peer %d Available", [self.peerList count]);
            
            if ([self.peerList count] == 0) {
                showAlert(@"There are no peers available right now.");
            } else {
                UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"List of Peers"
                                                                  message:@"Please select a peer."
                                                                 delegate:self
                                                        cancelButtonTitle:@"Cancel"
                                                        otherButtonTitles:nil];
                
                [message addButtonWithTitle:[session displayNameForPeer:peerID]];
                
                [message show];
            }
            
			[self setStatusAndAlertInformationBarText:[NSString stringWithFormat:@"Connecting to %@ ...", [session displayNameForPeer:peerID]]];
            
			[session connectToPeer:peerID withTimeout:10];
			break;
			
		case GKPeerStateConnected:
            [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(updateInformationBar) userInfo:nil repeats:NO];
            
            //[self setStatusAndAlertInformationBarText:[NSString stringWithFormat:@"Connected to %@.", [session displayNameForPeer:peerID]]];
			self.peerID = peerID;
			break;
            
		case GKPeerStateDisconnected:
			[self setStatusAndAlertInformationBarText:[NSString stringWithFormat:@"Disconnected to %@.", [session displayNameForPeer:peerID]]];
			self.session = nil;
            
        case GKPeerStateUnavailable:
            [self.peerList removeObject:peerID];
            break;
            
		default:
			break;
	}
}

-(void)updateInformationBar {
    if ([self.mode.text isEqualToString:@"Controller"]) {
        [self setStatusAndAlertInformationBarText:[NSString stringWithFormat:@"Connected to %@.", @"Crew-point"]];
    } else {
        [self setStatusAndAlertInformationBarText:[NSString stringWithFormat:@"Connected to %@.", @"Controller"]];
    }
}


- (void)session:(GKSession *)session didReceiveConnectionRequestFromPeer:(NSString *)peerID {
	NSError* error = nil;
	[session acceptConnectionFromPeer:peerID error:&error];
	if (error) {
		NSLog(@"%@", error);
	}
}

- (void)session:(GKSession *)session connectionWithPeerFailed:(NSString *)peerID withError:(NSError *)error {
	NSLog(@"%@|%@", peerID, error);
}

- (void)session:(GKSession *)session didFailWithError:(NSError *)error {
	NSLog(@"%@", error);
}

# pragma mark - Button Methods

- (void)functionButtonsPressed:(UIButton *)sender {
    // highlight current functional area label
    [self.gvaView functionLabelSelected:sender.currentTitle];
    
    if ([sender.currentTitle isEqualToString:@"SA"]) {
        
    } else if ([sender.currentTitle isEqualToString:@"WPN"]) {
        
    } else if ([sender.currentTitle isEqualToString:@"DEF"]) {
        
    } else if ([sender.currentTitle isEqualToString:@"SYS"]) {
        
    } else if ([sender.currentTitle isEqualToString:@"DRV"]) {
        
    } else if ([sender.currentTitle isEqualToString:@"STR"]) {
        
    } else if ([sender.currentTitle isEqualToString:@"COM"]) {
        
    } else if ([sender.currentTitle isEqualToString:@"BMS"]) {
        
    }
}

- (void)commonTaskButtonsPressed:(UIButton *)sender {
    if ([sender.currentTitle isEqualToString:@"F20"]) {//back to main screen
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)reconfigurableButtonsPressed:(UIButton *)sender {
    if ([sender.currentTitle isEqualToString:@"F1"]) {
        [self connect];
    } else if ([sender.currentTitle isEqualToString:@"F2"]) {
        [self disconnect];
    } else if ([sender.currentTitle isEqualToString:@"F3"]) {
        
    } else if ([sender.currentTitle isEqualToString:@"F4"]) {
        
    } else if ([sender.currentTitle isEqualToString:@"F5"]) {
        
    } else if ([sender.currentTitle isEqualToString:@"F6"]) {
        
    } else if ([sender.currentTitle isEqualToString:@"F7"]) {
        
    } else if ([sender.currentTitle isEqualToString:@"F8"]) {
        
    } else if ([sender.currentTitle isEqualToString:@"F9"]) {
        
    } else if ([sender.currentTitle isEqualToString:@"F10"]) {
        
    } else if ([sender.currentTitle isEqualToString:@"F11"]) {
        
    } else if ([sender.currentTitle isEqualToString:@"F12"]) {
        
    }
}

# pragma mark - Location and Compass Methods

#pragma mark - referene: http://blog.objectgraph.com/index.php/2012/01/10/how-to-create-a-compass-in-iphone/
- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading {
	// Convert Degree to Radian and move the needle
	float oldRad = -manager.heading.trueHeading * M_PI / 180.0f;
	float newRad = -newHeading.trueHeading * M_PI / 180.0f;
	CABasicAnimation * theAnimation;
    theAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    theAnimation.fromValue = [NSNumber numberWithFloat:oldRad];
    theAnimation.toValue = [NSNumber numberWithFloat:newRad];
    theAnimation.duration = 0.5f;
    [self.compass.layer addAnimation:theAnimation forKey:@"animateMyRotation"];
    self.compass.transform = CGAffineTransformMakeRotation(newRad);
	//NSLog(@"%f (%f) => %f (%f)", manager.heading.trueHeading, oldRad, newHeading.trueHeading, newRad);
}


# pragma mark - View Methods

- (void)setGvaView:(GvaView *)gvaView { //reflash our view every time
    _gvaView = gvaView;
    [self.gvaView setBackgroundColor:[UIColor lightGrayColor]];
    [self.gvaView setNeedsDisplay];
}

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    // core location
    self.locationManager = [[CLLocationManager alloc] init];
	self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
	self.locationManager.headingFilter = 1;
	self.locationManager.delegate = self;
	[self.locationManager startUpdatingHeading];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    
    [self setMode:nil];
    [self setCompass:nil];
    [self setSession:nil];
    [self setStatusAndAlertInformationBar:nil];
    [self.locationManager stopUpdatingHeading];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);// only support landscape
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
    
	[self.navigationController setNavigationBarHidden:YES animated:YES];
    
    // draw buttons
    NSArray *buttonText = [NSArray arrayWithObjects:@"F1",@"F2",@"F3",@"F4",@"F5",@"F6",@"F7",@"F8",@"F9",@"F10",@"F11",@"F12",@"F13",@"F14",@"F15",@"F16",@"F17",@"F18",@"F19",@"F20",@"SA",@"WPN",@"DEF",@"SYS",@"DRV",@"STR",@"COM",@"BMS",nil];
    
    CGRect reconfigurabelButtonLeft  = RECONFIGURABEL_BUTTON_LEFT;
    CGRect reconfigurabelButtonRight = RECONFIGURABEL_BUTTON_RIGHT;
    for (int i = 0; i < 6; i++) {
        UIButton *buttonLeft  = [[UIButton alloc] initWithFrame:reconfigurabelButtonLeft];
        UIButton *buttonRight = [[UIButton alloc] initWithFrame:reconfigurabelButtonRight];
        
        [buttonLeft setBackgroundColor:[UIColor blackColor]];
        [buttonRight setBackgroundColor:[UIColor blackColor]];
        if ([[buttonText objectAtIndex:i] isKindOfClass:[NSString class]] &&
            [[buttonText objectAtIndex:(i + 6)] isKindOfClass:[NSString class]]) {
            
            [buttonLeft setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [buttonLeft setTitle:(NSString *)[buttonText objectAtIndex:i] forState:UIControlStateNormal];
            buttonLeft.titleLabel.font = [UIFont fontWithName:@"Helvetica" size: 35.0];
            [buttonLeft addTarget:self action:@selector(reconfigurableButtonsPressed:) forControlEvents:UIControlEventTouchUpInside];
            
            [buttonRight setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [buttonRight setTitle:(NSString *)[buttonText objectAtIndex:(i + 6)] forState:UIControlStateNormal];
            buttonRight.titleLabel.font = [UIFont fontWithName:@"Helvetica" size: 35.0];
            [buttonRight addTarget:self action:@selector(reconfigurableButtonsPressed:) forControlEvents:UIControlEventTouchUpInside];
        }
        
        [self.gvaView addSubview:buttonLeft];
        reconfigurabelButtonLeft.origin.y += RECONFIGURABEL_BUTTON_GAP;
        
        [self.gvaView addSubview:buttonRight];
        reconfigurabelButtonRight.origin.y += RECONFIGURABEL_BUTTON_GAP;
    }
    
    CGRect functionButton   = FUNCTION_BUTTON;
    CGRect commonTaskButton = COMMON_TASK_BUTTON;
    for (int i = 0; i < 8; i++) {
        UIButton *buttonUp   = [[UIButton alloc] initWithFrame:functionButton];
        UIButton *buttonDown = [[UIButton alloc] initWithFrame:commonTaskButton];
        
        [buttonUp setBackgroundColor:[UIColor blackColor]];
        [buttonDown setBackgroundColor:[UIColor blackColor]];
        if ([[buttonText objectAtIndex:(i + 12)] isKindOfClass:[NSString class]] &&
            [[buttonText objectAtIndex:(i + 20)] isKindOfClass:[NSString class]]) {
            
            [buttonUp setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [buttonUp setTitle:(NSString *)[buttonText objectAtIndex:(i + 20)] forState:UIControlStateNormal];
            buttonUp.titleLabel.font = [UIFont fontWithName:@"Helvetica" size: 27.0];
            [buttonUp addTarget:self action:@selector(functionButtonsPressed:) forControlEvents:UIControlEventTouchUpInside];
            
            [buttonDown setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [buttonDown setTitle:(NSString *)[buttonText objectAtIndex:(i + 12)] forState:UIControlStateNormal];
            buttonDown.titleLabel.font = [UIFont fontWithName:@"Helvetica" size: 35.0];
            [buttonDown addTarget:self action:@selector(commonTaskButtonsPressed:) forControlEvents:UIControlEventTouchUpInside];
        }
        
        [self.gvaView addSubview:buttonDown];
        commonTaskButton.origin.x += COMMON_TASK_BUTTON_GAP;
        
        [self.gvaView addSubview:buttonUp];
        functionButton.origin.x += FUNCTION_BUTTON_GAP;
    }
    
    // add compass
    [self.compass setFrame:COMPASS];
    [self.gvaView addSubview:self.compass];
    
    // add status and alert information bar
    [self.statusAndAlertInformationBar setBackgroundColor:[UIColor clearColor]];
    //self.statusAndAlertInformationBar.backgroundColor = nil;
    self.statusAndAlertInformationBar.numberOfLines = 3;
    [self.gvaView addSubview:self.statusAndAlertInformationBar];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
    
	[self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

@end
