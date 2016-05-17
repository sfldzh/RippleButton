//
//  RippleButton.m
//  RippleButton
//
//  Created by Dimoo on 16/5/17.
//  Copyright © 2016年 Dimoo. All rights reserved.
//

#import "RippleButton.h"

@interface RippleButton()
@property (nonatomic, strong)id circleShape;
@end

@implementation RippleButton

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(nullable UIEvent *)event{
    CGFloat width = self.bounds.size.width, height = self.bounds.size.height;
    
    if (self.imageView.image) {
        self.circleShape = [self createImageShapeWithPosition:CGPointMake(width/2, height/2) pathRect:CGRectMake(-CGRectGetMidX(self.bounds), -CGRectGetMidY(self.bounds), self.imageView.image.size.width, self.imageView.image.size.height) ];
        [self.circleShape setContents:(id)[self.imageView.image CGImage]];
    }else{
        self.circleShape = [self createCircleShapeWithPosition:CGPointMake(width/2, height/2)
                                                      pathRect:CGRectMake(-CGRectGetMidX(self.bounds), -CGRectGetMidY(self.bounds), width, height)
                                                        radius:self.layer.cornerRadius];
    }
    
    
    
    [self.layer addSublayer:self.circleShape];
    return YES;
}


- (void)endTrackingWithTouch:(nullable UITouch *)touch withEvent:(nullable UIEvent *)event{
    CGPoint point = [touch locationInView:self];
    
    if (point.x<0||point.y<0||point.x>self.bounds.size.width||point.y>self.bounds.size.height) {
         [self.circleShape removeFromSuperlayer];
    }else{
        CGFloat scale = 2.5f;
        CAAnimationGroup *groupAnimation = [self createFlashAnimationWithScale:scale duration:0.5f];
        
        [groupAnimation setValue:self.circleShape forKey:@"circleShaperLayer"];
        groupAnimation.delegate =self;
        [self.circleShape addAnimation:groupAnimation forKey:nil];
    }
}


- (CALayer *)createImageShapeWithPosition:(CGPoint)position pathRect:(CGRect)rect{
    CALayer *imageLayer = [CALayer layer];
    [imageLayer setBounds:rect];
    [imageLayer setPosition:position];
    return imageLayer;
}

- (CAShapeLayer *)createCircleShapeWithPosition:(CGPoint)position pathRect:(CGRect)rect radius:(CGFloat)radius{
    CAShapeLayer *circleShape = [CAShapeLayer layer];
    circleShape.path = [self createCirclePathWithRadius:rect radius:radius];
    circleShape.position = position;
    circleShape.fillColor = [UIColor clearColor].CGColor;
    circleShape.strokeColor = self.flashColor ? self.flashColor.CGColor : [UIColor purpleColor].CGColor;
    
    circleShape.opacity = 0;
    circleShape.lineWidth = 1;
    
    return circleShape;
}

- (CAAnimationGroup *)createFlashAnimationWithScale:(CGFloat)scale duration:(CGFloat)duration{
    CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    scaleAnimation.fromValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
    scaleAnimation.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(scale, scale, 1)];
    
    CABasicAnimation *alphaAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    alphaAnimation.fromValue = @1;
    alphaAnimation.toValue = @0;
    
    CAAnimationGroup *animation = [CAAnimationGroup animation];
    animation.animations = @[scaleAnimation, alphaAnimation];
    animation.delegate = self;
    animation.duration = duration;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    
    return animation;
}

- (CGPathRef)createCirclePathWithRadius:(CGRect)frame radius:(CGFloat)radius{
    return [UIBezierPath bezierPathWithRoundedRect:frame cornerRadius:radius].CGPath;
}

#pragma mark - CAAnimationDelegate
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{
    CALayer *layer = [anim valueForKey:@"circleShaperLayer"];
    if (layer) {
        [layer removeFromSuperlayer];
    }
}


@end
