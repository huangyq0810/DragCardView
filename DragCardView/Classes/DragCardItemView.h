//
//  DragCardItemView.h
//  DragCardView
//
//  Created by admin on 27/7/18.
//

#import <UIKit/UIKit.h>
#define ROTATION_ANGLE M_PI/8
#define CLICK_ANIMATION_TIME 0.5
#define RESET_ANIMATION_TIME 0.3

@class DragCardItemView;
@protocol DragCardItemViewDelegate <NSObject>

-(void)swipCard:(DragCardItemView *)cardView Direction:(BOOL)isRight;
-(void)moveCards:(CGFloat)distance;
-(void)moveBackCards;
-(void)adjustOtherCards;

@end

@interface DragCardItemView : UIView

@property (nonatomic, weak) id<DragCardItemViewDelegate> delegate;
@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;
@property (nonatomic, assign) CGAffineTransform originalTransform;
@property (nonatomic, assign) CGPoint originalPoint;
@property (nonatomic, assign) CGPoint originalCenter;
@property (nonatomic, assign) BOOL canPan;
@property (nonatomic, strong) NSDictionary *infoDict;
@property (nonatomic, strong) UIImageView *headerImageView;
@property (nonatomic, strong) UILabel *numLabel;
@property (nonatomic, strong) UIButton *noButton;
@property (nonatomic, strong) UIButton *yesButton;

@end

