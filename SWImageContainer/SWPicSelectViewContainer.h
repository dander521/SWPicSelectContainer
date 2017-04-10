//
//  SWPicSelectViewContainer.h
//  SWPicSelectViewContainer
//
//  Created by swain on 2016/11/8.
//  Copyright © 2016年 swain. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SWPicSelectViewConfig.h"
#import "SWPicSelectCardView.h"

@class SWPicSelectCardView;

@protocol SWPicSelectViewContainerDelegate <NSObject>

- (void)changeSelectImageArray:(NSMutableArray *)imgArray;

@end

@interface SWPicSelectViewContainer : UIView


@property (nonatomic,assign)id<SWPicSelectViewContainerDelegate> deledate;

- (instancetype)initWithFrame:(CGRect)frame andImageURLArray:(NSArray *)array;
- (instancetype)initWithFrame:(CGRect)frame andImageArray:(NSArray *)array;

- (void)setABNImageURLArray:(NSMutableArray *)imageURLArray;

//获取当前选择的图片
- (NSMutableArray *)getSelectImageArray;

@end
