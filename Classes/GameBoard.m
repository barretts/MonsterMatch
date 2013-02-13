//
//  GameBoard.m
//  MonsterMatch
//
//  Created by Barrett Sonntag on 8/28/10.
//  Copyright 2010 MightyFunApps. All rights reserved.
//

#import "GameBoard.h"
#import "MonsterPiece.h"
#import "MonsterMatchAppDelegate.h"
//#import "MonsterPieceObject.h"

@implementation GameBoard

- (id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super" return value
	if( (self=[super init] ))
	{
		timesUp = NO;
		newLevel = NO;
		fill = NO;
		yoyo = NO;
		swap = NO;
		mark = NO;
		hint = NO;
		remove = NO;
		inFunction = NO;
		hintCount = 0;
		
		types = 8;
		NSInteger i = 0;
		
        for (i = 0; i < 12; ++i) {
            typeArray[i] = i;
        }
		
		boardColCount = 7;
		boardRowCount = 7;
		currentCheckRow = 0;
		cPickCount = 0;
		offset = 44;
		chainCount = 1;
		//animating = NO;
		
		
		if ([[NSUserDefaults standardUserDefaults] boolForKey:@"resume"] == YES) 
		{
			NSLog(@"resuming game!");
			NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:@"typeArray"];
			memcpy(&typeArray, data.bytes, data.length);
			gameType = [MonsterMatchAppDelegate get].currentGameType;// = [[NSUserDefaults standardUserDefaults] objectForKey:@"gameType"];
			resume = YES;
			
			if ([gameType isEqualToString:@"Timed"]) {
				[MonsterMatchAppDelegate get].timePosition = [[NSUserDefaults standardUserDefaults] doubleForKey:@"timePosition"];
				[[NSNotificationCenter defaultCenter]
				 postNotificationName:@"updateFillPosition"
				 object:nil ];
			}
		} else {
			gameType = [MonsterMatchAppDelegate get].currentGameType;
			[[NSUserDefaults standardUserDefaults] setObject:gameType forKey:@"gameType"];
			fresh = YES;
		}
		
		[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"resume"];
	}
	
	[[NSNotificationCenter defaultCenter]
	 addObserver:self
	 selector:@selector(MonsterTouch:)
	 name:@"MonsterTouch"
	 object:nil ];
	
	[[NSNotificationCenter defaultCenter]
	 addObserver:self
	 selector:@selector(MonsterTouchMove:)
	 name:@"MonsterTouchMove"
	 object:nil ];
	
	[[NSNotificationCenter defaultCenter]
	 addObserver:self
	 selector:@selector(goExplode:)
	 name:@"goExplode"
	 object:nil ];
	
	[[NSNotificationCenter defaultCenter]
	 addObserver:self
	 selector:@selector(goFresh:)
	 name:@"goFresh"
	 object:nil ];
	
	[self schedule:@selector(update:)];
	
	return self;
}

- (void) update:(ccTime) dt
{
	if (inFunction) {
		return;
	}
	
	if (explode) {
		[self explodeBoard];
		return;
	}
	
	if (hintCount < 600 ) {
		++hintCount;
	} else {
		hintCount = 0;
		NSLog(@"do hint");
		[self picksHint];
		return;
	}
	
	if (checkMoveBool) {
		[self checkMove];
		return;
	}
	
	if (yoyo) {
		[self picksYoyo];
		return;
	}
	
	if (swap) {
		[self picksSwap];
		return;
	}
	
	if (fill) {
		[self fillIcons];
		return;
	}
	
	if (mark) {
		[self markMatches];
		return;
	}
	
	if (remove) {
		[self removeMatches];
		return;
	}
	
	if (startCheckBool) {
		[self startCheck];
		return;
	}
	
	if (fresh) {
		[self freshBoard];
		return;
	}
	
	if (resume) {
		[self resumeBoard];
		return;
	}
}

- (void) freshBoard
{
	inFunction = YES;
	
	int rowNumber = 0;
	int colNumber = 0;
	int rowsDone = 0;
	NSInteger pieceType;
	NSString *pieceName;
	
	NSInteger i = 0, j, tmp;
	
	for (i = 11; i > 0; --i) {
		j = arc4random()%(i+1);
		tmp = typeArray[j];
		typeArray[j] = typeArray[i];
		typeArray[i] = tmp;
	}
	
	NSData *data = [NSData dataWithBytes:&typeArray length:sizeof(typeArray)];
	[[NSUserDefaults standardUserDefaults] setObject:data forKey:@"typeArray"];	
	
	do {
		for (colNumber = 0; colNumber < boardColCount; ++colNumber)
		{
			for (rowNumber = boardRowCount - 1; rowNumber > -1; --rowNumber)
			{
				pieceType = typeArray[arc4random() % types];
				pieceName = [NSString stringWithFormat:@"piece_%d.png", pieceType];
				board[colNumber][rowsDone] = [MonsterPiece node];
				board[colNumber][rowsDone].position = CGPointMake(44.0f * colNumber, 44.0f * rowNumber);
				[board[colNumber][rowsDone] updatePiece :rowsDone :colNumber :pieceType];
				board[colNumber][rowsDone].pieceName = pieceName;
				//[self addChild:piece];
				boardPositions[colNumber][rowsDone] = board[colNumber][rowsDone].position;
				//board[colNumber][rowsDone] = piece;
				++rowsDone;
			}
			
			rowsDone = 0;
		}
		//NSLog(@"created new board");
	} while ([self checkForMatches] || [self checkPossibleMatches] == NO);
	
	CGPoint tempPoint;
	
	for (colNumber = 0; colNumber < boardColCount; ++colNumber)
	{
		for (rowNumber = 0; rowNumber < boardRowCount; ++rowNumber)
		{
			tempPoint = board[colNumber][rowNumber].position;
			tempPoint.y = board[colNumber][rowNumber].position.y + 44 * boardRowCount + 44;
			board[colNumber][rowNumber].position = tempPoint;
			[board[colNumber][rowNumber] updateType :board[colNumber][rowNumber].type :board[colNumber][rowNumber].pieceName];
			[self addChild:board[colNumber][rowNumber]];
		}
	}
	
	fresh = NO;
	fill = YES;
	inFunction = NO;
}

