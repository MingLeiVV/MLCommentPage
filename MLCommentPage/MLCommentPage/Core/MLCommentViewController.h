//
//  MLCommentViewController.h
//
//  Created by lei on 13-4-9.
//  Copyright (c) 2013年 . All rights reserved.
//

#import "MLCommentContentList.h"
#import "MLCommentContentCell.h"
@class MLComment;


typedef NS_ENUM(NSUInteger, CommentListType) {
    CommentListType_Normal,
    CommentListType_OnlyHot,
    CommentListType_OnlyOrder,
};

typedef void(^CalculateBlock) (CGFloat height);

@protocol MLCommentViewControllerDelegate;

@interface MLCommentViewController : UIViewController

@property (nonatomic, strong) NSString *servers; // 服务器地址
@property (nonatomic, strong) NSDictionary *parameter; // 参数
@property (nonatomic, assign) CommentListType commentListType;//是热门评论+最新评论的全列表，还是只有热门评论
@property (nonatomic, assign) id <MLCommentViewControllerDelegate>delegate;
@property (nonatomic, strong, readonly) MLComment *currentSelectObject;  // 当前操作的数据对象
@property (nonatomic, assign, readonly) NSInteger commentCount; // 评论数

// 手动驱动加载数据（页面在展示会自动加载，一般不用）
- (void)loadCommentData;
@end

@protocol MLCommentViewControllerDelegate <NSObject>
// 点击回复抛出选中对象数据
- (void)commentViewController:(MLCommentViewController *)vc commentReply:(MLComment *)comment;
// 点赞抛出选中对象数据
- (void)commentSupporController:(MLCommentViewController *)vc comment:(MLComment *)comment callBack:(supporBlock)back;
- (void)commentViewController:(MLCommentViewController *)vc tabelViewContentSize:(CGSize)contentSize;
// 评论加载成功
- (void)commentViewController:(MLCommentViewController *)vc commentListDidFinishLoadWithPage:(NSInteger)page;
// 评论加载失败
- (void)commentViewController:(MLCommentViewController *)vc commentListDidFailLoadWithError:(NSError*)error page:(NSInteger)page;

- (void)hideKeyBoard;

- (void)scrollViewWillBeginDragging;

- (void)scrollViewDidEndDecelerating;
@end
