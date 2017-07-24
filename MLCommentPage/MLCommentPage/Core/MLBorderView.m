//
//  MLBorderView.m
//
//  Created by lei on 14-12-16.
//  Copyright (c) 2014年 . All rights reserved.
//

#import "MLBorderView.h"
#import "MLCommentContentCell.h"
#import <QuartzCore/QuartzCore.h>
#import "UIImageView+WebCache.h"
#import "MLComment.h"
#import "MLCommentVoteButton.h"

@interface MLBorderView()
{
    UILabel* titleLabel;
    UILabel* contentLabel;
    UILabel* numOfLevel;
    UIView* expandView;
    BOOL hasInit;
    
    NSString* titleName;
    NSString* contentString;
    NSString* tipString;
    NSInteger topExtraMargin;//楼盖楼，但Y值一样，用户昵称、正文等偏移就要加上上一楼的高度
    BOOL bLastView;//是否是最底下一层
    BOOL bHidenView;
    
//    id<BorderView_Delegate> delegate;
    
    NSInteger retTopMarginForContainView;
}
@property(nonatomic,retain)UIView* expandView;
@property(nonatomic,retain)UILabel* titleLabel; // 姓名
@property(nonatomic,retain)UILabel* contentLabel; // 内容
@property(nonatomic,retain)UILabel* numOfLevel;  // 发表时间
@property(nonatomic,retain)UIImageView* portraitImageView; // 头像
@property(nonatomic,retain)UIImageView* logoImageView; // 没用
@property(nonatomic,retain)UILabel* levelLabel;  // 没用
@property(nonatomic,retain)UILabel* localLabel;  // 地区
@property(nonatomic,retain)MLCommentVoteButton* commentVoteButton; // 点赞
@property(nonatomic,retain)MLCommentVoteButton* replyButton; // 回复
@property(nonatomic,retain)UIButton* extensionButton; // 全文

@end

@implementation MLBorderView
@synthesize titleName,contentString,tipString;
@synthesize titleLabel,expandView,contentLabel,numOfLevel,topExtraMargin,bLastView,bHidenView,portraitImageView,logoImageView, levelLabel,portraitUrl,teamLogo,userLevel,localLabel,commentVoteButton,replyButton,localName,voteCount;
@synthesize retTopMarginForContainView;
@synthesize delegate, isExtension;

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        hasInit = NO;
        topExtraMargin = 0;
        bLastView = NO;
        bHidenView = NO;
        isExtension = NO;
    }
    return self;
}