- (void) resumeBoard
{
	inFunction = YES;
	
	int rowNumber = 0;
	int colNumber = 0;
	int rowsDone = 0;
	NSInteger pieceType;
	NSString *pieceName;	
	do {
		for (colNumber = 0; colNumber < boardColCount; ++colNumber)
		{
			for (rowNumber = boardRowCount - 1; rowNumber > -1; --rowNumber)
			{
				pieceType = [[NSUserDefaults standardUserDefaults] integerForKey:[NSString stringWithFormat:@"board_%d_%d",colNumber,rowsDone]];
				pieceName = [NSString stringWithFormat:@"piece_%d.png", pieceType];
				board[colNumber][rowsDone] = [MonsterPiece node];
				board[colNumber][rowsDone].position = CGPointMake(44.0f * colNumber, 44.0f * rowNumber);
				[board[colNumber][rowsDone] updatePiece :rowsDone :colNumber :pieceType];
				board[colNumber][rowsDone].pieceName = pieceName;
				//[self addChild:piece];
				boardPositions[colNumber][rowsDone] = board[colNumber][rowsDone].position;
				//board[colNumber][rowsDone] = piece;
				++rowsDone;
			}
			
			rowsDone = 0;
		}
		//NSLog(@"created new board");
	} while ([self checkForMatches] || [self checkPossibleMatches] == NO);
	
	CGPoint tempPoint;
	
	for (colNumber = 0; colNumber < boardColCount; ++colNumber)
	{
		for (rowNumber = 0; rowNumber < boardRowCount; ++rowNumber)
		{
			tempPoint = board[colNumber][rowNumber].position;
			tempPoint.y = board[colNumber][rowNumber].position.y + 44 * boardRowCount + 44;
			board[colNumber][rowNumber].position = tempPoint;
			[board[colNumber][rowNumber] updateType :board[colNumber][rowNumber].type :board[colNumber][rowNumber].pieceName];
			[self addChild:board[colNumber][rowNumber]];
		}
	}
	
	resume = NO;
	fill = YES;
	inFunction = NO;
}

- (void) MonsterTouch: (NSNotification *) notification
{
	if (inFunction) {
		return;
	}
	
	inFunction = YES;
	
	//NSLog(@"MonsterTouch: animating = %@\n", (animating ? @"YES" : @"NO"));
	
	cMonsterPiece = [notification object];
	
	NSLog(@"MonsterPiece Touch Start: col:%d, row:%d, type:%d", cMonsterPiece.col, cMonsterPiece.row, cMonsterPiece.type);
	
	if (cPicks[0] == cMonsterPiece)
	{
		NSLog(@"the same icon was selected twice, not clearing out but returning as if no touch happened");
		//[self clearPicks :cPickCount];
		inFunction = NO;
		return;
	}
	
	[cMonsterPiece updateMarked:YES];
	
	if (cPickCount == 2)
	{
		NSLog(@"a third icon has been selected, clear out all selections");
		[self clearPicks :cPickCount];
		inFunction = NO;
		return;
	}
	
	if (cPickCount == 1)
	{
		NSInteger adjacentCheck = abs(cMonsterPiece.col - cPicks[0].col) + abs(cMonsterPiece.row - cPicks[0].row);
		if (adjacentCheck == 0 || adjacentCheck > 1)
		{
			NSLog(@"a second icon has been selected but is not adjacent, clearPicks and continue");
			[self clearPicks :cPickCount];
		}
	}
	
	checkMoveBool = YES;
	inFunction = NO;
}

