//
//  MLCommentViewController.m
//
//  Created by lei on 13-4-9.
//  Copyright (c) 2013年 . All rights reserved.
//

#import "MLCommentViewController.h"
#import "MLComment.h"
#import "MJRefresh.h"
#import "DataRequest.h"

@interface MLCommentViewController ()<CommentContentCell_Delegate,UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate, DataRequestDelegate>
{
    BOOL _didAddTimer;
    BOOL isLoadMore;
    BOOL isRefresh;
}

@property (strong, nonatomic) UITableView *commentTable;
@property (nonatomic, strong) MLCommentContentList *commentContentList;
@property (nonatomic, strong) NSMutableArray *expandedIndexPath;
@property (nonatomic, assign) NSInteger page;
@property(nonatomic, copy)NSString *requestUrl;
@end

@implementation MLCommentViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.servers && self.parameter) {
         [self loadCommentData];   
    }
}
- (void)initData {
    [self.view addSubview:self.commentTable];
    self.commentContentList = ([[MLCommentContentList alloc] init]);
    self.page = 1;
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
}

- (void)loadCommentData
{
    NSMutableDictionary *param = self.parameter.mutableCopy;
    [param setObject:@(_page) forKey:@"page"];
//    [NewsCommentList requestDataWithDelegate:self parameters:param];
}


#pragma mark - set
- (void)setServers:(NSString *)servers {
    _servers = servers;
    if (self.parameter && self.parameter.count > 0) {
        NSMutableString *urlString = _servers.mutableCopy;
        [self.parameter enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            [urlString appendString:[NSString stringWithFormat:@"&%@=%@",key,obj]];
        }];
        self.requestUrl = urlString.copy;
    }
}

- (void)setParameter:(NSDictionary *)parameter {
    _parameter = parameter;
    if (self.servers && ![self.servers isEqualToString:@""]) {
        NSMutableString *urlString = self.servers.mutableCopy;
        [_parameter enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            [urlString appendString:[NSString stringWithFormat:@"&%@=%@",key,obj]];
        }];
        self.requestUrl = urlString.copy;
    }
}

- (void)refresh
{
    _page = 1;
    isRefresh = YES;
    [self loadCommentData];
}

- (void)loadMore
{
    _page ++;
    isLoadMore = YES;
    [self loadCommentData];
}

- (void)showTip:(BOOL)requestSuccess {
    [self removeHUD];
    [self.commentTable.mj_header endRefreshing];
    [self.commentTable.mj_footer endRefreshing];
    isLoadMore = NO;
    isRefresh = NO;
    if (requestSuccess) {
        
        NSInteger count = [self.commentContentList countOfOrderList];
        
        if (count % 20 > 0 ) {
            // 无更多数据
            [self.commentTable.mj_footer endRefreshingWithNoMoreData];
        }
        if ([self.commentContentList countOfOrderList] == 0) {
            // 无数据提示
        }
    }else {
        [self showMessage:@"网络异常,请重试"];
        if ([self.commentContentList countOfOrderList] == 0) {
            [self showReloadHUD:self.commentTable callBack:^{
                [self refresh];
            }];
        }
    }
}

- (void)parseData:(NSDictionary *)data {
    
    NSInteger beforeCount = self.commentContentList.countOfOrderList;
    NSInteger after = 0;
    
    NSDictionary *commentDict = data;
    if (isLoadMore) {
        [self.commentContentList addContentObjectsWithOrderList:[commentDict objectForKey:@"cmntlist"] relationList:nil hotList:nil news:[commentDict objectForKey:@"newsdict"]];
        after = self.commentContentList.countOfOrderList;
        
    }
    else {
        if (_commentListType == CommentListType_OnlyHot) {
            [self.commentContentList refreshContentObjectsWithOrderList:nil relationList:nil hotList:[commentDict objectForKey:@"hotlist"] news:nil];
        }
        else if (_commentListType == CommentListType_OnlyOrder)
        {
            [self.commentContentList refreshContentObjectsWithOrderList:[commentDict objectForKey:@"cmntlist"] relationList:nil hotList:nil news:[commentDict objectForKey:@"newsdict"]];
        }
        else
        {
            [self.commentContentList refreshContentObjectsWithOrderList:[commentDict objectForKey:@"cmntlist"] relationList:nil hotList:[commentDict objectForKey:@"hotlist"] news:[commentDict objectForKey:@"newsdict"]];
        }
        
    }
    
    [self.commentTable reloadData];

}

