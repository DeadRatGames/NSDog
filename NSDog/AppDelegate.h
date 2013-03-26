//
//  AppDelegate.h
//  NSDog
//
//  Created by Christopher Larsen, Brian Croom on 2013-03-12.
//  Copyright (c) 2013 All rights reserved

#import <UIKit/UIKit.h>

@class ViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) IBOutlet UIWindow *window;
@property (strong, nonatomic) IBOutlet ViewController *viewController;

@end