- (void) MonsterTouchMove: (NSNotification *) notification
{
	if (inFunction) {
		return;
	}
	
	inFunction = YES;
	
	cPickCount = 1;
	
	cMonsterPiece = [notification object];
	cPicks[0] = cMonsterPiece;
	//NSLog(@"i want to move %@",[notification object]);
	if(cMonsterPiece.direction == @"left" && cMonsterPiece.col > 0)
	{
		NSLog(@"1");
		cMonsterPiece = board[cMonsterPiece.col-1][cMonsterPiece.row];
		checkMoveBool = YES;
		inFunction = NO;
		return;
	}
	
	if(cMonsterPiece.direction == @"right" && cMonsterPiece.col < 6)
	{
		NSLog(@"2");
		cMonsterPiece = board[cMonsterPiece.col+1][cMonsterPiece.row];
		checkMoveBool = YES;
		inFunction = NO;
		return;
	}
	
	if(cMonsterPiece.direction == @"up" && cMonsterPiece.row > 0)
	{
		NSLog(@"3");
		cMonsterPiece = board[cMonsterPiece.col][cMonsterPiece.row-1];
		checkMoveBool = YES;
		inFunction = NO;
		return;
	}
	
	if(cMonsterPiece.direction == @"down" && cMonsterPiece.row < 6)
	{
		NSLog(@"4");
		cMonsterPiece = board[cMonsterPiece.col][cMonsterPiece.row+1];
		checkMoveBool = YES;
		inFunction = NO;
		return;
	}
	NSLog(@"5");
	
	[self clearPicks :cPickCount];
	inFunction = NO;
}

- (void) checkMove
{
	inFunction = YES;
	//NSLog(@"checkMove: animating = %@\n", (animating ? @"YES" : @"NO"));

	MonsterPiece *tempMonsterPiece;
	if (cPickCount == 0) {
		cPicks[0] = cMonsterPiece;
		NSLog(@"an icon has been selected");
	} else if (cPickCount == 1) {
		tempMonsterPiece = cPicks[0];
		cPicks[0] = cMonsterPiece;
		cPicks[1] = tempMonsterPiece;
	}
	
	++cPickCount;
	
	//[cMonsterPiece updateMarked:YES];
	
	if (cPickCount == 2)
	{
		int tempType = cPicks[0].type;
		cPicks[0].type = cPicks[1].type;
		cPicks[1].type = tempType;
		
		if ([self checkForMatches])
		{
			NSLog(@"match!");
			hintCount = 0;
			swap = YES;
			checkMoveBool = NO;
			inFunction = NO;
			return;
		}
		
		NSLog(@"no match!");
		yoyo = YES;
		checkMoveBool = NO;
		inFunction = NO;
		return;
	}
	
	checkMoveBool = NO;
	inFunction = NO;
}

- (void) picksYoyo
{
	inFunction = YES;
	
	MonsterPiece *pickOne = cPicks[0];
	MonsterPiece *pickTwo = cPicks[1];
	
	int tempType = pickOne.type;
	pickOne.type = pickTwo.type;
	pickTwo.type = tempType;
	
	id action1 = [CCMoveTo actionWithDuration:.15 position:ccp(pickTwo.position.x, pickTwo.position.y)];
	id action2 = [CCMoveTo actionWithDuration:.15 position:ccp(pickOne.position.x, pickOne.position.y)];
	id action3 = [CCMoveTo actionWithDuration:.15 position:ccp(pickOne.position.x, pickOne.position.y)];
	id action4 = [CCMoveTo actionWithDuration:.15 position:ccp(pickTwo.position.x, pickTwo.position.y)];
	id endCall = [CCCallFunc actionWithTarget:self selector:@selector(yoyoEnded)];
	[cPicks[0] runAction: [CCSequence actions:action1, action2, nil]];
	[cPicks[1] runAction: [CCSequence actions:action3, action4, endCall, nil]];
	
	[self clearPicks:cPickCount];
}

- (void) yoyoEnded
{
	yoyo = NO;
	inFunction = NO;
}

- (void) picksSwap
{
	inFunction = YES;
	
	MonsterPiece *pickOne = cPicks[0];
	MonsterPiece *pickTwo = cPicks[1];
	
	int tempVar = pickOne.type;
	pickOne.type = pickTwo.type;
	pickTwo.type = tempVar;
	
	tempVar = pickOne.col;
	pickOne.col = pickTwo.col;
	pickTwo.col = tempVar;
	
	tempVar = pickOne.row;
	pickOne.row = pickTwo.row;
	pickTwo.row = tempVar;
	
	board[pickOne.col][pickOne.row] = pickOne;
	board[pickTwo.col][pickTwo.row] = pickTwo;
	
	id action1 = [CCMoveTo actionWithDuration:.15 position:ccp(pickTwo.position.x, pickTwo.position.y)];
	id action3 = [CCMoveTo actionWithDuration:.15 position:ccp(pickOne.position.x, pickOne.position.y)];
	id action5 = [CCCallFunc actionWithTarget:self selector:@selector(swapEnded)];
	[cPicks[0] runAction: action1];
	[cPicks[1] runAction: [CCSequence actions: action3, action5, nil]];
	
	[self clearPicks:cPickCount];
}

- (void) swapEnded
{
	mark = YES;
	swap = NO;
	inFunction = NO;
}

