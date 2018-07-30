//
//  DragCardView.m
//  DragCardView
//
//  Created by admin on 27/7/18.
//

#import "DragCardView.h"
#import "DragCardItemView.h"
#import "DargCardHeader.h"

#define CARD_NUM 4
#define MIN_INFO_NUM 10
#define CARD_SCALE 0.95

@interface DragCardView ()<DragCardItemViewDelegate>

@property (nonatomic, strong) NSMutableArray *allCards;

@property (nonatomic, assign) CGPoint lastCardCenter;
@property (nonatomic, assign) CGAffineTransform lastCardTTransform;
@property (nonatomic, strong) NSMutableArray *sourceObject;
@property (nonatomic, strong) UIButton *likeBtn;
@property (nonatomic, strong) UIButton *disLikeBtn;

@property (nonatomic, assign) BOOL flag;

@end

@implementation DragCardView

-(instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.allCards = [NSMutableArray array];
        self.sourceObject = [NSMutableArray array];
        self.page = 0;
        
        [self addControls];
        [self addCards];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self requestSourceData:YES];
        });
    }
    return  self;
}

/* 添加控件 */
- (void)addControls {
    UIButton *reloadBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [reloadBtn setTitle:@"重置" forState:UIControlStateNormal];
    reloadBtn.frame = CGRectMake([UIScreen mainScreen].bounds.size.width / 2 - 25, [UIScreen mainScreen].bounds.size.height - 60, 50, 30);
    [reloadBtn addTarget:self action:@selector(refreshAllCards) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:reloadBtn];
    
    self.disLikeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.disLikeBtn.frame = CGRectMake(lengthFit(80), CARD_HEIGHT + lengthFit(100), 60, 60);
    [self.disLikeBtn setImage:[UIImage imageNamed:@"dislikeBtn"] forState:UIControlStateNormal];
    [self.disLikeBtn addTarget:self action:@selector(leftButtonClickAction) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.disLikeBtn];
    
    
    self.likeBtn = [UIButton buttonWithType: UIButtonTypeCustom];
    self.likeBtn.frame = CGRectMake([UIScreen mainScreen].bounds.size.width - lengthFit(140), CARD_HEIGHT + lengthFit(100), 60, 60);
    [self.likeBtn setImage:[UIImage imageNamed:@"likeBtn"] forState:UIControlStateNormal];
    [self.likeBtn addTarget:self action:@selector(rightButtonClickAction) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.likeBtn];
}

/* 刷新所有卡片 */
- (void)refreshAllCards {
    self.sourceObject = [@[] mutableCopy];
    self.page = 0;
    for (NSInteger i = 0; i < _allCards.count; i++) {
        DragCardItemView *card = self.allCards[i];
        CGPoint finishPoint = CGPointMake(-CARD_WIDTH, 2 * PAN_DISTANCE + card.frame.origin.y);
        [UIView animateKeyframesWithDuration:0.5 delay:0.06 * i options:UIViewKeyframeAnimationOptionCalculationModeLinear animations:^{
            card.center = finishPoint;
            card.transform = CGAffineTransformMakeRotation(-ROTATION_ANGLE);
        } completion:^(BOOL finished) {
            
            card.yesButton.transform = CGAffineTransformMakeScale(1, 1);
            card.transform = CGAffineTransformMakeRotation(ROTATION_ANGLE);
            card.hidden = YES;
            card.center = CGPointMake([[UIScreen mainScreen] bounds].size.width + CARD_WIDTH, self.center.y);
            if (i == self.allCards.count - 1) {
                [self requestSourceData:YES];
            }
        }];
    }
}

