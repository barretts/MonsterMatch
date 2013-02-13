//
//  MonsterMatchAppDelegate.m
//  MonsterMatch
//
//  Created by Barrett Sonntag on 8/28/10.
//  Copyright MightyFunApps 2010. All rights reserved.
//

#import "MonsterMatchAppDelegate.h"
#import "cocos2d.h"
#import "GameScene.h"
#import "MenuScene.h"
#import "ResumeScene.h"
#import "SimpleAudioEngine.h"
//#import "MonsterPieceObject.h"

@implementation MonsterMatchAppDelegate

@synthesize window;
@synthesize currentGameType;
@synthesize currentScore;
@synthesize remainingLives;
@synthesize timePosition;
@synthesize playingAs;
@synthesize started;

- (void) applicationDidFinishLaunching:(UIApplication*)application
{
	// CC_DIRECTOR_INIT()
	//
	// 1. Initializes an EAGLView with 0-bit depth format, and RGB565 render buffer
	// 2. EAGLView multiple touches: disabled
	// 3. creates a UIWindow, and assign it to the "window" var (it must already be declared)
	// 4. Parents EAGLView to the newly created window
	// 5. Creates Display Link Director
	// 5a. If it fails, it will use an NSTimer director
	// 6. It will try to run at 60 FPS
	// 7. Display FPS: NO
	// 8. Device orientation: Portrait
	// 9. Connects the director to the EAGLView
	//
	CC_DIRECTOR_INIT();
	
	// Obtain the shared director in order to...
	//CCDirector *director = [CCDirector sharedDirector];
	
	//[director setAnimationInterval:1.0 / 30.0];
	
	// Sets landscape mode
	//[director setDeviceOrientation:kCCDeviceOrientationLandscapeLeft];
	
	// Turn on display FPS
	//[director setDisplayFPS:YES];
	
	// Turn on multiple touches
	//EAGLView *view = [director openGLView];
	//[view setMultipleTouchEnabled:YES];
	//[view pixelFormat:kRGBA8];
	
	// Default texture format for PNG/BMP/TIFF/JPEG/GIF images
	// It can be RGBA8888, RGBA4444, RGB5_A1, RGB565
	// You can change anytime.
	[CCTexture2D setDefaultAlphaPixelFormat:kTexture2DPixelFormat_RGBA8888];
	
	[[SimpleAudioEngine sharedEngine] preloadBackgroundMusic:@"backgroundMusic.mp3"];
	[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"icons.plist"];
	
	started = NO;
	
	if ([[NSUserDefaults standardUserDefaults] stringForKey:@"Timed-highScoreNameEntry0"] == nil) {
		NSLog(@"creating default score board");
		int i = 0, ii = 0;
		for (i = 9; i > -1; --i) {
			[[NSUserDefaults standardUserDefaults] setObject:@"Jack" forKey:[NSString stringWithFormat:@"Classic-highScoreNameEntry%d", i]];
			[[NSUserDefaults standardUserDefaults] setInteger:ii*10+10 forKey:[NSString stringWithFormat:@"Classic-highScoreEntry%d", i]];
			++ii;
		}
		
		ii = 0;
		for (i = 9; i > -1; --i) {
			[[NSUserDefaults standardUserDefaults] setObject:@"Jack" forKey:[NSString stringWithFormat:@"Timed-highScoreNameEntry%d", i]];
			[[NSUserDefaults standardUserDefaults] setInteger:ii*10+10 forKey:[NSString stringWithFormat:@"Timed-highScoreEntry%d", i]];
			++ii;
		}
	}/* else {
	  NSLog(@"resetting default score board");
	  int ii = 0;
	  for (int i = 9; i > -1; --i) {
	  [[NSUserDefaults standardUserDefaults] setObject:@"Jack" forKey:[NSString stringWithFormat:@"highScoreNameEntry%d", i]];
	  [[NSUserDefaults standardUserDefaults] setInteger:ii*10+10 forKey:[NSString stringWithFormat:@"highScoreEntry%d", i]];
	  ++ii;
	  }
	  }*/
	
	[[NSUserDefaults standardUserDefaults] synchronize];
	
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"resume"] == YES && [[NSUserDefaults standardUserDefaults] integerForKey:@"currentScore"] > 0)
	{
		[[CCDirector sharedDirector] runWithScene: [ResumeScene node]];
	} else {
		[[CCDirector sharedDirector] runWithScene: [MenuScene node]];
	}

}

+ (MonsterMatchAppDelegate *) get {
    return (MonsterMatchAppDelegate *) [[UIApplication sharedApplication] delegate];
}
/*
- (void) savePieceObjectWithKey :(MonsterPieceObject *)object :(NSString *)key
{ 
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSData *myEncodedObject = [NSKeyedArchiver archivedDataWithRootObject:object];
    [prefs setObject:myEncodedObject forKey:key];
}

- (MonsterPieceObject *) loadPieceObjectWithKey :(NSString *)key
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSData *myEncodedObject = [prefs objectForKey:key ];
    MonsterPieceObject *obj = (MonsterPieceObject *)[NSKeyedUnarchiver unarchiveObjectWithData: myEncodedObject];
    return obj;
}
*/

- (void)applicationWillResignActive:(UIApplication *)application {
	[[CCDirector sharedDirector] pause];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
	[[CCDirector sharedDirector] resume];
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
	[[CCDirector sharedDirector] purgeCachedData];
}

-(void) applicationDidEnterBackground:(UIApplication*)application {
	[[CCDirector sharedDirector] stopAnimation];
}

-(void) applicationWillEnterForeground:(UIApplication*)application {
	[[CCDirector sharedDirector] startAnimation];
}

- (void)applicationWillTerminate:(UIApplication *)application {
	NSLog(@"applicationWillTerminate!");
	[[CCDirector sharedDirector] end];
}

- (void)applicationSignificantTimeChange:(UIApplication *)application {
	[[CCDirector sharedDirector] setNextDeltaTimeZero:YES];
}

- (void)dealloc {
	[[CCDirector sharedDirector] release];
	[window release];
	[super dealloc];
}

@end
