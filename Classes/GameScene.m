//
//  HelloWorldLayer.m
//  MonsterMatch
//
//  Created by Barrett Sonntag on 8/28/10.
//  Copyright MightyFunApps 2010. All rights reserved.
//

// Import the interfaces
#import "GameScene.h"
#import "GameBoard.h"
#import "MenuScene.h"
#import "ResumeScene.h"
#import "HighScoreScene.h"
#import "MonsterMatchAppDelegate.h"

// HelloWorld implementation
@implementation GameScene

+(id) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	GameScene *layer = [GameScene node];
	
	// add layer as a child to scene
	[scene addChild:layer];
	
	// return the scene
	return scene;
}

// on "init" you need to initialize your instance
- (id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super" return value
	if( (self=[super init] ))
	{
		quit = NO;
		
		[CCTexture2D setDefaultAlphaPixelFormat:kTexture2DPixelFormat_RGB565];
		CCSprite *backGraphic = [CCSprite spriteWithFile:@"gameSceneBottom.png"];
		backGraphic.position = CGPointMake(160.0f, 240.0f);
		[self addChild:backGraphic z:0];
		
		[CCTexture2D setDefaultAlphaPixelFormat:kTexture2DPixelFormat_RGBA8888];
		CCSprite *topGraphic = [CCSprite spriteWithFile:@"gameSceneTop.png"];
		topGraphic.position = CGPointMake(160.0f, 240.0f);
		[self addChild:topGraphic z:2];
		
		CCMenuItem *quitButton = [CCMenuItemImage itemFromNormalImage:@"quit.png" selectedImage:@"quit.png" target:self selector:@selector(verifyQuit:)];
		CCMenu *quitMenu = [CCMenu menuWithItems:quitButton, nil];
		quitMenu.position = CGPointMake(30.0f, 458.0f);
		[self addChild:quitMenu z:3];
		
		CCMenuItem *pauseButton = [CCMenuItemImage itemFromNormalImage:@"pause.png" selectedImage:@"pause.png" target:self selector:@selector(verifyPause:)];
		CCMenu *pauseMenu = [CCMenu menuWithItems:pauseButton, nil];
		pauseMenu.position = CGPointMake(85.0f, 458.0f);
		[self addChild:pauseMenu z:3];
		
		scoreDisplay = [CCBitmapFontAtlas bitmapFontAtlasWithString:@"0" fntFile:@"score.fnt"];
		scoreDisplay.anchorPoint = ccp(1.0f,1.0f);
		scoreDisplay.position = CGPointMake(310.0f, 478.0f);
		[self addChild:scoreDisplay z:4];
		[scoreDisplay setString:[NSString stringWithFormat:@"%d",[MonsterMatchAppDelegate get].currentScore]];
		
		gameType = [MonsterMatchAppDelegate get].currentGameType;
		
		if ([gameType isEqualToString:@"Timed"]) {
			CCSprite *fillOverlay = [CCSprite spriteWithFile:@"fillBarOverlay.png"];
			fillOverlay.position = CGPointMake(160.0f, 38.5f);
			[self addChild:fillOverlay z:6];
			
			fillBar = [CCSprite spriteWithFile:@"fillBar.png"];
			fillBar.position = CGPointMake(160.0f, 38.5f);
			[self addChild:fillBar z:5];
		} else {
			for (int i = 0; i < 5; ++i) {
				owlLives[i] = [CCSprite spriteWithSpriteFrameName:@"owl.png"];
				owlLives[i].position = CGPointMake(28 + i * 50, 40.0f);
				[self addChild:owlLives[i] z:7+i];
			}
			
			[self toggleOwls];
		}

	}
	
	currentLevel = 0;
	levelBase = 50;
	lastLevel = 0;
	levelMultiplier = 1.5;
	fillWidth = 281;
	perPoint = (double) fillWidth / levelBase;
	perInterval = (double) fillWidth / (60 * 5);
	previousScore = 0;
	
	NSLog(@"%f", perPoint);
	
	[[NSNotificationCenter defaultCenter]
	 addObserver:self
	 selector:@selector(endGameMenu:)
	 name:@"endGame"
	 object:nil ];
	
	[[NSNotificationCenter defaultCenter]
	 addObserver:self
	 selector:@selector(updateScore:)
	 name:@"updateScore"
	 object:nil ];
	
	[[NSNotificationCenter defaultCenter]
	 addObserver:self
	 selector:@selector(updateFillPosition:)
	 name:@"updateFillPosition"
	 object:nil ];
	
	[[NSNotificationCenter defaultCenter]
	 addObserver:self
	 selector:@selector(endLife:)
	 name:@"endLife"
	 object:nil ];
	
	return self;
}