- (void) picksHint
{
	inFunction = YES;
	NSLog(@"picksHint fired");
	
	MonsterPiece *pickOne = board[matchList[0]][matchList[1]];
	MonsterPiece *pickTwo = board[matchList[2]][matchList[3]];
	
	id action1 = [CCMoveTo actionWithDuration:.3 position:ccp(pickTwo.position.x, pickTwo.position.y)];
	id action2 = [CCMoveTo actionWithDuration:.3 position:ccp(pickOne.position.x, pickOne.position.y)];
	id action3 = [CCMoveTo actionWithDuration:.3 position:ccp(pickOne.position.x, pickOne.position.y)];
	id action4 = [CCMoveTo actionWithDuration:.3 position:ccp(pickTwo.position.x, pickTwo.position.y)];
	id endCall = [CCCallFunc actionWithTarget:self selector:@selector(hintEnded)];
	[pickOne runAction: [CCSequence actions:action1, action2, nil]];
	[pickTwo runAction: [CCSequence actions:action3, action4, endCall, nil]];
}

- (void) hintEnded
{
	hint = NO;
	inFunction = NO;
}

- (void) markMatches
{
	inFunction = YES;
	NSLog(@"markMatches");
	
	NSInteger biggestMatch = 0;
	NSInteger scoreCount = 0;
	NSInteger score = 10;
	NSInteger removeCount = 0;
	NSInteger currentColumn = 0;
	NSInteger currentRow = 0;
	NSInteger matchCount = 0;
	NSInteger aLastType = -1;
	NSInteger firstMatchRow = 0;
	NSInteger firstMatchCol = 0;
	NSString *pieceName = 0;
	MonsterPiece *targetIcon;
	MonsterPiece *currentIcon;
	NSInteger i = 0;
	NSInteger i1 = 0;
	NSInteger i2 = 0;
	NSInteger markRow = 0;
	NSInteger markCol = 0;
	CGPoint firstPoint = CGPointMake(0.0f, 0.0f);
	CGPoint lastPoint = CGPointMake(0.0f, 0.0f);
	
	for (i = 0; i < 2; i++)
	{
		for (i1 = 0; i1 < boardColCount; i1++)
		{
			matchCount = 0;
			aLastType = -1;
			firstMatchRow = 0;
			firstMatchCol = 0;
			
			for (i2 = 0; i2 < boardRowCount; i2++)
			{
				if (i == 0)
				{
					//trace("markMatches horizontal");
					currentColumn = i1;
					currentRow = i2;
				}
				else
				{
					//trace("markMatches vertical");
					currentColumn = i2;
					currentRow = i1;
				}
				
				BOOL pieceMatch = NO;
				targetIcon = board[currentColumn][currentRow];
				
				//CGPoint targetIconPosition = targetIcon.position;
				//boardPositions[targetIcon.col][targetIcon.row];
				//targetIconPosition.x = targetIcon.col * offset;
				//targetIconPosition.y = targetIcon.row * offset;
				targetIcon.position = boardPositions[targetIcon.col][targetIcon.row];
				
				if (targetIcon.type == aLastType)
				{
					pieceMatch = YES;
					++matchCount;
				}
				
				if (!pieceMatch || i2 == 6)
				{
					if (matchCount >= 3)
					{
						for (markRow = firstMatchRow; markRow <= currentRow; markRow++)
						{
							for (markCol = firstMatchCol; markCol <= currentColumn; markCol++)
							{
								currentIcon = board[markCol][markRow];
								
								if (currentIcon.type == aLastType)
								{											
									if (!currentIcon.remove)
									{
										currentIcon.remove = YES;
										//var iconPop = new IconPop(currentIcon.type);
										//iconPop.x = currentIcon.x + offset / 2;
										//iconPop.y = currentIcon.y + offset / 2;
										//this.addChild(iconPop);
										//[self createExplosionX :boardPositions[markCol][markRow]];
										
										id action2 = [CCScaleTo actionWithDuration:.3 scale:0];
										id removeSprite = [CCCallFuncN actionWithTarget:self selector:@selector(removePop:)];
										
										pieceName = [NSString stringWithFormat:@"piece_%d.png", currentIcon.type];
										CCSprite *pop = [CCSprite spriteWithSpriteFrameName:pieceName];
										pop.position = currentIcon.position;
										[self addChild:pop];
										
										[pop runAction:[CCSequence actions: action2, removeSprite, nil]];
										
										++removeCount;
										//NSLog(@"match number %d", removeCount);
									}
									lastPoint = currentIcon.position;
								}
							}
						}
						
						++scoreCount;
						
						score = 10;
						
						switch(scoreCount)
						{
							case 1:
								break;
								
							case 2:
								score += 10;
								break;
								
							case 3:
								score += 20;
								break;
								
							case 4:
								score += 30;
								break;
								
							case 5:
								score += 50;
								break;
								
							case 6:
								score += 70;
								break;
								
							case 7:
								score += 100;
								break;
								
							case 8:
								score += 150;
								break;
								
							default:
								score += 10;
						}
						
						if (matchCount > 3)
						{
							score = score + (matchCount - 3) * 10;
						}
						
						if (matchCount > 5)
						{
							score = score + (matchCount - 5) * 10;
						}
						
						score = (chainCount + 1) * score;
						
						NSLog(@"updateScore: %d",score);
						[self updateScore :score];
						
						if (matchCount > biggestMatch)
						{
							biggestMatch = matchCount;
						}
						
						id action1 = [CCFadeOut actionWithDuration:.3];
						//id action3 = [CCDelayTime actionWithDuration:3];
						id action2 = [CCScaleTo actionWithDuration:.15 scale:3];
						id action5 = [CCScaleTo actionWithDuration:.15 scale:2];
						id action4 = [CCMoveBy actionWithDuration:.3 position:ccp(0,80)];
						id removeSprite = [CCCallFuncN actionWithTarget:self selector:@selector(removePop:)];
						
						CCBitmapFontAtlas *label1 = [CCBitmapFontAtlas bitmapFontAtlasWithString:[NSString stringWithFormat:@"%d",score] fntFile:@"score.fnt"];
						//label1.anchorPoint = ccp(0.5f,0.5f);
						
						if (i == 0)
						{
							NSLog(@"-- start vertical match --");
							NSLog(@"firstPoint x:%f y%f",firstPoint.x,firstPoint.y);
							NSLog(@"lastPoint x:%f y%f",lastPoint.x,lastPoint.y);
							NSLog(@"-- end difference --");
							//trace("markMatches horizontal");
							//label1.position = CGPointMake(firstPoint.x, firstPoint.y);
							//label1.position = CGPointMake(lastPoint.x, lastPoint.y);
							label1.position = CGPointMake(firstPoint.x, (firstPoint.y - lastPoint.y) / 2 + lastPoint.y);
						}
						else
						{
							NSLog(@"-- start horizontal match --");
							NSLog(@"firstPoint x:%f y%f",firstPoint.x,firstPoint.y);
							NSLog(@"lastPoint x:%f y%f",lastPoint.x,lastPoint.y);
							NSLog(@"-- end difference --");
							//trace("markMatches vertical");
							//label1.position = CGPointMake(firstPoint.x, firstPoint.y);
							//label1.position = CGPointMake(lastPoint.x, lastPoint.y);
							label1.position = CGPointMake((lastPoint.x - firstPoint.x) / 2 + firstPoint.x, firstPoint.y);
						}
						
						[self addChild:label1];
						id fordward = [CCSpawn actions:action1, action4, nil];
						[label1 runAction:[CCSequence actions: action2,action5,fordward,removeSprite, nil]];
					}
					
					firstPoint = targetIcon.position;
					aLastType = targetIcon.type;
					matchCount = 1;
					firstMatchCol = currentColumn;
					firstMatchRow = currentRow;
				}
			}
		}
	}
	
	NSLog(@"markMatches() removeCount: %d",removeCount);
	
	remove = YES;
	mark = NO;
	inFunction = NO;
}

