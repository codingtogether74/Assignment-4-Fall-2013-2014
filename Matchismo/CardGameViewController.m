//
//  CardGameViewController.m
//  Matchismo
//
//  Created by Tatiana Kornilova on 11/2/13.
//  Copyright (c) 2013 Tatiana Kornilova. All rights reserved.
//

#import "CardGameViewController.h"
#import "Grid.h"
#import "PadView.h"
#import "CheckView.h"


@interface CardGameViewController ()

@property (strong, nonatomic) Deck *deck;
@property (nonatomic,strong) CardMatchingGame *game;
@property (nonatomic) int flipCount;

@property (strong,nonatomic) Grid *grid;
@property (weak, nonatomic) IBOutlet PadView *padView;
@property (strong,nonatomic) NSMutableArray *cardsView; //of UIViews
@property (strong,nonatomic) NSMutableArray *cellCenters; //of CGPoints

@property (strong,nonatomic) NSMutableArray *indexCardsForCardsView; //of NSUIntegers
@property (strong,nonatomic) NSMutableArray *hints; // of UIViews

@property (nonatomic) NSUInteger numberViews;
@property (nonatomic) CGFloat cardAspectRatio;
@property (nonatomic) BOOL didLoad;

@property (nonatomic) NSUInteger hint;
@property (nonatomic) NSUInteger iOfSets;

@property (weak, nonatomic) IBOutlet UILabel *scoreLabel;
@property (weak, nonatomic) IBOutlet UILabel *resultsLabel;
@property (weak, nonatomic) IBOutlet UIButton *hintButton;

@end

@implementation CardGameViewController

- (CardMatchingGame *)game
{
    if (!_game) _game = [[CardMatchingGame alloc] initWithCardCount:self.startingCardCount usingDeck:[self createDeck]];
    _game.numberOfMatches =[self numberOfMatches];
    return _game;
}

- (Deck *)deck
{
    if (!_deck) _deck = [self createDeck];
    return _deck;
}

 - (Deck *)createDeck   //abstract
{
    return nil;
}

- (NSUInteger)numberOfMatches //abstract
{
    return 0;
}
- (CGFloat)cardAspectRatio //abstract
{
    return 60.0f/90.0f;
}

- (NSUInteger)numberViews
{
    
    if (_numberViews == 0 || !self.cardsView) {
        _numberViews = self.startingCardCount;
    }else _numberViews =[self.cardsView count];
    return _numberViews;
}

- (UIView *)cellViewForCard:(Card *)card inRect:(CGRect)rect //abstract
{
    return nil;
}
- (void) updateCell:(UIView *)cell usingCard:(Card *)card animate:(BOOL)animate
{
    // abstract
}

- (NSMutableArray *)cellCenters
{
    if (!_cellCenters) _cellCenters = [[NSMutableArray alloc] init];
    return _cellCenters;
}

