//
//  AppDelegate.m
//  favorites
//
//  Created by Ava Crnkovic-Rubsamen on 7/12/21.
//

#import "AppDelegate.h"
#import <Parse/Parse.h>
#import <UserNotifications/UserNotifications.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    ParseClientConfiguration *config = [ParseClientConfiguration  configurationWithBlock:^(id<ParseMutableClientConfiguration> configuration) {

            configuration.applicationId = @"P3zMPtHKDCkWLlzj6XiiNEa0tY2qK8owfSJeJ5bK";
            configuration.clientKey = @"TfL43o3yhULVamas2xzlYZO4BRNRB7cOC330nEvm";
            configuration.server = @"https://parseapi.back4app.com";
        }];
        [Parse initializeWithConfiguration:config];
    //[self registerForRemoteNotifications];
        return YES;
}
- (void)registerForRemoteNotifications {
 UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
 [center requestAuthorizationWithOptions:(UNAuthorizationOptionSound | UNAuthorizationOptionAlert | UNAuthorizationOptionBadge |     UNAuthorizationOptionCarPlay) completionHandler:^(BOOL granted, NSError * _Nullable error){
     if(!error){
         dispatch_async(dispatch_get_main_queue(), ^{
             [[UIApplication sharedApplication] registerForRemoteNotifications];
         });
     }else{
         NSLog(@"%@",error.description);
     }
 }];
}
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
 // Store the deviceToken in the current Installation and save it to Parse
 PFInstallation *currentInstallation = [PFInstallation currentInstallation];
 [currentInstallation setDeviceTokenFromData:deviceToken];
 [currentInstallation setObject:@[@"News"] forKey:@"channels"];
 [currentInstallation setObject:PFUser.currentUser.objectId forKey:@"userId"];
 [currentInstallation saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
     if (!error) {
         NSLog(@"installation saved!!!");
     }else{
         NSLog(@"installation save failed %@",error.debugDescription);
     }
 }];
}


#pragma mark - UISceneSession lifecycle


- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options {
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
}


- (void)application:(UIApplication *)application didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions {
    // Called when the user discards a scene session.
    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
}


@end
