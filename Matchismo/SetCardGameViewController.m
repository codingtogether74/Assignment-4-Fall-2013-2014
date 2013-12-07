//
//  SetCardGameViewController.m
//  Matchismo3
//
//  Created by Tatiana Kornilova on 11/12/13.
//  Copyright (c) 2013 Tatiana Kornilova. All rights reserved.
//

#import "SetCardGameViewController.h"
#import "SetCardDeck.h"
#import "SetCard.h"
#import "SetCardView.h"
@interface SetCardGameViewController ()

@end

@implementation SetCardGameViewController

- (Deck *)createDeck
{
    return [[SetCardDeck alloc] init];
}

- (NSUInteger)numberOfMatches
{
    return 3;
}
- (NSUInteger) startingCardCount
{
    return 12;
}
- (BOOL) addCardsAfterDelete
{
    return YES;
}

- (UIView *)cellViewForCard:(Card *)card inRect:(CGRect)rect //abstract
{
    if ([card isKindOfClass:[SetCard class]]) {
        SetCard *setCard =(SetCard *)card;
        SetCardView *newSetCardView = [[SetCardView alloc]  initWithFrame:rect];
        newSetCardView.opaque = NO;
//        newSetCardView.number = setCard.number;
        
        newSetCardView.rank = setCard.number;
        newSetCardView.symbol = setCard.symbol;
        newSetCardView.color = setCard.color;
        newSetCardView.shading = setCard.shading;
//        newSetCardView.chosen = setCard.isChosen;
        newSetCardView.faceUp = setCard.isChosen;

        //------
        
 
        return newSetCardView;
    }
    return nil;
}

- (void)updateCell:(UIView *)cell usingCard:(Card *)card animate:(BOOL)animate
{
        SetCardView *setCardView = (SetCardView *)cell;
        if ([card isKindOfClass:[SetCard class]]) {
            SetCard *setCard = (SetCard *)card;
//            setCardView.number = setCard.number;
             setCardView.rank = setCard.number;
            setCardView.symbol = setCard.symbol;
            setCardView.color = setCard.color;
            setCardView.shading = setCard.shading;
//            setCardView.faceUp = setCard.isChosen;
            //-------------
            if (setCardView.faceUp != setCard.isChosen) {
//           if (setCardView.chosen != setCard.isChosen) {
                if (animate) {
                    [UIView transitionWithView:setCardView
                                      duration:0.5
                                       options:UIViewAnimationOptionTransitionFlipFromLeft
                                    animations:^{
                                        setCardView.faceUp = setCard.isChosen;

                                       // setCardView.chosen = setCard.isChosen;
                                    } completion:NULL];
                } else {
//                    setCardView.chosen = setCard.isChosen;

                    setCardView.faceUp = setCard.isChosen;
                }
            }
        }
}
@end
