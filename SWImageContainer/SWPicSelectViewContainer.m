//
//  SWPicSelectViewContainer.m
//  SWPicSelectViewContainer
//
//  Created by swain on 2016/11/8.
//  Copyright © 2016年 swain. All rights reserved.
//

#import "SWPicSelectViewContainer.h"
#import "pop/POP.h"
#import <objc/runtime.h>

@interface SWPicSelectViewContainer ()
{
    BOOL contain;
    CGPoint startPoint;
    CGPoint originPoint;
    CGRect  originRect;
    CameraMoveDirection direction;
}

@property (nonatomic,strong) NSMutableArray *imageURLArray;

@property (nonatomic,strong) NSMutableArray *imageDataArray;

@property (nonatomic,strong) NSMutableArray<SWPicSelectCardView *> *cardArray;

@property (nonatomic,strong) NSMutableArray<NSValue*> *cardRectArray;

@property (nonatomic,strong) UIImageView *dargImageView;

@property (nonatomic,strong) SWPicSelectCardView *dargCardView;

@property (nonatomic,assign) CGFloat card_width;

@property (nonatomic,assign) BOOL moving;

@property (nonatomic,assign) BOOL isChangeingCard;

@end

@implementation SWPicSelectViewContainer

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self){
        self.cardArray = [NSMutableArray array];
        self.cardRectArray = [NSMutableArray array];
        [self addTouchEvent];
        
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame andImageURLArray:(NSArray *)array
{
    self = [self initWithFrame:frame];
    if (self) {
        self.imageURLArray = (id)array;
        
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame andImageArray:(NSArray *)array
{
    self = [self initWithFrame:frame];
    if (self) {
        self.imageDataArray = (id)array;
    }
    return self;
}

- (void)addTouchEvent
{
    // 添加清扫手势
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureHandle:)];
    [self addGestureRecognizer:pan];
    //长按手势
    UILongPressGestureRecognizer *longPressDrag = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressGestureHandle:)];
    longPressDrag.minimumPressDuration = 0.2;
    [self addGestureRecognizer:longPressDrag];
}

- (void)setABNImageURLArray:(NSMutableArray *)imageURLArray
{
    [self clearViewData];
    
    self.imageURLArray = imageURLArray;
    
    [self loadCardView];
}

- (void)clearViewData
{
    if (self.cardArray.count>0) {
        [self.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [obj removeFromSuperview];
        }];
    }
    
    [self.cardArray removeAllObjects];
    [self.cardRectArray removeAllObjects];
    [self.imageDataArray removeAllObjects];
}

- (void)loadCardView
{
    CGRect frame = self.bounds;
    NSInteger eitherRowCardCount = (kPicCount - 2)/2;
    CGFloat card_width = frame.size.width / ((kPicCount - 2)/2+1);
    CGFloat card_height = frame.size.height / ((kPicCount - 2)/2+1);
    self.card_width = card_width;
    //添加第一个
    CGRect firstCardFrame = CGRectMake(0,0, card_width * eitherRowCardCount -kBorderSize, card_height *eitherRowCardCount -kBorderSize);

    SWPicSelectCardView *view;
    if (self.imageURLArray) {
       view = [[SWPicSelectCardView alloc] initWithFrame:firstCardFrame andURL:self.imageURLArray[0]];

    }
    view.tag = 0;
    view.deledate = (id)self;
    [self.cardArray addObject:view];
    [self.cardRectArray addObject:[NSValue valueWithCGRect:firstCardFrame]];
    [self insertSubview:view atIndex:0];
    
    
    //添加右半边
    for (int i=1; i<kPicCount; i++) {
        CGFloat card_posx=0;
        CGFloat card_posy=0;
        CGFloat cardwidth=0;
        CGFloat cardheight=0;
        if (i> ((kPicCount-2)/2 +1)) {//横排的
            int chaIndex = i- ((kPicCount-2)/2 +1);
            card_posx= firstCardFrame.origin.x + card_width * eitherRowCardCount - card_width*chaIndex;
            card_posy= firstCardFrame.origin.y + ((kPicCount-2)/2)*card_height;
            cardwidth= card_width-kBorderSize;
            cardheight= card_height - kBorderSize;
        }else{//竖排的
            card_posx= firstCardFrame.origin.x + card_width * eitherRowCardCount;
            card_posy= firstCardFrame.origin.y + (i-1)*card_height;
            cardwidth= card_width;
            cardheight= card_height-kBorderSize;
        }
        
        
        CGRect cardFrame = CGRectMake(card_posx, card_posy, cardwidth, cardheight );
        
        NSURL *imageURL = nil;
        if (self.imageURLArray.count > i) {
            imageURL = self.imageURLArray[i];
        }
        SWPicSelectCardView *view;
        
        if (self.imageURLArray) {
            if (imageURL) {
                view = [[SWPicSelectCardView alloc] initWithFrame:cardFrame andURL:imageURL];
            }else{
                view = [[SWPicSelectCardView alloc] initWithFrame:cardFrame];
            }
            
        }else{
            
        }
        view.tag = i;
        view.deledate = (id)self;
        [self.cardArray addObject:view];
        [self.cardRectArray addObject:[NSValue valueWithCGRect:cardFrame]];
        [self insertSubview:view atIndex:0];
        
    }

}

