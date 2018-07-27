//
//  DragCardView.h
//  DragCardView
//
//  Created by admin on 27/7/18.
//

#import <UIKit/UIKit.h>

@protocol DragCardViewDataSource <NSObject>

@required
- (NSMutableArray *)requestSourceData;

@end

@interface DragCardView : UIView

@property (nonatomic, weak) id <DragCardViewDataSource> dataSource;
@property (nonatomic, assign) NSInteger page;

@end
