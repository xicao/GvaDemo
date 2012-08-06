//
//  UIAlertTableView.h
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

#import <UIKit/UIKit.h>

@class UIAlertView;

@interface UIAlertTableView : UIAlertView {
	// The Alert View to decorate
    UIAlertView *alertView;
	
	// The Table View to display
	UITableView *tableView;
	
	// Height of the table
	int tableHeight;
	
	// Space the Table requires (incl. padding)
	int tableExtHeight;
	
	id<UITableViewDataSource> dataSource;
	id<UITableViewDelegate> tableDelegate;
}

@property (nonatomic, assign) id dataSource;
@property (nonatomic, assign) id tableDelegate;

@property (nonatomic, readonly) UITableView *tableView;
@property (nonatomic, assign) int tableHeight;

- (void)prepare;

@end