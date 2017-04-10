//
//  ViewController.m
//  Demo
//
//  Created by swain on 2017/4/10.
//  Copyright © 2017年 swain. All rights reserved.
//

#import "ViewController.h"

#import "SWPicSelectViewContainer.h"

#define kWindowWidth        ([[UIScreen mainScreen] bounds].size.width)
#define kWindowHeight       ([[UIScreen mainScreen] bounds].size.height)
#define RGBColor(r, g, b)   [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1.0]

@interface ViewController ()

@property (nonatomic,strong)SWPicSelectViewContainer *picSelectView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.view.backgroundColor = RGBColor(255,252,236);
    
    //添加
    [self.view addSubview:self.picSelectView];
    
    NSMutableArray *imageArr = [NSMutableArray array];
    
    [imageArr addObject:[NSURL URLWithString:@"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1491816805633&di=85e496d8da5d5c8ddae9898160127ae0&imgtype=0&src=http%3A%2F%2Fnpic7.edushi.com%2Fcn%2Fzixun%2Fzh-chs%2F2017-03%2F03%2F3824368-2017030316251198.jpg"]];
    [imageArr addObject:[NSURL URLWithString:@"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1491824314063&di=651e79fc3599f6d4cc1b8d8086df45dc&imgtype=0&src=http%3A%2F%2Fimg.tupianzj.com%2Fuploads%2Fallimg%2F160821%2F9-160R1150K2.jpg"]];
    
    [self.picSelectView setABNImageURLArray:imageArr];
    
}

#pragma  mark - ABNPicSelectViewContainerDelegate

- (void)changeSelectImageArray:(NSMutableArray *)imgArray
{
   //返回修改后的图片数组
}

#pragma mark Getter Funciton

-(SWPicSelectViewContainer *)picSelectView
{
    if (_picSelectView==nil) {
        
        _picSelectView=[[SWPicSelectViewContainer alloc] initWithFrame:CGRectMake(0, 64, kWindowWidth,  kWindowWidth) andImageURLArray:nil];
        _picSelectView.deledate = (id)self;
    }
    return _picSelectView;
}


#pragma mark System Function

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