- (void) endGameMenu :(NSNotification *) notification
{
	[[CCDirector sharedDirector] replaceScene:[CCFadeTransition transitionWithDuration:1.0 scene:[HighScoreScene node]]];
}

- (void) verifyQuit :(id)sender
{
	quit = YES;
	[[CCDirector sharedDirector] stopAnimation];
	if ([gameType isEqualToString:@"Timed"]) {
		[self unschedule:@selector(timedUpdate:)];
	}
	
	UIAlertView* dialog = [[UIAlertView alloc] init];
	[dialog setDelegate:self];
	[dialog setTitle:@"Quit Game"];
	[dialog setMessage:@"Your current game progress will be lost if you quit. Are you sure you want to quit?"];
	[dialog addButtonWithTitle:@"Yes"];
	[dialog addButtonWithTitle:@"No"];
	[dialog show];
	[dialog release];
}

- (void) verifyPause :(id)sender
{
	quit = NO;
	[[CCDirector sharedDirector] stopAnimation];
	if ([gameType isEqualToString:@"Timed"]) {
		[self unschedule:@selector(timedUpdate:)];
	}
	
	UIAlertView* dialog = [[UIAlertView alloc] init];
	[dialog setDelegate:self];
	[dialog setTitle:@"Pause Game"];
	[dialog setMessage:@"Your current game progress will be saved and you can resume your game later. Are you sure you want to pause?"];
	[dialog addButtonWithTitle:@"Yes"];
	[dialog addButtonWithTitle:@"No"];
	[dialog show];
	[dialog release];
}

- (void) alertView :(UIAlertView *)alert clickedButtonAtIndex:(NSInteger)buttonIndex
{
	[[CCDirector sharedDirector] startAnimation];
	if (quit == YES) {
		if (buttonIndex==0) {
			[[CCDirector sharedDirector] replaceScene:[CCFadeTransition transitionWithDuration:1.0 scene:[MenuScene node]]];
		} else {
			quit = NO;
			if ([gameType isEqualToString:@"Timed"]) {
				[self schedule:@selector(timedUpdate:)];
			}
		}
	} else {
		if (buttonIndex==0) {
			[[CCDirector sharedDirector] replaceScene:[CCFadeTransition transitionWithDuration:1.0 scene:[ResumeScene node]]];
		} else {
			quit = NO;
			if ([gameType isEqualToString:@"Timed"]) {
				[self schedule:@selector(timedUpdate:)];
			}
		}
	}

}

- (void) goMain :(id)sender
{
	[self unschedule:@selector(timedUpdate:)];
	
	NSLog(@"on play");
	//[[CCDirector sharedDirector] replaceScene:[HelloWorld node]];
	[[CCDirector sharedDirector] replaceScene:[CCFadeTransition transitionWithDuration:1.0 scene:[MenuScene node]]];
}

- (void) onEnterTransitionDidFinish
{
	GameBoard *gameBoard = [GameBoard node];
	gameBoard.position = CGPointMake(28.0f, 113.0f);
	[self addChild:gameBoard z:1];
	
	NSLog(@"GameScene gametype: %@",gameType);
	
	if ([gameType isEqualToString:@"Classic"]) {
		NSLog(@"CLASSIC gooooo");
	} else {
		NSLog(@"timed gooooo");
		[self schedule:@selector(timedUpdate:)];
	}
}

- (void) updateScore :(NSNotification *) notification
{
	//[MonsterMatchAppDelegate get].currentScore += score;
	[scoreDisplay setString:[NSString stringWithFormat:@"%d",[MonsterMatchAppDelegate get].currentScore]];
	/*
	if (gameType != @"Timed") {
		[self fillUpdate];
	}*/
	
	if ([MonsterMatchAppDelegate get].currentScore >= 1000 * currentLevel + 1000) {
		NSLog(@"new life!"); 
		++currentLevel;
		if ([MonsterMatchAppDelegate get].remainingLives < 5) {
			[MonsterMatchAppDelegate get].remainingLives = [MonsterMatchAppDelegate get].remainingLives + 1;
			[self toggleOwls];
		}
	}
}

