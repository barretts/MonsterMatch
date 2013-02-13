//
//  HelloWorldLayer.h
//  MonsterMatch
//
//  Created by Barrett Sonntag on 8/28/10.
//  Copyright MightyFunApps 2010. All rights reserved.
//


// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"

// HelloWorld Layer
@interface GameScene : CCLayer
{
	@private CCBitmapFontAtlas *scoreDisplay;
	@private CCSprite *fillBar;
	@private CCSprite *owlLives[5];
	@private NSString *gameType;
	@private NSInteger currentLevel;
	@private double levelBase;
	@private double lastLevel;
	@private double levelMultiplier;
	@private double perPoint;
	@private double perInterval;
	@private NSInteger fillWidth;
	@private NSInteger previousScore;
	@private bool quit;
}

// returns a Scene that contains the HelloWorld as the only child
+ (id) scene;
- (void) endGameMenu:(NSNotification *)notification;
- (void) goMain:(id)sender;
- (void) onEnterTransitionDidFinish;
- (void) fillUpdate;
- (void) toggleOwls;

@end
