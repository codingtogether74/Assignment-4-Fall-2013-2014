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


- (UIView *)cellViewForCard:(Card *)card inRect:(CGRect)rect //abstract
{
    if ([card isKindOfClass:[SetCard class]]) {
        SetCard *setCard =(SetCard *)card;
        SetCardView *newSetCardView = [[SetCardView alloc]  initWithFrame:rect];
        newSetCardView.opaque = NO;
        newSetCardView.rank = setCard.number;
        newSetCardView.symbol = setCard.symbol;
        newSetCardView.color = setCard.color;
        newSetCardView.shading = setCard.shading;
        newSetCardView.faceUp = setCard.isChosen;
 
        return newSetCardView;
    }
    return nil;
}

- (void)updateCell:(UIView *)cell usingCard:(Card *)card animate:(BOOL)animate
{
        SetCardView *setCardView = (SetCardView *)cell;
        if ([card isKindOfClass:[SetCard class]]) {
            SetCard *setCard = (SetCard *)card;
            setCardView.rank = setCard.number;
            setCardView.symbol = setCard.symbol;
            setCardView.color = setCard.color;
            setCardView.shading = setCard.shading;
            setCardView.faceUp = setCard.isChosen;
//            setCardView.alpha = setCard.isUnplayable ? 0.3 : 1.0;
        }
}
- (NSAttributedString *)attributedCardsDescription:(NSArray *)cards
{
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] init];
    NSAttributedString *separator = [[NSAttributedString alloc] init];
    for (Card *card in cards) {
        separator = ([cards indexOfObject:card] ==([cards count]-1)) ? [[NSAttributedString alloc] initWithString:@""] :[[NSAttributedString alloc] initWithString:@" & "];
        [text appendAttributedString:[self cardAttributedContents:(SetCard *)card]];
        [text appendAttributedString:separator];
    }
    return text;

}

- (NSAttributedString *)cardAttributedContents:(SetCard *)card
{
    NSDictionary *symbolPallette = @{@"diamond":@"▲",@"squiggle":@"■",@"oval":@"●"};
    NSDictionary *colorPallette  = @{@"red":[UIColor redColor],@"green":[UIColor greenColor],@"purple":[UIColor purpleColor]};
    NSDictionary *alphaPallette  = @{@"solid":@0,@"striped":@0.2,@"open":@1};
    UIColor *cardOutlineColor    = colorPallette[card.color];
    UIColor *cardColor           = [cardOutlineColor colorWithAlphaComponent:(CGFloat)[alphaPallette[card.shading] floatValue]];
    NSDictionary *cardAttributes = @{NSForegroundColorAttributeName : cardColor,
                                         NSStrokeColorAttributeName : cardOutlineColor,
                                     NSStrokeWidthAttributeName: @-5,
                                     NSFontAttributeName: [self attributedFont]};
    NSString *textToDisplay      =  [@"" stringByPaddingToLength:card.number
                                                 withString:symbolPallette[card.symbol]
                                            startingAtIndex:0];
    NSAttributedString *cardContents = [[NSAttributedString alloc] initWithString:textToDisplay
                                                                       attributes:cardAttributes];

    return cardContents;
}
//------ resizable bold font ----
- (UIFont *)attributedFont
{
    UIFont *bodyFont = [[UIFont alloc] init];
    UIFontDescriptor *fontName = [UIFontDescriptor
                                     fontDescriptorWithFontAttributes: @{UIFontDescriptorFamilyAttribute: @"Menlo"}];
    UIFontDescriptor *fontNameBold = [fontName fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitBold];
    UIFontDescriptor *bodyFontName = [UIFontDescriptor preferredFontDescriptorWithTextStyle:UIFontTextStyleBody];
    NSNumber *bodyFontSize = bodyFontName.fontAttributes[UIFontDescriptorSizeAttribute];
    float bodyFontSizeValue = [bodyFontSize floatValue]+2.0f;
    bodyFont =
              [UIFont fontWithDescriptor:fontNameBold size:bodyFontSizeValue];
    return bodyFont;
}
//---------------

- (NSAttributedString *)textForSingleCard:(Card *)card
{
    NSMutableAttributedString *text =[[NSMutableAttributedString alloc]
                                      initWithAttributedString:[self cardAttributedContents:(SetCard *)card]];
    [text appendAttributedString:[[NSAttributedString alloc]
                                  initWithString:[NSString stringWithFormat:@"%@",(card.isChosen) ? @" selected!" : @" de-selected!"]]];
    return text;
}

@end
