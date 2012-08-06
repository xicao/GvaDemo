//
//  GvaViewViewController.h
//  GvaView
//
//  Created by Xi Cao on 3/08/12.
//  Copyright (c) 2012 xic. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GvaViewViewController : UIViewController

//use to distinguish controller and crew-point
@property (weak, nonatomic) IBOutlet UILabel *mode;

@property (nonatomic) int functionLabelNotifier;

@end