- (NSMutableArray *)hints
{
    if (!_hints) {_hints = [[NSMutableArray alloc] init];
    for (int i=0; i<3; i++) {
        UIView *hintSymbol =[[CheckView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
        [_hints addObject:hintSymbol];
    }
    }
    return _hints;
}


- (NSMutableArray *)indexCardsForCardsView
{
    if (!_indexCardsForCardsView) _indexCardsForCardsView = [[NSMutableArray alloc] init];
    return _indexCardsForCardsView;
}

- (Grid *)grid
{
    if (!_grid)
    {
        _grid =[[Grid alloc] init];
        _grid.size = self.padView.bounds.size;
        _grid.cellAspectRatio = self.cardAspectRatio;
        _grid.minimumNumberOfCells = self.numberViews;
        if (!_grid.inputsAreValid) _grid =nil;
        
    }
    return _grid;
}

#define DEFAULT_FACE_CARD_SCALE_FACTOR 0.95
#define NUMBER_ADD_CARDS 3


- (NSArray *)cardsView
{
    if (!_cardsView)
    {
        _cardsView = [[NSMutableArray alloc] init];
        self.cellCenters =nil;
        self.indexCardsForCardsView =nil;
        NSUInteger columnCount =self.grid.columnCount;

        NSUInteger numberCardsInPlay =[self.game cardsInPlay]-1;
        NSUInteger j =0;
        for (NSUInteger i=0; i<= numberCardsInPlay; i++) {
            Card *card = [self.game cardAtIndex:i];
            if (!card.isMatched) {
                NSUInteger row = (j+0.5)/columnCount;
                NSUInteger column =j%columnCount;
            
                CGPoint center = [self.grid centerOfCellAtRow:row inColumn:column];
                CGRect frame = [self.grid frameOfCellAtRow:row inColumn:column];
                
                CGRect frame1 = CGRectInset(frame,
                                            frame.size.width * (1.0 - DEFAULT_FACE_CARD_SCALE_FACTOR),
                                            frame.size.height * (1.0 - DEFAULT_FACE_CARD_SCALE_FACTOR));
                UIView *cardView = [self cellViewForCard:card inRect:frame1];
                [_cardsView addObject:cardView];
                self.cellCenters[j]= [NSValue valueWithCGPoint:center];
                self.indexCardsForCardsView[j]= [NSNumber numberWithInteger: i];
                j++;
            }
        }
    }
    return _cardsView;
}

-(void)reDrawViewsWithAnimationForView:(UIView*)view
{
    [self restartHints];
    
    self.cellCenters =nil;
    self.indexCardsForCardsView =nil;
    NSUInteger columnCount =self.grid.columnCount;
    NSUInteger numberCardsInPlay =[self.game cardsInPlay]-1;
    NSUInteger j =0;
    for (NSUInteger i=0; i<=numberCardsInPlay; i++)
    {
        if (i< [self.cardsView count]) {
            UIView *v = self.cardsView[i];
            if (!v.hidden)
            {
                NSUInteger row = (j+0.5)/columnCount;
                NSUInteger column =j%columnCount;
                CGPoint center = [self.grid centerOfCellAtRow:row inColumn:column];
                double distance = sqrt((v.center.x - center.x)*(v.center.x - center.x) +(v.center.y - center.y)*(v.center.y - center.y));
                CGRect frame = [self.grid frameOfCellAtRow:row inColumn:column];
                
                CGRect frame1 = CGRectInset(frame,
                                            frame.size.width * (1.0 - DEFAULT_FACE_CARD_SCALE_FACTOR),
                                            frame.size.height * (1.0 - DEFAULT_FACE_CARD_SCALE_FACTOR));
                if (distance>frame.size.width*0.0001f) {
                    [UIView animateWithDuration:0.2f
                                          delay:0.0f+(i*0.1f)
                                        options:UIViewAnimationOptionCurveEaseOut
                                     animations:^
                     {
                         
                         v.center =center;
                         v.frame =frame1;
                     }
                                     completion:nil];
                }
                    self.cellCenters[j]= [NSValue valueWithCGPoint:center];
                    self.indexCardsForCardsView[j]= [NSNumber numberWithInteger: i];
                
                    j++;
            }
        }
    }
}

- (IBAction)Deal
{
    self.game = nil;
    self.flipCount =0;
    self.grid.minimumNumberOfCells = self.startingCardCount;
    [self performIntroAnimationForView:self.padView];
    self.resultsLabel.text=[NSString stringWithFormat:@"Cards in deck: %d",([self.deck count]-[self.game cardsInPlay])];


}


- (IBAction)flipCard:(UITapGestureRecognizer *)gesture
{
    if (!self.padView.pinchedViews) {
        CGPoint tapLocation =[gesture locationInView:self.padView];
        NSUInteger indexView = [self indexForItemInViewArray:self.cardsView atPoint:tapLocation];
        if (indexView<[self.indexCardsForCardsView count]) {
            NSUInteger index =[self.indexCardsForCardsView[indexView] unsignedIntegerValue];
//            Card *card =[self.game cardAtIndex:index];
            [self.game chooseCardAtIndex:index];

            self.flipCount++;
            [self updateUI];
            if ([self.game.matchedCards count] == [self numberOfMatches]&& self.game.lastFlipPoints>0){
            [self deleteCardsFromGrid];
            }
        }
    } else {
        [self restoreAfterPichAnimationForView:self.padView];
        self.padView.pinchedViews =NO;
    }
}

- (NSUInteger)indexForItemInViewArray:(NSArray *)array atPoint:(CGPoint)point
{
    NSUInteger index =0;
    NSUInteger columnCount =self.grid.columnCount ;
    CGSize cellSize =self.grid.cellSize;
    NSUInteger column = floorf(point.x/cellSize.width)+1;
    NSUInteger row = floorf(point.y/cellSize.height) +1;
    index = (row -1)*columnCount +column-1;
    
    return index;
}

-(void)updateUI
{

    NSUInteger cardsCount = [self.indexCardsForCardsView count];
    for (int i=0; i< cardsCount;i++)
    {
        int indexView = [self.indexCardsForCardsView[i] integerValue];
        UIView *cell = self.cardsView[indexView];
        Card *card = [self.game cardAtIndex:indexView];
        [self updateCell:cell usingCard:card animate:YES];
    }
    self.scoreLabel.text = [NSString stringWithFormat:@"Score: %d", self.game.score];
    self.resultsLabel.text=[NSString stringWithFormat:@"Cards in deck: %d",([self.deck count]-[self.game cardsInPlay])];
}

- (void)deleteCardsFromGrid
{
 
        NSMutableArray *cardsViewToMove = [NSMutableArray array];
        
        NSIndexSet *indexes=[self.game getIndexesForMatchedCards:self.game.matchedCards];
        [indexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
            [cardsViewToMove addObject:self.cardsView[idx]];
        }];
        [self animateRemovingCards:cardsViewToMove];
//        [self updateUI];
}

- (void)animateRemovingCards:(NSArray *)dropsToRemove
{
    [UIView animateWithDuration:4.0 animations:^{
        for (UIView *drop in dropsToRemove) {
            int x = (arc4random()%(int)(self.padView.bounds.size.width*2)) - (int)self.padView.bounds.size.width*1;
            int y = self.padView.bounds.size.height;
            drop.center = CGPointMake(x, -y/2);
        }
    }
                     completion:^(BOOL finished) {
                         for (UIView *drop in dropsToRemove) {
                             NSUInteger indexView =[self.cardsView indexOfObject:drop];
                             ((UIView *)self.cardsView[indexView]).hidden = YES;
                         }
                         
                         self.grid.minimumNumberOfCells =[[self.game cardsOnTable] count];
                         
                         if (self.grid.inputsAreValid){
                             if (self.addCardsAfterDelete)
                             {
                                 [self addCards:nil];
                             } else[self reDrawViewsWithAnimationForView:self.padView];
                             
                         }
                     }];
}

- (IBAction)addCards:(id)sender
{
	CGPoint point = CGPointMake(self.view.bounds.size.width / 2.0f, self.view.bounds.size.height); // * 2.0f);
    NSMutableArray *cardsViewToInsert = [NSMutableArray array];
    
    [self.game addCards:NUMBER_ADD_CARDS];
    if ([self.game.indexesOfInsertedCards count] == NUMBER_ADD_CARDS) {
        self.grid.minimumNumberOfCells =[[self.game cardsOnTable] count]; ///???
        if (self.grid.inputsAreValid){
            NSUInteger columnCount =self.grid.columnCount;
            [self reDrawViewsWithAnimationForView:self.padView];
  
    __block int j;
     j=[self.cellCenters count];
        NSIndexSet *indexes=self.game.indexesOfInsertedCards;

            [indexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
                Card *card = [self.game cardAtIndex:idx];
                NSUInteger row = (j+0.5)/columnCount;
                NSUInteger column =j%columnCount;
        
                CGPoint center = [self.grid centerOfCellAtRow:row inColumn:column];
                CGRect frame = [self.grid frameOfCellAtRow:row inColumn:column];
                
                CGRect frame1 = CGRectInset(frame,
                                            frame.size.width * (1.0 - DEFAULT_FACE_CARD_SCALE_FACTOR),
                                            frame.size.height * (1.0 - DEFAULT_FACE_CARD_SCALE_FACTOR));

                UIView *cardView =[self cellViewForCard:card inRect:frame1];
                [self.cardsView addObject:cardView];
                self.cellCenters[j]= [NSValue valueWithCGPoint:center];
                self.indexCardsForCardsView[j]= [NSNumber numberWithInteger: idx];
                j++;

                cardView.center =point;
                cardView.hidden =YES;
               [cardsViewToInsert addObject:cardView];

            }];
            
        [self animateInsertingCards:cardsViewToInsert forView:self.padView];
        }
    }
}

