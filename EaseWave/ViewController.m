//
//  ViewController.m
//  EaseWave
//
//  Created by rhcf_wujh on 16/8/6.
//  Copyright © 2016年 wjh. All rights reserved.
//

#import "ViewController.h"
#import "EaseWaveView.h"
#import "NextVC.h"

@interface ViewController ()<UIScrollViewDelegate>

@property (nonatomic ,strong) UIScrollView * scrollView;
@property (nonatomic ,strong) EaseWaveView * wave;/**< 波浪*/
@property (nonatomic ,strong) NSTimer      * timer;/**< 定时器控制波浪逐渐变小*/
@property (nonatomic ,assign) CGFloat      tmpY;/**< 手指离开屏幕时保存的最大偏移量*/

@end

@implementation ViewController

#define SCREEN [UIScreen mainScreen].bounds.size
static CGFloat const WAVEHEIGHT = 50.0;//波浪视图高度
static CGFloat const MAXWAVEHEIGHT = WAVEHEIGHT + 10;//这个数字是设置波浪在scrollView偏移时保持的波峰的最大值的一个系数

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [self.view addSubview:self.scrollView];
    [self.scrollView addSubview:self.wave];
    
    UIButton * btnNext = [[UIButton alloc]initWithFrame:CGRectMake(137, 400, 100, 40)];
    btnNext.backgroundColor = [UIColor blueColor];
    [btnNext setTitle:@"下一页" forState:UIControlStateNormal];
    [btnNext addTarget:self action:@selector(btnNext:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnNext];
    
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)btnNext:(UIButton *)btn{
    NextVC * vc = [[NextVC alloc]init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    //修复滑动未结束时跳转下一个界面再快速返回不触发timer方法的bug
    if (self.timer == nil && self.tmpY != 0.0) {
        [self scrollViewDidEndDecelerating:_scrollView];
    }
}

- (UIScrollView *)scrollView{
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 100, SCREEN.width, SCREEN.height - 200)];
        _scrollView.backgroundColor = [UIColor clearColor];
        _scrollView.delegate = self;
        _scrollView.contentSize = CGSizeMake(0, _scrollView.bounds.size.height + 1);
        
        UIView * topView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN.width, 120+MAXWAVEHEIGHT)];
        topView.backgroundColor = [UIColor whiteColor];;
        [_scrollView addSubview:topView];
        
        UIView * bottomView = [[UIView alloc]initWithFrame:CGRectMake(0, 120+MAXWAVEHEIGHT, SCREEN.width, _scrollView.bounds.size.height - 120 - MAXWAVEHEIGHT)];
        bottomView.backgroundColor = [UIColor colorWithRed:108/255.0
                                                     green:179/255.0
                                                      blue:223/255.0
                                                     alpha:1.0];
        [_scrollView addSubview:bottomView];
        
    }
    return _scrollView;
}

- (EaseWaveView *)wave{
    if (!_wave) {
        _wave = [[EaseWaveView alloc]initWithFrame:CGRectMake(0, 120, SCREEN.width, MAXWAVEHEIGHT)];
        //可以手动修改背景颜色，默认背景颜色clearColor
//        _wave.backgroundColor = [UIColor blueColor];
        //可以手动修改波浪的颜色
//        _wave.backColor = [UIColor purpleColor];
//        _wave.frontColor = [UIColor greenColor];
    }
    return _wave;
}


#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGFloat y = scrollView.contentOffset.y ;
    if (y < -MAXWAVEHEIGHT) {
        y = -MAXWAVEHEIGHT;
    }
    else if (y > MAXWAVEHEIGHT){
        y = MAXWAVEHEIGHT;
    }
    if (y > 0.0) {
        if (self.tmpY > 0.0) {
            self.wave.present = self.tmpY ;
        }else {
            self.wave.present = y ;
        }
        return;
    }
    if (self.tmpY < 0.0) {
        self.wave.present = -self.tmpY ;
    }else {
        self.wave.present = -y ;
    }
}

//松开手时触发一次
- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset{
    CGFloat y =  scrollView.contentOffset.y;
    self.tmpY = y;
    if (self.tmpY < -MAXWAVEHEIGHT) {
        self.tmpY = -MAXWAVEHEIGHT;
    }
    else if (self.tmpY > MAXWAVEHEIGHT){
        self.tmpY = MAXWAVEHEIGHT;
    }
}
//结束滑动后触发一次
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    if (self.tmpY < 0.0) {
        if (self.timer == nil) {
            self.timer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(waveWillDisappearDown) userInfo:nil repeats:YES];
        }
    }else if (self.tmpY > 0.0) {
        if (self.timer == nil) {
            self.timer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(waveWillDisappearUp) userInfo:nil repeats:YES];
        }
    }
    if (self.timer) {
        [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
    }
}
//波浪慢慢下沉的效果
- (void)waveWillDisappearDown{
    self.wave.present = -self.tmpY ;
    self.tmpY += 0.5 ;
    if (self.tmpY > 0.0) {
        [self waveDidDisappear];
    }
}
//波浪慢慢下沉的效果
- (void)waveWillDisappearUp{
    self.wave.present = self.tmpY ;
    self.tmpY -= 0.5;
    if (self.tmpY <= 0.0) {
        [self waveDidDisappear];
    }
}
//波浪恢复平静
- (void)waveDidDisappear{
    self.wave.present = 0.0;
    self.tmpY = 0.0;
    [self.timer invalidate];
    self.timer = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
