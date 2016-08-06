//
//  EaseWaveView.m
//  EaseWave
//
//  Created by rhcf_wujh on 16/8/6.
//  Copyright © 2016年 wjh. All rights reserved.
//

#import "EaseWaveView.h"

@interface EaseWaveView ()

// y = A sin ( ax + b) + c;
@property (nonatomic,assign) CGFloat b;
@property (nonatomic,assign) CGFloat A;
@property (nonatomic,strong) CADisplayLink * displayLink;

@end

@implementation EaseWaveView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)drawRect:(CGRect)rect{
    CGContextRef context = UIGraphicsGetCurrentContext();
    // 创建路径
    CGMutablePathRef path = CGPathCreateMutable();
    
    //画水 back
    CGContextSetLineWidth(context, 1);
    if (!self.backColor) {
        self.backColor = [UIColor colorWithRed:53/255.0 green:132/255.0 blue:214/255.0 alpha:1.0];
    }
    UIColor * blue = self.backColor;
    CGContextSetFillColorWithColor(context, [blue CGColor]);
    
    float y  = (1 - self.present) * rect.size.height;
    float y1 = (1 - self.present) * rect.size.height;
    
    CGPathMoveToPoint(path, NULL, 0, y);
    for(float x = 0; x <= rect.size.width * 3.0; x++){
        //正弦函数y = A sin ( ax + b) + c;
        float A = _A ;
        float a = 3 / rect.size.width * M_PI ;
        float b = 2 * _b / rect.size.width * M_PI;
        float c = (1 - self.present) * rect.size.height ;
        y =  A * sin(a * x +  b) + c;
        CGPathAddLineToPoint(path, nil, x, y);
    }
    
    CGPathAddLineToPoint(path, nil, rect.size.width , rect.size.height);
    CGPathAddLineToPoint(path, nil, 0, rect.size.height);
    
    CGContextAddPath(context, path);
    CGContextFillPath(context);
    CGContextDrawPath(context, kCGPathStroke);
    CGPathRelease(path);
    
    
    CGMutablePathRef path1 = CGPathCreateMutable();
    
    //画水 front
    CGContextSetLineWidth(context, 1);
    if (!self.frontColor) {
        self.frontColor = [UIColor colorWithRed:108/255.0 green:179/255.0 blue:223/255.0 alpha:1.0];
    }
    UIColor * blue1 = self.frontColor;
    CGContextSetFillColorWithColor(context, [blue1 CGColor]);
    
    CGPathMoveToPoint(path1, NULL, 0, y1);
    for(float x = 0; x <= rect.size.width; x++){
        //正弦函数y = A sin ( ax + b) + c; 若想要前后波浪高度不一致，可以尝试修改c
        float A = _A ;
        float a = 3 / rect.size.width * M_PI ;
        float b = (_b / rect.size.width + 1 )* M_PI;
        float c = (1 - self.present) * rect.size.height ;
        y1 =  A * sin(a * x +  b) + c;
        CGPathAddLineToPoint(path1, nil, x, y1);
    }
    
    CGPathAddLineToPoint(path1, nil, rect.size.width , rect.size.height );
    CGPathAddLineToPoint(path1, nil, 0, rect.size.height );
    
    CGContextAddPath(context, path1);
    CGContextFillPath(context);
    CGContextDrawPath(context, kCGPathStroke);
    CGPathRelease(path1);
}

- (void)setPresent:(CGFloat)present{
    _present = present / 100;
    //启动定时器
    [self createTimer];
    //修改波浪的幅度 0.3可以尝试修改
    _A = self.frame.size.height * _present * 0.3;
}

- (void)createTimer{
    if (!self.displayLink) {
        self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(action)];
        [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    }
}
- (void)action{
    //让波浪左右移动效果 10可以尝试修改
    _b = _b + 10;
    if (_b >= self.frame.size.width * 2.0) {
        _b = 0;
    }
    [self setNeedsDisplay];
}


@end
