//
//  CardMatchingGame.m
//  Matchismo
//
//  Created by Tatiana Kornilova on 11/7/13.
//  Copyright (c) 2013 Tatiana Kornilova. All rights reserved.
//

#import "CardMatchingGame.h"
#import "GameSettings.h"

@interface CardMatchingGame()

@property (nonatomic,readwrite) NSInteger score;
@property (strong, nonatomic) Deck *deck;
@property (nonatomic,strong) NSMutableArray *cards; // of Card
@property (nonatomic,strong) NSMutableArray *faceUpCards; // of Card
@property (readwrite,nonatomic) NSInteger lastFlipPoints;
@property (nonatomic,strong) GameSettings *gameSettings;
@property (readwrite,nonatomic) NSIndexSet *indexesOfInsertedCards;

@end

@implementation CardMatchingGame

-(NSMutableArray *)cards
{
    if (!_cards) _cards = [[NSMutableArray alloc] init];
    return _cards;
}

-(NSArray *)cardsOnTable
{
   NSMutableArray *remCards =[[NSMutableArray alloc] init];
    for (Card *card in self.cards) {
        if (!card.isMatched) {
            [remCards addObject:card];
        }
    }
    return [remCards copy];
}

-(NSMutableArray *)matchesInRemainingCards
{
    NSMutableArray *matches =[[NSMutableArray alloc] init];
    NSMutableArray *checkCards =[[NSMutableArray alloc] init];
    if (self.numberOfMatches ==3)
    {
        NSUInteger nCards = [self.cardsOnTable count];
        for (int i=0; i<nCards; i++) {
            Card *card1 =self.cardsOnTable[i];
            [checkCards addObject:card1];
            for (int j=i+1; j<nCards; j++) {
                Card *card2 =self.cardsOnTable[j];
                 [checkCards addObject:card2];
                for (int k=j+1; k<nCards; k++) {
                    Card *card3 =self.cardsOnTable[k];
                    [checkCards addObject:card3];
                    int matchScore =[card3 match:checkCards];
                    if (matchScore>0) {
                        [matches addObject:[checkCards copy]];
                    }
                     [checkCards removeObject:card3];
                }
                [checkCards removeObject:card2];
            }
            [checkCards removeObject:card1];
        }
       return matches;
    }
    
    return nil;
}

- (int) matchBonus
{
    if (_matchBonus<= 0) _matchBonus = MATCH_BONUS;
    return _matchBonus;
}

- (int) mismatchPenalty
{
    if (_mismatchPenalty<= 0) _mismatchPenalty = MISMATCH_PENALTY;
    return _mismatchPenalty;
}

- (int) flipCost
{
    if (_flipCost <= 0) _flipCost = COST_TO_CHOOSE;
    return _flipCost;
}

- (void)setNumberOfMatches:(NSUInteger)numberOfMatches
{
    _numberOfMatches = numberOfMatches >= 2 ? numberOfMatches :2;
}
- (GameSettings *)gameSettings
{
    if (!_gameSettings) _gameSettings = [[GameSettings alloc] initFromUserDefaults];
    
    return _gameSettings;
}

static const int MISMATCH_PENALTY = 2;
static const int MATCH_BONUS = 4;
static const int COST_TO_CHOOSE = 1;

-(void)chooseCardAtIndex:(NSUInteger)index
{
    Card *card = [self cardAtIndex:index];
    if (!card.isMatched) {
        if (card.isChosen) {
            card.chosen =NO;
        } else {
            // match against another cards
            self.faceUpCards= [[NSMutableArray alloc] initWithArray:@[card]];
            self.lastFlipPoints = 0;
            for (Card *otherCard in self.cards) {
                if (otherCard.isChosen && !otherCard.isMatched) {
                    [self.faceUpCards insertObject:otherCard atIndex:0];
                    // decision on match
                    if ([self.faceUpCards count] == (self.numberOfMatches)) {
            
                        int matchScore = [card match:self.faceUpCards];
                        if (matchScore) {
                            self.lastFlipPoints = matchScore * self.matchBonus;    //MATCH_BONUS;
                            for (Card *faceUpCard in self.faceUpCards) {
                                faceUpCard.matched =YES;
                            }
                            
                        } else {
                            self.lastFlipPoints = - self.mismatchPenalty;          //MISMATCH_PENALTY;
                            for (Card *faceUpCard in self.faceUpCards) {
                                if (faceUpCard != card) faceUpCard.chosen =NO;
                            }
                        }
                        self.matchedCards =[self.faceUpCards copy];
                        break;
                    }
                    // decision on match
                }
            }
            self.score+= self.lastFlipPoints - self.flipCost;                     //COST_TO_CHOOSE;
             self.matchedCards =[self.faceUpCards copy];
            card.chosen = YES;
        }
    }
}

-(Card *)cardAtIndex:(NSUInteger)index
{
    return (index<[self.cards count]) ? self.cards[index] : nil;
}

- (NSUInteger)cardsInPlay
{
    return [self.cards count];
}


- (NSIndexSet *)getIndexesForMatchedCards:(NSArray *)cards
{
    NSMutableIndexSet *indexes =[[NSMutableIndexSet alloc] init];
    if (cards) {
        for (Card *card1 in cards) {
            [indexes addIndex: [self.cards indexOfObject:card1]];
        }
        return indexes;
    }
    return nil;
}
- (void)addCards:(NSUInteger)cardsNumber
{
    NSMutableIndexSet *indexes =  [[NSMutableIndexSet alloc] init];
    if (cardsNumber <=[self.deck count]){
        for (NSUInteger i=0; i<cardsNumber; i++) {
            Card *card = [self.deck drawRandomCard];
            [self.cards addObject:card];
            [indexes addIndex: [self.cards indexOfObject:card]];
        }
        self.indexesOfInsertedCards =indexes;
    } else {
        self.indexesOfInsertedCards =nil;
    }
}
- (NSIndexSet  *)indexesOfInsertedCards
{
    if (!_indexesOfInsertedCards) {
        _indexesOfInsertedCards = [[NSIndexSet alloc] init];
    }
    return _indexesOfInsertedCards ;
}

-(instancetype)initWithCardCount:(NSUInteger)count
                       usingDeck:(Deck *)deck
             
{
    self = [super init];
    if (self) {
        self.deck = deck;
        self.matchBonus = self.gameSettings.bonus;
        self.mismatchPenalty = self.gameSettings.penalty;
        self.flipCost = self.gameSettings.flipCost;
        for (int i= 0; i<count; i++) {
            Card *card = [self.deck drawRandomCard];
            if (card) {
                [self.cards addObject:card];
            } else {
                self =nil;
                break;
            }
        }
    }
    return self;
}

@end
