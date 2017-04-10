//
//  ABNPicSelectCardView.h
//  ABNPicSelectCardView
//
//  Created by swain on 2016/11/8.
//  Copyright © 2016年 swain. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWPicSelectViewConfig.h"

@class SWPicSelectCardView;
@protocol SWPicSelectCardViewDelegate <NSObject>

- (void)picSelectCardViewClick:(SWPicSelectCardView*)view andIndex:(NSInteger)index;

- (void)deleteImageSortList:(NSInteger)tag;

-  (void)addCardImageManage:(UIImage*)image;

-  (void)addCardImageSuccess;

- (void)addUIImageTouchEvent:(SWPicSelectCardView *)view;

@end

@interface SWPicSelectCardView : UIView

@property (nonatomic,assign)id<SWPicSelectCardViewDelegate> deledate;

/* 当前控件状态 **/
@property (nonatomic) ABNPicSelectState state;

- (instancetype)initWithFrame:(CGRect)frame;

- (instancetype)initWithFrame:(CGRect)frame andURL:(NSURL *)url;

- (instancetype)initWithFrame:(CGRect)frame andImage:(UIImage *)image;

@property (nonatomic,strong)UIImage *image;

@property (nonatomic,strong)NSURL *imgURL;

/* 设置图片 **/
- (void)setImageByData:(UIImage *)image;
- (void)setImageByURL:(NSURL *)url;

/* 设置成加载状态 **/
- (void)setLoadingImage:(UIImage *)image;
/* 设置成加载失败状态 **/
- (void)setErrorImage;

/* 设置删除图片 **/
- (void)setDeleteImage;

/* 设置重新加载图片 **/
- (void)setReLoadingImage;

/* 转变为拖动模式 **/
- (void)changeStateToMoving;

/* 设置为正常状态 **/
- (void)setNormalImage;

- (void)setAnchorPoint:(CGPoint)anchorPoint;
- (void)setDefaultAnchorPoint:(UIView *)view;

@end
