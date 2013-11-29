//
//  PlayingCardGameViewController.m
//  Matchismo3
//
//  Created by Tatiana Kornilova on 11/12/13.
//  Copyright (c) 2013 Tatiana Kornilova. All rights reserved.
//

#import "PlayingCardGameViewController.h"
#import "PlayingCardDeck.h"
#import "PlayingCard.h"
#import "PlayingCardView.h"

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


- (NSUInteger) startingCardCount
{
    return 20;
}

- (UIView *)cellViewForCard:(Card *)card inRect:(CGRect)rect //abstract
{
    //  PlayingCardView *newPlayingCardView=nil;
    if ([card isKindOfClass:[PlayingCard class]]) {
        PlayingCard *playingCard =(PlayingCard *)card;
        PlayingCardView *newPlayingCardView = [[PlayingCardView alloc]  initWithFrame:rect];
        newPlayingCardView.opaque = NO;
        newPlayingCardView.rank=playingCard.rank;
        newPlayingCardView.suit=playingCard.suit;
        newPlayingCardView.faceUp=playingCard.isChosen;
        return newPlayingCardView;
    }
    return nil;
}

- (void) updateCell:(UIView *)cell usingCard:(Card *)card animate:(BOOL)animate
{
    PlayingCardView *playingCardView = (PlayingCardView *)cell;
    if ([card isKindOfClass:[PlayingCard class]]) {
        PlayingCard *playingCard =(PlayingCard *)card;
        playingCardView.rank = playingCard.rank;
        playingCardView.suit = playingCard.suit;
        //-------------
        if (playingCardView.faceUp != playingCard.isChosen) {
            if (animate) {
                [UIView transitionWithView:playingCardView
                                  duration:0.5
                                   options:UIViewAnimationOptionTransitionFlipFromLeft
                                animations:^{
                                    playingCardView.faceUp = playingCard.isChosen;
                                } completion:NULL];
            } else {
                playingCardView.faceUp = playingCard.isChosen;
            }
        }
     }
}

- (NSAttributedString *)attributedCardsDescription:(NSArray *)cards
{
    NSString *text = [cards componentsJoinedByString:@"&"];
    return [[NSAttributedString alloc] initWithString:text];
}

- (NSAttributedString *)textForSingleCard:(Card *)card
{
    return [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@" %@ flipped %@",card,(card.isChosen) ? @"up!" : @"back!"]];
}


@end
