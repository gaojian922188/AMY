//
//  AppDelegate.m
//  AMY
//
//  Created by 檀路生 on 15/3/9.
//  Copyright (c) 2015年 ASYH. All rights reserved.
//

#import "AppDelegate.h"
#import "AMYIndexViewController.h"
#import "AMYCalendarViewController.h"
#import "AMYMineViewController.h"
#import "AMYMoreViewController.h"
@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    UITabBarController *tabarController = [[UITabBarController alloc]init];
    self.window.rootViewController = tabarController;
    tabarController.tabBar.selectedImageTintColor = [UIColor colorWithRed:243/255.f green:104/255.f blue:149/255.f alpha:1];
    
    AMYIndexViewController *indexViewController = [[AMYIndexViewController alloc]init];
    indexViewController.tabBarItem.image = [UIImage imageNamed:@"tabbar_index_n"];
    indexViewController.tabBarItem.selectedImage = [UIImage imageNamed:@"tabbar_index_s"];
    indexViewController.tabBarItem.title = @"首页";
    
    AMYCalendarViewController *calendarViewController = [[AMYCalendarViewController alloc]init];
    calendarViewController.tabBarItem.image = [UIImage imageNamed:@"tabbar_calendar_n"];
    calendarViewController.tabBarItem.selectedImage = [UIImage imageNamed:@"tabbar_calendar_s"];
    calendarViewController.tabBarItem.title = @"日历";
    
    AMYMineViewController *mineViewController = [[AMYMineViewController alloc]init];
    mineViewController.tabBarItem.image = [UIImage imageNamed:@"tabbar_mine_n"];
    mineViewController.tabBarItem.selectedImage = [UIImage imageNamed:@"tabbar_mine_s"];
    mineViewController.tabBarItem.title = @"我的";
    
    AMYMoreViewController *moreViewController = [[AMYMoreViewController alloc]init];
    moreViewController.tabBarItem.image = [UIImage imageNamed:@"tabbar_more_n"];
    moreViewController.tabBarItem.selectedImage = [UIImage imageNamed:@"tabbar_more_s"];
    moreViewController.tabBarItem.title = @"更多";
    
    tabarController.viewControllers = @[indexViewController,calendarViewController,mineViewController,moreViewController];
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