#pragma mark - requestDelegate

- (void)requestFinished:(BaseDataRequest *)request {
    NSDictionary* data = [request.json objectForKey:@"result"];
    [self parseData:data];
    [self showTip:YES];
    if (_delegate && [_delegate respondsToSelector:@selector(commentViewController:commentListDidFinishLoadWithPage:)]) {
        [_delegate commentViewController:self commentListDidFinishLoadWithPage:_page];
    }
}

- (void)requestFailed:(BaseDataRequest *)request {
    [self showTip:NO];
    if (_delegate && [_delegate respondsToSelector:@selector(commentViewController:commentListDidFailLoadWithError:page:)]) {
        [_delegate commentViewController:self commentListDidFailLoadWithError:request.error page:_page];
    }
}

#pragma mark - CommentContentCell_Delegate
// 展开盖楼
-(void)expandClickedWithCell:(MLCommentContentCell *)cell
{
    if (!_expandedIndexPath) {
        _expandedIndexPath = [[NSMutableArray alloc] initWithCapacity:0];
    }
    NSIndexPath* indexPath = [self.commentTable indexPathForCell:cell];
    
    
    [_expandedIndexPath addObject:indexPath];
    NSArray* indexPathArray = [NSArray arrayWithObject:indexPath];
    [self.commentTable reloadRowsAtIndexPaths:indexPathArray withRowAnimation:UITableViewRowAnimationNone];
    [self.commentTable reloadData];
}
// 展开全文
-(void)extensionClickedWithCell:(MLCommentContentCell *)cell
{
    NSIndexPath* indexPath = [self.commentTable indexPathForCell:cell];
    NSArray* indexPathArray = [NSArray arrayWithObject:indexPath];
    [self.commentTable reloadRowsAtIndexPaths:indexPathArray withRowAnimation:UITableViewRowAnimationNone];
}

-(void)replyClickedWithCommentModel:(MLComment*)commentModel
{
    _currentSelectObject = commentModel;
    if (_delegate && [_delegate respondsToSelector:@selector(commentViewController:commentReply:)]) {
        [_delegate commentViewController:self commentReply:self.currentSelectObject];
    }
}

- (void)supporClickWithCommment:(MLComment *)commentModel callBack:(supporBlock)back {

    _currentSelectObject = commentModel;
    if (_delegate && [_delegate respondsToSelector:@selector(commentSupporController:comment:callBack:)]) {
        [_delegate commentSupporController:self comment:self.currentSelectObject callBack:back];
    }
}

