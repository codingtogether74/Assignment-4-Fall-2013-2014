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


@interface CardGameViewController ()

@property (strong, nonatomic) Deck *deck;
@property (nonatomic,strong) CardMatchingGame *game;
@property (nonatomic) int flipCount;

@property (strong,nonatomic) Grid *grid;
@property (weak, nonatomic) IBOutlet PadView *padView;
@property (strong,nonatomic) NSMutableArray *cardsView; //of UIView
@property (strong,nonatomic) NSMutableArray *cellCenters; //of CGPoints
@property (strong,nonatomic) NSMutableArray *indexCardsForCardsView; //of NSUIntege
@property (nonatomic) NSUInteger numberViews;
@property (nonatomic) CGFloat cardAspectRatio;
@property (nonatomic) BOOL didLoad;


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

- (IBAction)Deal
{
    self.game = nil;
    self.flipCount =0;

    self.grid.minimumNumberOfCells = self.startingCardCount;

    [self reDrawViewsForView:self.padView withHidden:YES];
    [self performIntroAnimationForView:self.padView];
}


- (IBAction)flipCard:(UITapGestureRecognizer *)gesture
{
    if (!self.padView.pinchedViews) {
    CGPoint tapLocation =[gesture locationInView:self.padView];
    NSUInteger indexView = [self indexForItemInViewArray:self.cardsView atPoint:tapLocation];
    NSUInteger index =[self.indexCardsForCardsView[indexView] unsignedIntegerValue];
        [self.game chooseCardAtIndex:index];
        self.flipCount++;
        [self updateUI];
        [self deleteCardsFromGrid];
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
    for (UIView *cell in self.cardsView ) {
        NSUInteger indexView = [self.cardsView indexOfObject:cell];
        NSUInteger index =[self.indexCardsForCardsView[indexView] unsignedIntegerValue];

        Card *card = [self.game cardAtIndex:index];
        [self updateCell:cell usingCard:card animate:YES];
    }
    
    self.scoreLabel.text = [NSString stringWithFormat:@"Score: %d", self.game.score];
    self.resultsLabel.text=[NSString stringWithFormat:@"Cards in deck: %d",([self.deck count]-[self.game cardsInPlay])];

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
        [self animateRemovingCards:cardsViewToMove];
        [self updateUI];
    }
}

- (void)animateRemovingCards:(NSArray *)dropsToRemove
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
                         if (self.grid.inputsAreValid)
                        [self reDrawViewsForView:self.padView withHidden:NO] ;
                         if (self.addCardsAfterDelete) {
                             [self addCards:nil];
                         }
                     }];
}

- (IBAction)addCards:(id)sender
{
    NSMutableArray *cardsViewToInsert = [NSMutableArray array];
    NSMutableArray *cardsViewPreviuos = [NSMutableArray array];
    
    [self.game addCards:NUMBER_ADD_CARDS];
    NSIndexSet *indexes=self.game.indexesOfInsertedCards;
    self.grid.minimumNumberOfCells =[self.cardsView count]+NUMBER_ADD_CARDS;
    if (self.grid.inputsAreValid)
        cardsViewPreviuos = [self takeViewsForView:self.padView withHidden:NO] ;
    [indexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        NSUInteger indexView =[self.indexCardsForCardsView indexOfObject:[NSNumber numberWithInteger: idx]];
        [cardsViewToInsert addObject:self.cardsView[indexView]];
        [cardsViewPreviuos removeObject:self.cardsView[indexView]];
    }];
    [self animateInsertingCards:cardsViewToInsert withPreviousViews:cardsViewPreviuos forView:self.padView];
        [self updateUI];
 }

- (void)animateInsertingCards:(NSArray *)cardsViewToInsert
            withPreviousViews:(NSArray *)cardsViewPreviuos
                      forView:(UIView *)view
{
	CGPoint point = CGPointMake(self.view.bounds.size.width / 2.0f, self.view.bounds.size.height); // * 2.0f);
    for (UIView *subView in [view subviews])
    {
        [subView removeFromSuperview];
    }
    for (UIView *v in cardsViewPreviuos) {
        v.hidden =NO;
        [view addSubview:v];
    }
    for (UIView *v in cardsViewToInsert) {
        v.hidden =YES;
        v.center = point;
        [view addSubview:v];
    }

    int i=0;
    for (UIView *v in cardsViewToInsert) {
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

-(NSMutableArray *)takeViewsForView:(UIView*)view withHidden:(BOOL)hidden
{
    NSMutableArray *cardsViewAll = [NSMutableArray array];

    self.cardsView =nil;
    for (UIView *v in self.cardsView) {
        v.hidden =hidden;
        [cardsViewAll addObject:v];
    }
    return cardsViewAll;
}


-(void)reDrawViewsForView:(UIView*)view withHidden:(BOOL)hidden
{
    for (UIView *subView in [view subviews])
    {
        [subView removeFromSuperview];
    }
     self.cardsView =nil;
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
- (void)restoreAfterPichAnimationForView:(UIView*)view
{
    int i=0;
    for (UIView *v in [view subviews]) {
        [UIView animateWithDuration:0.4f
                              delay:0.1f*i
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^
         {
             int index = [self.cardsView indexOfObject:v];
             CGPoint center = [self.cellCenters[index] CGPointValue];
             v.center = center;
             
         }
                         completion:nil];
        i++;
    }
    
}

- (void)redrawView:(UIView*)view withScale:(float)scale
{
	CGPoint point = CGPointMake(self.view.bounds.size.width / 2.0f, self.view.bounds.size.height / 2.0f) ; // * 2.0f);
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
             CGPoint newcenter = CGPointMake(center.x + (point.x-center.x)*scale, center.y + (point.y-center.y)*scale);
             v.center = newcenter;
             
         }
                         completion:nil];
        i++;
    }
    
}
-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
   
    self.grid.size = self.padView.bounds.size;
    self.grid.cellAspectRatio = self.cardAspectRatio;    
    self.grid.minimumNumberOfCells = self.numberViews;
    if (!self.grid.inputsAreValid) self.grid =nil;

    [self reDrawViewsForView:self.padView withHidden:NO];
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