- (void) removeMatches
{
	inFunction = YES;
	NSLog(@"removeMatches");
	
	NSInteger moveAmount;
	NSInteger removeCount;
	NSInteger pieceType;
	MonsterPiece *currentIcon;
	MonsterPiece *targetIcon;
	MonsterPiece *updateIcon;
	CGPoint targetIconPosition;
	
	for (NSInteger colNumber = 0; colNumber < boardColCount; colNumber++)
	{
		removeCount = boardColCount;
		
		for (NSInteger rowNumber = boardRowCount - 1; rowNumber >= 0; --rowNumber)
		{
			currentIcon = board[colNumber][rowNumber];
			
			if (!currentIcon.remove)
			{
				--removeCount;
				
				if (removeCount != rowNumber)
				{
					targetIcon = board[colNumber][removeCount];
					[targetIcon updateType:currentIcon.type :[NSString stringWithFormat:@"piece_%d.png", currentIcon.type]];
					targetIcon.moving = NO;
					[targetIcon updateMarked:NO];
					targetIcon.position = currentIcon.position;
					board[colNumber][removeCount] = targetIcon;				}
			}
			
			currentIcon.remove = NO;
		}
		
		moveAmount = offset * removeCount + 44;
		
		NSLog(@"moveAmount: %d",moveAmount);
		
		for (NSInteger rowNumber = 0; rowNumber < removeCount; ++rowNumber)
		{
			NSLog(@"moving a row");
			
			updateIcon = board[colNumber][rowNumber];
			
			pieceType = typeArray[arc4random() % types];
			[updateIcon updateType:pieceType :[NSString stringWithFormat:@"piece_%d.png", pieceType]];
			
			targetIconPosition = updateIcon.position;
			targetIconPosition.y = updateIcon.position.y + moveAmount;
			updateIcon.position = targetIconPosition;
			updateIcon.moving = NO;
			[updateIcon updateMarked:NO];
			
			board[colNumber][rowNumber] = updateIcon;
		}
	}
	
	remove = NO;
	fill = YES;
	inFunction = NO;
}

