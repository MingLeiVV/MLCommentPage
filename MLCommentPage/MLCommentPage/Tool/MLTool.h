//
//  MLTool.h
//  MLTools
//
//  Created by Minlay on 16/9/20.
//  Copyright © 2016年 Minlay. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface MLTool : NSObject
+ (BOOL)isRunningOniPad;
+ (UIDeviceOrientation)deviceOrientation;
+ (NSString*)encryptPwd:(NSString*)pwd;
+ (NSString*)decryptPwd:(NSString*)encryptPassword;
+ (NSString*)MD5DigestFromString:(NSString*)aString;
+ (NSString*)MD5Digest:(NSData*)data;
+ (NSString*)MD5RandomString;
+ (NSString*)MD5RandomStringFromTime:(NSDate*)cTime extraNum:(BOOL)bNeed;
+ (NSString*) stringWithUUID;
+ (NSString *)HMAC_SHA1:(NSString *)key text:(NSString *)text;
+ (NSInteger)getFreeMemory;
+ (NSString *)getDeviceUniqueMD5;
+ (NSString *)getSid;
+ (UIImage*)makeTwoImageForOne:(UIImage*)image1 firstRect:(CGRect)subRect1 secondImage:(UIImage*)image2 sencondRect:(CGRect)subRect2;
+ (NSString*)writeToDocument:(id)data folder:(NSString*)folderName fileName:(NSString*)filename;
+ (NSString*)stringFromDocumentFolder:(NSString*)folderName fileName:(NSString*)filename;
+ (NSDictionary*)dictFromDocumentFolder:(NSString*)folderName fileName:(NSString*)filename;
+ (NSArray*)arrayFromDocumentFolder:(NSString*)folderName fileName:(NSString*)filename;
+ (NSString*)humanizeDateFormatFromDate:(NSDate*)date;
+ (NSString*)threePartDateFormatFromDate:(NSDate*)date;
+ (NSString *)flattenHTML:(NSString *)html;
+ (NSInteger)getFileSizeFromPath:(NSString*)pathString;
+ (BOOL)isRetina;
+ (BOOL)isPad;
+ (BOOL)isSimulator;

+ (BOOL)isDigtal:(NSString *)string;
+ (BOOL)isLegalIP:(NSString*)ipString;
+ (NSString*)digtalStringFromPrefixSufixDigtalString:(NSString*)string;
+ (NSComparisonResult)versionCompareWithVersion1:(NSString*)version1 version2:(NSString*)version2;

+(NSString*)urlParmFormatWithSourceString:(NSString*)sourceString FromDict:(NSDictionary*)dict order:(NSArray*)orderArray useEncode:(BOOL)encoded;
+(NSString*)urlString:(NSString*)urlString replaceStringKey:(NSString*)stringKey withValueString:(NSString*)valueString;
+(NSString*)urlString:(NSString*)urlString valueForKey:(NSString*)stringKey;
+(NSString*)formatlizeJSonStringWith:(NSString*)oldJson;
+(UIColor *)colorWithHexString: (NSString *)color;
+(NSString *)IPStringWtihLastComponetHiden: (NSString *)ipString;
// 快速删除cell多余的行
+ (void)removeExcessCellOfTableView:(UITableView *)table;
@end