- (NSMutableArray *)getSelectImageArray
{
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:kPicCount];
    
    if (self.imageURLArray) {
        [_cardArray enumerateObjectsUsingBlock:^(SWPicSelectCardView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj.state == ABNPicSelectState_Normal && obj.imgURL ) {
                [array addObject:obj.imgURL];
            }
        
        }];
    }else if(self.imageDataArray){
        [_cardArray enumerateObjectsUsingBlock:^(SWPicSelectCardView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj.state == ABNPicSelectState_Normal && obj.image ) {
                array[obj.tag] = obj.image;
            }
        }];
    }
    return array;
}


- (SWPicSelectCardView *)checkViewContainPoint:(CGPoint) point containDrap:(BOOL)iscontainDrap
{
    __block CGPoint checkpoint = point;
    __block NSInteger index = -1;
 
    [self.cardArray enumerateObjectsUsingBlock:^(SWPicSelectCardView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.image != nil) {
            if (iscontainDrap == YES) {//是否包含正在拖拽的项
                if (CGRectContainsPoint(CGRectMake(obj.frame.origin.x+kBorderSize, obj.frame.origin.y +kBorderSize, obj.frame.size.width - kBorderSize*2, obj.frame.size.width - kBorderSize*2), checkpoint))
                {
                    index = idx;
                    *stop = YES;
                }
            }else{
                if (CGRectContainsPoint(CGRectMake(obj.frame.origin.x+kBorderSize, obj.frame.origin.y +kBorderSize, obj.frame.size.width - kBorderSize*2, obj.frame.size.width - kBorderSize*2), checkpoint) && obj.tag!=self.dargCardView.tag )
                {
                    index = idx;
                    *stop = YES;
                }
            }
        }
    }];
    
    if (index != -1) {
        return self.cardArray[index];
    }else{
        return nil;
    }
}

- (void)sortImageArrayByTag
{
    [self.cardArray sortUsingComparator:^NSComparisonResult(SWPicSelectCardView *obj1, SWPicSelectCardView *obj2) {
        
        if (obj1.tag < obj2.tag) {
            
            return NSOrderedAscending;
            
        } else if (obj1.tag > obj2.tag) {
            
            return NSOrderedDescending;
            
        } else {
            
            return NSOrderedSame;
            
        }
    }];
}

- (void)changeItemToOtherPlaceByTag:(NSInteger)tag
{
    //要换的tag
    NSInteger dragViewTag = self.dargCardView.tag;
    
    SWPicSelectCardView *cardview= self.cardArray[tag];
    cardview.tag = dragViewTag;
    
    self.dargCardView.tag = tag;
    
    [self sortImageArrayByTag];
    //换位置
    
    [UIView animateWithDuration:0.4
                          delay:0.0
         usingSpringWithDamping:0.6
          initialSpringVelocity:0.4
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         cardview.frame = [self.cardRectArray[dragViewTag] CGRectValue];
                     }
                     completion:^(BOOL finished) {
                         self.isChangeingCard = NO;
                         [self changeCardImageSuccess];
                     }];
}

- (void)changeCardViewByDirection:(CameraMoveDirection)state
{
    //如果当前没有图片就返回
    NSInteger numEmptyIndex = [self checkArrayNotEmptyIndex];
    if (numEmptyIndex == -1) {
        return;
    }
    
    if (state == kCameraMoveDirectionLeft) {
        [self.cardArray enumerateObjectsUsingBlock:^(SWPicSelectCardView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj.image) {
                if (obj.tag+1 <= self.cardArray.count-1) {
                    if (self.cardArray[obj.tag+1].image) {
                        obj.tag +=1;
                    }else{
                        obj.tag = 0;
                    }
                    
                }else{
                    obj.tag = 0;
                }
                [self effect_ChangeToFrame:obj toRect:[self.cardRectArray[obj.tag] CGRectValue]];
            }
        }];
        
    }else if (state == kCameraMoveDirectionRight){
        [self.cardArray enumerateObjectsUsingBlock:^(SWPicSelectCardView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj.image) {
                if (obj.tag-1 >= 0) {
                    if (self.cardArray[obj.tag-1].image) {
                        obj.tag -=1;
                    }else{
                        obj.tag = numEmptyIndex;
                    }
                    
                }else{
                    obj.tag = numEmptyIndex;
                }
                [self effect_ChangeToFrame:obj toRect:[self.cardRectArray[obj.tag] CGRectValue]];
            }
        }];
    }
    
    [self sortImageArrayByTag];
    
    [self changeCardImageSuccess];
}

