//
//  GameBoard.h
//  MonsterMatch
//
//  Created by Barrett Sonntag on 8/28/10.
//  Copyright 2010 MightyFunApps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import	"MonsterPiece.h"

@interface GameBoard : CCLayer {
	@private MonsterPiece *cMonsterPiece;
	@private MonsterPiece *cPicks[2];
	@private MonsterPiece *board[7][7];
	@private CGPoint boardPositions[7][7];
	@private NSInteger cPickCount;
	@private NSInteger types;
	@private NSInteger typeArray[12];
	@private NSInteger boardRowCount;
	@private NSInteger boardColCount;
	@private NSInteger currentCheckRow;
	@private NSInteger offset;
	//@private BOOL animating;
	@private NSInteger chainCount;
	@private NSString *gameType;
	@private BOOL timesUp;
	@private BOOL newLevel;
	@private NSInteger hintCount;
	@private int *matchList;
	
	@private BOOL inFunction;
	@private BOOL fill;
	@private BOOL yoyo;
	@private BOOL swap;
	@private BOOL hint;
	@private BOOL mark;
	@private BOOL remove;
	@private BOOL fresh;
	@private BOOL resume;
	@private BOOL checkMoveBool;
	@private BOOL startCheckBool;
	@private BOOL explode;
}

- (void) update:(ccTime)dt;
- (void) freshBoard;
- (void) resumeBoard;
- (void) MonsterTouch:(NSNotification *)notification;
- (void) MonsterTouchMove:(NSNotification *)notification;
- (void) checkMove;
- (void) picksYoyo;
- (void) picksSwap;
- (void) picksHint;
- (void) markMatches;
- (void) removeMatches;
- (void) fillIcons;
- (void) startCheck;
- (BOOL) checkPossibleMatches;
- (void) clearPicks :(int)clearCount;
- (BOOL) checkRowForPossibleMatches :(NSInteger)targetCheckRow;
- (BOOL) checkForMatches;
- (void) explodeBoard;
- (void) removePop :(id)sender;
- (void) stoppedFalling :(id)sender data:(MonsterPiece *)targetPiece;
- (void) updateSave;
//- (void) animationStarted;
//- (void) animationEnded;
//- (void) functionEnded;
- (void) updateScore:(NSInteger)score;
- (void) endGameMenu;

@end
