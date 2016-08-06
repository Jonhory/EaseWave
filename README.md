EaseWave For iOS Demo

Demo链接：github:<https://github.com/JonHory/EaseWave>

###效果图
![Icon](https://raw.githubusercontent.com/JonHory/EaseWave/master/waveGif.gif)

###绘制基础
* 正弦函数y = A sin ( ax + b) + c;   
  
  A代表峰值，a代表周期，b代表在x方向的偏移量，c代表在y方向的偏移量

  理解了这些参数我们就可以随意修改波浪的效果。
  
  在本效果中，后波浪的参数:
  
      float A = _A ;
      float a = 3 / rect.size.width * M_PI ;
      float b = 2 * _b / rect.size.width * M_PI;  
      float c = (1 - self.present) * rect.size.height ;

  前波浪的参数:
  
      float A = _A ;
      float a = 3 / rect.size.width * M_PI ;
      float b = (_b / rect.size.width + 1 )* M_PI;
      float c = (1 - self.present) * rect.size.height ;
        
* 使用CADisplayLink来控制波浪产生位移效果
    
      //让波浪左右移动效果 10可以尝试修改
      _b = _b + 10;
      if (_b >= self.frame.size.width * 2.0) {
          _b = 0;
      }
      [self setNeedsDisplay];


###使用帮助
####具体使用的代码可以看github Demo代码,这里只写一些关键点
在VC.m文件中增加属性

    @property (nonatomic ,strong) UIScrollView * scrollView;
    @property (nonatomic ,strong) EaseWaveView * wave;/**< 波浪*/
    @property (nonatomic ,strong) NSTimer      * timer;/**< 定时器控制波浪逐渐变小*/
    @property (nonatomic ,assign) CGFloat      tmpY;/**< 手指离开屏幕时保存的最大偏移量*/
    

参数设置

    static CGFloat const WAVEHEIGHT    = 50.0;//波浪视图高度
    static CGFloat const MAXWAVEHEIGHT = WAVEHEIGHT + 10;//这个数字是设置波浪在scrollView偏移时保持的波峰的最大值的一个系数
    
###波浪视图创建方法很简单

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
    
###关键代码
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


###特别注意，修复一个BUG

    - (void)viewWillDisappear:(BOOL)animated{
        [super viewWillDisappear:animated];
        //修复滑动未结束时跳转下一个界面再快速返回不触发timer方法的bug
        if (self.timer == nil && self.tmpY != 0.0) {
            [self scrollViewDidEndDecelerating:_scrollView];
        }
    }