//
//  AppDelegate.m
//  ModernWallet
//
//  Created by Георгий Малюков on 08.12.15.
//  Copyright © 2015 Lykkex. All rights reserved.
//

#import "AppDelegate.h"
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#import <Google/Analytics.h>

#import "ABPadLockScreen.h"
#import "LWConstants.h"
#import "UIColor+Generic.h"
#import "UIView+Toast.h"
#import "LWKeychainManager.h"
#import <WindowsAzureMessaging/WindowsAzureMessaging.h>
#import "LWPrivateKeyManager.h"
#import "LWTransactionManager.h"
#import "LWURLProtocol.h"
#import "LWUtils.h"
#import "LWAuthManager.h"
#import "LWKYCDocumentsModel.h"
#import "LWOffchainTransactionsManager.h"
#import "LWLocalizationManager.h"
#import "LWMarginalWalletsDataManager.h"
#import "ModernWallet-Swift.h"
#import "AFNetworking.h"


@import PushKit;



@interface AppDelegate () <PKPushRegistryDelegate>{
    NSData *notificationToken;
}


#pragma mark - Private

- (void)customizePINScreen;
- (void)customizeNavigationBar;
@end


@implementation AppDelegate


#pragma mark - Lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // Configure tracker from GoogleService-Info.plist.
    NSError *configureError;
    [[GGLContext sharedInstance] configureWithError:&configureError];
    NSAssert(!configureError, @"Error configuring Google services: %@", configureError);
    
    // Optional: configure GAI options.
    GAI *gai = [GAI sharedInstance];
    gai.trackUncaughtExceptions = YES;  // report uncaught exceptions
    gai.logger.logLevel = kGAILogLevelVerbose;  // remove before app release
    gai.dispatchInterval = 20;
    
    
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    [self subsctibeForNotAuthorized];
    
    if([UIDevice currentDevice].userInterfaceIdiom==UIUserInterfaceIdiomPhone)
        application.statusBarOrientation = UIInterfaceOrientationPortrait;
    //Clear keychain on first run in case of reinstallation
    BOOL success=[NSURLProtocol registerClass:[LWURLProtocol class]];
    
//    NSString *build = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleVersionKey];  //Anton Belkin aksed to remove logout after update
//
//
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"FirstRun"]) {
        // Delete values from keychain here
        
        [[LWKeychainManager instance] clear];
        [[NSUserDefaults standardUserDefaults] setValue:@"1strun" forKey:@"FirstRun"];
//        [[NSUserDefaults standardUserDefaults] setObject:build forKey:@"LWLastLaunchedVersion"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    

    [Fabric with:@[CrashlyticsKit]];
    
    
    [[LWLocalizationManager shared] downloadLocalization];
    

    [self customizePINScreen];
    [self customizeNavigationBar];
    
    [CSToastManager setQueueEnabled:NO];

    // init main controller
//    self.mainController = [LWAuthNavigationController new]; //rely on storyboard for initial view controller
    self.mainController = self.window.rootViewController; //assign initial view controller from story board to mainController in case it's used somewhere
    
    
    self.window.backgroundColor = [UIColor whiteColor];
//    self.window.rootViewController = self.mainController;
    
    [self.window makeKeyAndVisible];
    
    
    UIUserNotificationType types = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
    UIUserNotificationSettings *mySettings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
    [[UIApplication sharedApplication] registerUserNotificationSettings:mySettings];
    
//     Register for remote notifications.
    [[UIApplication sharedApplication] registerForRemoteNotifications];

    NSDictionary *apnsBody = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    if (apnsBody) {
//        [[LWTransactionManager shared] checkForPendingActions];
    }
    [self subscribeForPendingOffchainRequests];
    
    [[LWAuthManager instance] requestAPIVersion];
    [[LWAuthManager instance] requestSwiftCredentials];
    
    PKPushRegistry *pushRegistry = [[PKPushRegistry alloc] initWithQueue:dispatch_get_main_queue()];
    pushRegistry.delegate = self;
    pushRegistry.desiredPushTypes = [NSSet setWithObject:PKPushTypeVoIP];
    
    return YES;
}


// Handle remote notification registration.
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *) deviceToken {
    
//    NSData *data=deviceToken;
//    NSUInteger capacity = data.length * 2;
//    NSMutableString *sbuf = [NSMutableString stringWithCapacity:capacity];
//    const unsigned char *buf = data.bytes;
//    NSInteger i;
//    for (i=0; i<data.length; ++i) {
//        [sbuf appendFormat:@"%02X", (NSUInteger)buf[i]];
//    }
//    
//    UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Token" message:sbuf delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
//    [alert show];

    notificationToken=deviceToken;
    
//    NSString *notif = [LWKeychainManager instance].notificationsTag;
    
    if([LWKeychainManager instance].notificationsTag)
        [self registerForNotificationsInAzureWithTag:[LWKeychainManager instance].notificationsTag];
 }