#pragma mark - logic
// 计算高度
- (CGFloat)calculateCellHeightWithComments:(NSArray *)comments expand:(BOOL)expandLevel{
   
    NSInteger commentLevelsCount = [comments count];
    
    NSString* content = @"";
    CGSize expectedContentLabelSize ;

    CGFloat totalHeight = 0;
    CGSize maximumLabelSize = CGSizeMake(self.commentTable.bounds.size.width - CommentContentCell_LeftMargin - CommentContentCell_RightMargin - CommentContentCell_LeftInMargin - CommentContentCell_RightInMargin,9999);
    if (comments&&commentLevelsCount > 0) {
        //有叠加楼层
        if ((!expandLevel) && commentLevelsCount > CommentContentCell_DefaultNumOfLevel) {
            BOOL hasAddedHiden = NO;
            
            for (int i = 0; i < commentLevelsCount; i++)
            {
                CGFloat contentHeight = i == 0 ? CommentContentCell_ContentFontSize : CommentContentCell_SubContentFontSize;
                MLComment* commentModel = [comments objectAtIndex:i];
                BOOL isExtension = commentModel.isExtension;
                content = commentModel.content;
                
                if (i < CommentContentCell_DefaultTopNumOfLevel) {
                    //前两层楼层
                    
                    expectedContentLabelSize = [content sizeWithFont:[UIFont systemFontOfSize:contentHeight]
                                                          constrainedToSize:maximumLabelSize
                                                              lineBreakMode:NSLineBreakByWordWrapping];
                    
                    float extensionLineHeight = 0.0;
                    if (expectedContentLabelSize.height > CommentContentCell_ShortenContentHeight && !isExtension) {
                        expectedContentLabelSize.height = CommentContentCell_ShortenContentHeight;
                        extensionLineHeight = CommentContentCell_ExtensionButtonHeight;
                    }
                    
                    totalHeight += CommentContentCell_TopMargin + CommentContentCell_FloorNoLabelHeight + CommentContentCell_ContentTopMargin + expectedContentLabelSize.height + extensionLineHeight + CommentContentCell_ContentBottomMargin;

                }
                else if(i < commentLevelsCount - CommentContentCell_DefaultBottomNumOfLevel)
                {
                    //中间点开显示隐藏楼层按钮
                    if (!hasAddedHiden) {
                        hasAddedHiden = YES;
                        totalHeight += CommentContentCell_MergeHeight;
                    }
                }
                else if (i == commentLevelsCount -1) //最外层，当前楼
                {
                    
                    
                    expectedContentLabelSize = [content sizeWithFont:[UIFont systemFontOfSize:contentHeight]
                                                   constrainedToSize:maximumLabelSize
                                                       lineBreakMode:NSLineBreakByWordWrapping];
                    
                    float extensionLineHeight = 0.0;
                    
                    if (expectedContentLabelSize.height > CommentContentCell_ShortenContentHeight && !isExtension) {
                        expectedContentLabelSize.height = CommentContentCell_ShortenContentHeight;
                        extensionLineHeight = CommentContentCell_ExtensionButtonHeight;
                    }
                    
                    totalHeight += CommentContentCell_LastBorderTimeTopMargin + CommentContentCell_TimeLabelHeight + CommentContentCell_LastBorderTimeBottomMargin + CommentContentCell_LastBorderContentTopMargin + expectedContentLabelSize.height + extensionLineHeight + CommentContentCell_LastBorderContentBottomMargin;

                }
                else
                {
                    expectedContentLabelSize = [content sizeWithFont:[UIFont systemFontOfSize:contentHeight]
                                                   constrainedToSize:maximumLabelSize
                                                       lineBreakMode:NSLineBreakByWordWrapping];
                    
                    float extensionLineHeight = 0.0;
                    if (expectedContentLabelSize.height > CommentContentCell_ShortenContentHeight && !isExtension) {
                        expectedContentLabelSize.height = CommentContentCell_ShortenContentHeight;
                        extensionLineHeight = CommentContentCell_ExtensionButtonHeight;
                    }
                    
                    totalHeight += CommentContentCell_TopMargin + CommentContentCell_FloorNoLabelHeight + CommentContentCell_ContentTopMargin + expectedContentLabelSize.height + extensionLineHeight + CommentContentCell_ContentBottomMargin;
                }
            }
        }
        //无叠加楼层(全显示)
        else
        {
            if (1 == commentLevelsCount) {
                maximumLabelSize = CGSizeMake(self.commentTable.bounds.size.width - CommentContentCell_LeftMargin - CommentContentCell_RightMargin,9999);
                MLComment* commentModel = [comments objectAtIndex:0];
                if ([commentModel isKindOfClass:[NSDictionary class]]) {
                    NSLog(@"ssss");
                }
                content = commentModel.content;
                BOOL isExtension = commentModel.isExtension;
                
                expectedContentLabelSize = [content sizeWithFont:[UIFont systemFontOfSize:CommentContentCell_ContentFontSize]
                                               constrainedToSize:maximumLabelSize
                                                   lineBreakMode:NSLineBreakByWordWrapping];
                
                float extensionLineHeight = 0.0;
                if (expectedContentLabelSize.height > CommentContentCell_ShortenContentHeight && !isExtension) {
                    expectedContentLabelSize.height = CommentContentCell_ShortenContentHeight;
                    extensionLineHeight = CommentContentCell_ExtensionButtonHeight;
                }
                
                totalHeight += CommentContentCell_LastBorderTimeTopMargin + CommentContentCell_TimeLabelHeight + CommentContentCell_LastBorderTimeBottomMargin+ expectedContentLabelSize.height +  extensionLineHeight + CommentContentCell_LastBorderContentBottomMargin;

            }
            else
            {
                maximumLabelSize = CGSizeMake(self.commentTable.bounds.size.width - CommentContentCell_LeftMargin - CommentContentCell_RightMargin - CommentContentCell_LeftInMargin - CommentContentCell_RightInMargin,9999);
                for (int i = 0; i < commentLevelsCount - 1; ++i) {
                    CGFloat contentHeight = i == 0 ? CommentContentCell_ContentFontSize : CommentContentCell_SubContentFontSize;
                    MLComment* commentMode = [comments objectAtIndex:i];
                    content = commentMode.content;
                    BOOL isExtension = commentMode.isExtension;

                    expectedContentLabelSize = [content sizeWithFont:[UIFont systemFontOfSize:contentHeight]
                                                   constrainedToSize:maximumLabelSize
                                                       lineBreakMode:NSLineBreakByWordWrapping];
                    
                    float extensionLineHeight = 0.0;
                    if (expectedContentLabelSize.height > CommentContentCell_ShortenContentHeight && !isExtension) {
                        expectedContentLabelSize.height = CommentContentCell_ShortenContentHeight;
                        extensionLineHeight = CommentContentCell_ExtensionButtonHeight;
                    }
                    
                    totalHeight += CommentContentCell_TopMargin + CommentContentCell_FloorNoLabelHeight + CommentContentCell_ContentTopMargin + expectedContentLabelSize.height + extensionLineHeight+ CommentContentCell_ContentBottomMargin;

                }
                
                maximumLabelSize = CGSizeMake(self.commentTable.bounds.size.width - CommentContentCell_LeftMargin - CommentContentCell_RightMargin,9999);
                MLComment* commentMode = [comments lastObject];

                content = commentMode.content;
                BOOL isExtension = commentMode.isExtension;

                expectedContentLabelSize = [content sizeWithFont:[UIFont systemFontOfSize:CommentContentCell_SubContentFontSize]
                                               constrainedToSize:maximumLabelSize
                                                   lineBreakMode:NSLineBreakByWordWrapping];
                
                float extensionLineHeight = 0.0;
                if (expectedContentLabelSize.height > CommentContentCell_ShortenContentHeight && !isExtension) {
                    expectedContentLabelSize.height = CommentContentCell_ShortenContentHeight;
                    extensionLineHeight = CommentContentCell_ExtensionButtonHeight;
                }
                
                totalHeight += CommentContentCell_LastBorderTimeTopMargin + CommentContentCell_TimeLabelHeight + CommentContentCell_LastBorderTimeBottomMargin + CommentContentCell_LastBorderContentTopMargin + expectedContentLabelSize.height + extensionLineHeight + CommentContentCell_LastBorderContentBottomMargin;

            }
        }
    }
    return totalHeight;

}