- (void) fillIcons
{
	inFunction = YES;
	NSLog(@"fillIcons");
	
	NSInteger colNumber = 0;
	NSInteger rowNumber = 0;
	float time = .3;
	float delayTime = 0;
	float maxTime = 0;
	float maxDelay = 0;
	MonsterPiece *currentIcon;
	CGPoint targetPosition;
	NSInteger targetYPosition;
	
	while (colNumber < boardColCount)
	{
		//NSLog(@"%d",board[colNumber][0].position.y);
		//NSLog(@"%d",boardPositions[0][0].y);
		//NSLog(@"---------");
		if (board[colNumber][0].position.y > boardPositions[0][0].y)
		{
			//NSLog(@"y is less than y");
			for (rowNumber = 0; rowNumber < boardRowCount; ++rowNumber)
			{
				currentIcon = board[colNumber][rowNumber];
				targetPosition = currentIcon.position;
				targetYPosition = boardPositions[0][rowNumber].y;
				//NSLog(@"%d",targetYPosition);
				targetPosition.x = boardPositions[colNumber][0].x;
				currentIcon.position = targetPosition;
				
				if (targetPosition.y != targetYPosition && currentIcon.moving == NO)
				{
					currentIcon.moving = YES;
					
					//delayTime = .1 * (boardRowCount - rowNumber);
					id action1 = [CCMoveTo actionWithDuration:time position:ccp(currentIcon.position.x, targetYPosition)];
					id ease1 = [CCEaseOut actionWithAction:action1 rate:time];
					id call1 = [CCCallFuncND actionWithTarget:self selector:@selector(stoppedFalling:data:) data:currentIcon];
					//id delay = [CCDelayTime actionWithDuration:delayTime];
					[currentIcon runAction:[CCSequence actions:ease1, call1, nil]];
					
					if (delayTime > maxDelay)
					{
						maxDelay = delayTime;
					}
					
					if (maxTime < time+maxDelay)
					{
						maxTime = time+maxDelay;
					}
				}
			}
		}
		++colNumber;
	}
	
	id endDelay = [CCDelayTime actionWithDuration:maxTime+.25];
	id endCall = [CCCallFunc actionWithTarget:self selector:@selector(endFill)];
	
	[self runAction:[CCSequence actions:endDelay,endCall,nil]];
}

- (void) endFill
{
	fill = NO;
	startCheckBool = YES;
	inFunction = NO;
}

- (void) startCheck
{
	inFunction = YES;
	startCheckBool = NO;
	NSLog(@"startCheck");
	
	if ([self checkForMatches])
	{
		chainCount++;
		
		mark = YES;
		inFunction = NO;
	} else {
		chainCount = 0;
		
		if ([self checkPossibleMatches])
		{
			[self updateSave];
			inFunction = NO;
		} else {
			explode = YES;
			inFunction = NO;
			//NSLog(@"startCheck: game over man!");
		}
	}
}

- (BOOL) checkRowForPossibleMatches :(NSInteger)targetCheckRow
{
	NSLog(@"checkRowForPossibleMatches: %d",targetCheckRow);
	
	matchList = malloc(4 * sizeof(int *));
	
	matchList[0] = -1;
	matchList[1] = -1;
	matchList[2] = -1;
	matchList[3] = -1;
	
	int **swapArray = malloc(4 * sizeof(int *));
	
	for(int i = 0; i < 4; i++)
	{
		swapArray[i] = malloc(2 * sizeof(int));
	}
	
	swapArray[0][0] = 1;
	swapArray[0][1] = 0;
	swapArray[1][0] = 0;
	swapArray[1][1] = 1;
	swapArray[2][0] = -1;
	swapArray[2][1] = 0;
	swapArray[3][0] = 0;
	swapArray[3][1] = -1;
	
	NSInteger colNumber;
	NSInteger currentSwap;
	NSInteger swapColumn;
	NSInteger currentRow;
	NSInteger swapIconType;
	NSInteger leftColumn;
	NSInteger rightColumn;
	NSInteger currentIconType;
	NSInteger topRow;
	NSInteger bottomRow;
	
	for (colNumber = 0; colNumber < boardColCount; ++colNumber)
	{
		for (currentSwap = 0; currentSwap < 4; currentSwap++)
		{
			swapColumn = colNumber + swapArray[currentSwap][0];
			currentRow = targetCheckRow + swapArray[currentSwap][1];
			
			if (swapColumn > -1 && swapColumn < boardRowCount && currentRow > -1 && currentRow < boardRowCount)
			{
				swapIconType = board[colNumber][targetCheckRow].type;
				board[colNumber][targetCheckRow].type = board[swapColumn][currentRow].type;
				board[swapColumn][currentRow].type = swapIconType;
				
				leftColumn = colNumber;
				rightColumn = colNumber;
				currentIconType = board[colNumber][targetCheckRow].type;
				
				while (leftColumn > 0 && currentIconType == board[leftColumn - 1][targetCheckRow].type)
				{
					--leftColumn;
				}
				while (rightColumn < boardColCount - 1 && currentIconType == board[rightColumn + 1][targetCheckRow].type)
				{
					++rightColumn;
				}
				
				topRow = targetCheckRow;
				bottomRow = targetCheckRow;
				
				while (topRow > 0 && currentIconType == board[colNumber][topRow - 1].type)
				{
					--topRow;
				}
				while (bottomRow < boardRowCount - 1 && currentIconType == board[colNumber][bottomRow + 1].type)
				{
					++bottomRow;
				}
				
				swapIconType = currentIconType;
				board[colNumber][targetCheckRow].type = board[swapColumn][currentRow].type;
				board[swapColumn][currentRow].type = swapIconType;
				
				if (rightColumn - leftColumn >= 2 || bottomRow - topRow >= 2)
				{
					matchList[0] = colNumber;
					matchList[1] = targetCheckRow;
					matchList[2] = swapColumn;
					matchList[3] = currentRow;
					currentSwap = 4;
					colNumber = boardColCount;
					targetCheckRow = boardRowCount;
				}
			}
		}
	}
	
	if (matchList[0] != -1)
	{
		NSLog(@"row %d has a match", matchList[1]);
		currentCheckRow = boardRowCount;
		return YES;
	}
	
	//trace('row '+targetCheckRow+' has no match!');
	return NO;
}

