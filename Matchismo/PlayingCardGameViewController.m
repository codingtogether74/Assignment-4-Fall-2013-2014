//
//  PlayingCardGameViewController.m
//  Matchismo3
//
//  Created by Tatiana Kornilova on 11/12/13.
//  Copyright (c) 2013 Tatiana Kornilova. All rights reserved.
//

#import "PlayingCardGameViewController.h"
#import "PlayingCardDeck.h"

@interface PlayingCardGameViewController ()

@end

@implementation PlayingCardGameViewController

- (Deck *)createDeck
{
    return [[PlayingCardDeck alloc] init];
}
- (NSUInteger)numberOfMatches
{
    return 2;
}
-(void)updateCardButton:(UIButton *)cardButton usingCard:(Card *)card
{
    // Abstract method to add a background image representing the back of a card
    // and to decide if selected card is higlighted
    [cardButton setTitle:[self titleForCard:card] forState:UIControlStateNormal];
    [cardButton setBackgroundImage:[self backgroundImageForCard:card] forState:UIControlStateNormal];
}

- (NSAttributedString *)attributedCardsDescription:(NSArray *)cards
{
    NSString *text = [cards componentsJoinedByString:@"&"];
//    text = [text stringByAppendingString:@" "];
    return [[NSAttributedString alloc] initWithString:text];
}

- (NSAttributedString *)textForSingleCard:(Card *)card
{
    return [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@" %@ flipped %@",card,(card.isChosen) ? @"up!" : @"back!"]];
}

-(UIImage *)backgroundImageForCard:(Card *)card //abstract
{
    return [UIImage imageNamed:card.isChosen ? @"cardfront" : @"card-back"];
}
-(NSString *)titleForCard:(Card *)card //abstract
{
    return card.isChosen ? card.contents : @"";
}

@end
