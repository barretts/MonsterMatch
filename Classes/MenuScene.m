//
//  MenuScene.m
//  MonsterMatch
//
//  Created by Barrett Sonntag on 9/9/10.
//  Copyright 2010 MightyFunApps. All rights reserved.
//

#import "MenuScene.h"
#import "GameScene.h"
#import "MonsterMatchAppDelegate.h"
#import "HighScoreScene.h"
#import "InstructionsScene.h"
#import "SimpleAudioEngine.h"

@implementation MenuScene

- (id) init
{
	self = [super init];
	if (self != nil) {
		[[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"resume"];
		[CCTexture2D setDefaultAlphaPixelFormat:kTexture2DPixelFormat_RGB565];
		CCSprite *backGraphic = [CCSprite spriteWithFile:@"menuBackground.png"];
		backGraphic.position = CGPointMake(160.0f, 240.0f);
		[self addChild:backGraphic z:0];
		
		[CCTexture2D setDefaultAlphaPixelFormat:kTexture2DPixelFormat_RGBA8888];
		//CCLabel *label = [CCLabel labelWithString:@"hello world" fontName:@"HauntAOE.ttf" fontSize:24];
		//CCMenuItemLabel *start = [CCMenuItemLabel itemWithLabel:label target:self selector:@selector(start:)];
		CCBitmapFontAtlas *label1 = [CCBitmapFontAtlas bitmapFontAtlasWithString:@"Classic" fntFile:@"haunt.fnt"];
		CCMenuItemLabel *menuItem1 = [CCMenuItemLabel itemWithLabel:label1 target:self selector:@selector(goClassic:)];
		CCBitmapFontAtlas *label2 = [CCBitmapFontAtlas bitmapFontAtlasWithString:@"Timed" fntFile:@"haunt.fnt"];
		CCMenuItemLabel *menuItem2 = [CCMenuItemLabel itemWithLabel:label2 target:self selector:@selector(goTimed:)];
		CCBitmapFontAtlas *label3 = [CCBitmapFontAtlas bitmapFontAtlasWithString:@"Info" fntFile:@"haunt.fnt"];
		CCMenuItemLabel *menuItem3 = [CCMenuItemLabel itemWithLabel:label3 target:self selector:@selector(goInfo:)];
		
		//CCMenuItemLabel *menuItem4 = [CCMenuItemLabel itemWithLabel:label4 target:self selector:@selector(onPlay:)];
		
		//CCMenu *menu = [CCMenu menuWithItems:menuItem1, menuItem2, menuItem3, menuItem4, nil];
		CCMenu *menu = [CCMenu menuWithItems:menuItem1, menuItem2, menuItem3, nil];
		[menu alignItemsVerticallyWithPadding:0.0f];
		
		menu.position = CGPointMake(160.0f, 290.0f);
		
		[self addChild:menu];
		
		CCBitmapFontAtlas *label4 = [CCBitmapFontAtlas bitmapFontAtlasWithString:@"Playing As:" fntFile:@"haunt.fnt"];
		label4.position = CGPointMake(160.0f, 160.0f);
		
		[self addChild:label4];
		
		//UITextField *myText = [[UITextField alloc] initWithFrame:CGRectMake(60, 165, 200, 90)];
		playerNameTextField = [[UITextField alloc] initWithFrame:CGRectMake(100.0f, 350.0f, 120, 30)];
		[playerNameTextField setBorderStyle:UITextBorderStyleRoundedRect];
		[playerNameTextField setDelegate:self];
		[playerNameTextField setTextColor: [UIColor colorWithRed:0 green:0 blue:0 alpha:1.0]];
		playerNameTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
		playerNameTextField.textAlignment = UITextAlignmentCenter;
		
		CCBitmapFontAtlas *label5 = [CCBitmapFontAtlas bitmapFontAtlasWithString:@"Music:" fntFile:@"score.fnt"];
		label5.position = CGPointMake(185.0f, 22.0f);
		
		[self addChild:label5];
		
		musicState = [[UISwitch alloc] initWithFrame:CGRectMake(218.0f, 445.0f, 0, 0)];
		[musicState addTarget:self action:@selector(handleSliderChange:) forControlEvents:UIControlEventValueChanged];
	}
	
	if ([[NSUserDefaults standardUserDefaults] stringForKey:@"PlayingAs"] == nil) {
		[playerNameTextField setText:@"Your Name"];
		[[NSUserDefaults standardUserDefaults] setObject:playerNameTextField.text forKey:@"PlayingAs"];
		
		musicState.on = YES;
		[[NSUserDefaults standardUserDefaults] setBool:musicState.on forKey:@"MusicPlay"];
	} else {
		[playerNameTextField setText:[[NSUserDefaults standardUserDefaults] stringForKey:@"PlayingAs"]];
		musicState.on = (BOOL)[[NSUserDefaults standardUserDefaults] boolForKey:@"MusicPlay"];
	}

	[[NSUserDefaults standardUserDefaults] synchronize];
	
	return self;
}

- (void) onEnterTransitionDidFinish
{
	[[[[CCDirector sharedDirector] openGLView] window] addSubview:playerNameTextField];
	[[[[CCDirector sharedDirector] openGLView] window] addSubview:musicState];
	
	if(musicState.on && [MonsterMatchAppDelegate get].started == NO)
	{
		//[[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
		[[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"backgroundMusic.mp3"];
		[MonsterMatchAppDelegate get].started = YES;
	}
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [playerNameTextField resignFirstResponder];
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
	[playerNameTextField setFrame:CGRectMake(85.0f, 230.0f, 150, 30)];
	[playerNameTextField selectAll:self];
	[UIMenuController sharedMenuController].menuVisible = NO;

}

- (void)textFieldDidEndEditing: (UITextField *)textField 
{
	[[NSUserDefaults standardUserDefaults] setObject:playerNameTextField.text forKey:@"PlayingAs"];
	[[NSUserDefaults standardUserDefaults] synchronize];
	[playerNameTextField setFrame:CGRectMake(100.0f, 350.0f, 120, 30)];
	[playerNameTextField endEditing:YES];
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

- (void)goClassic:(id)sender
{
	NSLog(@"starting classic game");
	[MonsterMatchAppDelegate get].currentScore = 0;
	[MonsterMatchAppDelegate get].currentGameType = @"Classic";
	[MonsterMatchAppDelegate get].playingAs = playerNameTextField.text;
	[MonsterMatchAppDelegate get].remainingLives = 5;
	[playerNameTextField removeFromSuperview];
	[musicState removeFromSuperview];
	[[CCDirector sharedDirector] replaceScene:[CCFadeTransition transitionWithDuration:1.0 scene:[GameScene node]]];
}

- (void)goTimed:(id)sender
{
	NSLog(@"starting timed game");
	[MonsterMatchAppDelegate get].currentScore = 0;
	[MonsterMatchAppDelegate get].currentGameType = @"Timed";
	[MonsterMatchAppDelegate get].playingAs = playerNameTextField.text;
	[playerNameTextField removeFromSuperview];
	[musicState removeFromSuperview];
	[[CCDirector sharedDirector] replaceScene:[CCFadeTransition transitionWithDuration:1.0 scene:[GameScene node]]];
}

- (void)goInfo:(id)sender
{
	NSLog(@"showing instructions");
	[playerNameTextField removeFromSuperview];
	[musicState removeFromSuperview];
	[[CCDirector sharedDirector] replaceScene:[CCFadeTransition transitionWithDuration:1.0 scene:[InstructionsScene node]]];
	//[[CCDirector sharedDirector] replaceScene:[CCFadeTransition transitionWithDuration:1.0 scene:[HighScoreScene node]]];
}

// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
	// in case you have something to dealloc, do it in this method
	// in this particular example nothing needs to be released.
	// cocos2d will automatically release all the children (Label)
	
	// don't forget to call "super dealloc"
	[musicState release];
	[playerNameTextField release];
	[super dealloc];
}

@end