/* 请求数据 */
- (void)requestSourceData:(BOOL)needLoad {
    
    if ([self.dataSource respondsToSelector:@selector(requestSourceData)]) {
        NSMutableArray *objectArray = [@[] mutableCopy];
        objectArray = [self.dataSource requestSourceData];
        
        if (objectArray.count == 0) {
            return;
        }
        
        [self.sourceObject addObjectsFromArray: objectArray];
        self.page++;
        
        //如果只是补充数据则不需要重新load卡片，而若是刷新卡片组则需要重新load
        if (needLoad) {
            [self loadAllCards];
        }
    }
}
/* 重新加载卡片 */
- (void)loadAllCards {
    for (NSInteger i = 0; i < self.allCards.count; i++) {
        DragCardItemView *draggableView = self.allCards[i];
        if ([self.sourceObject firstObject]) {
            draggableView.infoDict = [self.sourceObject firstObject];
            [self.sourceObject removeObjectAtIndex:0];
            [draggableView layoutSubviews];
            draggableView.hidden = NO;
        }else{
            //如果没有数据则隐藏卡片
            draggableView.hidden = YES;
        }
    }
    
    for (NSInteger i = 0; i < _allCards.count; i++) {
        DragCardItemView *draggableView = self.allCards[i];
        CGPoint finishPoint = CGPointMake(self.center.x, CARD_HEIGHT / 2 + 40);
        [UIView animateKeyframesWithDuration:0.5 delay:0.06 * i options:UIViewKeyframeAnimationOptionCalculationModeLinear animations:^{
            draggableView.center = finishPoint;
            draggableView.transform = CGAffineTransformMakeRotation(0);
            if (i > 0 && i < CARD_NUM - 1) {
                DragCardItemView *preDraggableView = [self.allCards objectAtIndex:i - 1];
                draggableView.transform = CGAffineTransformScale(draggableView.transform, pow(CARD_SCALE, i), pow(CARD_SCALE, i));
                CGRect frame = draggableView.frame;
                frame.origin.y = preDraggableView.frame.origin.y + (preDraggableView.frame.size.height - frame.size.height) + 20 * pow(0.7, i);
                draggableView.frame = frame;
                
            } else if (i == CARD_NUM - 1) {
                DragCardItemView *preDraggableView = [self.allCards objectAtIndex:i - 1];
                draggableView.transform = preDraggableView.transform;
                draggableView.frame = preDraggableView.frame;
            }
            
            draggableView.originalCenter = draggableView.center;
            draggableView.originalTransform = draggableView.transform;
            
            if (i == CARD_NUM - 1) {
                self.lastCardCenter = draggableView.center;
                self.lastCardTTransform = draggableView.transform;
            }
            
        } completion:^(BOOL finished) {
            
        }];
    }
}

/* 首次添加卡片 */
- (void)addCards {
    for (NSInteger i = 0; i < CARD_NUM; i++) {
        DragCardItemView *draggableView = [[DragCardItemView alloc] initWithFrame:CGRectMake([[UIScreen mainScreen] bounds].size.width + CARD_WIDTH, self.center.y - CARD_HEIGHT / 2, CARD_WIDTH, CARD_HEIGHT)];
        if (i > 0 && i < CARD_NUM - 1) {
            draggableView.transform = CGAffineTransformScale(draggableView.transform, pow(CARD_SCALE, i), pow(CARD_SCALE, i));
        }else if (i == CARD_NUM - 1) {
            draggableView.transform = CGAffineTransformScale(draggableView.transform, pow(CARD_SCALE, i - 1), pow(CARD_SCALE, i - 1));
        }
        draggableView.transform = CGAffineTransformMakeRotation(ROTATION_ANGLE);
        draggableView.delegate = self;
        [_allCards addObject:draggableView];
        if (i == 0) {
            draggableView.canPan = YES;
        } else {
            draggableView.canPan = NO;
        }
        
    }
    for (NSInteger i = (NSInteger)CARD_NUM - 1; i >= 0; i--) {
        [self addSubview:_allCards[i]];
    }
}

/* 滑动后续操作 */
- (void)swipCard:(DragCardItemView *)cardView Direction:(BOOL)isRight {
    if (isRight) {
        [self like:cardView.infoDict];
    } else {
        [self unlike:cardView.infoDict];
    }
    [_allCards removeObject:cardView];
    cardView.transform = self.lastCardTTransform;
    cardView.center = self.lastCardCenter;
    cardView.canPan = NO;
    [self insertSubview:cardView belowSubview:[_allCards lastObject]];
    [_allCards addObject:cardView];
//    [_allCards ];
//    DragCardItemView *firstView = [_allCards firstObject];
//    firstView.canPan = YES;
    if ([self.sourceObject firstObject] != nil) {
        
        cardView.infoDict = [self.sourceObject firstObject];
        [self.sourceObject removeObjectAtIndex:0];
        [cardView layoutSubviews];
        if (self.sourceObject.count < MIN_INFO_NUM) {
            [self requestSourceData:NO];
        }
        
    } else {
        cardView.hidden = YES;//如果没有数据则隐藏卡片
    }
    
    for (NSInteger i = 0; i < CARD_NUM; i++) {
        DragCardItemView *draggableView = [_allCards objectAtIndex:i];
        draggableView.originalCenter = draggableView.center;
        draggableView.originalTransform = draggableView.transform;
        if (i == 0) {
            draggableView.canPan = YES;
        }
    }
}

