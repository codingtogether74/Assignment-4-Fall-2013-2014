//
//  HistoryViewController.m
//  Matchismo3old
//
//  Created by Tatiana Kornilova on 11/13/13.
//  Copyright (c) 2013 Tatiana Kornilova. All rights reserved.
//

#import "HistoryViewController.h"

@interface HistoryViewController ()
@property (weak, nonatomic) IBOutlet UITextView *historyTextView;

@end

@implementation HistoryViewController

- (void)setFlipsHistory:(NSArray *)flipsHistory
{
    _flipsHistory = flipsHistory;
    if (self.view.window) [self updateUI];

}
-(void)updateUI
{
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] init];
    int i =1;
    for (NSAttributedString *step in self.flipsHistory) {
         [text appendAttributedString:[[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%3d:  ",i]]];
         [text appendAttributedString:step];
         [text appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n\n "]];
        i++;
    }
    self.historyTextView.attributedText = text;
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self updateUI];
}


@end
