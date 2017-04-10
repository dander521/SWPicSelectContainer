//
//  ABNPicSelectCardView.m
//  ABNPicSelectCardView
//
//  Created by swain on 2016/11/8.
//  Copyright © 2016年 swain. All rights reserved.
//

#import "SWPicSelectCardView.h"
#import "UIImageView+WebCache.h"
#import "SWPicSelectViewContainer.h"
#import "UIImage+SWTool.h"
#import "UIActionSheet+Blocks.h"
#import "SWProgressView.h"

#define KeyWindow  [[UIApplication sharedApplication] keyWindow]

@interface SWPicSelectCardView ()


@property (nonatomic,strong)UIImageView *imageView;

@property (nonatomic,strong)UIButton *plusImageView;

@property (nonatomic,strong)UIButton *errorImageView;

@property (nonatomic,strong)SWProgressView *progressView;

@property(nonatomic,strong)UIActionSheet *choiceSheet;

@end

@implementation SWPicSelectCardView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.imgURL = nil;
        self.image = nil;
        self.state = ABNPicSelectState_Empty;
        
        [self initUI];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame andURL:(NSURL *)url
{
    self = [self init];
    if (self) {
        self.frame = frame;
        
        [self setImageByURL:url];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame andImage:(UIImage *)image
{
    self = [self initWithFrame:frame];
    if (self) {
        self.frame = frame;
        
        [self setImageByData:image];
    }
    
    return self;
}

- (void)initUI
{
    self.backgroundColor = [UIColor clearColor];
    
    //添加图片
    self.imageView = [ [UIImageView alloc] init];
    self.imageView.frame = self.bounds;
    self.imageView.contentMode = UIViewContentModeScaleToFill;
    self.imageView.image = [UIImage imageWithColor:[UIColor groupTableViewBackgroundColor]];
    [self addSubview:self.imageView];
    
    //加号图片
    self.plusImageView = [ [UIButton alloc] initWithFrame: CGRectMake(0, 0, 30, 30)];
    [self.plusImageView setImage:[UIImage imageNamed:@"icon_add"] forState:UIControlStateNormal];
    self.plusImageView.center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
    self.plusImageView.userInteractionEnabled = NO;
    [self addSubview:self.plusImageView];
    
    //错误图片
    self.errorImageView = [ [UIButton alloc] initWithFrame: CGRectMake(0, 0, 30, 30)];
    [self.errorImageView setImage:[UIImage imageNamed:@"no"] forState:UIControlStateNormal];
    self.errorImageView.center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
    self.errorImageView.userInteractionEnabled = NO;
    [self addSubview:self.errorImageView];
    
    //加载效果
    [self addSubview:self.progressView];
    self.progressView.hidden = YES;
    
    //更新当前状态
    [self updateCardState];
    
    //添加手势
    [self addHandEvent:self];
}

- (void)uploadImage:(UIImage *)image
{
    if (image) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSData *data = UIImageJPEGRepresentation(image, 1.0);
            
            //上传图片
            
            [self setImageByData:image];
            
        });
    }
    
    
}

#pragma mark - Change Image Function

- (void)setImageByData:(UIImage *)image
{
    self.imageView.image = image;
    self.image = image;
    if (self.progressView.isCircleStop == NO) {
        self.progressView.isCircleStop = YES;
    }
    
    //设置状态
    [self setCardState:ABNPicSelectState_Normal];
}

- (void)setImageByURL:(NSURL *)url
{
    self.imgURL = url;
    
    NSLog(@"设置图片URL %@",[url absoluteString]);
    [self.imageView sd_setImageWithURL:self.imgURL completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (image) {
            self.image = image;
            if (self.progressView.hidden == NO) {
                if (self.progressView.isCircleStop == NO) {
                    self.progressView.isCircleStop = YES;
                }
            }
        }else{
            NSLog(@"%@",error.localizedDescription);
        }
    }];
    
    if (self.deledate && [self.deledate respondsToSelector:@selector(addCardImageSuccess)]) {
        [self.deledate addCardImageSuccess];
    }
    
    //设置状态
    [self setCardState:ABNPicSelectState_Normal];
}

- (void)setNormalImage
{
    //设置状态
    [self setCardState:ABNPicSelectState_Normal];
}

