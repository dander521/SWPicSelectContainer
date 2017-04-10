//
//  SWPicSelectViewConfig.h
//  SWPicSelectViewConfig
//
//  Created by swain on 16/7/6.
//  Copyright © 2016年 swain. All rights reserved.
//

#ifndef SWPicSelectViewConfig_h
#define SWPicSelectViewConfig_h

typedef NS_OPTIONS(NSInteger, ABNPicSelectState) {
    ABNPicSelectState_Normal   = 0,
    ABNPicSelectState_Empty  = 1,
    ABNPicSelectState_Loading  = 2,
    ABNPicSelectState_Error  = 3,
    ABNPicSelectState_Moveing  = 4
};

typedef NS_OPTIONS(NSInteger, CameraMoveDirection) {
    kCameraMoveDirectionNone   = 0,
    kCameraMoveDirectionUp  = 1,
    kCameraMoveDirectionDown  = 2,
    kCameraMoveDirectionRight  = 3,
    kCameraMoveDirectionLeft  = 4
};

static  const CGFloat gestureMinimumTranslation = 20.0 ;

#define ABNWidth  [UIScreen mainScreen].bounds.size.width
#define CCHeight [UIScreen mainScreen].bounds.size.height

static const int kPicCount = 6;

static const CGFloat kBorderSize = 1.0f;

#endif /* SWPicSelectViewConfig_h */
