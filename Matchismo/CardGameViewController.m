//
//  CardGameViewController.m
//  Matchismo
//
//  Created by Tatiana Kornilova on 11/2/13.
//  Copyright (c) 2013 Tatiana Kornilova. All rights reserved.
//

#import "CardGameViewController.h"
#import "Grid.h"


@interface CardGameViewController ()

@property (strong, nonatomic) Deck *deck;
@property (nonatomic,strong) CardMatchingGame *game;
@property (nonatomic) int flipCount;

@property (strong,nonatomic) Grid *grid;
@property (weak, nonatomic) IBOutlet UIView *padView;
@property (strong,nonatomic) NSMutableArray *cardsView; //of UIView
@property (strong,nonatomic) NSMutableArray *cellCenters; //of CGPoints
@property (strong,nonatomic) NSMutableArray *indexCardsForCardsView; //of NSUIntege
@property (nonatomic) NSUInteger numberViews;



@property (weak, nonatomic) IBOutlet UILabel *scoreLabel;
@property (weak, nonatomic) IBOutlet UILabel *resultsLabel;

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

-(void)updateCardButton:(UIButton *)cardButton usingCard:(Card *)card //abstract
{
    // Abstract method to add a background image representing the back of a card
    // and to decide if selected card is higlighted
}

- (NSAttributedString *)textForSingleCard:(Card *)card //abstract
{
    // Abstract method to return text for self.resultsLabel.text
    // when you manage one card
    return nil;
}

- (NSAttributedString *)attributedCardsDescription:(NSArray *)cards  //abstract
{
    return nil;
}
- (NSMutableArray *)cellCenters
{
    if (!_cellCenters) _cellCenters = [[NSMutableArray alloc] init];
    return _cellCenters;
}
- (NSMutableArray *)indexCardsForCardsView
{
    if (!_indexCardsForCardsView) _indexCardsForCardsView = [[NSMutableArray alloc] init];
    return _indexCardsForCardsView;
}

- (BOOL)deleteMatchedCards
{
    if(!_deleteMatchedCards) _deleteMatchedCards =YES;
    return _deleteMatchedCards;
}

- (Grid *)grid
{
    if (!_grid)
    {
        _grid =[[Grid alloc] init];
        _grid.size = self.padView.bounds.size;
        _grid.cellAspectRatio = 60.0/90.0;
        _grid.minimumNumberOfCells = self.numberViews;
        if (!_grid.inputsAreValid) _grid =nil;
        
    }
    return _grid;
    
}

#define DEFAULT_FACE_CARD_SCALE_FACTOR 0.95

- (NSArray *)cardsView
{
    if (!_cardsView)
    {
        _cardsView = [[NSMutableArray alloc] init];
        self.cellCenters =nil;
        self.indexCardsForCardsView =nil;
        NSUInteger columnCount =self.grid.columnCount;
        //        NSLog(@"rowCount = %d columnCount = %d",rowCount,columnCount);
        NSUInteger numberCardsInPlay =[self.game cardsInPlay]-1;
        NSUInteger j =0;
        for (NSUInteger i=0; i<= numberCardsInPlay; i++) {
            Card *card = [self.game cardAtIndex:i];
            if (!card.isMatched) {
                NSUInteger row = (j+0.5)/columnCount;
                NSUInteger column =j%columnCount;
                //            NSLog(@"i = %d row = %d column = %d",i,row,column);
                CGPoint center = [self.grid centerOfCellAtRow:row inColumn:column];
                CGRect frame = [self.grid frameOfCellAtRow:row inColumn:column];
                
                CGRect frame1 = CGRectInset(frame,
                                            frame.size.width * (1.0 - DEFAULT_FACE_CARD_SCALE_FACTOR),
                                            frame.size.height * (1.0 - DEFAULT_FACE_CARD_SCALE_FACTOR));
                [_cardsView addObject:[self cellViewForCard:card inRect:frame1]];
                self.cellCenters[j]= [NSValue valueWithCGPoint:center];
                self.indexCardsForCardsView[j]= [NSNumber numberWithInteger: i];
                j++;
                
            }
        }
    }
    return _cardsView;
}

- (IBAction)Deal {
    self.game = nil;
    self.flipCount =0;

    [self updateUI];
}


- (IBAction)flipCard:(UITapGestureRecognizer *)gesture
{
    CGPoint tapLocation =[gesture locationInView:self.padView];
    NSUInteger indexView = [self indexForItemInViewArray:self.cardsView atPoint:tapLocation];
    NSUInteger index =[self.indexCardsForCardsView[indexView] unsignedIntegerValue];
        [self.game chooseCardAtIndex:index];
        self.flipCount++;
        [self updateUI];
      if (self.deleteMatchedCards) {[self deleteCardsFromGrid];}
   
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
    for (UIView *cell in self.cardsView ) {
        NSUInteger indexView = [self.cardsView indexOfObject:cell];
        NSUInteger index =[self.indexCardsForCardsView[indexView] unsignedIntegerValue];

        Card *card = [self.game cardAtIndex:index];
        [self updateCell:cell usingCard:card animate:YES];
    }
    
    self.scoreLabel.text = [NSString stringWithFormat:@"Score: %d", self.game.score];
    [self updateFlipResult];

}

