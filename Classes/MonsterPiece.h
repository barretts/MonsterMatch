//
//  MonsterPiece.h
//  MonsterMatch
//
//  Created by Barrett Sonntag on 8/28/10.
//  Copyright 2010 MightyFunApps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface MonsterPiece : CCLayer <CCTargetedTouchDelegate> {
	@private CCSprite *MonsterFace;
	@private CCSprite *selectedSprite;
	@private CGPoint touchPoint;
	@private CGPoint previousPoint;
	@private CGPoint pointDifference;
}

@property int row;
@property int col;
@property int type;
@property bool remove;
@property bool marked;
@property bool moving;
@property (retain) NSString *pieceName;
@property bool state;
@property (retain) NSString *direction;

- (void)updatePiece :(int)updateRow :(int)updateCol :(int)updateType;
- (void)updateType :(int)updateType :(NSString *)updateName;
- (void)updateMarked :(BOOL)status;

@end
