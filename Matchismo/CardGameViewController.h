//
//  CardGameViewController.h
//  Matchismo
//
//  Created by Tatiana Kornilova on 11/2/13.
//  Copyright (c) 2013 Tatiana Kornilova. All rights reserved.
//
// Abstract class. Must implement methods as describeed below.

#import <UIKit/UIKit.h>
#import "Deck.h"
#import "CardMatchingGame.h"

@interface CardGameViewController : UIViewController

@property (nonatomic)NSUInteger startingCardCount;  //abstract
@property (nonatomic)BOOL addCardsAfterDelete; //abstract


// protected
// for subclasses
- (Deck *)createDeck;   //abstract
- (NSUInteger)numberOfMatches; //abstract
- (CGFloat)cardAspectRatio; //abstract


- (UIView *)cellViewForCard:(Card *)card inRect:(CGRect)rect; //abstract
- (void) updateCell:(UIView *)cell usingCard:(Card *)card animate:(BOOL)animate; //abstract

@end
