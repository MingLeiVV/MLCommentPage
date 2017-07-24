//
//  MLComment.h
//
//  Created by lei  on 14-12-11
//  Copyright (c) 2014 . All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MJExtension.h"


@interface MLComment : NSObject
@property (nonatomic, retain) NSString *time;
@property (nonatomic, retain) NSString *mid;
@property (nonatomic, retain) NSString *newsid;
@property (nonatomic, retain) NSString *parent;
@property (nonatomic, retain) NSString *suppor;
@property (nonatomic, retain) NSString *uid;
@property (nonatomic, retain) NSString *level;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *area;
@property (nonatomic, retain) NSString *profile;
@property (nonatomic, retain) NSString *content;
@property (nonatomic, retain) NSArray  *replay;

@property (nonatomic, assign) BOOL isExtension;// content 字数过多，如果为YES，则是用户手工点展开后

@end
