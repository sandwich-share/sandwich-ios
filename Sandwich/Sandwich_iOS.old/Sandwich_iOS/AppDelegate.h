//
//  AppDelegate.h
//  Sandwich_iOS
//
//  Created by Diego Waxemberg on 4/10/13.
//  Copyright (c) 2013 Diego Waxemberg. All rights reserved.
//`

#import <UIKit/UIKit.h>

@class ViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) ViewController *viewController;
@property NSMutableSet* peerlist;
@end
