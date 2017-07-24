//
//  MLCommentContentCell.m
//
//  Created by lei on 13-11-29.
//  Copyright (c) 2013年 . All rights reserved.
//

#import "MLCommentContentCell.h"
#import "MLTool.h"
#import "NSString+URLEncode.h"
#import "UIView+Position.h"
#import "MLComment.h"
//
@interface MLCommentContentCell()
@property(nonatomic,retain)NSMutableArray* levelViews;
@property(nonatomic,retain)NSMutableArray* requestArray;
@property(nonatomic, retain)UIView *cellLine;
@property (retain, nonatomic) UIView *seperateView;

-(void)addBorderViewToArray:(NSMutableArray*)dest atIndex:(NSInteger)index;
@end

@implementation MLCommentContentCell

@synthesize commentLevels=mCommentLevels,data,expandLevel=mExpandLevel;
@synthesize levelViews;
@synthesize delegate;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        hasInit = NO;
        mExpandLevel = NO;
        
        hasInit = YES;
        [self initUI];
    }
    return self;
}

- (void) cancelRequests
{
    [self.requestArray makeObjectsPerformSelector:@selector(cancel)];
    [self.requestArray removeAllObjects];
}

-(void)initUI
{
    self.userInteractionEnabled = YES;
    self.autoresizingMask  = UIViewAutoresizingFlexibleWidth;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.backgroundColor = [UIColor clearColor];// --[UIColor clearColor];
    UIImage* backImage = [[UIImage imageNamed:@"wf_wiget_back.png"] stretchableImageWithLeftCapWidth:1.0 topCapHeight:40.0];
    UIImageView* backView = [[UIImageView alloc] initWithImage:backImage];
    self.backgroundView = backView;
    
    
    if (!self.seperateView) {
        self.seperateView = [[UIView alloc] initWithFrame:CGRectMake(9, self.height - 0.5, self.width - 18, 0.5)];
        self.seperateView.backgroundColor = [UIColor colorWithRed:213.0/255.0 green:213.0/255.0 blue:213.0/255.0 alpha:1.0];
        [self.seperateView setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.contentView addSubview:self.seperateView];
        
        NSLayoutConstraint *leading = [NSLayoutConstraint constraintWithItem:self.seperateView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeLeading multiplier:1.0f constant:9];
        
        NSLayoutConstraint *traiting = [NSLayoutConstraint constraintWithItem:self.seperateView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTrailing multiplier:1.0f constant:-9];
        
        NSLayoutConstraint *bottom = [NSLayoutConstraint constraintWithItem:self.seperateView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeBottom multiplier:1.0f constant:-0.5];//modify by lyr
        
        NSLayoutConstraint *height = [NSLayoutConstraint
                                      constraintWithItem:self.seperateView
                                      attribute:NSLayoutAttributeHeight
                                      relatedBy:NSLayoutRelationGreaterThanOrEqual
                                      toItem:nil
                                      attribute:NSLayoutAttributeNotAnAttribute
                                      multiplier:1
                                      constant:0.5];
        
        [self.contentView addConstraint:leading];
        [self.contentView addConstraint:traiting];
        [self.contentView addConstraint:bottom];
        [self.contentView addConstraint:height];
        

    }
    
    
}


