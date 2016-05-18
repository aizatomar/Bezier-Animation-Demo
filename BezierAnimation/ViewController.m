//
//  ViewController.m
//  BezierAnimation
//
//  Created by Aizat Omar on 14/4/15.
//  Copyright (c) 2015 Aizat Omar. All rights reserved.
//

#import "ViewController.h"
#import <QuartzCore/QuartzCore.h>
#import <AVFoundation/AVAudioPlayer.h>

@interface ViewController ()
{
    AVAudioPlayer *_metalDoor;
    CAKeyframeAnimation *_pathAnimation;
}

// IBOutlets
@property (nonatomic, weak) IBOutlet UIImageView *imageTop;
@property (nonatomic, weak) IBOutlet UIImageView *imageBottom;
@property (nonatomic, weak) IBOutlet UIImageView *imageFlare;
@property (nonatomic, weak) IBOutlet UIButton *btnRestart;

// Private
- (void)restartPosition;     // Reset position of images
- (void)restartAnimation;   // Play animation

// IBAction
- (IBAction)pressRestart:(UIButton *)sender;

@end

@implementation ViewController

#pragma mark - View controller

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Initialize sound
    NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"MetalDoor" ofType:@"mp3"]];
    _metalDoor = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    [_metalDoor prepareToPlay];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // Reset position of images out of screen
    [self restartPosition];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // Play animation
    [self restartAnimation];
}

#pragma mark - Private

- (void)restartPosition {
    // Hide flare and button
    [self.imageFlare setHidden:YES];
    [self.btnRestart setHidden:YES];
    
    // Check should it go in from left or right
    static BOOL isReverse = YES;
    isReverse = !isReverse;
    
    // Draw path for top image
    UIBezierPath *topPath = [UIBezierPath bezierPath];
    [topPath moveToPoint:CGPointZero];
    [topPath addLineToPoint:CGPointMake(CGRectGetMaxX(self.imageTop.frame), CGRectGetMinY(self.imageTop.frame))];
    [topPath addLineToPoint:CGPointMake(CGRectGetMaxX(self.imageTop.frame), ((2.0-isReverse)/3.0)*CGRectGetMaxY(self.imageTop.frame))];
    [topPath addLineToPoint:CGPointMake(CGRectGetMinX(self.imageTop.frame), ((2.0-(!isReverse))/3.0)*CGRectGetMaxY(self.imageTop.frame))];
    [topPath addLineToPoint:CGPointZero];
    [topPath closePath];
    
    // Mask layer for top image
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.path = topPath.CGPath;
    [self.imageTop.layer setMask:maskLayer];
    
    // Draw path for bottom image
    UIBezierPath *bottomPath = [UIBezierPath bezierPath];
    [bottomPath moveToPoint:CGPointMake(CGRectGetMaxX(self.imageBottom.frame), CGRectGetMaxY(self.imageBottom.frame))];
    [bottomPath addLineToPoint:CGPointMake(CGRectGetMinX(self.imageBottom.frame), CGRectGetMaxY(self.imageBottom.frame))];
    [bottomPath addLineToPoint:CGPointMake(CGRectGetMinX(self.imageBottom.frame), ((2.0-(!isReverse))/3.0)*CGRectGetMaxY(self.imageBottom.frame))];
    [bottomPath addLineToPoint:CGPointMake(CGRectGetMaxX(self.imageBottom.frame), ((2.0-isReverse)/3.0)*CGRectGetMaxY(self.imageBottom.frame))];
    [bottomPath addLineToPoint:CGPointMake(CGRectGetMaxX(self.imageBottom.frame), CGRectGetMaxY(self.imageBottom.frame))];
    [bottomPath closePath];
    
    // Mask layer for bottom image
    CAShapeLayer *maskLayer2 = [CAShapeLayer layer];
    maskLayer2.path = bottomPath.CGPath;
    [self.imageBottom.layer setMask:maskLayer2];
    
    // Shift left or right out of view
    int negative = isReverse ? -1 : 1;
    [self.imageTop setCenter:CGPointMake(CGRectGetMidX(self.imageTop.frame) + (negative * CGRectGetWidth(self.imageTop.frame)), CGRectGetMidY(self.imageTop.frame))];
    [self.imageBottom setCenter:CGPointMake(CGRectGetMidX(self.imageBottom.frame) - (negative * CGRectGetWidth(self.imageBottom.frame)), CGRectGetMidY(self.imageBottom.frame))];
}

