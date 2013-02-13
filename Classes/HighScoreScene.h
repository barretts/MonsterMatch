//
//  HighScoreScene.h
//  MonsterMatch
//
//  Created by Barrett Sonntag on 9/26/10.
//  Copyright 2010 MightyFunApps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface HighScoreScene : CCScene {
	@private NSString *gameType;
	@private CCBitmapFontAtlas *hsLabels[10];
	@private CCBitmapFontAtlas *hsLabelsN[10];
}

@end
