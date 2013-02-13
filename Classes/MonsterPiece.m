//
//  MonsterPiece.m
//  MonsterMatch
//
//  Created by Barrett Sonntag on 8/28/10.
//  Copyright 2010 MightyFunApps. All rights reserved.
//

#import "MonsterPiece.h"

@implementation MonsterPiece

@synthesize row;
@synthesize col;
@synthesize type;
@synthesize remove;
@synthesize marked;
@synthesize moving;
@synthesize pieceName;
@synthesize state;
@synthesize direction;

- (id) init
{
	if( (self=[super init]) ) 
	{
		selectedSprite = [CCSprite spriteWithSpriteFrameName:@"selected.png"];
		selectedSprite.visible = NO;
		selectedSprite.position = CGPointMake(0.0f, -1.0f);
		[self addChild:selectedSprite z:1];
		moving = NO;
	}
	
	return self;
}

- (CGRect)rect
{
	//CGSize s = MonsterFace.textureRect.size;
	return CGRectMake(-22, -22, 44, 44);
}

- (void)updatePiece :(int)updateRow :(int)updateCol :(int)updateType
{
	row = updateRow;
	col = updateCol;
	type = updateType;
	state = NO;
}
				   
- (void)updateType :(int)updateType :(NSString *)updateName
{
	//MonsterFace = nil;
	[self removeChild:MonsterFace cleanup:NO];
	type = updateType;
	MonsterFace = [CCSprite spriteWithSpriteFrameName:updateName];
	[self addChild:MonsterFace z:0];
}

- (void)updateMarked:(BOOL)status
{
	marked = status;
	if (marked == YES) {
		//NSLog(@"marking col:%d, row:%d", col, row);
		selectedSprite.visible = YES;
		id action1 = [CCFadeIn actionWithDuration:.1];
		id action2 = [CCFadeOut actionWithDuration:.1];
		[selectedSprite runAction:[CCSequence actions:action1, action2, action1, nil]];
		//[self addChild:selectedSprite];
	} else {
		//NSLog(@"unmarking col:%d, row:%d", col, row);
		selectedSprite.visible = NO;
		id action = [CCFadeIn actionWithDuration:0];
		[selectedSprite runAction:action];
		//[self removeChild:selectedSprite cleanup:NO];
	}
}

- (void)onEnter
{
	[[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
	[super onEnter];
}

- (void)onExit
{
	[[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
	[super onExit];
}

- (BOOL)containsTouchLocation:(UITouch *)touch
{
	return CGRectContainsPoint(self.rect, [self convertTouchToNodeSpace:touch]);
}

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
	if (state != NO) return NO;
	if ( ![self containsTouchLocation:touch] ) return NO;	
	
	[[NSNotificationCenter defaultCenter]
	 postNotificationName:@"MonsterTouch"
	 object:self ];
	
	touchPoint = [[CCDirector sharedDirector] convertToGL:[touch locationInView:[touch view]]];
	
	state = YES;
	return YES;
}

- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
	// If it weren't for the TouchDispatcher, you would need to keep a reference
	// to the touch from touchBegan and check that the current touch is the same
	// as that one.
	// Actually, it would be even more complicated since in the Cocos dispatcher
	// you get NSSets instead of 1 UITouch, so you'd need to loop through the set
	// in each touchXXX method.
}

- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
	//NSAssert(state == kPieceStateGrabbed, @"MonsterPiece - Unexpected state!");
	previousPoint = [[CCDirector sharedDirector] convertToGL: [touch previousLocationInView:[touch view]]];
	
	pointDifference = ccpSub(previousPoint, touchPoint);
	
	if (abs(pointDifference.x) > abs(pointDifference.y)) {
		NSLog(@"horizonal");
		if (pointDifference.x < -5) {
			//NSLog(@"left");
			direction = @"left";
			[[NSNotificationCenter defaultCenter]
			 postNotificationName:@"MonsterTouchMove"
			 object:self ];
			state = NO;
		} else if (pointDifference.x > 5) {
			//NSLog(@"right");
			direction = @"right";
			[[NSNotificationCenter defaultCenter]
			 postNotificationName:@"MonsterTouchMove"
			 object:self ];
			state = NO;
		}
	} else {
		NSLog(@"vertical");
		if (pointDifference.y < -5) {
			//NSLog(@"down");
			direction = @"down";
			[[NSNotificationCenter defaultCenter]
			 postNotificationName:@"MonsterTouchMove"
			 object:self ];
			state = NO;
		} else if (pointDifference.y > 5) {
			//NSLog(@"up");
			direction = @"up";
			[[NSNotificationCenter defaultCenter]
			 postNotificationName:@"MonsterTouchMove"
			 object:self ];
			state = NO;
		}
	}
	
	state = NO;
}

- (void) ungrab
{
	state = NO;
	NSLog(@"ungrab = %@", (state ? @"YES" : @"NO")); 
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
