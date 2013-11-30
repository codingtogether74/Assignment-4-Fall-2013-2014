//
//  PadView.h
//  Matchismo4a
//
//  Created by Tatiana Kornilova on 11/30/13.
//  Copyright (c) 2013 Tatiana Kornilova. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PadView : UIView
@property (nonatomic) BOOL pinchedViews;

-(void)pinch:(UIPinchGestureRecognizer *)gesture;
-(void)pan:(UIPanGestureRecognizer *)gesture;

@end
