//
//  MenuScene.h
//  MonsterMatch
//
//  Created by Barrett Sonntag on 9/9/10.
//  Copyright 2010 MightyFunApps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

// MenuScene Scene
@interface MenuScene : CCScene <UITextFieldDelegate>
{
	UITextField *playerNameTextField;
	UISwitch *musicState;
}

@end