-(void)updateFlipResult
{
    NSString *text=@" ";
    NSMutableAttributedString *textResult=[[NSMutableAttributedString alloc] init];
    if ([self.game.matchedCards  count]>0)
    {
        if ([self.game.matchedCards count] == [self numberOfMatches])
        {
           [textResult appendAttributedString:[self attributedCardsDescription:self.game.matchedCards]];
            if (self.game.lastFlipPoints<0) {
                text = [text stringByAppendingString:[NSString stringWithFormat:@"✘ %d penalty",self.game.lastFlipPoints]];
            } else {
                text = [text stringByAppendingString:[NSString stringWithFormat:@"✔ +%d bonus",self.game.lastFlipPoints]];
            }
            
        } else textResult = [[NSMutableAttributedString alloc] initWithAttributedString:[self textForSingleCard:[self.game.matchedCards lastObject]]];
        
        [textResult appendAttributedString:[[NSAttributedString alloc] initWithString:text]];
        self.resultsLabel.attributedText = textResult;

    } else
        self.resultsLabel.attributedText= [[NSAttributedString alloc] initWithString:@"Play game!"];
}

- (void)deleteCardsFromGrid
{
 
    if ([self.game.matchedCards count] == [self numberOfMatches]&& self.game.lastFlipPoints>0)
    {
        
        NSMutableArray *cardsViewToMove = [NSMutableArray array];
        
        NSIndexSet *indexes=[self.game getIndexesForMatchedCards:self.game.matchedCards];
        [indexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
            NSUInteger indexView =[self.indexCardsForCardsView indexOfObject:[NSNumber numberWithInteger: idx]];
            [cardsViewToMove addObject:self.cardsView[indexView]];
        }];
        [self animateRemovingDrops:cardsViewToMove];

    }
}


- (void)animateRemovingDrops:(NSArray *)dropsToRemove
{
    [UIView animateWithDuration:1.0 animations:^{
        for (UIView *drop in dropsToRemove) {
            int x = (arc4random()%(int)(self.padView.bounds.size.width*5)) - (int)self.padView.bounds.size.width*2;
            int y = self.padView.bounds.size.height;
            drop.center = CGPointMake(x, -y);
        }
    }
                     completion:^(BOOL finished) {
                         [dropsToRemove makeObjectsPerformSelector:@selector(removeFromSuperview)];

                         self.grid.minimumNumberOfCells =[self.cardsView count]-self.numberOfMatches;
                         if (!_grid.inputsAreValid) _grid =nil;
                         
                         self.cardsView =nil;
                         [self prepareViewsForView:self.padView withHidden:NO] ;
 //                        [self performAfterDeleteAnimationForView:self.padView];
                     }];
}


-(void)prepareViewsForView:(UIView*)view withHidden:(BOOL)hidden
{
    for (UIView *subView in [view subviews])
    {
        [subView removeFromSuperview];
    }
    
    for (UIView *v in self.cardsView) {
        v.hidden =hidden;
        [view addSubview:v];
    }
}

- (void)performIntroAnimationForView:(UIView*)view
{
	CGPoint point = CGPointMake(self.view.bounds.size.width / 2.0f, self.view.bounds.size.height); // * 2.0f);
    for (UIView *v in [view subviews])
    {
       
       v.center = point;
       v.hidden = NO ;
       //v.center = point;
    }
    int i=0;
    for (UIView *v in [view subviews]) {
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
- (void)performAfterDeleteAnimationForView:(UIView*)view
{

    int i=0;
    for (UIView *v in [view subviews]) {
        [UIView animateWithDuration:0.65f
                              delay:0.5f+0.5f*i
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^
         {
             
             v.hidden = NO ;
             int index = [self.cardsView indexOfObject:v];
             CGPoint center = [self.cellCenters[index] CGPointValue];
             v.center = center;
             v.transform = CGAffineTransformMakeRotation(-0.22f);
             
         }
                         completion:nil];
        i++;
    }
    
}

-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
   
    self.grid.size = self.padView.bounds.size;
    self.grid.cellAspectRatio = 60.0/90.0;
    self.grid.minimumNumberOfCells = self.numberViews;
    if (!_grid.inputsAreValid) _grid =nil;
    self.cardsView =nil;
    [self prepareViewsForView:self.padView withHidden:NO];
//       [self performAfterDeleteAnimationForView:self.padView];
 //   NSLog(@"Layuot width %f height %f",self.padView.bounds.size.width,self.padView.bounds.size.height);

 
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
//    [self prepareViewsForView:self.padView withHidden:NO];

    [self performIntroAnimationForView:self.padView];
//    NSLog(@"DidAppear width %f height %f",self.padView.bounds.size.width,self.padView.bounds.size.height);
}
@end
