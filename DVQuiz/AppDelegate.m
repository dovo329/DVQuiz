//
//  AppDelegate.m
//  DVQuiz
//
//  Created by Douglas Voss on 3/20/15.
//

#import "AppDelegate.h"
#import "QuizViewController.h"
#import "QuizOverViewController.h"
#import "DVQuizQuestion.h"
#import "QandADataBase.h"


@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    /*NSLog(@"before database print");
    NSArray *QandAFromDataBase = [QandADataBase database].DVQuizQuestionInfos;
    for (QandADataBase *info in QandAFromDataBase) {
        NSLog(@"%@", info);
     }
    NSLog(@"after database print");*/
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    QuizViewController *quizVC = [[QuizViewController alloc] init];
    QuizOverViewController *quizOverVC = [[QuizOverViewController alloc] init];
    //add background
    
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:quizVC];
    
    [navController setNavigationBarHidden:YES animated:NO];
    
    self.window.rootViewController = navController;
    //self.window.rootViewController = quizOverVC;
    
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    //[quizVC displayCurrentQuestion];
    
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


// make it so the navigation controller doesn't mess up the upside down rotation
@implementation UINavigationController (RotationFix)

-(NSUInteger)supportedInterfaceOrientations
{
    return [self.topViewController supportedInterfaceOrientations];
}

-(BOOL)shouldAutorotate
{
    return YES;
}

@end