- (BOOL) checkPossibleMatches
{
	NSLog(@"checkPossibleMatches");
	
	BOOL matches = NO;
	currentCheckRow = 0;
	
	while (currentCheckRow < boardRowCount)
	{
		if ([self checkRowForPossibleMatches :currentCheckRow])
		{
			matches = YES;
		}
		++currentCheckRow;
	}
	
	if (matches == NO)
	{
		NSLog(@"checkPossibleMatches: game over man!");
	}
	
	return matches;
}

- (void) clearPicks :(int)clearCount
{
	NSLog(@"clearPicks :(int)clearCount = %d", clearCount);
	while (clearCount > 0) {
		[cPicks[clearCount - 1] updateMarked:NO];
		cPicks[clearCount - 1] = nil;
		--clearCount;
	}
	
	cPickCount = 0;
}

- (BOOL) checkForMatches
{
	NSLog(@"checkForMatches");
	//NSLog(@"checkForMatches: animating = %@\n", (animating ? @"YES" : @"NO"));
	
	NSInteger colNumber = 0;
	NSInteger rowNumber = 0;
	MonsterPiece *currentPiece;
	MonsterPiece *nextPiece;
	NSInteger matchCount = 1;
	
	for (rowNumber = 0; rowNumber < boardRowCount; ++rowNumber) {
		matchCount = 1;
		
		for (colNumber = 0; colNumber < boardColCount - 1; ++colNumber) {
			currentPiece = board[colNumber][rowNumber];
			nextPiece = board[colNumber + 1][rowNumber];
			
			if (currentPiece.type == nextPiece.type)
			{
				++matchCount;
				if (matchCount > 2) {
					return YES;
				}
				continue;
			}
			matchCount = 1;
		}
	}
	
	for (colNumber = 0; colNumber < boardColCount; ++colNumber) {
		matchCount = 1;
		
		for (rowNumber = 0; rowNumber < boardRowCount - 1; ++rowNumber) {
			currentPiece = board[colNumber][rowNumber];
			nextPiece = board[colNumber][rowNumber + 1];
			
			if (currentPiece.type == nextPiece.type)
			{
				++matchCount;
				if (matchCount > 2) {
					return YES;
				}
				continue;
			}
			matchCount = 1;
		}
	}
	
	return NO;
}

- (void) explodeBoard
{
	inFunction = YES;
	explode = NO;
	/*
	id action1 = [CCFadeOut actionWithDuration:.1];
	id action4 = [CCFadeIn actionWithDuration:.1];
	id action3 = [CCDelayTime actionWithDuration:.8];
	id action2 = [CCScaleTo actionWithDuration:0 scale:0];
	id action5 = [CCScaleTo actionWithDuration:1 scale:1];
	id removeSprite = [CCCallFuncN actionWithTarget:self selector:@selector(removePop:)];
	
	CCBitmapFontAtlas *label1 = [CCBitmapFontAtlas bitmapFontAtlasWithString:@"NO MORE MOVES!" fntFile:@"score.fnt"];
	label1.position = CGPointMake(140, 140);
	label1.opacity = 0;
	[label1 runAction:[CCSequence actions: action2,action4,action3,action1, nil]];
	[label1 runAction:[CCSequence actions: action5,removeSprite, nil]];
	
	[self addChild:label1];
	*/
	NSInteger colNumber = 0;
	NSInteger rowNumber = 0;
	float time = .3;
	//float delayTime = 0;
	//float maxTime = 0;
	//float maxDelay = 0;
	
	for (rowNumber = 0; rowNumber < boardColCount; ++rowNumber)
	{
		for (colNumber = 0; colNumber < boardColCount; ++colNumber)
		{
			//delayTime = .05 * (boardRowCount - rowNumber);
			id action1 = [CCMoveTo actionWithDuration:time position:ccp(board[colNumber][rowNumber].position.x, -44 * (rowNumber + 1) - 44)];
			id call1 = [CCCallFuncN actionWithTarget:self selector:@selector(removePop:)];
			//[CCCallFunc actionWithTarget:self selector:@selector(animationEnded)];
			//id ease1 = [CCEaseBounceOut actionWithAction:action1];
			//id delay = [CCDelayTime actionWithDuration:delayTime];
			[board[colNumber][rowNumber] runAction:[CCSequence actions:action1, call1, nil]];
			/*
			if (delayTime > maxDelay)
			{
				maxDelay = delayTime;
			}
			
			if (maxTime < time+maxDelay)
			{
				maxTime = time+maxDelay;
			}*/
		}
	}
	
	id endDelay = [CCDelayTime actionWithDuration:time];
	id endCall;
	
	if ([gameType isEqualToString:@"Timed"] && timesUp == NO) {
		endCall = [CCCallFunc actionWithTarget:self selector:@selector(explodeEndedFresh)];
	} else if ([gameType isEqualToString:@"Classic"] && [MonsterMatchAppDelegate get].remainingLives > 0) {
		endCall = [CCCallFunc actionWithTarget:self selector:@selector(explodeEndedFreshNewLife)];
	} else {
		endCall = [CCCallFunc actionWithTarget:self selector:@selector(endGameMenu)];
	}
	
	[self runAction:[CCSequence actions:endDelay,endCall,nil]];
}
	
