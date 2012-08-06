//
//  GvaDemoViewController.m
//  GvaDemo
//
//  Created by Xi Cao on 6/08/12.
//  Copyright (c) 2012 xic. All rights reserved.
//

#import "GvaDemoViewController.h"

@interface GvaDemoViewController ()

@end

@implementation GvaDemoViewController

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)orientation {
    //[[UIApplication sharedApplication] setStatusBarHidden:YES];// hide status bar
    return UIInterfaceOrientationIsLandscape(orientation);// only support landscape
}

//hide navigation bar
- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
    
	[self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
    
	[self.navigationController setNavigationBarHidden:NO animated:YES];
}

@end
