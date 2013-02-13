//
//  HighScoreScene.m
//  MonsterMatch
//
//  Created by Barrett Sonntag on 9/26/10.
//  Copyright 2010 MightyFunApps. All rights reserved.
//

#import "HighScoreScene.h"
#import "MonsterMatchAppDelegate.h"
#import "MenuScene.h"

@implementation HighScoreScene

// on "init" you need to initialize your instance
- (id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super" return value
	self = [super init];
	if (self != nil) {
		[[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"resume"];
		gameType = [MonsterMatchAppDelegate get].currentGameType;
		
		[CCTexture2D setDefaultAlphaPixelFormat:kTexture2DPixelFormat_RGB565];
		CCSprite *backGraphic = [CCSprite spriteWithFile:@"highScoreScene.png"];
		backGraphic.position = CGPointMake(160.0f, 240.0f);
		[self addChild:backGraphic z:0];
		
		[CCTexture2D setDefaultAlphaPixelFormat:kTexture2DPixelFormat_RGBA8888];
		
		int i = -1, ii = -1, iii = -1;
		
		struct high_score_entry {
			NSString *name;
			int highScore;
		};
		
		struct high_score_entry structArray[10];
		
		for (i = 0; i < 10; i++) {
			if ([[NSUserDefaults standardUserDefaults] stringForKey:[NSString stringWithFormat:@"%@-highScoreNameEntry%d", gameType, i]] != nil && [[NSUserDefaults standardUserDefaults] stringForKey:[NSString stringWithFormat:@"%@-highScoreEntry%d", gameType, i]] != nil) {
				//NSLog(@"score board isn't nil");
				structArray[i].name = [[NSUserDefaults standardUserDefaults] stringForKey:[NSString stringWithFormat:@"%@-highScoreNameEntry%d", gameType, i]];
				structArray[i].highScore = [[NSUserDefaults standardUserDefaults] integerForKey:[NSString stringWithFormat:@"%@-highScoreEntry%d", gameType, i]];
				ii = i;
			}
		}
		
		if ([MonsterMatchAppDelegate get].currentScore > 0) {
			for (i = ii; i >= 0; i--) {
				if ([MonsterMatchAppDelegate get].currentScore > structArray[i].highScore) {
					if (i < 9) {
						structArray[i + 1] = structArray[i];
					}
					
					structArray[i].name = [MonsterMatchAppDelegate get].playingAs;
					structArray[i].highScore = [MonsterMatchAppDelegate get].currentScore;
					iii = i;
					
					if (i == ii && ii < 9) {
						iii = ii = i + 1;
					}
				}
				else if (i == ii && i < 9) {
					structArray[i + 1].name = [MonsterMatchAppDelegate get].playingAs;
					structArray[i + 1].highScore = [MonsterMatchAppDelegate get].currentScore;
					
					iii = ii = i + 1;
				}
			}
		}
		
		//NSLog(@"new high score at %d",iii);
		
		/*if (ii == -1 && [MonsterMatchAppDelegate get].currentScore > 0) {
		 structArray[0].name = [MonsterMatchAppDelegate get].playingAs;
		 structArray[0].highScore = [MonsterMatchAppDelegate get].currentScore;
		 ii = 0;
		 }*/
		
		for (i = 0; i <= ii; i++) {
			[[NSUserDefaults standardUserDefaults] setObject:structArray[i].name forKey:[NSString stringWithFormat:@"%@-highScoreNameEntry%d", gameType, i]];
			[[NSUserDefaults standardUserDefaults] setInteger:structArray[i].highScore forKey:[NSString stringWithFormat:@"%@-highScoreEntry%d", gameType, i]];
		}
		
		for (i = 9; i > -1; --i) {
			//hsLabels[i] = [CCBitmapFontAtlas bitmapFontAtlasWithString:[NSString stringWithFormat:@"%@ - %d", [[NSUserDefaults standardUserDefaults] stringForKey:[NSString stringWithFormat:@"highScoreNameEntry%d", i]], [[NSUserDefaults standardUserDefaults] integerForKey:[NSString stringWithFormat:@"highScoreEntry%d", i]]] fntFile:@"score.fnt"];
			hsLabels[i] = [CCBitmapFontAtlas bitmapFontAtlasWithString:[NSString stringWithFormat:@"%d", [[NSUserDefaults standardUserDefaults] integerForKey:[NSString stringWithFormat:@"%@-highScoreEntry%d", gameType, i]]] fntFile:@"score.fnt"];
			hsLabels[i].anchorPoint = ccp(1,1);
			hsLabels[i].position = CGPointMake(300.0f, 404.0f - (i * 31));
			if (i == iii) {
				hsLabels[i].color = ccRED;
			}
			[self addChild:hsLabels[i]];
			
			hsLabelsN[i] = [CCBitmapFontAtlas bitmapFontAtlasWithString:[NSString stringWithFormat:@"%@", [[NSUserDefaults standardUserDefaults] stringForKey:[NSString stringWithFormat:@"%@-highScoreNameEntry%d", gameType, i]]] fntFile:@"score.fnt"];
			hsLabelsN[i].anchorPoint = ccp(0,1);
			hsLabelsN[i].position = CGPointMake(16.0f, 404.0f - (i * 31));
			if (i == iii) {
				hsLabelsN[i].color = ccRED;
			}
			[self addChild:hsLabelsN[i]];
		}
		
		[[NSUserDefaults standardUserDefaults] synchronize];
		
		CCBitmapFontAtlas *boardName = [CCBitmapFontAtlas bitmapFontAtlasWithString:[NSString stringWithFormat:@"%@ mode High Scores", gameType] fntFile:@"score.fnt"];
		boardName.position = CGPointMake(160.0f, 30.0f);
		[self addChild:boardName];
		
		CCMenuItem *quitButton = [CCMenuItemImage itemFromNormalImage:@"menu.png" selectedImage:@"menu.png" target:self selector:@selector(verifyQuit:)];
		CCMenu *quitMenu = [CCMenu menuWithItems:quitButton, nil];
		quitMenu.position = CGPointMake(30.0f, 458.0f);
		[self addChild:quitMenu z:3];
	}
	
	return self;
}

- (void) onEnterTransitionDidFinish
{
	NSLog(@"game type was %@ and the final score was %d",[MonsterMatchAppDelegate get].currentGameType,[MonsterMatchAppDelegate get].currentScore);
}

- (void) verifyQuit :(id)sender
{
	[[CCDirector sharedDirector] replaceScene:[CCFadeTransition transitionWithDuration:1.0 scene:[MenuScene node]]];
}

// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
	// in case you have something to dealloc, do it in this method
	// in this particular example nothing needs to be released.
	// cocos2d will automatically release all the children (Label)
	
	// don't forget to call "super dealloc"
	[super dealloc];
}

@end
