//
//  UIAlertTableView.m
//  UIAlertTableView
//
// Copyright 2010 partiql Ltd, Switzerland.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#import "UIAlertTableView.h"

#define kTablePadding 8.0f


@interface UIAlertView (private)
- (void)layoutAnimated:(BOOL)fp8;
@end

@implementation UIAlertTableView

@synthesize dataSource;
@synthesize tableDelegate;
@synthesize tableHeight;
@synthesize tableView;

- (void)layoutAnimated:(BOOL)fp8 {
	[super layoutAnimated:fp8];
	[self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y - tableExtHeight/2, self.frame.size.width, self.frame.size.height + tableExtHeight)];
	
	// We get the lowest non-control view (i.e. Labels) so we can place the table view just below
	UIView *lowestView;
	int i = 0;
	while (![[self.subviews objectAtIndex:i] isKindOfClass:[UIControl class]]) {
		lowestView = [self.subviews objectAtIndex:i];
		i++;
	}
	
	CGFloat tableWidth = 262.0f;
	
	tableView.frame = CGRectMake(11.0f, lowestView.frame.origin.y + lowestView.frame.size.height + 2 * kTablePadding, tableWidth, tableHeight);
	
	for (UIView *sv in self.subviews) {
		// Move all Controls down
		if ([sv isKindOfClass:[UIControl class]]) {
			sv.frame = CGRectMake(sv.frame.origin.x, sv.frame.origin.y + tableExtHeight, sv.frame.size.width, sv.frame.size.height);
		}
	}
	
}

- (void)show{
	[self prepare];
    [super show];
}

- (void)prepare {
	if (tableHeight == 0) {
		tableHeight = 150.0f;
	}
	
	tableExtHeight = tableHeight + 2 * kTablePadding;
	
    tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 0.0f, 0.0f) style:UITableViewStylePlain];
	tableView.delegate = tableDelegate;
	tableView.dataSource = dataSource;	
	
	[self insertSubview:tableView atIndex:0];
	
	[self setNeedsLayout];
}

- (void)dealloc {
	[tableView release];
    [super dealloc];
}

@end