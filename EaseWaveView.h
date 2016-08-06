//
//  EaseWaveView.h
//  EaseWave
//
//  Created by rhcf_wujh on 16/8/6.
//  Copyright © 2016年 wjh. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EaseWaveView : UIView

//函数表达式 y = A sin ( ax + b) + c; A代表峰值，a代表周期，b代表在x方向的偏移量，c代表在y方向的偏移量
@property (nonatomic,assign) CGFloat present;/**< 用来控制A,c*/
@property (nonatomic,strong) UIColor * frontColor;/**< 前面波浪的颜色*/
@property (nonatomic,strong) UIColor * backColor;/**< 后面波浪的颜色*/

@end
