//
//  ResumeScene.m
//  MonsterMatch
//
//  Created by Barrett Sonntag on 10/24/10.
//  Copyright 2010 Might Fun Apps. All rights reserved.
//

#import "ResumeScene.h"
#import "GameScene.h"
#import "MenuScene.h"
#import "MonsterMatchAppDelegate.h"
#import "SimpleAudioEngine.h"

@implementation ResumeScene

- (id) init
{
	self = [super init];
	if (self != nil) {
		[CCTexture2D setDefaultAlphaPixelFormat:kTexture2DPixelFormat_RGB565];
		CCSprite *backGraphic = [CCSprite spriteWithFile:@"menuBackground.png"];
		backGraphic.position = CGPointMake(160.0f, 240.0f);
		[self addChild:backGraphic z:0];
		
		[CCTexture2D setDefaultAlphaPixelFormat:kTexture2DPixelFormat_RGBA8888];
		//CCLabel *label = [CCLabel labelWithString:@"hello world" fontName:@"HauntAOE.ttf" fontSize:24];
		//CCMenuItemLabel *start = [CCMenuItemLabel itemWithLabel:label target:self selector:@selector(start:)];
		CCBitmapFontAtlas *label1 = [CCBitmapFontAtlas bitmapFontAtlasWithString:@"Resume Game" fntFile:@"haunt.fnt"];
		CCMenuItemLabel *menuItem1 = [CCMenuItemLabel itemWithLabel:label1 target:self selector:@selector(goResume:)];
		CCBitmapFontAtlas *label2 = [CCBitmapFontAtlas bitmapFontAtlasWithString:@"New game" fntFile:@"haunt.fnt"];
		CCMenuItemLabel *menuItem2 = [CCMenuItemLabel itemWithLabel:label2 target:self selector:@selector(goNew:)];
		
		CCBitmapFontAtlas *label4 = [CCBitmapFontAtlas bitmapFontAtlasWithString:[NSString stringWithFormat:@"%@ - %d",[[NSUserDefaults standardUserDefaults] stringForKey:@"gameType"],[[NSUserDefaults standardUserDefaults] integerForKey:@"currentScore"]] fntFile:@"score.fnt"];
		label4.position = CGPointMake(160.0f, 300.0f);
		[self addChild:label4];
		
		CCBitmapFontAtlas *label5 = [CCBitmapFontAtlas bitmapFontAtlasWithString:@"Music:" fntFile:@"score.fnt"];
		label5.position = CGPointMake(185.0f, 22.0f);
		[self addChild:label5];
		
		NSLog(@"resume game type: %@",[[NSUserDefaults standardUserDefaults] stringForKey:@"gameType"]);
		NSLog(@"resume game lives: %d",[[NSUserDefaults standardUserDefaults] integerForKey:@"remainingLives"]);
		NSLog(@"resume game time: %d",[[NSUserDefaults standardUserDefaults] integerForKey:@"timePosition"]);
		NSLog(@"resume game score: %d",[[NSUserDefaults standardUserDefaults] integerForKey:@"currentScore"]);
		
		//CCMenuItemLabel *menuItem4 = [CCMenuItemLabel itemWithLabel:label4 target:self selector:@selector(onPlay:)];
		
		//CCMenu *menu = [CCMenu menuWithItems:menuItem1, menuItem2, menuItem3, menuItem4, nil];
		CCMenu *menu = [CCMenu menuWithItems:menuItem1, menuItem2, nil];
		[menu alignItemsVerticallyWithPadding:0.0f];
		
		menu.position = CGPointMake(160.0f, 230.0f);
		
		[self addChild:menu];
		
		musicState = [[UISwitch alloc] initWithFrame:CGRectMake(218.0f, 445.0f, 0, 0)];
		[musicState addTarget:self action:@selector(handleSliderChange:) forControlEvents:UIControlEventValueChanged];
		musicState.on = (BOOL)[[NSUserDefaults standardUserDefaults] boolForKey:@"MusicPlay"];
	}
	
	return self;
}

- (void) onEnterTransitionDidFinish
{
	[[[[CCDirector sharedDirector] openGLView] window] addSubview:musicState];
	
	if(musicState.on && [MonsterMatchAppDelegate get].started == NO)
	{
		//[[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
		[[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"backgroundMusic.mp3"];
		[MonsterMatchAppDelegate get].started = YES;
	}
}

- (void)goResume:(id)sender
{
	[musicState removeFromSuperview];
	NSLog(@"resuming game");
	[MonsterMatchAppDelegate get].remainingLives = [[NSUserDefaults standardUserDefaults] integerForKey:@"remainingLives"];
	[MonsterMatchAppDelegate get].currentScore = [[NSUserDefaults standardUserDefaults] integerForKey:@"currentScore"];
	[MonsterMatchAppDelegate get].currentGameType = [[NSUserDefaults standardUserDefaults] stringForKey:@"gameType"];
	NSLog(@"goResume game type: %@",[MonsterMatchAppDelegate get].currentGameType);
	[MonsterMatchAppDelegate get].playingAs = [[NSUserDefaults standardUserDefaults] stringForKey:@"PlayingAs"];
	[[CCDirector sharedDirector] replaceScene:[CCFadeTransition transitionWithDuration:1.0 scene:[GameScene node]]];
}

- (void)goNew:(id)sender
{
	NSLog(@"starting new game");
	UIAlertView* dialog = [[UIAlertView alloc] init];
	[dialog setDelegate:self];
	[dialog setTitle:@"New Game"];
	[dialog setMessage:@"Your current saved game progress will be lost if you start a new game. Are you sure you want to start a new game?"];
	[dialog addButtonWithTitle:@"Yes"];
	[dialog addButtonWithTitle:@"No"];
	[dialog show];
	[dialog release];
}

- (void) alertView :(UIAlertView *)alert clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (buttonIndex==0) {
		[musicState removeFromSuperview];
		[[CCDirector sharedDirector] replaceScene:[CCFadeTransition transitionWithDuration:1.0 scene:[MenuScene node]]];
	}
}

-(IBAction)handleSliderChange:(id)sender
{
	NSLog(@"music = %@", (musicState.on ? @"YES" : @"NO"));
	if(musicState.on)
	{
		[[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"backgroundMusic.mp3"];
	} else {
		[[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
	}
	
	[[NSUserDefaults standardUserDefaults] setBool:musicState.on forKey:@"MusicPlay"];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

@end