- (void)animateInsertingCards:(NSArray *)cardsViewToInsert
                      forView:(UIView *)view
{
    
    int i=0;
    for (UIView *v in cardsViewToInsert) {
        [view addSubview:v];
        [UIView animateWithDuration:0.65f
                              delay:0.5f+(i*0.2f)
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^
         {
             
             v.hidden = NO ;
             NSUInteger indexView = [self.cardsView indexOfObject:v];
             NSUInteger index =[self.indexCardsForCardsView indexOfObject:[NSNumber numberWithInteger: indexView]];
             CGPoint center = [self.cellCenters[index] CGPointValue];
             v.center = center;
             
         }
                         completion:nil];
        i++;
    }
}

- (void)performIntroAnimationForView:(UIView*)view
{
    for (UIView*v in [self.padView subviews]) {
        [v removeFromSuperview];
    }
   self.cardsView =nil;
	CGPoint point = CGPointMake(self.view.bounds.size.width / 2.0f, self.view.bounds.size.height); // * 2.0f);

    int i=0;
    for (UIView *v in self.cardsView) {
        v.center = point;
        [view addSubview:v];
	[UIView animateWithDuration:0.65f
                          delay:0.5f+(i*0.2F)
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^
     {
             v.hidden = NO ;
             int index = [self.cardsView indexOfObject:v];
             CGPoint center = [self.cellCenters[index] CGPointValue];
             v.center = center;

     }
                     completion:nil];
        i++;
    }
    
}
- (void)restoreAfterPichAnimationForView:(UIView*)view
{
    NSUInteger cardsCount = [self.indexCardsForCardsView count];
    for (int i=0; i< cardsCount;i++)
    {
        int indexView = [self.indexCardsForCardsView[i] integerValue];
        UIView *v = self.cardsView[indexView];
        CGPoint center = [self.cellCenters[i] CGPointValue] ;
        [UIView animateWithDuration:0.4f
                              delay:0.0f*i
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^
         {
             v.center = center;
             
         }
                         completion:nil];
        
    }
}

