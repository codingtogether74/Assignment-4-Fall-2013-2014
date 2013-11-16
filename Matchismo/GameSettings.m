//
//  GameSettings.m
//  Matchismo3
//
//  Created by Tatiana Kornilova on 11/15/13.
//  Copyright (c) 2013 Tatiana Kornilova. All rights reserved.
//

#import "GameSettings.h"

@implementation GameSettings

#define SETTINGS_KEY @"GAME_SETTINGS_KEY"
#define BONUS_KEY @"Bonus"
#define PENALTY_KEY @"Penalty"
#define FLIPCOST_KEY @"FlipCost"

static const int MISMATCH_PENALTY = 2;
static const int MATCH_BONUS = 4;
static const int COST_TO_CHOOSE = 1;


// convenience initializer
- (id)initFromUserDefaults
{
    self = [self init];
    if (self) {
        id plist =[[NSUserDefaults standardUserDefaults] dictionaryForKey:SETTINGS_KEY];
        if ([plist isKindOfClass:[NSDictionary class]]) {
            NSDictionary *resultDictionary = (NSDictionary *)plist;
            _bonus = [resultDictionary[BONUS_KEY] intValue];
            _penalty = [resultDictionary[PENALTY_KEY] intValue];
            _flipCost = [resultDictionary[FLIPCOST_KEY] intValue];
            if (!_bonus || !_penalty || !_flipCost) self = nil;
        }
    }
    return self;
}

- (void)synchronize
{
    NSMutableDictionary *mutableGameSettingsFromUserDefaults = [[[NSUserDefaults standardUserDefaults] dictionaryForKey:SETTINGS_KEY] mutableCopy];
    if (!mutableGameSettingsFromUserDefaults) mutableGameSettingsFromUserDefaults = [[NSMutableDictionary alloc] init];
    mutableGameSettingsFromUserDefaults = [self asPropertyList];
    [[NSUserDefaults standardUserDefaults] setObject:mutableGameSettingsFromUserDefaults forKey:SETTINGS_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}

- (id)asPropertyList
{
    return @{ BONUS_KEY : @(self.bonus), PENALTY_KEY : @(self.penalty), FLIPCOST_KEY : @(self.flipCost)};
}

- (void) defaults
{
    self.bonus = MATCH_BONUS;
    self.penalty = MISMATCH_PENALTY;
    self.flipCost = COST_TO_CHOOSE;
    [self synchronize];
}

// designated initializer
- (id)init
{
    self = [super init];
    if (self) {
        _bonus = MATCH_BONUS;
        _penalty = MISMATCH_PENALTY;
        _flipCost = COST_TO_CHOOSE;
    }
    return self;
}

@end
