//
//  MLCommentContentCell.h
//
//  Created by lei on 13-11-29.
//  Copyright (c) 2013年 . All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MLBorderView.h"
#import "NSArray+Safe.h"

@class MLCommentContentCell,MLComment;

@protocol CommentContentCell_Delegate <NSObject>
// 点击叠加楼层
- (void)expandClickedWithCell:(MLCommentContentCell *)cell;
// 回复评论点击
- (void)replyClickedWithCommentModel:(MLComment*)commentModel;
// 点赞点击
- (void)supporClickWithCommment:(MLComment *)commentModel callBack:(supporBlock)back;
// 点击查看全文
- (void)extensionClickedWithCell:(MLCommentContentCell *)cell;
@end

@interface MLCommentContentCell : UITableViewCell
{
    NSArray* mCommentLevels;
    id data;
    BOOL hasInit;
    BOOL mExpandLevel;
}

@property(nonatomic,retain)NSArray* commentLevels;
@property(nonatomic,retain)id data;
@property(nonatomic,assign)BOOL expandLevel;
@property(nonatomic,assign)id<CommentContentCell_Delegate> delegate;

-(NSString*)hideIPWithSourceIP:(NSString*)ipstr;
-(void)reloadData;
- (void)changeToNightMode:(BOOL)night;
- (id)getDataAtPoint:(CGPoint)pt;

@end