- (void)restartAnimation {
    // Animate sliding into center
    NSTimeInterval delay = 0.5;
    [UIView animateWithDuration:0.5
                          delay:delay
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         // Play sound
                         if ([_metalDoor isPlaying]) {
                             [_metalDoor stop];
                             [_metalDoor setCurrentTime:0.0];
                         }
                         NSTimeInterval now = _metalDoor.deviceCurrentTime;
                         [_metalDoor playAtTime:now + delay + 0.4];
                         
                         // Slide images to center
                         [self.imageTop setCenter:self.view.center];
                         [self.imageBottom setCenter:self.view.center];
                     }
                     completion:^(BOOL finished) {
                         // Hide and disable restart button
                         [self.btnRestart setTransform:CGAffineTransformMakeScale(2.0, 2.0)];
                         [self.btnRestart setHidden:NO];
                         [self.btnRestart setAlpha:0.0];
                         [self.btnRestart setEnabled:NO];
                         
                         [UIView animateWithDuration:0.5
                                               delay:0.0
                                             options:UIViewAnimationOptionCurveEaseOut
                                          animations:^{
                                              // Fade in restart button
                                              [self.btnRestart setTransform:CGAffineTransformMakeScale(1.0, 1.0)];
                                              [self.btnRestart setAlpha:1.0];
                                          }
                                          completion:^(BOOL finished) {
                                              // Enable restart button
                                              [self.btnRestart setEnabled:YES];
                                              
                                              // Path out image flare
                                              [self.imageFlare.layer setPosition:CGPointZero];
                                              [self.imageFlare setHidden:NO];
                                              
                                              UIBezierPath *circlePath = [UIBezierPath bezierPathWithArcCenter:self.view.center
                                                                                                        radius:250.0
                                                                                                    startAngle:-(M_PI/2.0)
                                                                                                      endAngle:-((M_PI/2.0)-((1.0/180.0)*M_PI))
                                                                                                     clockwise:NO];
                                              
//                                              UIBezierPath *topPath = [UIBezierPath bezierPath];
//                                              [topPath moveToPoint:CGPointZero];
//                                              [topPath addLineToPoint:CGPointMake(CGRectGetMaxX(self.imageTop.frame), CGRectGetMinY(self.imageTop.frame))];
//                                              [topPath addLineToPoint:CGPointMake(CGRectGetMaxX(self.imageTop.frame), (1.0/3.0)*CGRectGetMaxY(self.imageTop.frame))];
//                                              [topPath addLineToPoint:CGPointMake(CGRectGetMinX(self.imageTop.frame), (2.0/3.0)*CGRectGetMaxY(self.imageTop.frame))];
//                                              [topPath addLineToPoint:CGPointZero];
//                                              [topPath closePath];
                                              
                                              // Add animation to image flare
                                              _pathAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
                                              _pathAnimation.duration = 1.0;
                                              _pathAnimation.calculationMode = kCAAnimationPaced;
                                              _pathAnimation.removedOnCompletion = NO;
                                              _pathAnimation.fillMode = kCAFillModeForwards;
                                              _pathAnimation.path = circlePath.CGPath;
                                              _pathAnimation.delegate = self;
                                              
                                              [self.imageFlare.layer addAnimation:_pathAnimation forKey:@"FlareTop"];
                                          }];
                     }];
}

#pragma mark - IBAction

- (IBAction)pressRestart:(UIButton *)sender {
    // Reset position and play animation
    [self restartPosition];
    [self restartAnimation];
}

#pragma mark - Core animation delegate

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    // Hide image flare upon complete animation
    if ([anim isEqual:[self.imageFlare.layer animationForKey:@"FlareTop"]]) {
        [self.imageFlare setHidden:YES];
    }
}

@end