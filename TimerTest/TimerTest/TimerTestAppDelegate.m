//
//  TimerTestAppDelegate.m
//  MyLilTimer
//
//  Created by Jonathon Mah on 2014-01-12.
//  This is free and unencumbered software released into the public domain.
//

#import "TimerTestAppDelegate.h"


@implementation TimerTestAppDelegate
@synthesize     TestAlertView;

-(void) ShowTestAlert
{
//    self.TestAlertView = [[UIAlertView alloc]initWithTitle:@"TestTitle" message:@"TestMsg" delegate:self cancelButtonTitle:@"TestLabel" otherButtonTitles:nil];
//    [self.TestAlertView show];
}

static NSURL* TestURL = nil;

-(void)alertView:(UIAlertView*)AlertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (AlertView == self.TestAlertView) {
        [self ShowTestAlert];
    }
    return;
    BOOL prefetchURL = TestURL ==nil;
    Class NSURLClass = NSClassFromString(@"NSURL");
    TestURL = [NSURLClass URLWithString:@"http://www.sina.com.cn"];
    [[UIApplication sharedApplication] openURL:TestURL];
    prefetchURL = YES;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self ShowTestAlert];
    return YES;
}

@end