- (NSUInteger)checkArrayNotEmptyIndex
{
    __block NSUInteger index = -1;
    [self.cardArray enumerateObjectsUsingBlock:^(SWPicSelectCardView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.image == nil) {
            *stop = YES;
        }else{
            index = idx;
        }
    }];
    
    return index;
}

#pragma mark Hand Event

-(void)longPressGestureHandle:(UILongPressGestureRecognizer *)sender
{
    //NSLog(@"长按 %ld",self.tag);
    
    if (sender.state == UIGestureRecognizerStateBegan)
    {
        startPoint = [sender locationInView:self];
        
        SWPicSelectCardView *cardView= [self checkViewContainPoint:startPoint containDrap:YES];
        
        if (cardView) {
            self.dargCardView = cardView;
            originPoint = self.dargCardView.center;
            originRect = self.dargCardView.frame;
            [self bringSubviewToFront:self.dargCardView];
            
            [self.dargCardView changeStateToMoving];
            
            CGFloat changeWidth = _card_width*0.7;
            
            CGRect frame = CGRectMake(startPoint.x, startPoint.y, changeWidth, changeWidth);
            //缩小
            [self effect_ChangeBounds:self.dargCardView toRect:frame];
        }
        //NSLog(@"长按:开始");
    }else if (sender.state == UIGestureRecognizerStateChanged)
    {
        if (self.dargCardView) {
            CGPoint newPoint = [sender locationInView:self];
            self.dargCardView.center = newPoint;
            
            if(self.isChangeingCard == NO){
                self.isChangeingCard = YES;
                //NSLog(@"当前拖拽的tag:%ld",self.dargCardView.tag);
                SWPicSelectCardView *cardView=[self checkViewContainPoint:newPoint containDrap:NO];
                if (cardView && (cardView.tag != self.dargCardView.tag )) {
                    //NSLog(@"需要跟%ld换位置",cardView.tag);
                    
                    [self changeItemToOtherPlaceByTag:cardView.tag];
                }else{
                    self.isChangeingCard = NO;
                }
            }
        }
        //NSLog(@"长按:移动");
    }else if (sender.state == UIGestureRecognizerStateEnded)
    {
        if (self.dargCardView) {
            CGRect rect = [self.cardRectArray[self.dargCardView.tag] CGRectValue];
            
            [self effect_ChangeToFrame:self.dargCardView toRect:CGRectMake(rect.origin.x, rect.origin.y, rect.size.width,  rect.size.height)];
            
            [self.dargCardView setNormalImage];
            
            [self exchangeSubviewAtIndex:1 withSubviewAtIndex:0];
            self.dargCardView = nil;
            
        }
        
        //NSLog(@"长按:结束");
    }
}

- (void)panGestureHandle:( UIPanGestureRecognizer *)gesture
{
    CGPoint translation = [gesture translationInView: self];
    
    if (gesture.state == UIGestureRecognizerStateBegan )
    {
        direction = kCameraMoveDirectionNone;
    }
    
    else if (gesture.state == UIGestureRecognizerStateChanged && direction == kCameraMoveDirectionNone)
    {
        
        direction = [ self determineCameraDirectionIfNeeded:translation];
        
        switch (direction) {
                
            case kCameraMoveDirectionDown:
                
                //NSLog (@ "Start moving down" );
                
                break ;
                
            case kCameraMoveDirectionUp:
                
                //NSLog (@ "Start moving up" );
                
                break ;
                
            case kCameraMoveDirectionRight:
                
                //NSLog (@ "Start moving right" );
                [self changeCardViewByDirection:kCameraMoveDirectionRight];
                
                break ;
                
            case kCameraMoveDirectionLeft:
                
                //NSLog (@ "Start moving left" );
                [self changeCardViewByDirection:kCameraMoveDirectionLeft];
                
                break ;
                
            default :
                
                break ;
        }
    }
    
    else if (gesture.state == UIGestureRecognizerStateEnded )
    {
        // now tell the camera to stop
        
    }
    
}

// This method will determine whether the direction of the user's swipe

