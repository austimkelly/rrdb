//
//  RockAndRollBirthdaysAppDelegate.m
//  RockAndRollBirthdays
//
//The MIT License (MIT)
//
//Copyright (c) <2011-2014> <Fizzy Artwerks>
//
//Permission is hereby granted, free of charge, to any person obtaining a copy
//of this software and associated documentation files (the "Software"), to deal
//in the Software without restriction, including without limitation the rights
//to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//copies of the Software, and to permit persons to whom the Software is
//furnished to do so, subject to the following conditions:
//
//The above copyright notice and this permission notice shall be included in
//all copies or substantial portions of the Software.
//
//THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//THE SOFTWARE.
//

#import "RockAndRollBirthdaysAppDelegate.h"

@interface  RockAndRollBirthdaysAppDelegate()

- (void) createAndCheckDatabase;
- (void) animateSplashScreen;

@property (strong, nonatomic) NSString *dbPath;
@property (strong, nonatomic) UIImageView *splashView;
@end


@implementation RockAndRollBirthdaysAppDelegate



@synthesize window = _window;
@synthesize dbPath = _dbPath;
@synthesize splashView = _splashView;

#define DB_NAME @"persistentStore"
#define DB_RESOURCE_NAME @"rrdb"
#define DB_PACKAGE @"rrdb.sqlite/StoreContent"

- (NSString *)documentsDir
{
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return [documentPaths lastObject];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    
    NSString *documentDir = self.documentsDir;
    
    self.dbPath = [[documentDir stringByAppendingPathComponent:DB_PACKAGE] stringByAppendingPathComponent:DB_NAME];
    
    [self createAndCheckDatabase];
    
    [self animateSplashScreen];
       
    return YES;
}
	

- (void) createAndCheckDatabase {
    BOOL success; 
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    success = [fileManager fileExistsAtPath:self.dbPath];
    if (success) {
        return;
    }
    
    NSString *databasePathFromApp = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:DB_RESOURCE_NAME];
    
    NSError *error;
    NSString *folder = [self.documentsDir stringByAppendingPathComponent:DB_PACKAGE];
    [fileManager createDirectoryAtPath:folder withIntermediateDirectories:YES attributes:nil error:&error];
    [fileManager copyItemAtPath:databasePathFromApp toPath:self.dbPath error:&error];
    if (error) {
        NSLog(@"Error copying file=%@", error);
    }
    
}

// Put the splash screen image over the default view and then shrink and fade it out
- (void)animateSplashScreen{
    self.splashView = [[UIImageView alloc] initWithFrame:CGRectMake(0,0, 320, 480)];
    self.splashView.image = [UIImage imageNamed:@"Default.png"];
    [self.window.rootViewController.view addSubview:self.splashView];
    [self.window bringSubviewToFront:self.splashView];
    [UIView animateWithDuration:2 
                     animations:^{
                         // make splash screen transparent
                         self.splashView.alpha = 0.5;
                         // shrink down splash screen to the center
                         self.splashView.frame = CGRectMake(self.splashView.frame.size.width/2, self.splashView.frame.size.height/2, 0, 0);
                     }
                     completion:^(BOOL finished) {
                         [self.splashView removeFromSuperview];
                     }];
    
    

}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}



@end
