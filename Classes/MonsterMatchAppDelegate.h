//
//  MonsterMatchAppDelegate.h
//  MonsterMatch
//
//  Created by Barrett Sonntag on 8/28/10.
//  Copyright MightyFunApps 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MonsterMatchAppDelegate : NSObject <UIApplicationDelegate> {
	UIWindow *window;
}

@property (nonatomic, retain) UIWindow *window;
@property NSInteger currentScore;
@property NSInteger remainingLives;
@property double timePosition;
@property (retain) NSString *currentGameType;
@property (retain) NSString *playingAs;
@property BOOL started;

+ (MonsterMatchAppDelegate *) get;

@end
