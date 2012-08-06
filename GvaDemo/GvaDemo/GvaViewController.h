//
//  GvaViewViewController.h
//  GvaView
//
//  Created by Xi Cao on 3/08/12.
//  Copyright (c) 2012 xic. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <QuartzCore/QuartzCore.h>
#import <GameKit/GameKit.h>
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <MobileCoreServices/MobileCoreServices.h>

@interface GvaViewViewController : UIViewController <CLLocationManagerDelegate>

@property (nonatomic,retain) CLLocationManager *locationManager;

//use to distinguish controller and crew-point
@property (weak, nonatomic) IBOutlet UILabel *mode;

@property (nonatomic) int functionLabelNotifier;

@end