/* 滑动中更改其他卡片位置 */
- (void)moveCards:(CGFloat)distance {
    if (fabs(distance) <= PAN_DISTANCE) {
        for (NSInteger i = 1; i < CARD_NUM - 1; i++) {
            DragCardItemView *draggableView = _allCards[i];
            DragCardItemView *preDraggableView = [_allCards objectAtIndex:i - 1];
            draggableView.transform = CGAffineTransformScale(draggableView.originalTransform, 1 + (1 / CARD_SCALE - 1) * fabs(distance / PAN_DISTANCE) * 0.6, 1 + (1 / CARD_SCALE - 1) * fabs(distance / PAN_DISTANCE) * 0.8);//0.8为缩减因数，使放大速度始终小于卡片移动速度的
            CGPoint center = draggableView.center;
            center.y = draggableView.originalCenter.y - (draggableView.originalCenter.y - preDraggableView.originalCenter.y) * fabs(distance / PAN_DISTANCE) * 0.8;//此处的0.8同上
            draggableView.center = center;
        }
    }
    
    if (distance > 0) {
        self.likeBtn.transform = CGAffineTransformMakeScale(1 + 0.1 * fabs(distance / PAN_DISTANCE), 1 + 0.1 * fabs(distance / PAN_DISTANCE));
    } else {
        self.disLikeBtn.transform = CGAffineTransformMakeScale(1 + 0.1 * fabs(distance / PAN_DISTANCE), 1 + 0.1 * fabs(distance / PAN_DISTANCE));
    }
}

/* 滑动终止后复原其他卡片 */
- (void)moveBackCards {
    for (NSInteger i = 1; i < CARD_NUM - 1; i++) {
        DragCardItemView *draggableView = _allCards[i];
        [UIView animateWithDuration:0.5 delay:0.0 usingSpringWithDamping:0.6 initialSpringVelocity:0.6 options:(UIViewAnimationOptionAllowUserInteraction | UIViewAnimationCurveEaseInOut) animations:^{
            draggableView.transform = draggableView.originalTransform;
            draggableView.center = draggableView.originalCenter;
        } completion:nil];
        
    }
}

/* 滑动后调整其他卡片位置 */
- (void)adjustOtherCards {
    [UIView animateWithDuration:0.2 animations:^{
        for (NSInteger i = 1; i < CARD_NUM - 1; i++) {
            DragCardItemView *draggableView = self.allCards[i];
            DragCardItemView *preDraggableView = [self.allCards objectAtIndex:i - 1];
            draggableView.transform = preDraggableView.originalTransform;
            draggableView.center = preDraggableView.originalCenter;
        }
    } completion:^(BOOL finished) {
        self.disLikeBtn.transform = CGAffineTransformMakeScale(1, 1);
        self.likeBtn.transform = CGAffineTransformMakeScale(1, 1);
    }];
}

/* 点击“喜欢”的后续操作 */
- (void)like:(NSDictionary *)userInfo {
    NSLog(@"like:%@",userInfo[@"number"]);
}

/* 点击“不喜欢”的后续操作 */
- (void)unlike:(NSDictionary *)userInfo {
    NSLog(@"unlike:%@",userInfo[@"number"]);
}

- (void)rightButtonClickAction {
    if (self.flag == YES || self.allCards.count == 0) {
        return;
    }
    self.flag = YES;
    DragCardItemView *dragView = self.allCards[0];
    CGPoint finishPoint = CGPointMake([[UIScreen mainScreen] bounds].size.width + CARD_WIDTH * 2 / 3, 2 * PAN_DISTANCE + dragView.frame.origin.y);
    [UIView animateWithDuration:CLICK_ANIMATION_TIME animations:^{
        self.likeBtn.transform = CGAffineTransformMakeScale(1.2, 1.2);
        dragView.center = finishPoint;
        dragView.transform = CGAffineTransformMakeRotation(ROTATION_ANGLE);
    } completion:^(BOOL finished) {
        self.likeBtn.transform = CGAffineTransformMakeScale(1, 1);
        [self swipCard:dragView Direction:YES];
        self.flag = NO;
    }];
    [self adjustOtherCards];
}

- (void)leftButtonClickAction {
    if (self.flag == YES || self.allCards.count == 0) {
        return;
    }
    
    self.flag = YES;
    DragCardItemView *dragView = self.allCards[0];
    CGPoint finishPoint = CGPointMake(-CARD_WIDTH * 2 / 3, 2 * PAN_DISTANCE + dragView.frame.origin.y);
    [UIView animateWithDuration:CLICK_ANIMATION_TIME animations:^{
        self.disLikeBtn.transform = CGAffineTransformMakeScale(1.2, 1.2);
        dragView.center = finishPoint;
        dragView.transform = CGAffineTransformMakeRotation(-ROTATION_ANGLE);
    } completion:^(BOOL finished) {
        self.disLikeBtn.transform = CGAffineTransformMakeScale(1, 1);
        [self swipCard:dragView Direction:NO];
        self.flag = NO;
    }];
    [self adjustOtherCards];
}

@end