- (void)setLoadingImage:(UIImage *)image;
{
    if (image) {
        self.image = image;
    }
    
    self.imageView.image = [UIImage imageWithColor:[UIColor groupTableViewBackgroundColor]];
    self.imgURL = nil;
    self.progressView.hidden = NO;
    self.progressView.isCircleStop = NO;
    [self.progressView startCircleAnimation:^(BOOL isFinish) {
        self.progressView.hidden = YES;
    }];
    
    //设置状态
    [self setCardState:ABNPicSelectState_Loading];
    
    [self uploadImage:image];
}

- (void)setErrorImage
{
    self.image = [[UIImage alloc] init];
    //设置状态
    [self setCardState:ABNPicSelectState_Error];
}

/* 设置删除图片 **/
- (void)setDeleteImage
{
    self.image = nil;
    self.imageView.image = [UIImage imageWithColor:[UIColor groupTableViewBackgroundColor]];
    self.imgURL = nil;
    
    //设置状态
    [self setCardState:ABNPicSelectState_Empty];
    
    //调整位置
    if (self.deledate && [self.deledate respondsToSelector:@selector(deleteImageSortList:)]) {
        [self.deledate deleteImageSortList:self.tag];
    }
   
}

/* 设置重新加载图片 **/
- (void)setReLoadingImage
{
    [self setLoadingImage:self.image];
}

- (void)changeStateToMoving
{
    [self setCardState:ABNPicSelectState_Moveing];
}

#pragma mark - State Change Function

- (void)updateCardState
{
    if (self.state == ABNPicSelectState_Empty) {//待设置图片状态
        self.plusImageView.hidden = NO;
        self.imageView.hidden = NO;
        self.errorImageView.hidden = YES;
        self.progressView.isCircleStop = YES;
        self.progressView.hidden = YES;
    }else if(self.state == ABNPicSelectState_Normal) {//有图片状态
        self.plusImageView.hidden = YES;
        self.imageView.hidden = NO;
         self.errorImageView.hidden = YES;
    }else if(self.state == ABNPicSelectState_Loading) {//加载图片状态
        self.plusImageView.hidden = YES;
        self.imageView.hidden = NO;
        self.errorImageView.hidden = YES;
    }else if(self.state == ABNPicSelectState_Error) {//加载失败状态
        self.plusImageView.hidden = YES;
        self.imageView.hidden = NO;
        self.errorImageView.hidden = NO;
        self.progressView.isCircleStop = YES;
        self.progressView.hidden = YES;
    }else if(self.state == ABNPicSelectState_Moveing){//移动状态
        self.plusImageView.hidden = YES;
        self.imageView.hidden = NO;
        self.errorImageView.hidden = YES;
        self.progressView.isCircleStop = YES;
        self.progressView.hidden = YES;
    }
}

- (void)setCardState:(ABNPicSelectState)state
{
    self.state = state;
    if (self.state == ABNPicSelectState_Empty) {//待设置图片状态
        self.plusImageView.hidden = NO;
        self.imageView.hidden = NO;
        self.errorImageView.hidden = YES;
        self.progressView.isCircleStop = YES;
        self.progressView.hidden = YES;
    }else if(self.state == ABNPicSelectState_Normal) {//有图片状态
        self.plusImageView.hidden = YES;
        self.imageView.hidden = NO;
        self.errorImageView.hidden = YES;
    }else if(self.state == ABNPicSelectState_Loading) {//加载图片状态
        self.plusImageView.hidden = YES;
        self.imageView.hidden = NO;
        self.errorImageView.hidden = YES;
    }else if(self.state == ABNPicSelectState_Error) {//加载失败状态
        self.plusImageView.hidden = YES;
        self.imageView.hidden = NO;
        self.errorImageView.hidden = NO;
        self.progressView.isCircleStop = YES;
        self.progressView.hidden = YES;
    }else if(self.state == ABNPicSelectState_Moveing){//移动状态
        self.plusImageView.hidden = YES;
        self.imageView.hidden = NO;
        self.errorImageView.hidden = YES;
        self.progressView.isCircleStop = YES;
        self.progressView.hidden = YES;
    }
}

#pragma mark - Getter