-(void)initUI
{
    UIImageView* pImagView = [[UIImageView alloc]initWithFrame:CGRectMake(8, 16, 25, 25)];
    self.portraitImageView = pImagView;
    self.portraitImageView.backgroundColor  = [UIColor grayColor];
    self.portraitImageView.hidden = YES;
    [self addSubview:pImagView];
    
    
    UILabel* label = [[UILabel alloc] init];
    label = [[UILabel alloc] init];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont systemFontOfSize:CommentContentCell_TitleFontSize];
    label.textColor = SubTitleColor ; //titleColor
    [self addSubview:label];
    self.titleLabel = label;
    
    label = [[UILabel alloc] init];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont systemFontOfSize:CommentContentCell_TitleFontSize];
    label.textColor = NumColor; //numColor
    [self addSubview:label];
    self.numOfLevel = label;
    
    label = [[UILabel alloc] init];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont systemFontOfSize:15];
    label.textColor = SubTextColor;                                                     // testColor
    label.numberOfLines = 0;
    [self addSubview:label];
    self.contentLabel = label;
    
    UIButton* button = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 45, 20)];
    [button setImage:[UIImage imageNamed:@"extension_icon"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(extensionButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    self.extensionButton = button;
    button.hidden = YES;
    [self addSubview:button];
    
    if (bLastView) {
        self.titleLabel.textColor = TitleColor;
        self.contentLabel.textColor = TextColor;
        label.font = [UIFont systemFontOfSize:CommentContentCell_ContentFontSize];
        
        label = [[UILabel alloc] init];
        label.backgroundColor = [UIColor clearColor];
        label.font = [UIFont systemFontOfSize:CommentContentCell_TimeFontSize];
        label.textColor = TimeColor;
        [self addSubview:label];
        self.localLabel = label;
        
        
        MLCommentVoteButton* voteButton = [MLCommentVoteButton loadFromXib];
        voteButton.countTextAlignment = NSTextAlignmentLeft;
        self.commentVoteButton = voteButton;
        [voteButton addTarget:self action:@selector(voteButtonCliecked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:voteButton];
        
        MLCommentVoteButton* rButton = [MLCommentVoteButton loadFromXib];
        rButton.icon = @"reply_icon";
        rButton.voteCount = @"回复";
        self.replyButton = rButton;
        [replyButton addTarget:self action:@selector(replyButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:replyButton];
    }
    
}

-(void)initExpandView
{
    UIButton* parentView = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 320, CommentContentCell_MergeHeight)];
    [parentView addTarget:self action:@selector(thisClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    UIImageView *icon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@""]];
    
    UILabel* tipLabel = [[UILabel alloc] init];
    tipLabel.backgroundColor = [UIColor clearColor];
    tipLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
    tipLabel.font = [UIFont systemFontOfSize:CommentContentCell_ExpandFontSize];
    tipLabel.textColor = TipsColor;  // tipsColor
    tipLabel.text = @"显示隐藏的评论";
    [tipLabel sizeToFit];
    CGRect tipRect = parentView.bounds;
    tipRect.size =tipLabel.frame.size;
    tipRect.origin.x = (parentView.bounds.size.width/2 - tipRect.size.width/2 - 5 - icon.frame.size.width / 2);
    tipRect.origin.y = (parentView.bounds.size.height/2 - tipRect.size.height/2);
    tipLabel.frame = tipRect;
    tipLabel.tag = 11111222;
    [parentView addSubview:tipLabel];
    
    icon.frame = CGRectMake(tipRect.origin.x + tipRect.size.width + 10, tipRect.origin.y + 3, icon.frame.size.width, icon.frame.size.height);
    [parentView addSubview:icon];
    
    self.expandView = parentView;
    [self addSubview:parentView];
}

-(void)thisClicked:(UIButton*)sender
{
    UILabel* tipLabel = (UILabel*)[self.expandView viewWithTag:11111222];
    tipLabel.text = @"隐藏评论显示中";
    CGRect parentRect = tipLabel.superview.frame;
    [tipLabel sizeToFit];
    CGRect tipRect = parentRect;
    tipRect.size = tipLabel.frame.size;
    tipRect.origin.x = (parentRect.size.width/2 - tipRect.size.width/2);
    tipRect.origin.y = (parentRect.size.height/2 - tipRect.size.height/2);
    tipLabel.frame = tipRect;
    
    if (delegate && [delegate respondsToSelector:@selector(BorderViewClicked:)]) {
        [delegate BorderViewClicked:self];
    }
}
- (void)extensionButtonClicked:(UIButton*)sender
{
    isExtension = YES;
    if (delegate &&[delegate respondsToSelector:@selector(borderViewExtensionButtonClicked:dataIndex:)]) {
        self.extensionButton.hidden = YES;
        [delegate borderViewExtensionButtonClicked:self dataIndex:self.dataIndex];
    }
}
-(void)reloadData
{
    if (!hasInit) {
        hasInit = YES;
        [self initUI];
    }
    
    if (bHidenView) {
        if (!expandView) {
            [self initExpandView];
        }
    }
    
    if (bLastView) {
        self.backgroundColor = BGColor;//[UIColor clearColor];
        self.layer.borderWidth = 0;
        
        self.portraitImageView.hidden = NO;
        self.portraitImageView.layer.cornerRadius = 12.5;
        self.portraitImageView.layer.masksToBounds = YES;
        if (portraitUrl) {
            [self.portraitImageView sd_setImageWithURL:[NSURL URLWithString:portraitUrl] placeholderImage:[UIImage imageNamed:@"SPCommentHeadPortrait"]];
        }
        else
        {
            self.portraitImageView.image = [UIImage imageNamed:@"SPCommentHeadPortrait"];
        }
        
        
        self.localLabel.text = localName;

        self.commentVoteButton.voteCount = voteCount;
    }
    else
    {
        self.backgroundColor = QuoteBGColor;//[UIColor whiteColor]; --------
        self.layer.borderWidth = 0.5;
        self.layer.borderColor= BorderColor; // borderColor
    }
    if (!bHidenView) {
        titleLabel.text = titleName;
        contentLabel.text = contentString;
        numOfLevel.text = tipString;
        expandView.hidden = YES;
        
        if (teamLogo) {
            self.logoImageView.hidden = NO;
            [self.logoImageView sd_setImageWithURL:[NSURL URLWithString:teamLogo] placeholderImage:nil];
            if (userLevel) {
                self.levelLabel.hidden = NO;
                self.levelLabel.text = userLevel;
            }
        }
        
        
    }
    else
    {
        titleLabel.text = nil;
        contentLabel.text = nil;
        numOfLevel.text = nil;
        expandView.hidden = NO;
    }
    
}
-(void)setVoteCount:(NSString *)count
{
    voteCount = count;
    self.commentVoteButton.voteCount = count;
}
-(void)myLayoutSubviews
{
    CGRect mainRect = self.bounds;
    if (!bHidenView) {
        [self.numOfLevel sizeToFit]; //楼层
        CGRect numRect = mainRect;
        if (!bLastView) {
            numRect.size = self.numOfLevel.frame.size;
            numRect.origin.x = mainRect.size.width - self.numOfLevel.frame.size.width - CommentContentCell_FloorNoRightInMargin;
            numRect.origin.y = topExtraMargin + CommentContentCell_TopMargin;
        }
        else //如果是最后一楼，则不是楼层，是时间
        {
            numRect.origin.y = CommentContentCell_LastBorderTimeTopMargin;
            numRect.origin.x = mainRect.size.width - self.numOfLevel.frame.size.width - CommentContentCell_RightMargin;
            numRect.size.height = CommentContentCell_TimeLabelHeight;
            
            self.numOfLevel.font = [UIFont systemFontOfSize:CommentContentCell_TimeFontSize];
        }
        self.numOfLevel.frame = numRect;
        
        
        CGRect titleRect = mainRect; //用户名
        titleRect.size.height = CommentContentCell_FloorNoLabelHeight;
        if (bLastView) {
            titleRect.origin.x = CommentContentCell_LeftMargin;
            if (userLevel)//有主队信息 用户名Label Y值跟logo一样
            {
                titleRect.origin.y = self.portraitImageView.frame.origin.y;
            }
            else
            {//如果没有主队信息，用户名label 跟中心点Y偏移跟 Logo一样
                titleRect.origin.y = self.portraitImageView.frame.origin.y + self.portraitImageView.frame.size.height/2 - titleRect.size.height/2;
            }
        }
        else
        {
            titleRect.origin.x = CommentContentCell_LeftInMargin;
            if (userLevel) {//有主队信息
                titleRect.origin.y = topExtraMargin + CommentContentCell_NickLabelTopMarginHasHome;
            }
            else
            {
                titleRect.origin.y = numRect.origin.y;
            }
        }
        
        titleLabel.frame = titleRect;
        
        //主队级别
//        CGRect levelRect = self.levelLabel.frame;
//        levelRect.origin.y = titleRect.origin.y + titleRect.size.height + CommentContentCell_NickHomeLevelMargin;
//        levelRect.origin.x = titleRect.origin.x + 20;
//        levelRect.size = CGSizeMake(50, 10);
//        self.levelLabel.frame = levelRect;
//        
//        //主队logo
//        CGRect logoRect = self.logoImageView.frame;
//        logoRect.origin.x = titleRect.origin.x;
//        self.logoImageView.frame = logoRect;
//        self.logoImageView.center = CGPointMake(self.logoImageView.center.x, self.levelLabel.center.y);
        
        NSInteger curY = CommentContentCell_TopMargin + CommentContentCell_FloorNoLabelHeight + CommentContentCell_ContentTopMargin + topExtraMargin;
        if (bLastView) {
            curY = CommentContentCell_LastBorderTimeTopMargin + CommentContentCell_TimeLabelHeight + CommentContentCell_LastBorderTimeBottomMargin + topExtraMargin;
            if (topExtraMargin > 0) {
                curY += CommentContentCell_LastBorderContentTopMargin;
            }
        }
        self.retTopMarginForContainView = curY;// 当非lastView 时content 的上沿
        
        //开始计算正文内容的Y
        CGRect contentRect = mainRect;
        if (bLastView) {
            contentRect.size.height = mainRect.size.height - curY;
            contentRect.origin.y = curY;//lastView 的contentLabel的Y要加上以前各楼的高度
            contentRect.origin.x = CommentContentCell_LeftMargin;
            contentRect.size.width = self.bounds.size.width - CommentContentCell_LeftMargin - CommentContentCell_RightMargin;
        }
        else
        {
            contentRect.size.height = self.bounds.size.height - curY;
            contentRect.origin.y = curY;
            contentRect.origin.x = CommentContentCell_LeftInMargin;
            contentRect.size.width = self.bounds.size.width - CommentContentCell_LeftInMargin - CommentContentCell_RightInMargin;
        }
        
        CGSize cSize = [contentString sizeWithFont:self.contentLabel.font constrainedToSize:contentRect.size];
        contentRect.size = cSize;
        float extensionLineHeight = 0.0; //因为有全文展开按钮而导致的多余高度
        if (cSize.height > CommentContentCell_ShortenContentHeight && !isExtension)
        {
            contentRect.size.height = CommentContentCell_ShortenContentHeight;
            contentRect.origin.y -= 5;
            
            self.extensionButton.hidden = NO;
            CGRect buttonRect = self.extensionButton.frame;
            buttonRect.origin.x = contentRect.origin.x;
            buttonRect.origin.y = contentRect.origin.y + contentRect.size.height;
            self.extensionButton.frame = buttonRect;
            
            extensionLineHeight = CommentContentCell_ExtensionButtonHeight;
        }
        self.contentLabel.frame = contentRect;
        
        if (bLastView) {
            
            contentRect = self.contentLabel.frame;
            self.localLabel.frame = CGRectMake(CommentContentCell_LeftMargin, contentRect.origin.y + contentRect.size.height + extensionLineHeight + CommentContentCell_LocalTopMargin, 110, 10);
            
            CGRect voteRect = self.commentVoteButton.frame;
            voteRect.origin.x = self.bounds.size.width - 100;
            voteRect.origin.y = self.localLabel.frame.origin.y + self.localLabel.frame.size.height/2 - voteRect.size.height/2;
            voteRect.size = CGSizeMake(42, 25);
            self.commentVoteButton.frame = voteRect;
            
            self.replyButton.frame = voteRect;
            CGRect replyRect = self.replyButton.frame;
            replyRect.origin.x = voteRect.origin.x + voteRect.size.width + 5;
            self.replyButton.frame = replyRect;
 
        }
    }
    else
    {
        CGRect expandRect = CGRectMake(0, topExtraMargin, mainRect.size.width, CommentContentCell_MergeHeight);
        self.expandView.frame = expandRect;
    }
    ;
}

-(void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    if (!CGRectEqualToRect(frame, CGRectZero)) {
        [self myLayoutSubviews];
    }
}

-(CGSize)sizeThatFits:(CGSize)size
{
    CGSize totalSize = CGSizeZero;
    CGRect mainRect = CGRectMake(0, 0, size.width, 10000);
    if (!bHidenView)
    {
        [self.numOfLevel sizeToFit]; //楼层
        CGRect numRect = mainRect;
        if (!bLastView) {
            numRect.size = self.numOfLevel.frame.size;
            numRect.origin.x = mainRect.size.width - self.numOfLevel.frame.size.width - CommentContentCell_FloorNoRightInMargin;
            numRect.origin.y = topExtraMargin + CommentContentCell_TopMargin;
        }
        else //如果是最后一楼，则不是楼层，是时间
        {
            numRect.origin.y = CommentContentCell_LastBorderTimeTopMargin;
            numRect.origin.x = mainRect.size.width - self.numOfLevel.frame.size.width - CommentContentCell_RightMargin;
            numRect.size.height = CommentContentCell_TimeLabelHeight;
        }
       
        NSInteger curY = CommentContentCell_TopMargin + CommentContentCell_FloorNoLabelHeight + CommentContentCell_ContentTopMargin + topExtraMargin;
        if (bLastView) {
            curY = CommentContentCell_LastBorderTimeTopMargin + CommentContentCell_TimeLabelHeight + CommentContentCell_LastBorderTimeBottomMargin + topExtraMargin;
            if (topExtraMargin > 0) {
                curY += CommentContentCell_LastBorderContentTopMargin;
            }
        }
        
        //开始计算正文内容的Y
        CGRect contentRect = mainRect;
        if (bLastView) {
            contentRect.size.height = mainRect.size.height - curY;
            contentRect.origin.y = curY;//lastView 的contentLabel的Y要加上以前各楼的高度
            contentRect.origin.x = CommentContentCell_LeftMargin;
            contentRect.size.width = mainRect.size.width - CommentContentCell_LeftMargin - CommentContentCell_RightMargin;
        }
        else
        {
            contentRect.size.height = mainRect.size.height - curY;
            contentRect.origin.y = curY;
            contentRect.origin.x = CommentContentCell_LeftInMargin;
            contentRect.size.width = mainRect.size.width - CommentContentCell_LeftInMargin - CommentContentCell_RightInMargin;
        }
        
        CGSize cSize = [contentString sizeWithFont:self.contentLabel.font constrainedToSize:contentRect.size];
        contentRect.size = cSize;
        
        float extensionLineHeight = 0.0; //因为有全文展开按钮而导致的多余高度
        if (cSize.height > CommentContentCell_ShortenContentHeight && !isExtension)
        {
            contentRect.size.height = CommentContentCell_ShortenContentHeight;
            extensionLineHeight = CommentContentCell_ExtensionButtonHeight;
        }
        
        totalSize.width = size.width;
        
        if (bLastView) {
            totalSize.height = contentRect.origin.y + extensionLineHeight +contentRect.size.height +CommentContentCell_LastBorderContentBottomMargin;
        }
        else
        {
            totalSize.height = contentRect.origin.y + contentRect.size.height + extensionLineHeight +  CommentContentCell_LastBorderTimeBottomMargin;
        }
//        totalSize.height = contentRect.origin.y + contentRect.size.height + borderMargin;
    }
    else
    {
        totalSize.width = size.width;
        totalSize.height = topExtraMargin + CommentContentCell_MergeHeight;
    }
    return totalSize;
}

#pragma mark - button clicked
-(void)voteButtonCliecked:(id)sender
{
    if (self.delegate &&[self.delegate respondsToSelector:@selector(borderViewVoteClicked:dataIndex:callBack:)]) {
        __weak typeof(self) weakSelf = self;
        [self.delegate borderViewVoteClicked:self dataIndex:self.dataIndex callBack:^{
            weakSelf.voteCount = [NSString stringWithFormat:@"%ld", [weakSelf.voteCount integerValue] + 1];
        }];
    }
}

-(void)replyButtonClicked:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(borderViewReplyClicked:dataIndex:)]) {
        [self.delegate borderViewReplyClicked:self dataIndex:self.dataIndex];
    }
}
@end

