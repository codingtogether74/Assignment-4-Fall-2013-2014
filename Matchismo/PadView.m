//
//  PadView.m
//  Matchismo4a
//
//  Created by Tatiana Kornilova on 11/30/13.
//  Copyright (c) 2013 Tatiana Kornilova. All rights reserved.
//

#import "PadView.h"

@interface PadView () <UIDynamicAnimatorDelegate>

@property (strong, nonatomic) UIDynamicAnimator *animator;
@property (strong, nonatomic) NSMutableArray *attachementsForViews; //of UIAttachmentBehavior
@end

@implementation PadView

- (UIDynamicAnimator *)animator
{
    if (!_animator) {
        _animator = [[UIDynamicAnimator alloc] initWithReferenceView:self];
        _animator.delegate = self;
    }
    return _animator;
}
-(NSMutableArray *)attachementsForViews
{
    if (!_attachementsForViews) _attachementsForViews = [[NSMutableArray alloc] init];
    return _attachementsForViews;
}

- (void)attachCardsViewToPoint:(CGPoint)anchorPoint
{
   for (UIView *v in [self subviews]) {
        UIAttachmentBehavior *attachment = [[UIAttachmentBehavior alloc] initWithItem:v attachedToAnchor:anchorPoint];
       [self.attachementsForViews addObject:attachment];
        [self.animator addBehavior:attachment];
   }
}

- (void)pinch:(UIPinchGestureRecognizer *)gesture
{
    CGPoint gesturePoint =[gesture locationInView:self];
    
    if (gesture.state == UIGestureRecognizerStateBegan) {
        [self attachCardsViewToPoint:gesturePoint];
        self.pinchedViews =YES;
    } else if (gesture.state == UIGestureRecognizerStateChanged) {
        for (UIAttachmentBehavior *attachment in self.attachementsForViews) {
            attachment.anchorPoint = gesturePoint;
            attachment.length *= gesture.scale;
        }
        gesture.scale = 1.0;
    } else if (gesture.state == UIGestureRecognizerStateEnded) {
        for (UIAttachmentBehavior *attachment in self.attachementsForViews) {
            attachment.anchorPoint = gesturePoint;
            attachment.length *= gesture.scale;
        }
        gesture.scale = 1.0;
        for (UIAttachmentBehavior *attachment in self.attachementsForViews) {
            [self.animator removeBehavior:attachment];
        }
    }
}

- (void)pan:(UIPanGestureRecognizer *)gesture
{
    CGPoint gesturePoint =[gesture locationInView:self];
    if (self.pinchedViews) {
        if (gesture.state == UIGestureRecognizerStateBegan) {
            [self attachCardsViewToPoint:gesturePoint];
        } else if (gesture.state == UIGestureRecognizerStateChanged) {
            for (UIAttachmentBehavior *attachment in self.attachementsForViews) {
                attachment.anchorPoint = gesturePoint;
            }
        } else if (gesture.state == UIGestureRecognizerStateEnded) {
            for (UIAttachmentBehavior *attachment in self.attachementsForViews) {
                attachment.anchorPoint = gesturePoint;
            }
            for (UIAttachmentBehavior *attachment in self.attachementsForViews) {
                [self.animator removeBehavior:attachment];
            }
        }
    }
}
@end
