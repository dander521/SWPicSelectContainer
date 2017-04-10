# SWPicSelectContainer
仿"探探"上传图片控件-支持滑动,拖拽,上传
# Demo
![Demo gif](Demo/screengif.gif)

# Installation
```
git => "https://github.com/heartfly/SWPicSelectContainer.git"
```

# Usage
* Initialization
```
SWPicSelectViewContainer *picSelectView=[[SWPicSelectViewContainer alloc] initWithFrame:CGRectMake(0, 64, kWindowWidth,  kWindowWidth) andImageURLArray:nil];
picSelectView.deledate = (id)self;
[self.view addSubview:picSelectView];
    
    
```
* DataSource & Delegate
```
     
NSMutableArray *imageArr = [NSMutableArray array];
[imageArr addObject:[NSURL URLWithString:@"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1491816805633&di=85e496d8da5d5c8ddae9898160127ae0&imgtype=0&src=http%3A%2F%2Fnpic7.edushi.com%2Fcn%2Fzixun%2Fzh-chs%2F2017-03%2F03%2F3824368-2017030316251198.jpg"]];
[imageArr addObject:[NSURL URLWithString:@"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1491824314063&di=651e79fc3599f6d4cc1b8d8086df45dc&imgtype=0&src=http%3A%2F%2Fimg.tupianzj.com%2Fuploads%2Fallimg%2F160821%2F9-160R1150K2.jpg"]];
[picSelectView setABNImageURLArray:imageArr];
    
    
#pragma  mark - ABNPicSelectViewContainerDelegate
- (void)changeSelectImageArray:(NSMutableArray *)imgArray
{
   //返回修改后的图片数组
}
