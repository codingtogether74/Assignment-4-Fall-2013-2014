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
- (NSString *)gameName
{
    return @"Set   Cards";
}
-(void)updateCardButton:(UIButton *)cardButton  usingCard:(Card *)card
{
    if ([card isKindOfClass:[SetCard class]]) {
        
        [cardButton setAttributedTitle:[self cardAttributedContents:(SetCard *)card] forState:UIControlStateNormal];
        if (card.isChosen) {
            cardButton.backgroundColor = [UIColor colorWithRed: 0.0 green:0.2 blue:0.5 alpha:0.2];
        } else {
            cardButton.backgroundColor = nil;//[UIColor whiteColor];
        }
        cardButton.alpha = card.isMatched ? 0.0 : 1.0;
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