-(void)reloadDataWithUI
{

    if (!self.levelViews) {
        NSMutableArray* viewArray = [[NSMutableArray alloc] initWithCapacity:0];
        self.levelViews = viewArray;
    }
    else
    {
        for (int i=0; i<[self.levelViews count]; i++) {
            UIView* aView = [self.levelViews objectAtIndex:i];
            [aView removeFromSuperview];
        }
        [self.levelViews removeAllObjects];
    }
    
    NSInteger commentLevelsCount = [self.commentLevels count];
    if (self.commentLevels && commentLevelsCount>0) {
        if ((!self.expandLevel)&&commentLevelsCount>CommentContentCell_DefaultNumOfLevel) {
            BOOL hasAddedHiden = NO;
            for (int i=0; i<commentLevelsCount; i++) {
                if (i<CommentContentCell_DefaultTopNumOfLevel) {
                    [self addBorderViewToArray:self.levelViews atIndex:i];
                }
                else if(i<commentLevelsCount-CommentContentCell_DefaultBottomNumOfLevel)
                {
                    if (!hasAddedHiden) {
                        hasAddedHiden = YES;
                        MLBorderView* borderView = [[MLBorderView alloc] init];
                        borderView.delegate = self;
                        borderView.bHidenView = YES;
                        [borderView reloadData];
                        [self.contentView addSubview:borderView];
                        [self.contentView sendSubviewToBack:borderView];
                        [self.levelViews addObject:borderView];
                    }
                }
                else
                {
                    [self addBorderViewToArray:self.levelViews atIndex:i];
                }
            }
        }
        else
        {
            for (int i=0; i<commentLevelsCount; i++) {
                [self addBorderViewToArray:self.levelViews atIndex:i];
            }
        }
    }
}
-(void)addBorderViewToArray:(NSMutableArray*)dest atIndex:(NSInteger)index
{
    MLBorderView* borderView = [[MLBorderView alloc] init];
    borderView.delegate = self;
    MLComment* commentModel = [self.commentLevels objectAtIndex:index];
    NSString* content = commentModel.content;
    borderView.isExtension = commentModel.isExtension;
    borderView.contentString = content;
    borderView.dataIndex = index;
    
    NSString *areaStr = commentModel.area;
    NSString* nickStr = commentModel.name;
    if (index == 0) {//最后一楼
        borderView.titleName = commentModel.name;
        NSString* timeStr = commentModel.time;
        NSDateFormatter* formater = [[NSDateFormatter alloc] init];
        formater.dateFormat = @"yyyy-MM-dd HH:mm:ss";
        NSDate* newFormatDate  = [formater dateFromString:timeStr];
        NSString* createDateStr = [MLTool humanizeDateFormatFromDate:newFormatDate];
        borderView.tipString = [NSString stringWithFormat:@"%@",createDateStr];
        borderView.bLastView = YES;
        borderView.portraitUrl = commentModel.profile;
        
        if (areaStr) {
            borderView.localName = [NSString stringWithFormat:@"[%@]",areaStr];
        }
        
        NSString* voteCount = commentModel.suppor;
        if (!voteCount) {
            voteCount = @"0";
        }
        borderView.voteCount = voteCount;
        
    }
    else
    {
        borderView.titleName = commentModel.name;
        borderView.tipString = [NSString stringWithFormat:@"%ld楼",index];
        borderView.bLastView = NO;
    }
    
    
    
    [borderView reloadData];
    [self.contentView addSubview:borderView];
    [self.contentView sendSubviewToBack:borderView];
    [dest addObject:borderView];
}

