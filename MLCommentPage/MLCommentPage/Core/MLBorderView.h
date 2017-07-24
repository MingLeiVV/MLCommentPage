//
//  MLBorderView.h
//
//  Created by lei on 14-12-16.
//  Copyright (c) 2014年 . All rights reserved.
//

#import <UIKit/UIKit.h>

static const NSInteger CommentContentCell_DefaultNumOfLevel = 4;
static const NSInteger CommentContentCell_DefaultTopNumOfLevel = 2;
static const NSInteger CommentContentCell_DefaultBottomNumOfLevel = 2;

static const CGFloat CommentContentCell_TitleFontSize =12.0;
static const CGFloat CommentContentCell_ContentFontSize = 17.0;
static const CGFloat CommentContentCell_SubContentFontSize = 15.0;
static const CGFloat CommentContentCell_ExpandFontSize = 17.0;
static const CGFloat CommentContentCell_TimeFontSize = 9.0;


static const CGFloat CommentContentCell_LeftMargin =45.0;
static const CGFloat CommentContentCell_RightMargin =11.0;
static const CGFloat CommentContentCell_LeftInMargin =16.0;//非最后楼 正文左侧距离borderview 边缘像素
static const CGFloat CommentContentCell_RightInMargin =7.0;//非最后楼 正文右侧距离borderview 边缘像素

static const CGFloat CommentContentCell_FloorNoRightInMargin =15.0;//楼数左边距离borderview左边边缘像素
static const CGFloat CommentContentCell_TopMargin =17;//楼数和顶部之间的间隙 非最后楼
static const CGFloat CommentContentCell_ContentTopMargin =20;//正文和楼数之间的间隙 非最后楼
static const CGFloat CommentContentCell_ContentBottomMargin =22;//正文和底部之间的间隙 非最后楼

static const CGFloat CommentContentCell_FloorNoLabelHeight =12;//楼数Label高度 用户名label高度

static const CGFloat CommentContentCell_LastBorderTimeTopMargin =24;//最后楼 时间（如刚刚）与顶部之间的间隙
static const CGFloat CommentContentCell_LastBorderTimeBottomMargin =13;//最后楼 时间（如刚刚）与下沿之间的间隙
static const CGFloat CommentContentCell_LastBorderContentTopMargin =9;//最后楼  正文与上一楼最下沿之间的间隙
static const CGFloat CommentContentCell_LastBorderContentBottomMargin =35;//最后楼  正文与cell 最下沿之间的间隙

static const CGFloat CommentContentCell_NickHomeLevelMargin =3;//用户名和主队级别之间的间隙
static const CGFloat CommentContentCell_LocalTopMargin =8;//地点和正文之间的间隙 只有最后一楼有
static const CGFloat CommentContentCell_MergeHeight =45; //折叠楼层高度

static const CGFloat CommentContentCell_TimeLabelHeight =9;//最后楼 时间Label高度

static const CGFloat CommentContentCell_NickLabelTopMarginHasHome =11; //非最后楼用户名上沿 有主队  无主队时上沿跟楼数一样

static const CGFloat CommentContentCell_ExtensionButtonHeight =14;//如果文字大于4行，需要收起，该值即为展开按钮的高度

static const CGFloat CommentContentCell_ShortenContentHeight =72;//超过4行，正文内容缩起后的高度


#define TitleColor [UIColor colorWithRed:185.0/255.0 green:185/255.0 blue:185/255.0 alpha:1.0]
#define SubTitleColor [UIColor colorWithRed:136/255.0 green:136/255.0 blue:136/255.0 alpha:1.0]
#define NumColor [UIColor colorWithRed:111/255.0 green:111/255.0 blue:111/255.0 alpha:1.0]
#define TextColor [UIColor blackColor]
#define SubTextColor [UIColor colorWithRed:105/255.0 green:105/255.0 blue:105/255.0 alpha:1.0]
#define TipsColor [UIColor colorWithRed:15/255.0 green:151/255.0 blue:237/255.0 alpha:1.0]
#define BorderColor [[UIColor colorWithRed:224/255.0 green:224/255.0 blue:224/255.0 alpha:1.0] CGColor]
#define BGColor [UIColor whiteColor];
#define QuoteBGColor [UIColor colorWithRed:245/255.0 green:245/255.0 blue:245/255.0 alpha:1.0]

#define TimeColor [UIColor colorWithRed:185/255.0 green:185/255.0 blue:185/255.0 alpha:1.0]

@class BorderView;

typedef void(^supporBlock)();
@protocol BorderView_Delegate <NSObject>
-(void)BorderViewClicked:(BorderView*)sender;
-(void)borderViewReplyClicked:(BorderView*)borderView dataIndex:(NSInteger)dataIndex;
-(void)borderViewVoteClicked:(BorderView*)borderView dataIndex:(NSInteger)dataIndex callBack:(supporBlock)back;
-(void)borderViewExtensionButtonClicked:(BorderView *)borderView dataIndex:(NSInteger)dataIndex; //点击展开
@end

@interface MLBorderView : UIView

@property(nonatomic,retain)NSString* titleName;
@property(nonatomic,retain)NSString* contentString;
@property(nonatomic,retain)NSString* tipString;
@property(nonatomic,retain)NSString* portraitUrl;
@property(nonatomic,retain)NSString* teamLogo;
@property(nonatomic,retain)NSString* userLevel;
@property(nonatomic,retain)NSString* localName;
@property(nonatomic,retain)NSString* voteCount;
 
@property(nonatomic,assign)NSInteger topExtraMargin;
@property(nonatomic,assign)BOOL bLastView;
@property(nonatomic,assign)BOOL bHidenView;
@property(nonatomic,assign)NSInteger retTopMarginForContainView;
@property(nonatomic,assign)id<BorderView_Delegate> delegate;
@property (nonatomic, assign) NSInteger dataIndex;
@property(nonatomic, assign)BOOL isExtension;//超过4行，展开后为YES;
-(void)initUI;
-(void)reloadData;

@end