-(void) registerForNotificationsInAzureWithTag:(NSString *) tag
{
    NSString *HUBLISTENACCESS;//=@"Endpoint=sb://lykke-dev.servicebus.windows.net/;SharedAccessKeyName=DefaultListenSharedAccessSignature;SharedAccessKey=KLvwXsxLPxY2dCgXChIp/QD5/Kg00+tgruhFom59098=";
    NSString *HUBNAME;//=@"lykke-notifications-dev";
    
    if([[LWKeychainManager instance].address isEqualToString:kProductionServer] || [[LWKeychainManager instance].address isEqualToString:kStagingTestServer])
    {
        HUBLISTENACCESS=@"Endpoint=sb://lykkewallet.servicebus.windows.net/;SharedAccessKeyName=DefaultListenSharedAccessSignature;SharedAccessKey=XwEA5pk9uDLkZXgnZF5sdDrZYEx5eoaE7LFlLoy+wh4=";
        HUBNAME=@"lykke-notifications";
    }
    else
    {
        HUBLISTENACCESS=@"Endpoint=sb://lykke-dev.servicebus.windows.net/;SharedAccessKeyName=DefaultListenSharedAccessSignature;SharedAccessKey=KLvwXsxLPxY2dCgXChIp/QD5/Kg00+tgruhFom59098=";
        HUBNAME=@"lykke-notifications-dev";

    }
    
//    NSString *notif = [LWKeychainManager instance].notificationsTag;

    
    dispatch_async(dispatch_get_main_queue(), ^{
    
    SBNotificationHub* hub = [[SBNotificationHub alloc] initWithConnectionString:HUBLISTENACCESS
                                                             notificationHubPath:HUBNAME];
    
    [hub registerNativeWithDeviceToken:notificationToken tags:[NSSet setWithObject:tag] completion:^(NSError* error) {
        if (error != nil) {
            NSLog(@"Error registering for notifications: %@", error);
            if(([[LWKeychainManager instance].address isEqualToString:kProductionServer] || [[LWKeychainManager instance].address isEqualToString:kStagingTestServer])==NO)
            {
//                UIAlertView *alert=[[UIAlertView alloc] initWithTitle:nil message:@"Error registering for notifications" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
//                [alert show];
            }

        }
        else {
            NSLog(@"Registered for notifications");
        }
    }];
});
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification: (NSDictionary *)userInfo {
    NSLog(@"%@", userInfo);
    int type=[userInfo[@"aps"][@"type"] intValue];
    
    if(type==8)
    {
        [[LWAuthManager instance] requestPendingTransactions];
        return;
    }
    if(type == 12) {
//        [self subscribeForPendingOffchainRequests];
//        [[LWTransactionManager shared] checkForPendingActions];
        return;
    }
    
    UIApplicationState state = [application applicationState];
}

- (void)application:(UIApplication *)app
didFailToRegisterForRemoteNotificationsWithError:(NSError *)err {
    NSLog(@"Error in registration. Error: %@", err);
    UIAlertView *alert=[[UIAlertView alloc] initWithTitle:nil message:@"Error getting notifications token" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alert show];

}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    
    UIApplication *app = [UIApplication sharedApplication];
    UIBackgroundTaskIdentifier bgTask;
    bgTask = [app beginBackgroundTaskWithExpirationHandler:^{
 //       [app endBackgroundTask:bgTask];
    }];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(30 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self waitForImageToUpload:bgTask];
    });

}
                   
-(void) waitForImageToUpload:(UIBackgroundTaskIdentifier) taskId
{
    if([[LWKYCDocumentsModel shared] isUploadingImage])
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self waitForImageToUpload:taskId];
        });
    else
        [[UIApplication sharedApplication] endBackgroundTask:taskId];


}


-(void) application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    if([LWKeychainManager instance].isAuthenticated == NO) {
        completionHandler(UIBackgroundFetchResultNoData);
        return;
    }
    
    int type=[userInfo[@"aps"][@"type"] intValue];
    

    if(type==8)
    {
        [LWPrivateKeyManager shared].backgroudFetchCompletionHandler=completionHandler;
        [[LWAuthManager instance] requestPendingTransactions];
        return;
    }
    
    if(type == 12) {
        [LWTransactionManager shared].backgroudFetchCompletionHandler = completionHandler;
 
        return;
    }

    UIApplicationState state = [application applicationState];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ApplicationDidBecomeActiveNotification" object:nil];

}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


#pragma mark - Private

- (void)customizePINScreen {
    [[ABPadLockScreenView appearance] setViewColor:[UIColor whiteColor]];
    [[ABPadLockScreenView appearance] setLabelColor:[UIColor blackColor]];
    [[ABPadButton appearance] setBackgroundColor:[UIColor clearColor]];
    [[ABPadButton appearance] setBorderColor:[UIColor colorWithHexString:kABPadBorderColor]];
    [[ABPadButton appearance] setSelectedColor:[UIColor lightGrayColor]];
    [[ABPadButton appearance] setTextColor:[UIColor blackColor]];
    [[ABPinSelectionView appearance] setSelectedColor:[UIColor colorWithHexString:kABPadSelectedColor]];
}

- (void)customizeNavigationBar {
 //   UIFont *font = [UIFont fontWithName:kNavigationBarFontName size:kNavigationBarFontSize];
    UIFont *font = [UIFont fontWithName:@"ProximaNova-Semibold" size:17.0];
    
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                [UIColor colorWithHexString:kNavigationBarFontColor], NSForegroundColorAttributeName,
                                font, NSFontAttributeName,
                                nil];
    
    [[UINavigationBar appearance] setTitleTextAttributes:attributes];
    [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithHexString:kNavigationTintColor]];
    
    [[UINavigationBar appearance] setTintColor:
     [UIColor colorWithHexString:kNavigationBarTintColor]];
    [[UINavigationBar appearance] setShadowImage:[[UIImage alloc] init]];
    [[UINavigationBar appearance] setBackgroundImage:[[UIImage alloc] init]
                                       forBarMetrics:UIBarMetricsDefault];
    
    

    
    
    
}

- (void)pushRegistry:(PKPushRegistry *)registry didUpdatePushCredentials:(PKPushCredentials *)credentials forType:(NSString *)type{
    if([credentials.token length] == 0) {
        NSLog(@"voip token NULL");
        return;
    }
    
    NSLog(@"PushCredentials: %@", credentials.token);
}

- (void)pushRegistry:(PKPushRegistry *)registry didReceiveIncomingPushWithPayload:(PKPushPayload *)payload forType:(NSString *)type
{
    
}

@end