- (void) explodeEndedFresh
{
	fresh = YES;
	inFunction = NO;
}

- (void) explodeEndedFreshNewLife
{
	[[NSNotificationCenter defaultCenter]
	 postNotificationName:@"endLife"
	 object:nil ];
	fresh = YES;
	inFunction = NO;
}

- (void) removePop :(id)sender
{
	[self removeChild:sender cleanup:YES];
}

- (void) stoppedFalling :(id)sender data:(MonsterPiece *)targetPiece
{
	targetPiece.moving = NO;
}
/*
- (void) animationStarted
{
	animating = YES;
}

- (void) animationEnded
{
	animating = NO;
}

- (void) functionEnded
{
	inFunction = NO;
}
*/
- (void) goExplode :(NSNotification *) notification
{
	timesUp = YES;
	explode = YES;
}

- (void) goFresh :(NSNotification *) notification
{
	newLevel = YES;
	explode = YES;
}
/*
-(void) explodeWait:(ccTime) dt
{
	if(!animating && !inFunction)
	{
		animating = YES;
		//[self unschedule:@selector(explodeWait:)];
		[self explodeBoard];
	}
}*/

- (void) updateScore :(NSInteger)score
{
	[MonsterMatchAppDelegate get].currentScore += score;
	
	[[NSNotificationCenter defaultCenter]
	 postNotificationName:@"updateScore"
	 object:nil ];
}

- (void) endGameMenu
{
	[[NSNotificationCenter defaultCenter]
	 postNotificationName:@"endGame"
	 object:nil ];
}

- (void) updateSave
{	
	for (int c = 0; c < 7; ++c) {
		for (int r = 0; r < 7; ++r) {
			[[NSUserDefaults standardUserDefaults] setInteger:board[c][r].type forKey:[NSString stringWithFormat:@"board_%d_%d",c,r]];
		}
	}
	
	if ([gameType isEqualToString:@"Classic"]) {
		[[NSUserDefaults standardUserDefaults] setInteger:[MonsterMatchAppDelegate get].remainingLives forKey:@"remainingLives"];
	}
	
	if ([gameType isEqualToString:@"Timed"]) {
		[[NSUserDefaults standardUserDefaults] setDouble:[MonsterMatchAppDelegate get].timePosition forKey:@"timePosition"];
	}
	
	[[NSUserDefaults standardUserDefaults] setInteger:[MonsterMatchAppDelegate get].currentScore forKey:@"currentScore"];
}

// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
	NSLog(@"dealloc");
	// in case you have something to dealloc, do it in this method
	// in this particular example nothing needs to be released.
	// cocos2d will automatically release all the children (Label)

	/*
	MonsterPiece *tempPiece = [MonsterPiece alloc];
	MonsterPieceObject *tempPieceObject = [MonsterPieceObject alloc];
	
	for (int c = 0; c < 7; ++c) {
		for (int r = 0; r < 7; ++r) {
			tempPiece = board[c][r];
			tempPieceObject = [[MonsterPieceObject alloc] initWithParams:tempPiece.pieceName :[NSNumber numberWithInt:tempPiece.row] :[NSNumber numberWithInt:tempPiece.col] :[NSNumber numberWithInt:tempPiece.type]];
			[[MonsterMatchAppDelegate get] savePieceObjectWithKey:tempPieceObject :[NSString stringWithFormat:@"board_%d_%d",c,r]];
		}
	}
	
	[tempPiece release];
	[tempPieceObject release];
	*/
	[self unschedule:@selector(update:)];
	
	[[NSNotificationCenter defaultCenter]
	 removeObserver:self
	 name:@"MonsterTouch"
	 object:nil ];
	
	[[NSNotificationCenter defaultCenter]
	 removeObserver:self
	 name:@"MonsterTouchMove"
	 object:nil ];
	
	[[NSNotificationCenter defaultCenter]
	 removeObserver:self
	 name:@"goExplode"
	 object:nil ];
	
	[[NSNotificationCenter defaultCenter]
	 removeObserver:self
	 name:@"goFresh"
	 object:nil ];
	
	// don't forget to call "super dealloc"
	[super dealloc];
}

@end