-(NSString*)hideIPWithSourceIP:(NSString*)ipstr
{
    NSString* rtval = ipstr;
    if (ipstr) {
        NSArray* componet = [ipstr componentsSeparatedByString:@"."];
        if ([componet count]==4) {
            rtval = [NSString stringWithFormat:@"%@.%@.*.*",[componet objectAtIndex:0],[componet objectAtIndex:1]];
        }
    }
    return rtval;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

-(void)reloadData
{
    [self reloadDataWithUI];
}

#pragma mark - borderView delegate Methods
-(void)BorderViewClicked:(MLBorderView*)sender
{
    if (delegate &&[delegate respondsToSelector:@selector(expandClickedWithCell:)]) {
        [delegate expandClickedWithCell:self];
    }
}
-(void)borderViewReplyClicked:(MLBorderView*)borderView  dataIndex:(NSInteger)dataIndex
{
    if (delegate && [delegate respondsToSelector:@selector(replyClickedWithCommentModel:)]) {
        MLComment* model = [self.commentLevels safeObjectAtIndex:dataIndex];
        [delegate replyClickedWithCommentModel:model];
    }
}
// 点赞点击
-(void)borderViewVoteClicked:(MLBorderView*)borderView  dataIndex:(NSInteger)dataIndex callBack:(supporBlock)back {
    MLComment* model = [self.commentLevels safeObjectAtIndex:dataIndex];
    if (delegate && [delegate respondsToSelector:@selector(supporClickWithCommment:callBack:)]) {
        [delegate supporClickWithCommment:model callBack:back];
    }
}
-(void)borderViewExtensionButtonClicked:(MLBorderView *)borderView dataIndex:(NSInteger)dataIndex
{
    MLComment* model = [self.commentLevels safeObjectAtIndex:dataIndex];
    if (model) {
        model.isExtension = YES;
        
        if (delegate && [delegate respondsToSelector:@selector(extensionClickedWithCell:)]) {
            [delegate extensionClickedWithCell:self];
        }
    }
}
#pragma mark - Methods 

-(void)myLayoutSubviews
{
    CGRect mainRect = self.bounds;
    NSInteger levelViewsCount = [self.levelViews count];//楼数
    
    if (levelViewsCount > 0)
    {
        MLBorderView* firstBorderView = [self.levelViews firstObject];
        CGRect viewRect = CGRectMake(mainRect.origin.x + CommentContentCell_LeftMargin, CommentContentCell_LastBorderTimeTopMargin + CommentContentCell_TimeLabelHeight + CommentContentCell_LastBorderTimeBottomMargin, mainRect.size.width - CommentContentCell_LeftMargin - CommentContentCell_RightMargin, mainRect.size.height);
        
        int firstHeight = [firstBorderView sizeThatFits:viewRect.size].height;
        CGRect firstFrame = CGRectMake(0, 0, mainRect.size.width, firstHeight);
        firstBorderView.frame = firstFrame;
        int extraHeight = - CommentContentCell_LastBorderTimeBottomMargin;
        for (int i = 1; i < levelViewsCount; i++)
        {
            MLBorderView* oldView = [self.levelViews objectAtIndex:i];
            
            oldView.topExtraMargin = extraHeight;
            
            //所有楼层都从同一个Y偏移开始
            CGRect viewRect = CGRectMake(mainRect.origin.x + CommentContentCell_LeftMargin, firstHeight +CommentContentCell_LastBorderTimeBottomMargin, mainRect.size.width - CommentContentCell_LeftMargin - CommentContentCell_RightMargin, mainRect.size.height);
            viewRect.size = [oldView sizeThatFits:viewRect.size];
            oldView.frame = viewRect; //设置非最后一楼/单楼楼高
            
            extraHeight = viewRect.size.height;
        }
        firstBorderView.frame = firstFrame;
        self.cellLine.frame = CGRectMake(9, self.bounds.size.height - 0.5, self.contentView.bounds.size.width - 18, 0.5);
    }
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
    int totalHeight = 0;
    
    CGRect mainRect = CGRectMake(0, 0, self.contentView.bounds.size.width, 10000);
    
    NSInteger levelViewsCount = [self.levelViews count];
    if (levelViewsCount > 0)
    {
        MLBorderView* lastBorderView = [self.levelViews lastObject];
        lastBorderView.frame = mainRect;
        
        NSInteger contentTopMargin = lastBorderView.retTopMarginForContainView;//正文lable 上沿Y
        
        levelViewsCount = levelViewsCount - 1;
        
        int extraHeight = 0;
        for (int i = 0; i < levelViewsCount; i++)
        {
            MLBorderView* oldView = [self.levelViews objectAtIndex:i];
            oldView.topExtraMargin = extraHeight;
            
            CGRect viewRect = CGRectMake(mainRect.origin.x + CommentContentCell_LeftMargin, mainRect.origin.y + contentTopMargin, mainRect.size.width - CommentContentCell_LeftMargin - CommentContentCell_RightMargin, mainRect.size.height - contentTopMargin);
            viewRect.size = [oldView sizeThatFits:viewRect.size];
            oldView.frame = viewRect;
            extraHeight = viewRect.size.height;
            
            if (i == levelViewsCount - 1)
            {
                lastBorderView.topExtraMargin = extraHeight;
            }
        }
        CGSize borderSize = [lastBorderView sizeThatFits:mainRect.size];
        totalHeight = borderSize.height;
    }
    

    
    CGSize totalSize = CGSizeZero;
    totalSize.width = mainRect.size.width;
    totalSize.height = totalHeight;
    return totalSize;
}

- (id)getDataAtPoint:(CGPoint)pt
{
    NSUInteger index = NSNotFound;
    for (MLBorderView *view in self.levelViews) {
        if (CGRectContainsPoint(view.frame, pt)) {
            index = view.dataIndex;
            break;
        }
    }
    
    if (index == NSNotFound) {
        index = [self.commentLevels count] - 1;
    }
    
    return [self.commentLevels objectAtIndex:index];
}
#pragma mark - requestDelegate
//- (void)requestDidFinishLoad:(BaseDataRequest*)request {
//    
//}
//- (void)request:(BaseDataRequest*)request didFailLoadWithError:(NSError*)error {
//    NSDictionary* userInfo = request.userInfo;
//    NSInteger dataIndex = [[userInfo objectForKey:@"commentdataindex"] integerValue];
//    
//    MLComment* model = [self.commentLevels safeObjectAtIndex:dataIndex];
//    
//    BorderView* borderView = [self.levelViews safeObjectAtIndex:dataIndex];
//    
//    if ([model isKindOfClass:[MLComment class]]) {
//        NSInteger voteCount = [borderView.voteCount integerValue];
//        if (voteCount > 0) {
//            voteCount--;
//            borderView.voteCount = [NSString stringWithFormat:@"%ld", voteCount];
//        }
//        
//    }
//}
@end