- (SWProgressView *)progressView
{
    if (_progressView == nil) {
        _progressView = [[SWProgressView alloc] initWithFrame:CGRectMake(self.frame.size.width*0.5-25,self.frame.size.height*0.50 -25, 50, 50)];
    }
    return _progressView;
}

- (void)addHandEvent:(UIView *)view
{
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureHandle:)];
    [view addGestureRecognizer:tap];
}

-(void)tapGestureHandle:(UITapGestureRecognizer *)sender
{
    SWPicSelectCardView *cardView = (SWPicSelectCardView *)sender.view;
    
    if (cardView.image && cardView.state == ABNPicSelectState_Error) {

        int delImgIndex=0;
        int reuploadIndex=1;
        NSArray *titles=@[@"删除图片",@"重新上传一次"];
        
        [UIActionSheet showInView:KeyWindow
                        withTitle:nil
                cancelButtonTitle:@"取消"
           destructiveButtonTitle:nil
                otherButtonTitles:titles
                         tapBlock:^(UIActionSheet *actionSheet, NSInteger buttonIndex) {
                             if (buttonIndex==delImgIndex) {
                                 [self setDeleteImage];
                             }else if(buttonIndex == reuploadIndex){
                                 [self setLoadingImage:nil];
                             }else if (buttonIndex == -1){
                                 
                             }
                         }];
        
        return;
    }else if (cardView.image && (cardView.state == ABNPicSelectState_Normal || cardView.state == ABNPicSelectState_Loading)) {
        int delImgIndex=0;
        NSArray *titles=@[@"删除图片"];

        [UIActionSheet showInView:KeyWindow
                        withTitle:nil
                cancelButtonTitle:@"取消"
           destructiveButtonTitle:nil
                otherButtonTitles:titles
                         tapBlock:^(UIActionSheet *actionSheet, NSInteger buttonIndex) {
                             if (buttonIndex==delImgIndex) {
                                 [self setDeleteImage];
                             }else if (buttonIndex == -1){
                                 
                             }
                         }];
        
        return;
    }
    
    @try{
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.modalPresentationStyle= UIModalPresentationOverFullScreen;
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
       
        imagePicker.delegate = (id)self;
        [KeyWindow.rootViewController presentViewController:imagePicker animated:YES completion:nil];
        [[UIApplication sharedApplication].keyWindow endEditing:YES];
    }
    @catch(NSException *exception) {
        NSLog(@"exception:%@", exception);
    }
    @finally {
        
    }
    
    
}

#pragma mark UIImagePickerControllerDelegate

// 取消选择
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    // 退出当前界面
    [picker dismissViewControllerAnimated:YES completion:nil];
}

// 选择完成
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    if (self.deledate && [self.deledate respondsToSelector:@selector(addCardImageManage:)]) {
        [self.deledate addCardImageManage:[info objectForKey:UIImagePickerControllerOriginalImage]];
    }
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (self.image && self.state == ABNPicSelectState_Error) {
        if (buttonIndex == 0) {//删除图片
            [self setDeleteImage];
        } else if (buttonIndex == 1) {//重新上传
            [self setLoadingImage:nil];
            
        }
        
    }else if (self.image &&( self.state == ABNPicSelectState_Normal ||  self.state == ABNPicSelectState_Loading)) {
        if (buttonIndex == 0) {//删除图片
            [self setDeleteImage];
        }
    }
    
    [self.choiceSheet dismissWithClickedButtonIndex:0 animated:YES];
    [self.choiceSheet removeFromSuperview];
    self.choiceSheet = nil;

}


#pragma mark - System Function

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.imageView.frame = self.bounds;
    self.plusImageView.frame = self.bounds;
    self.errorImageView.frame = self.bounds;
    self.progressView.frame = CGRectMake(self.bounds.origin.x+self.bounds.size.width*0.5-25,self.bounds.origin.y+self.bounds.size.height*0.50 -25, 50, 50);
}

- (void)setAnchorPoint:(CGPoint)anchorPoint
{
    self.layer.anchorPoint = anchorPoint;
    self.imageView.layer.anchorPoint = anchorPoint;
}

- (void)setDefaultAnchorPoint:(UIView *)view
{
    self.layer.anchorPoint = CGPointMake(0.5, 0.5);
    self.imageView.layer.anchorPoint = CGPointMake(0.5, 0.5);;
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
}

@end