- (void) endLife :(NSNotification *) notification
{
	[MonsterMatchAppDelegate get].remainingLives = [MonsterMatchAppDelegate get].remainingLives - 1;
	[self toggleOwls];
}

- (void) toggleOwls
{
	NSLog(@"toggleOwls remainingLives:%d",[MonsterMatchAppDelegate get].remainingLives);
	NSInteger totalLives = [MonsterMatchAppDelegate get].remainingLives - 1;
	
	NSInteger targetOwl = totalLives;
	
	while (targetOwl < 5) {
		[owlLives[targetOwl] setOpacity:100];
		++targetOwl;
	}
	
	targetOwl = totalLives;
	
	while (targetOwl > -1) {
		[owlLives[targetOwl] setOpacity:255];
		--targetOwl;
	}  
}

- (void) fillUpdate
{
	NSLog(@"perPoint %f",perPoint);
	NSLog(@"currentScore %d",[MonsterMatchAppDelegate get].currentScore);
	NSLog(@"fillUpdate %f",perPoint * [MonsterMatchAppDelegate get].currentScore);
	/*
	if (gameType == @"Timed") {
		fillBar.position = CGPointMake(fillBar.position.x + perPoint * ([MonsterMatchAppDelegate get].currentScore - previousScore), fillBar.position.y);
		previousScore = [MonsterMatchAppDelegate get].currentScore;
	} else {
		fillBar.position = CGPointMake(-121 + perPoint * [MonsterMatchAppDelegate get].currentScore, fillBar.position.y);
	}
	*/
	
	NSLog(@"fillUpdate: %f",([MonsterMatchAppDelegate get].currentScore - lastLevel));
	NSLog(@"fullFille: %f",-121 + perPoint * ([MonsterMatchAppDelegate get].currentScore - lastLevel));
	
	fillBar.position = CGPointMake(-121 + perPoint * ([MonsterMatchAppDelegate get].currentScore - lastLevel), fillBar.position.y);
	
	if(fillBar.position.x >= 160)
	{
		fillBar.position = CGPointMake(-121, fillBar.position.y);
		
		lastLevel = levelBase;
		levelBase = (double) levelBase * levelMultiplier;
		++currentLevel;
		//perPoint = (double) fillWidth / levelBase;
		
		NSLog(@"lastLevel: %f",lastLevel);
		NSLog(@"levelBase: %f",levelBase);
		
		[[NSNotificationCenter defaultCenter]
		 postNotificationName:@"goFresh"
		 object:nil ];
	}
}

-(void) timedUpdate:(ccTime) dt
{
	//NSLog(@"%f",dt);
	if(fillBar.position.x > -121)
	{
		fillBar.position = CGPointMake((double) fillBar.position.x - perInterval * dt, fillBar.position.y);
		[MonsterMatchAppDelegate get].timePosition = fillBar.position.x;
		[[NSUserDefaults standardUserDefaults] setDouble:[MonsterMatchAppDelegate get].timePosition forKey:@"timePosition"];
	} else {
		[self unschedule:@selector(timedUpdate:)];
		
		[[NSNotificationCenter defaultCenter]
		 postNotificationName:@"goExplode"
		 object:nil ];
	}
}

- (void) updateFillPosition:(NSNotification *)notification;
{
	fillBar.position = CGPointMake([MonsterMatchAppDelegate get].timePosition, fillBar.position.y);
}

// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
	// in case you have something to dealloc, do it in this method
	// in this particular example nothing needs to be released.
	// cocos2d will automatically release all the children (Label)
	
	[self unschedule:@selector(timedUpdate:)];
	
	[self unschedule:@selector(tick:)];
	
	[[NSNotificationCenter defaultCenter]
	 removeObserver:self
	 name:@"fillUpdate"
	 object:nil ];
	
	[[NSNotificationCenter defaultCenter]
	 removeObserver:self
	 name:@"updateFillPosition"
	 object:nil ];
	
	[[NSNotificationCenter defaultCenter]
	 removeObserver:self
	 name:@"endGame"
	 object:nil ];
	
	[[NSNotificationCenter defaultCenter]
	 removeObserver:self
	 name:@"updateScore"
	 object:nil ];
	
	[[NSNotificationCenter defaultCenter]
	 removeObserver:self
	 name:@"endLife"
	 object:nil ];
	
	// don't forget to call "super dealloc"
	[super dealloc];
}
@end