- ( CameraMoveDirection )determineCameraDirectionIfNeeded:( CGPoint )translation
{
    
    if (direction != kCameraMoveDirectionNone)
        
        return direction;
    
    // determine if horizontal swipe only if you meet some minimum velocity
    
    if (fabs(translation.x) > gestureMinimumTranslation)
        
    {
        
        BOOL gestureHorizontal = NO;
        
        if (translation.y == 0.0 )
            
            gestureHorizontal = YES;
        
        else
            
            gestureHorizontal = (fabs(translation.x / translation.y) > 5.0 );
        
        if (gestureHorizontal)
            
        {
            
            if (translation.x > 0.0 )
                
                return kCameraMoveDirectionRight;
            
            else
                
                return kCameraMoveDirectionLeft;
            
        }
        
    }
    
    // determine if vertical swipe only if you meet some minimum velocity
    
    else if (fabs(translation.y) > gestureMinimumTranslation)
        
    {
        
        BOOL gestureVertical = NO;
        
        if (translation.x == 0.0 )
            
            gestureVertical = YES;
        
        else
            
            gestureVertical = (fabs(translation.y / translation.x) > 5.0 );
        
        if (gestureVertical)
            
        {
            
            if (translation.y > 0.0 )
                
                return kCameraMoveDirectionDown;
            
            else
                
                return kCameraMoveDirectionUp;
            
        }
        
    }
    
    return direction;
    
}

#pragma mark - ABNPicSelectCardViewDelegate

- (void)picSelectCardViewClick:(SWPicSelectCardView*)view andIndex:(NSInteger)index
{
    
}

/* 删除图片时，对数组排队**/
- (void)deleteImageSortList:(NSInteger)tag
{
    //后面都是被删除的图片
    if (tag + 1 <= self.cardArray.count-1) {
        if (self.cardArray[tag+1].image == nil) {
            [self changeCardImageSuccess];
            return;
        }else{
        
        }
    }else{
        [self changeCardImageSuccess];
        return;
    }
    __block BOOL needMove = NO;
    __block int moveType = 0;
    
    [self.cardArray enumerateObjectsUsingBlock:^(SWPicSelectCardView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if(obj.image == nil && idx == 0 && needMove == NO) {
            
            needMove = YES;
            moveType = 1;//首位删除移动判断
            obj.tag -= 1;
            if (obj.tag< 0) {
                obj.tag = self.cardArray.count-1;
            }
        }else if(moveType == 1){
            
            obj.tag -= 1;
            if (obj.tag< 0) {
                obj.tag = self.cardArray.count-1;
            }
            
        }
        
        if (obj.image == nil && idx!=0 && needMove == NO){
        
            obj.tag = self.cardArray.count-1;
            
            needMove = YES;
            moveType = 2;//后面某一位移动判断
        }else if(moveType == 2){
            obj.tag -= 1;
            if (obj.tag< 0) {
                obj.tag = self.cardArray.count-1;
            }
        }
        
        
        if (needMove) {
            //调整位子
            NSValue *frameValue = self.cardRectArray[obj.tag];
            [self viewCardChangeToFrame:[frameValue CGRectValue] View:obj];
        }
        
    }];
    
    //按照tag排序
    [self sortImageArrayByTag];
    
    [self changeCardImageSuccess];
}

//添加图片管理
-  (void)addCardImageManage:(UIImage*)image
{
    [self.cardArray enumerateObjectsUsingBlock:^(SWPicSelectCardView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.image == nil) {
            [obj setLoadingImage:image];
            * stop = YES;
        }
    }];
    
    [self changeCardImageSuccess];
}


-  (void)addCardImageSuccess
{
    [self changeCardImageSuccess];
}

-  (void)changeCardImageSuccess
{
    if (self.deledate && [self.deledate respondsToSelector:@selector(changeSelectImageArray:)]) {
        [self.deledate changeSelectImageArray:[self getSelectImageArray]];
    }
}


- (void)addUIImageTouchEvent:(SWPicSelectCardView *)view
{
    //self.dargImageView =  [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, rect.size.width*0.5, rect.size.width*0.5)];
    //[self addSubview:self.dargImageView];
    [self.dargCardView exchangeSubviewAtIndex:0 withSubviewAtIndex:1];
}

#pragma mark ViewCard Animation

- (void)viewCardChangeToFrame:(CGRect) frame View:(UIView *)view
{
    [UIView animateWithDuration:0.5
                          delay:0.0
         usingSpringWithDamping:0.6
          initialSpringVelocity:0.4
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         view.frame = frame;
                     }
                     completion:^(BOOL finished) {
                         
                     }];
}

- (void)effect_ChangeBounds:(UIView *)view toRect:(CGRect)rect
{
    POPSpringAnimation *anim = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerBounds];
    anim.toValue = [NSValue valueWithCGRect:rect];
    [view pop_addAnimation:anim forKey:@"size"];
}

- (void)effect_ChangeToFrame:(UIView *)view toRect:(CGRect)rect
{
    POPSpringAnimation *anim = [POPSpringAnimation animationWithPropertyNamed:@"view.frame"];
    anim.toValue = [NSValue valueWithCGRect:rect];
    [view pop_addAnimation:anim forKey:@"frame"];
}

#pragma mark System Function



@end