- (BOOL)canBecomeFirstResponder
{
    return YES;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSInteger rowNum = indexPath.row;
    NSInteger section = indexPath.section;
    
    float height = 0.0;
    if (section == 0)
    {
        NSArray *commentsArr = [self.commentContentList hotObjectsWithIndex:indexPath.row];
        
        BOOL expend = NO;
        height = [self calculateCellHeightWithComments:commentsArr expand:expend];
    }
    else
    {
        NSArray *commentsArr = [self.commentContentList contentObjectsWithIndex:indexPath.row];
        
        BOOL expend = NO;
        
        if (_expandedIndexPath&&[_expandedIndexPath count]>0) {
            for (NSIndexPath* expandedPath in _expandedIndexPath) {
                NSInteger expandedRow = expandedPath.row;
                if (expandedRow==rowNum) {
                    expend = YES;
                    break;
                }
            }
        }
        
        height = [self calculateCellHeightWithComments:commentsArr expand:expend];
    }
    return height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (CommentListType_OnlyOrder == _commentListType || CommentListType_OnlyHot == _commentListType)
    {
        return 0;
    }
    if (section == 0) {
        NSInteger hotListCount = [self.commentContentList countOfHotList];
        if (hotListCount == 0) {
            return 0;
        }
    }
    else
    {
        NSInteger orderListCount = [self.commentContentList countOfOrderList];
        if (orderListCount == 0) {
            return 0;
        }
    }
    return 35.0;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    float height = 35.0;
    NSInteger hotListCount = [self.commentContentList countOfHotList];
    NSInteger orderListCount = [self.commentContentList countOfOrderList];
    if ((section == 0 && hotListCount == 0) || (section == 1 && orderListCount == 0)) {
        return nil;
    }
    UIView* view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, height)];
    view.backgroundColor = [UIColor whiteColor];
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(10, 1, 320, height - 2)];
    if (section == 0) {
        label.text = @"热门评论";
    }
    else
    {
        label.text = @"最新评论";
    }
    label.font = [UIFont systemFontOfSize:14.0];
    label.textColor = [UIColor colorWithRed:85.0/255.0 green:85.0/255.0 blue:85.0/255.0 alpha:1.0];
    
    [view addSubview:label];
    
    UIView* redLine = [[UIView alloc]initWithFrame:CGRectMake(10, 34, 58, 1)];
    redLine.backgroundColor = [UIColor redColor];
    [view addSubview:redLine];
    
    UIView* grayView = [[UIView alloc]initWithFrame:CGRectMake(redLine.frame.origin.x + redLine.frame.size.width, redLine.frame.origin.y, self.view.bounds.size.width - 20 - redLine.frame.size.width, 1)];
    grayView.backgroundColor = [UIColor colorWithRed:213.0/255.0 green:213.0/255.0 blue:213.0/255.0 alpha:1.0];;
    [view addSubview:grayView];
    
    return view;
}
#pragma mark - UITableViewData
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger count;
    if (section == 0) {
        count = [self.commentContentList countOfHotList];
    }
    else{
        count = [self.commentContentList countOfOrderList];
    }
    
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSInteger rowNum = [indexPath row];
    NSInteger section = [indexPath section];
    UITableViewCell* cell = nil;
    // 热门评论
    if (section == 0) {
        MLCommentContentCell* rtval = nil;
        static NSString* userIdentifier = @"CommentContentIdentifier";
        rtval = (MLCommentContentCell *)[tableView dequeueReusableCellWithIdentifier:userIdentifier];
        if (!rtval) {
            rtval = [[MLCommentContentCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:userIdentifier];
            rtval.delegate = self;
        }else {
//            NSLog(@"reusing");
        }
        rtval.expandLevel = NO;
        rtval.commentLevels = [self.commentContentList hotObjectsWithIndex:rowNum];
        [rtval reloadData];
        cell = rtval;
    }
    else
    {   // 其他评论
        MLCommentContentCell* rtval = nil;
        static NSString* userIdentifier = @"CommentContentIdentifier";
        rtval = (MLCommentContentCell*)[tableView dequeueReusableCellWithIdentifier:userIdentifier];
        if (!rtval) {
            rtval = [[MLCommentContentCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:userIdentifier];
            rtval.delegate = self;
        }else {
//            NSLog(@"reusing");
        }
        rtval.expandLevel = NO;
        if (_expandedIndexPath&&[_expandedIndexPath count]>0) {
            for (NSIndexPath* expandedPath in _expandedIndexPath) {
                NSInteger expandedRow = expandedPath.row;
                if (expandedRow==rowNum) {
                    rtval.expandLevel = YES;
                    break;
                }
            }
        }
        rtval.commentLevels = [self.commentContentList contentObjectsWithIndex:rowNum];
        [rtval reloadData];
        cell = rtval;
    }
    cell.contentView.backgroundColor = [UIColor colorWithRed:245.0/255.0 green:245.0/255.0 blue:245.0/255.0 alpha:1.0];
    return cell;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}


#pragma mark - lazy
- (UITableView *)commentTable {
    if (!_commentTable) {
        _commentTable = [[UITableView alloc]initWithFrame:self.view.bounds];
        _commentTable.delegate = self;
        _commentTable.dataSource = self;
        _commentTable.scrollsToTop = YES;
        _commentTable.separatorStyle = UITableViewCellSeparatorStyleNone;
        _commentTable.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
            [self refresh];
        }];
        _commentTable.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
            [self loadMore];
        }];
    }
    return _commentTable;
}

- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    _delegate = nil;
}
@end
