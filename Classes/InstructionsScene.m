//
//  InstructionsScene.m
//  MonsterMatch
//
//  Created by Barrett Sonntag on 10/5/10.
//  Copyright 2010 Might Fun Apps. All rights reserved.
//

#import "InstructionsScene.h"
#import "MenuScene.h"

@implementation InstructionsScene
// on "init" you need to initialize your instance
- (id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super" return value
	self = [super init];
	if (self != nil) {
		[CCTexture2D setDefaultAlphaPixelFormat:kTexture2DPixelFormat_RGB565];
		CCSprite *backGraphic = [CCSprite spriteWithFile:@"instructions.png"];
		backGraphic.position = CGPointMake(160.0f, 240.0f);
		[self addChild:backGraphic z:0];
		
		[CCTexture2D setDefaultAlphaPixelFormat:kTexture2DPixelFormat_RGBA8888];
		CCMenuItem *quitButton = [CCMenuItemImage itemFromNormalImage:@"menu.png" selectedImage:@"menu.png" target:self selector:@selector(verifyQuit:)];
		CCMenu *quitMenu = [CCMenu menuWithItems:quitButton, nil];
		quitMenu.position = CGPointMake(30.0f, 458.0f);
		[self addChild:quitMenu z:3];
	}
	
	return self;
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
