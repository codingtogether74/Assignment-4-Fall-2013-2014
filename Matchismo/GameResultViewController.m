//
//  GameResultViewController.m
//  Matchismo3
//
//  Created by Tatiana Kornilova on 11/14/13.
//  Copyright (c) 2013 Tatiana Kornilova. All rights reserved.
//

#import "GameResultViewController.h"
#import "GameResult.h"

@interface GameResultViewController ()

@property (weak, nonatomic) IBOutlet UITextView *display;
@property (nonatomic) SEL sortSelector;

@end

@implementation GameResultViewController

- (void)updateUI
{
    NSMutableAttributedString *displayAttributed = [[NSMutableAttributedString alloc] initWithString:@""];;
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterShortStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    
    //---- search max /min score and duration ----
    NSArray *resultOrdered = [[GameResult allGameResults] sortedArrayUsingSelector:@selector(compareScoreToGameResult:)];
    GameResult *resultMax =[resultOrdered firstObject];
    GameResult *resultMin =[resultOrdered lastObject];
    int maxScore = resultMax.score;
    int minScore = resultMin.score;

    resultOrdered = [[GameResult allGameResults] sortedArrayUsingSelector:@selector(compareDurationToGameResult:)];
    resultMax =[resultOrdered firstObject];
    resultMin =[resultOrdered lastObject];
    int minDuration = (int)roundf(resultMin.duration);
    int maxDuration = (int)roundf(resultMax.duration);

    //--------------------------------------------
    
    for (GameResult *result in [[GameResult allGameResults] sortedArrayUsingSelector:self.sortSelector]) {
        NSString *displayString = [NSString stringWithFormat:@"%@ Score: %4d (%@, %0g)\n", result.gameName, result.score,
                                   [formatter stringFromDate:result.end], round(result.duration)];
        NSMutableAttributedString *scoreAttributed =[[NSMutableAttributedString alloc] initWithString:displayString];
        
        //--- hightlight max/min score and max/min duration -----
        NSRange rangeScoreNumber = NSMakeRange([displayString rangeOfString:@":"].location+1,
                                               [displayString rangeOfString:@"("].location-[displayString rangeOfString:@":"].location-1);
        NSRange rangeDurationNumber = NSMakeRange([displayString rangeOfString:@"," options:NSBackwardsSearch].location+1,
                                                  [displayString rangeOfString:@")"].location-[displayString rangeOfString:@","
                                                                                                                   options:NSBackwardsSearch].location-1);
        
        if (result.score == minScore) {
            [scoreAttributed setAttributes: @{NSForegroundColorAttributeName: [UIColor colorWithRed: 0.0 green:0.6 blue:0.1 alpha:1.0],NSBackgroundColorAttributeName: [UIColor yellowColor]} range:rangeScoreNumber];
        }
        if ((int)roundf(result.duration) == maxDuration) {
            [scoreAttributed setAttributes: @{NSForegroundColorAttributeName: [UIColor colorWithRed: 0.0 green:0.6 blue:0.1 alpha:1.0],NSBackgroundColorAttributeName: [UIColor yellowColor]} range:rangeDurationNumber];
        }
       
        if (result.score == maxScore) {
            [scoreAttributed setAttributes: @{NSForegroundColorAttributeName: [UIColor redColor]} range:rangeScoreNumber];
        }
        if ((int)roundf(result.duration) == minDuration) {
            [scoreAttributed setAttributes: @{NSForegroundColorAttributeName: [UIColor redColor]} range:rangeDurationNumber];
        }
         //----------------------------------------------------
        [displayAttributed appendAttributedString:scoreAttributed];
    }
    self.display.attributedText = displayAttributed;
}

#pragma mark - View Controller Lifecycle

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self updateUI];
}
#pragma mark - Sorting

@synthesize sortSelector = _sortSelector;  // because we implement BOTH setter and getter

// return default sort selector if none set (by score)

- (SEL)sortSelector
{
    if (!_sortSelector) _sortSelector = @selector(compareScoreToGameResult:);
    return _sortSelector;
}

// update the UI when changing the sort selector

- (void)setSortSelector:(SEL)sortSelector
{
    _sortSelector = sortSelector;
    [self updateUI];
}
- (IBAction)sortByDate
{
    self.sortSelector = @selector(compareEndDateToGameResult:);
}

- (IBAction)sortByScore
{
    self.sortSelector = @selector(compareScoreToGameResult:);
}

- (IBAction)sortByDuration
{
    self.sortSelector = @selector(compareDurationToGameResult:);
}

#pragma mark - (Unused) Initialization before viewDidLoad

- (void) setup
{
    //initialization that can't wait until viewDidLoad
}

- (void)awakeFromNib
{
    [self setup];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    [self setup];
    return self;
}

@end