-(void)removeHints
{
    for (UIView *h in self.hints) {
        [h removeFromSuperview];
    }
}

-(void)restartHints
{
    for (UIView *h in self.hints) {
        [h removeFromSuperview];
    }
    self.hint =0;
    [self.hintButton  setTitle: [NSString stringWithFormat:@"Hint"]forState:UIControlStateNormal];
    self.iOfSets =0;

}

- (IBAction)hintButton:(UIButton *)sender
{
    NSMutableArray *arrayOfSets =[[NSMutableArray alloc] init];
    NSIndexSet *indexes =[[NSIndexSet alloc] init];
    NSMutableArray *cardsViewToHint = [NSMutableArray array];
    
    
    arrayOfSets =self.game.matchesInRemainingCards;
    switch (self.hint) {
        case 0:
            self.resultsLabel.text=[NSString stringWithFormat:@"Cards in deck: %d",([self.deck count]-[self.game cardsInPlay])];
            self.resultsLabel.text=[self.resultsLabel.text stringByAppendingString:[NSString stringWithFormat:@" %d sets",[arrayOfSets count]] ];
            if ([arrayOfSets count]>0) {
                self.hint =1;
                self.iOfSets =0;
                
            }
            break;
        case 1:
        {
            if (self.iOfSets<[arrayOfSets count]) {
                [self.hintButton  setTitle: [NSString stringWithFormat:@"Set %d>>",(self.iOfSets+1)]
                                  forState:UIControlStateNormal];
                indexes= [self.game getIndexesForMatchedCards:arrayOfSets[self.iOfSets]];
                __block int j =0;
                
                [indexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop)
                 {
                     UIView *card1 =self.cardsView[idx];
                     [cardsViewToHint addObject:card1];
                     j++;
                 }];
                [self  animateHintedCards:cardsViewToHint forView:self.padView];
                self.iOfSets++;
            } else
            {
                [self restartHints];
            }
            break;
        }
        default:
            break;
    }
}

- (void)animateHintedCards:(NSArray *)cardsViewToHint forView:(UIView *)view
{
    
    int i=0;

    [self removeHints];
    for (UIView *v in cardsViewToHint) {
        UIView *hintSymbol = self.hints[i];
        hintSymbol.frame =CGRectMake(0.0f, 0.0f, 20.0f, 20.0f);
        hintSymbol.hidden =YES;
        [view addSubview:hintSymbol];
        [UIView animateWithDuration:0.65f
                              delay:0.5f+(i*0.2f)
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^
         {
             hintSymbol.frame =CGRectMake(v.frame.origin.x, v.frame.origin.y, 20.0f, 20.0f);
             hintSymbol.hidden = NO ;
         }
                         completion:nil];
        i++;
    }
}

-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    [self restartHints];

    self.grid.size = self.padView.bounds.size;
    self.grid.cellAspectRatio = self.cardAspectRatio;    
    self.grid.minimumNumberOfCells = [[self.game cardsOnTable] count];//self.numberViews;
    if (self.grid.inputsAreValid && [[self.padView subviews] count]>0){
   [self reDrawViewsWithAnimationForView:self.padView];

//    [self reDrawViewsForView:self.padView withHidden:NO];
    }
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (self.didLoad){
    [self performIntroAnimationForView:self.padView];
        self.didLoad =!self.didLoad;
    }
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    self.didLoad =YES;
    [self.padView addGestureRecognizer:[[UIPinchGestureRecognizer alloc] initWithTarget:self.padView action:@selector(pinch:)]];
    [self.padView addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self.padView action:@selector(pan:)]];
    [self updateUI];

}
@end
