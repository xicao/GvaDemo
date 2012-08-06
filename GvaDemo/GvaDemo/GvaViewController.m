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

#define FUNCTION_BUTTON             CGRectMake(157.5,30-CALIBRATION,65,65)
#define FUNCTION_BUTTON_GAP         92

#define COMMON_TASK_BUTTON          CGRectMake(157.5,685-CALIBRATION,65,65)
#define COMMON_TASK_BUTTON_GAP      92

#define RECONFIGURABEL_BUTTON_LEFT  CGRectMake(66,185-CALIBRATION,63,60)
#define RECONFIGURABEL_BUTTON_RIGHT CGRectMake(895,185-CALIBRATION,63,60)
#define RECONFIGURABEL_BUTTON_GAP   68

#define COMPASS                     CGRectMake(248,185-CALIBRATION,100,106)

@interface GvaViewViewController ()

@property (nonatomic, weak) IBOutlet GvaView *gvaView;

@property (nonatomic,retain) UIImageView *compass;

@end

@implementation GvaViewViewController

@synthesize mode = _mode;
@synthesize functionLabelNotifier = _functionLabelNotifier;
@synthesize gvaView = _gvaView;
@synthesize compass = _compass;
@synthesize locationManager = _locationManager;

# pragma mark - Lazy Instantiation

- (UIImageView *)compass {
    if (!_compass) {
        _compass = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"compass.png"]];
    }
    
    return _compass;
}

# pragma mark - Button Methods

- (void)functionalAreaSelectionButtonsPressed:(UIButton *)sender {
    // highlight current functional area label
    [self.gvaView functionLabelSelected:sender.currentTitle];
}

- (void)commonTaskButtonsPressed:(UIButton *)sender {
    if ([sender.currentTitle isEqualToString:@"F20"]) {//back to main screen
        [self.navigationController popViewControllerAnimated:YES];
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
            
            [buttonRight setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [buttonRight setTitle:(NSString *)[buttonText objectAtIndex:(i + 6)] forState:UIControlStateNormal];
            buttonRight.titleLabel.font = [UIFont fontWithName:@"Helvetica" size: 35.0];
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
            [buttonUp addTarget:self action:@selector(functionalAreaSelectionButtonsPressed:) forControlEvents:UIControlEventTouchUpInside];
            
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
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
    
	[self.navigationController setNavigationBarHidden:NO animated:YES];
}


@end
