//
//  MLTool.m
//  MLTools
//
//  Created by Minlay on 16/9/20.
//  Copyright © 2016年 Minlay. All rights reserved.
//

#import "MLTool.h"
#include <time.h>
#include <stdio.h>

#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonCryptor.h>

#import <CommonCrypto/CommonHMAC.h>
#import <CommonCrypto/CommonCryptor.h>

#import <mach/mach.h>
#import <mach/mach_host.h>

#define ARC4RANDOM_MAX      0x10000000

#define MinuteLen 60
#define HourLen (60*(MinuteLen))
#define DayLen (24*(HourLen))
#define WeekLen (7*(DayLen))
#define MonthLen (30*(WeekLen))
#define YearLen (30*(MonthLen))

char* SHA1Digest(NSString*pwd)
{
    //计算SHA1摘要
    NSString* shaStr=[NSString stringWithFormat:@"fetion.com.cn:%@",pwd];
    uint8_t *res = (uint8_t *)malloc(sizeof(uint8_t)*100);
    uint8_t *b1 = (uint8_t *)malloc(sizeof(uint8_t)*(20+1));
    
    uint8_t temp[21]= {0};
    
    memset(res, 0, sizeof(uint8_t)*100);
    memset(b1, 0 ,sizeof(uint8_t)*(20+1));
    const char* pwdChar=[shaStr UTF8String];
    CC_SHA1(pwdChar, strlen(pwdChar), b1);
    
    for(int i=0;i<20;i++)
    {
        sprintf((char*)temp,"%02x",b1[i]);
        strcat((char*)res, (char*)temp);
    }
    free(b1);
    return (char*)res;
}

NSData*  sha1OfData(NSData* data)
{
    NSData* shaData=nil;
    int size=sizeof(uint8_t);
    uint8_t *b1 = (uint8_t *)malloc(size*(CC_SHA1_DIGEST_LENGTH+1));
    memset(b1, 0, sizeof(uint8_t)*(CC_SHA1_DIGEST_LENGTH+1));
    CC_SHA1([data bytes], [data length], b1);
    shaData=[[NSData alloc] initWithBytes:b1 length:CC_SHA1_DIGEST_LENGTH];
    free(b1);
    return shaData;
}

NSString* binToHexWithData(NSData*data)
{
    //将二进制数据转换为十六进制字符串
    if(data&&[data length]>0)
    {
        NSMutableString* mStr=[[NSMutableString alloc] initWithCapacity:0];
        
        for(int i=0;i<[data length];i++)
        {
            NSData* subData=[data subdataWithRange:NSMakeRange(i, 1)];
            uint8_t* bytes=(uint8_t*)[subData bytes];
            NSString* tempStr=[NSString stringWithFormat:@"%02X",bytes[0]];
            [mStr appendString:tempStr];
        }
        
        return mStr;
    }
    return nil;
}

NSUInteger getValueByChar(char ch)
{
    NSUInteger ret=0;
    switch(ch)
    {
        case 'A':ret=10;break;
        case 'B':ret=11;break;
        case 'C':ret=12;break;
        case 'D':ret=13;break;
        case 'E':ret=14;break;
        case 'F':ret=15;break;
        case '9':ret=9;break;
        case '8':ret=8;break;
        case '7':ret=7;break;
        case '6':ret=6;break;
        case '5':ret=5;break;
        case '4':ret=4;break;
        case '3':ret=3;break;
        case '2':ret=2;break;
        case '1':ret=1;break;
        case '0':ret=0;break;
    }
    return ret;
}
uint8_t  getCharValuewithPre(char pre,char next)
{
    NSUInteger preValue= getValueByChar(pre)*16;
    NSUInteger nextValue=getValueByChar(next);
    uint8_t ret=preValue+nextValue;
    return ret;
}

NSData* hexToBinWithString(NSString* txt)
{
    //将十六进制字符串转换为二进制数据.
    const char* charArray=[[txt uppercaseString] UTF8String];
    NSMutableData* mData=[[NSMutableData alloc] initWithLength:0];
    
    for(int i=0;i<[txt length];i+=2)
    {
        char  pre=charArray[i];
        char  next=charArray[i+1];
        uint8_t value=getCharValuewithPre(pre,  next);
        uint8_t chArrays[1]={value};
        [mData appendBytes:chArrays length:1];
    }
    
    
    return mData;//memory leak
}

NSData* AES256Encrypt(NSData* srcData,NSData* keyData)
{
    NSData* retData=nil;
    //keyData 必须为32个字节数据
    //设置向量
    uint8_t iv[]={ 0, 0x39, 0x9f, 0x3d, 0x12, 0x5d, 0xb5, 0x53, 0xa, 0xb5, 0xe0,
        0, 0xd6, 0xb0, 0xf4, 0x5a };
    const void* keyPtr=[keyData bytes];
    
    NSUInteger dataLength = [srcData length];
    
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    
    size_t numBytesEncrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt, kCCAlgorithmAES128, kCCOptionPKCS7Padding,
                                          keyPtr, kCCKeySizeAES256,
                                          iv /* initialization vector (optional) */,
                                          [srcData bytes], dataLength, /* input */
                                          buffer, bufferSize, /* output */
                                          &numBytesEncrypted);
    if (cryptStatus == kCCSuccess) {
        //the returned NSData takes ownership of the buffer and will free it on deallocation
        retData= [NSData dataWithBytes:buffer length:numBytesEncrypted];
    }
    
    free(buffer); //free the buffer;
    return retData;
}

NSData* AES256Decrypt(NSData* data,NSData* keyData)
{
    NSData* retData=nil;
    uint8_t iv[]={ 0, 0x39, 0x9f, 0x3d, 0x12, 0x5d, 0xb5, 0x53, 0xa, 0xb5, 0xe0,
        0, 0xd6, 0xb0, 0xf4, 0x5a };
    
    const void* keyPtr=[keyData bytes];
    
    NSUInteger dataLength = [data length];
    
    //See the doc: For block ciphers, the output size will always be less than or
    //equal to the input size plus the size of one block.
    //That's why we need to add the size of one block here
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    
    size_t numBytesDecrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt, kCCAlgorithmAES128, kCCOptionPKCS7Padding,
                                          keyPtr, kCCKeySizeAES256,
                                          iv /* initialization vector (optional) */,
                                          [data bytes], dataLength, /* input */
                                          buffer, bufferSize, /* output */
                                          &numBytesDecrypted);
    
    if (cryptStatus == kCCSuccess) {
        //the returned NSData takes ownership of the buffer and will free it on deallocation
        retData= [NSData dataWithBytes:buffer length:numBytesDecrypted];
    }
    
    free(buffer); //free the buffer;
    return retData;
    
}



@implementation MLTool


+ (BOOL)isRunningOniPad
{
    
    static BOOL hasCheckedDeviceType = NO;
    static BOOL isRunningOniPad = NO;
    
    if (!hasCheckedDeviceType) {
        if ([[UIDevice currentDevice] respondsToSelector:@selector(userInterfaceIdiom)])
        {
            
            if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
            {
                isRunningOniPad = YES;
                hasCheckedDeviceType = YES;
                return isRunningOniPad;
            }
            
        }
        
        hasCheckedDeviceType = YES;
    }
    
    return isRunningOniPad;
}

+ (UIDeviceOrientation)deviceOrientation
{
    return [[UIDevice currentDevice] orientation];
}
/*
 *加密用户密码：
 *输入：用户原始密码
 *输出:使用AES256加密后得到数据的十六进制格式字符串。
 */
+ (NSString*)encryptPwd:(NSString*)pwd
{
    NSString* ret=nil;
    if([pwd length]>0)
    {
        NSData* srcData=[pwd dataUsingEncoding:NSUTF8StringEncoding];
        NSString* keyStr=@"A16AEC8FD8612156308AAFADEAE7774EE081E7676AF9B0879C57602AB8F1105D";
        NSData* keyData=hexToBinWithString(keyStr);
        NSData* data=AES256Encrypt(srcData,keyData);
        ret=binToHexWithData(data);
    }
    return ret;
}
/*
 *解密用户密码：
 *输入：AES256加密后的十六进制字符串
 *输出:用户原始密码。
 */
+ (NSString*)decryptPwd:(NSString*)encryptPassword
{
    if([encryptPassword length]>0)
    {
        NSString* keyStr=@"A16AEC8FD8612156308AAFADEAE7774EE081E7676AF9B0879C57602AB8F1105D";
        NSData* keyData=hexToBinWithString(keyStr);
        NSData* data=hexToBinWithString(encryptPassword);
        NSData* srcData=AES256Decrypt(data, keyData);
        return [[NSString alloc] initWithData:srcData encoding:NSUTF8StringEncoding];
    }
    return nil;
}

+ (NSInteger)getFreeMemory
{
    mach_port_t host_port;
    mach_msg_type_number_t host_size;
    vm_size_t pagesize;
    host_port = mach_host_self();
    host_size = sizeof(vm_statistics_data_t) / sizeof(integer_t);
    host_page_size(host_port, &pagesize);
    vm_statistics_data_t vm_stat;
    if (host_statistics(host_port, HOST_VM_INFO, (host_info_t)&vm_stat, &host_size) != KERN_SUCCESS) {
        NSLog(@"Failed to fetch vm statistics");
        return 0.0;
    }
    /* Stats in bytes */
    natural_t mem_free = vm_stat.free_count * pagesize;
    
    return mem_free*1.0;
}

+ (NSString *)getDeviceUniqueMD5
{
    static NSString* macaddressMd5 = nil;
//    if (!macaddressMd5) {
//        NSString* macaddress = [[UIDevice currentDevice] macaddress];
//        macaddressMd5 = [self MD5DigestFromString:macaddress];
//    }
    return macaddressMd5;
}

+ (NSString *)getSid
{
//    NSString* macaddress = [[UIDevice currentDevice] macaddress];
//    NSDate* nowDate = [NSDate date];
//    NSTimeInterval nowInterval = [nowDate timeIntervalSince1970];
//    NSString* rtval = [NSString stringWithFormat:@"%@%f",macaddress,nowInterval];
//    rtval = [self MD5DigestFromString:rtval];
    return nil;
}

+ (NSString*)MD5DigestFromString:(NSString*)aString
{
    return [MLTool MD5Digest:[aString dataUsingEncoding:NSUTF8StringEncoding]];
}

+ (NSString*)MD5Digest:(NSData*)data
{
    //计算MD5摘要
    NSString* retData=nil;
    if([data length]>0)
    {
        uint8_t result[CC_MD5_DIGEST_LENGTH];
        CC_MD5([data bytes],[data length],result);
        retData = [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",result[0], result[1], result[2], result[3],
                   result[4], result[5], result[6], result[7],
                   result[8], result[9], result[10], result[11],
                   result[12], result[13], result[14], result[15]];
    }
    return retData;
}

+ (NSString*)MD5RandomString
{
    return [self MD5RandomStringFromTime:nil extraNum:YES];
}

+ (NSString*)MD5RandomStringFromTime:(NSDate*)cTime extraNum:(BOOL)bNeed
{
    if (!cTime) {
        cTime = [NSDate date];
    }
    double timeNum = [cTime timeIntervalSince1970];
    if (bNeed) {
        srandom(time(NULL));
        double val = floorf(((double)arc4random())/ARC4RANDOM_MAX);
        timeNum += val;
    }
    NSString* rtval = [MLTool MD5DigestFromString:[NSString stringWithFormat:@"%f",timeNum]];
    return rtval;
}

+ (NSString*) stringWithUUID {
    CFUUIDRef    uuidObj = CFUUIDCreate(nil);//create a new UUID
    //get the string representation of the UUID
    NSString    *uuidString = (NSString*)CFBridgingRelease(CFUUIDCreateString(nil, uuidObj));
    CFRelease(uuidObj);
    return uuidString;
}

+ (NSString *)HMAC_SHA1:(NSString *)key text:(NSString *)text
{
    
    const char *cKey  = [key cStringUsingEncoding:NSUTF8StringEncoding];
    const char *cData = [text cStringUsingEncoding:NSUTF8StringEncoding];
    
    char cHMAC[CC_SHA1_DIGEST_LENGTH];
    
    CCHmac(kCCHmacAlgSHA1, cKey, strlen(cKey), cData, strlen(cData), cHMAC);
    
    NSData *HMAC = [[NSData alloc] initWithBytes:cHMAC length:CC_SHA1_DIGEST_LENGTH];
    NSString *hash = [HMAC base64Encoding];//base64 编码。
    return hash;
}

+(UIImage*)makeTwoImageForOne:(UIImage*)image1 firstRect:(CGRect)subRect1 secondImage:(UIImage*)image2 sencondRect:(CGRect)subRect2
{
    CGSize destSizeNew = CGSizeMake(MAX(subRect1.size.width+subRect1.origin.x, subRect2.size.width+subRect2.origin.x), MAX(subRect1.size.height+subRect1.origin.y, subRect2.size.height+subRect2.origin.y));
    CGFloat scale1 = 1.0;
    CGFloat scale2 = 1.0;
    if([image1 respondsToSelector:@selector(scale)])
    {
        scale1 = image1.scale;
        scale2 = image2.scale;
        if (scale1>1.0||scale2>1.0) {
            destSizeNew = CGSizeMake(destSizeNew.width*(MAX(scale1, scale2)), destSizeNew.height*(MAX(scale1, scale2)));
            subRect1 = CGRectMake(subRect1.origin.x, subRect1.origin.y, subRect1.size.width*scale1, subRect1.size.height*scale1);
            subRect2 = CGRectMake(subRect2.origin.x*scale1, subRect2.origin.y*scale1, subRect2.size.width*scale1, subRect2.size.height*scale1);
            image1 = [[UIImage alloc]initWithCGImage:image1.CGImage scale:1.0 orientation:image1.imageOrientation];
            image2 = [[UIImage alloc]initWithCGImage:image2.CGImage scale:1.0 orientation:image2.imageOrientation];
        }
    }
    
    
    UIGraphicsBeginImageContext(destSizeNew);
    [image1 drawInRect:subRect1];
    [image2 drawInRect:subRect2];
    UIImage* outImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    UIImage* rtval = nil;
    if([image1 respondsToSelector:@selector(scale)])
    {
        if (scale1>1.0||scale2>1.0) {
        }
        rtval = [UIImage imageWithCGImage:outImage.CGImage scale:(scale1>1.0||scale2>1.0?2.0:1.0) orientation:outImage.imageOrientation];
    }
    else
    {
        rtval = outImage;
    }
    return rtval;
}

+ (NSString*)writeToDocument:(id)data folder:(NSString*)folderName fileName:(NSString*)filename
{
    NSArray* documentPathArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* documentPath = [documentPathArray objectAtIndex:0];
    if (folderName) {
        documentPath = [documentPath stringByAppendingPathComponent:folderName];
    }
    if (![[NSFileManager defaultManager] fileExistsAtPath:documentPath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:documentPath withIntermediateDirectories:YES attributes:nil error:NULL];
    }
    NSString* filepathName = [documentPath stringByAppendingPathComponent:filename];
    NSLog(@"filepathName=%@",filepathName);
    if ([data respondsToSelector:@selector(writeToFile:atomically:)]) {
        BOOL ret = [data writeToFile:filepathName atomically:YES];
        if (ret) {
            return filepathName;
        }
    }
    return nil;
}

+ (NSString*)stringFromDocumentFolder:(NSString*)folderName fileName:(NSString*)filename
{
    NSArray* documentPathArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* documentPath = [documentPathArray objectAtIndex:0];
    if (folderName) {
        documentPath = [documentPath stringByAppendingPathComponent:folderName];
    }
    NSString* filepathName = [documentPath stringByAppendingPathComponent:filename];
    NSString* rtval = [NSString stringWithContentsOfFile:filepathName encoding:NSUTF8StringEncoding error:nil];
    if (!rtval) {
        rtval = [NSString stringWithContentsOfFile:filepathName encoding:NSUnicodeStringEncoding error:nil];
    }
    return rtval;
}

+ (NSDictionary*)dictFromDocumentFolder:(NSString*)folderName fileName:(NSString*)filename
{
    NSArray* documentPathArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* documentPath = [documentPathArray objectAtIndex:0];
    if (folderName) {
        documentPath = [documentPath stringByAppendingPathComponent:folderName];
    }
    NSString* filepathName = [documentPath stringByAppendingPathComponent:filename];
    NSDictionary* rtval = [NSDictionary dictionaryWithContentsOfFile:filepathName];
    return rtval;
}

+ (NSArray*)arrayFromDocumentFolder:(NSString*)folderName fileName:(NSString*)filename
{
    NSArray* documentPathArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* documentPath = [documentPathArray objectAtIndex:0];
    if (folderName) {
        documentPath = [documentPath stringByAppendingPathComponent:folderName];
    }
    NSString* filepathName = [documentPath stringByAppendingPathComponent:filename];
    NSArray* rtval = [NSArray arrayWithContentsOfFile:filepathName];
    return rtval;
}

+ (NSString*)humanizeDateFormatFromDate:(NSDate*)date
{
    NSString* showedStr = @"刚刚";
    NSTimeInterval timeLen = [date timeIntervalSinceNow];
    timeLen = abs((int)timeLen)*1.0;
    if (date) {
        if ((int)timeLen/YearLen>=1) {
            int hours = (int)timeLen/YearLen;
            showedStr = [NSString stringWithFormat:@"%d年前",hours];
        }
        else if ((int)timeLen/MonthLen>=1) {
            int hours = (int)timeLen/MonthLen;
            showedStr = [NSString stringWithFormat:@"%d月前",hours];
        }
        else if ((int)timeLen/WeekLen>=1) {
            int hours = (int)timeLen/WeekLen;
            showedStr = [NSString stringWithFormat:@"%d周前",hours];
        }
        else if ((int)timeLen/DayLen>=1) {
            int days = (int)timeLen/DayLen;
            showedStr = [NSString stringWithFormat:@"%d天前",days];
        }
        else if ((int)timeLen/HourLen>=1) {
            int hours = (int)timeLen/HourLen;
            showedStr = [NSString stringWithFormat:@"%d小时前",hours];
        }
        else if ((int)timeLen/MinuteLen>=1) {
            int minutes = (int)timeLen/MinuteLen;
            showedStr = [NSString stringWithFormat:@"%d分钟前",minutes];
        }
    }
    return showedStr;
}

+ (NSString*)threePartDateFormatFromDate:(NSDate*)date
{
    NSString* showedStr = @"";
    NSTimeInterval timeLen = [date timeIntervalSinceNow];
    timeLen = abs((int)timeLen)*1.0;
    if (date) {
        NSDateFormatter* formater = [[NSDateFormatter alloc] init];
        if ((int)timeLen/DayLen>=1)
        {
            
            formater.dateFormat = @"yyyy-MM-dd";
            
        }
        else
        {
            formater.dateFormat = @"HH:mm:ss";
        }
        showedStr = [formater stringFromDate:date];
    }
    return showedStr;
}

+ (NSString *)flattenHTML:(NSString *)html
{
    NSScanner *theScanner;
    NSString *text = nil;
    theScanner = [NSScanner scannerWithString:html];
    while ([theScanner isAtEnd] == NO) {
        // find start of tag
        [theScanner scanUpToString:@"<" intoString:NULL] ;
        // find end of tag
        [theScanner scanUpToString:@">" intoString:&text] ;
        // replace the found tag with a space
        //(you can filter multi-spaces out later if you wish)
        html = [html stringByReplacingOccurrencesOfString:
                [ NSString stringWithFormat:@"%@>", text]
                                               withString:@""];
        
    } // while //
    
    return html;
}

+ (NSInteger)getFileSizeFromPath:(NSString*)pathString
{
    const char* path = [pathString UTF8String];
    FILE * file;
    int fileSizeBytes = 0;
    file = fopen(path,"r");
    if(file>0){
        fseek(file, 0, SEEK_END);
        fileSizeBytes = ftell(file);
        fseek(file, 0, SEEK_SET);
        fclose(file);
    }
    return fileSizeBytes;
}

+ (BOOL)isRetina
{
    BOOL rtval = NO;
    if ([UIScreen instancesRespondToSelector:@selector(currentMode)]) {
        CGSize screenSize = [[[UIScreen mainScreen] currentMode] size];
        if (CGSizeEqualToSize(screenSize, CGSizeMake(640, 960))) {
            rtval = YES;
        }
        else if (CGSizeEqualToSize(screenSize, CGSizeMake(2048, 1536))) {
            rtval = YES;
        }
        else if (CGSizeEqualToSize(screenSize, CGSizeMake(640, 1136))) {
            rtval = YES;
        }
    }
    return rtval;
    
}

+(NSString*)urlParmFormatWithSourceString:(NSString*)sourceString FromDict:(NSDictionary*)dict order:(NSArray*)orderArray useEncode:(BOOL)encoded
{
    NSString* rtval = sourceString;
    if (dict) {
        if(!rtval)
        {
            rtval = @"";
        }
        NSArray* keyArray = [dict allKeys];
        int keyCount = [keyArray count];
        if (orderArray) {
            keyCount = [orderArray count];
        }
        for (int i = 0; i<keyCount; i++) {
            NSString* oneKey = nil;
            if (orderArray) {
                oneKey = [orderArray objectAtIndex:i];
            }
            else
            {
                oneKey = [keyArray objectAtIndex:i];
            }
            
            NSString* oneValue = [dict objectForKey:oneKey];
            if (oneValue) {
                if (encoded) {
//                    rtval = [self urlString:rtval replaceStringKey:[oneKey rawUrlEncode] withValueString:[oneValue rawUrlEncode]];
                }
                else
                {
                    rtval = [self urlString:rtval replaceStringKey:oneKey withValueString:oneValue];
                }
            }
        }
    }
    return rtval;
}

+(BOOL)isPad
{
    return (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
}

+ (BOOL)isSimulator
{
    return (NSNotFound != [[[UIDevice currentDevice] model] rangeOfString:@"Simulator"].location);
}

+ (BOOL)isPureInt:(NSString *)string{
    
    NSScanner* scan = [NSScanner scannerWithString:string];
    
    int val;
    
    return [scan scanInt:&val] && [scan isAtEnd];
    
}

+ (BOOL)isPureFloat:(NSString *)string{
    
    NSScanner* scan = [NSScanner scannerWithString:string];
    
    float val;
    
    return [scan scanFloat:&val] && [scan isAtEnd];
}

+ (BOOL)isDigtal:(NSString *)string
{
    BOOL rtval = NO;
    if (string&&[string length]>0) {
        if ([self isPureInt:string]) {
            rtval = YES;
        }
        else if([self isPureFloat:string])
        {
            rtval = YES;
        }
    }
    
    return rtval;
}

+ (BOOL)isLegalIP:(NSString*)ipString
{
    BOOL rtval = NO;
    if (ipString&&[ipString length]>0) {
        NSArray* ipComments = [ipString componentsSeparatedByString:@"."];
        if ([ipComments count]==4) {
            BOOL isLegal = YES;
            for (NSString* oneString in ipComments) {
                if ([MLTool isDigtal:oneString]) {
                    if ([oneString intValue]<=255&&[oneString intValue]>=0) {
                        ;
                    }
                    else {
                        isLegal = NO;
                        break;
                    }
                }
                else {
                    isLegal = NO;
                    break;
                }
            }
            if (isLegal) {
                rtval = YES;
            }
        }
    }
    return rtval;
}

+ (NSString*)digtalStringFromPrefixSufixDigtalString:(NSString*)string
{
    NSString* rtval = @"";
    if (string&&[string length]>0) {
        NSInteger curIndex = 0;
        NSInteger curLen = [string length];
        while (curLen>0) {
            NSString* curString = [string substringWithRange:NSMakeRange(curIndex, curLen)];
            if ([MLTool isDigtal:curString]) {
                break;
            }
            else {
                if ([curString length]>1) {
                    NSString* tempString = [curString substringWithRange:NSMakeRange(0, 1)];
                    BOOL needFromRight = NO;
                    if (![MLTool isDigtal:tempString]) {
                        if (([tempString isEqualToString:@"-"]||[tempString isEqualToString:@"+"])&&[curString length]>1) {
                            NSString* temp2 = [curString substringWithRange:NSMakeRange(1, 1)];
                            if ([MLTool isDigtal:temp2]) {
                                needFromRight = YES;
                            }
                            else {
                                curIndex += 2;
                                curLen -= 2;
                            }
                        }
                    }
                    else {
                        needFromRight = YES;
                    }
                    
                    if (needFromRight) {
                        tempString = [curString substringWithRange:NSMakeRange([curString length]-1, 1)];
                        if (![MLTool isDigtal:tempString]) {
                            curLen -= 1;
                        }
                        else {
                            NSInteger curSearchIndex = [tempString length]-1;
                            NSString* tempString3 = [curString substringWithRange:NSMakeRange(curSearchIndex, 1)];
                            while ([MLTool isDigtal:tempString3]&&curSearchIndex>0) {
                                curSearchIndex -= 1;
                                tempString3 = [curString substringWithRange:NSMakeRange(curSearchIndex, 1)];
                            }
                            curLen -= curLen - curSearchIndex;
                        }
                    }
                }
                else {
                    curLen = 0;
                    break;
                }
            }
        }
        
        if (curLen>0) {
            rtval = [string substringWithRange:NSMakeRange(curIndex, curLen)];
        }
    }
    return rtval;
    
}

+ (NSComparisonResult)versionCompareWithVersion1:(NSString*)version1 version2:(NSString*)version2
{
    if (version1&&version2) {
        NSComparisonResult result = NSOrderedSame;
        NSArray* versionArray1 = [version1 componentsSeparatedByString:@"."];
        NSArray* versionArray2 = [version2 componentsSeparatedByString:@"."];
        int arrayCount1 = [versionArray1 count];
        int arrayCount2 = [versionArray2 count];
        int maxCount = arrayCount1>arrayCount2?arrayCount1:arrayCount2;
        for (int i=0; i<maxCount; i++) {
            int versionComponet1 = 0;
            if (arrayCount1>i) {
                versionComponet1 = [(NSString*)[versionArray1 objectAtIndex:i] intValue];
            }
            int versionComponet2 = 0;
            if (arrayCount2>i) {
                versionComponet2 = [(NSString*)[versionArray2 objectAtIndex:i] intValue];
            }
            if (versionComponet1<versionComponet2) {
                result = NSOrderedAscending;
                break;
            }
            else if(versionComponet1>versionComponet2){
                result = NSOrderedDescending;
                break;
            }
        }
        return result;
    }
    else {
        if (version1&&!version2) {
            return NSOrderedDescending;
        }
        else if(!version1&&version2)
        {
            return NSOrderedAscending;
        }
        else {
            return NSOrderedSame;
        }
    }
}

+(NSString*)urlString:(NSString*)urlString replaceStringKey:(NSString*)stringKey  withValueString:(NSString*)valueString
{
    NSString* rtval = urlString;
    if (stringKey) {
        if (![stringKey  hasSuffix:@"="]) {
            stringKey  = [stringKey  stringByAppendingString:@"="];
        }
        if (urlString==nil) {
            urlString = @"";
        }
        NSRange keyRange = [urlString rangeOfString:stringKey];
        if (keyRange.location!=NSNotFound) {
            if (keyRange.location>0) {
                NSRange connectRange = NSMakeRange(keyRange.location-1, 1);
                NSString* connectString = [urlString substringWithRange:connectRange];
                while (![connectString isEqualToString:@"?"]&&![connectString isEqualToString:@"&"]) {
                    keyRange = [urlString rangeOfString:stringKey options:NSCaseInsensitiveSearch range:NSMakeRange(keyRange.location+keyRange.length, urlString.length - (keyRange.location+keyRange.length))];
                    if (keyRange.location!=NSNotFound) {
                        connectRange = NSMakeRange(keyRange.location-1, 1);
                        connectString = [urlString substringWithRange:connectRange];
                    }
                    else
                    {
                        break;
                    }
                }
            }
        }
        if (keyRange.location!=NSNotFound) {
            NSString* firstString = [urlString substringToIndex:keyRange.location];
            NSString* secondString = nil;
            NSInteger andRangeLoc = keyRange.location+keyRange.length;
            NSRange andRange = [urlString rangeOfString:@"&" options:NSCaseInsensitiveSearch range:NSMakeRange(andRangeLoc, urlString.length - andRangeLoc)];
            if (andRange.location!=NSNotFound) {
                NSRange secondRange = NSMakeRange(andRange.location, urlString.length - (andRange.location));
                secondString = [urlString substringWithRange:secondRange];
            }
            secondString = secondString==nil?@"":secondString;
            rtval = [NSString stringWithFormat:@"%@%@%@%@",firstString,stringKey,valueString,secondString];
        }
        else
        {
            if ([urlString rangeOfString:@"?"].location!=NSNotFound)
                rtval = [urlString stringByAppendingFormat:@"&%@%@",stringKey ,valueString];
            else
                rtval = [urlString stringByAppendingFormat:@"?%@%@",stringKey ,valueString];
        }
    }
    return rtval;
}

+(NSString*)urlString:(NSString*)urlString valueForKey:(NSString*)stringKey
{
    NSString* rtval = nil;
    if (stringKey&&urlString) {
        if (![stringKey  hasSuffix:@"="]) {
            stringKey  = [stringKey  stringByAppendingString:@"="];
        }
        NSRange keyRange = [urlString rangeOfString:stringKey];
        if (keyRange.location!=NSNotFound) {
            NSRange searchRange = NSMakeRange(keyRange.location+keyRange.length, urlString.length - (keyRange.location+keyRange.length));
            NSRange seperatorRange1 = [urlString rangeOfString:@"?" options:NSCaseInsensitiveSearch range:searchRange];
            NSRange seperatorRange2 = [urlString rangeOfString:@"&" options:NSCaseInsensitiveSearch range:searchRange];
            NSInteger seperatorlocation = NSNotFound;
            if (seperatorRange1.location!=NSNotFound) {
                seperatorlocation = seperatorRange1.location;
            }
            if (seperatorRange2.location!=NSNotFound) {
                seperatorlocation = (seperatorlocation>seperatorRange2.location)?(seperatorRange2.location):seperatorlocation;
            }
            NSRange valueRange = searchRange;
            if (seperatorlocation!=NSNotFound) {
                valueRange.length = seperatorlocation - valueRange.location;
            }
            rtval = [urlString substringWithRange:valueRange];
        }
        
    }
    return rtval;
}

+(NSString*)formatlizeJSonStringWith:(NSString*)oldJson
{
    NSString* rtval = oldJson;
    if ([oldJson hasPrefix:@"("]) {
        oldJson = [oldJson substringFromIndex:1];
    }
    if ([rtval hasSuffix:@")"]) {
        oldJson = [oldJson substringToIndex:[oldJson length]-1];
    }
    
    NSRange oldRange = [oldJson rangeOfString:@"\\'"];
    while (oldRange.location!=NSNotFound) {
        BOOL needAdd = NO;
        if (oldRange.location>0) {
            NSString* preString = [oldJson substringWithRange:NSMakeRange(oldRange.location-1, 1)];
            if ([preString isEqualToString:@"\\"]) {
                needAdd = NO;
            }
            else {
                needAdd = YES;
            }
        }
        else {
            needAdd = YES;
        }
        if (needAdd) {
            oldJson = [oldJson stringByReplacingOccurrencesOfString:@"\\'" withString:@"\\\\'"];
        }
        int location = oldRange.location+oldRange.length+1;
        NSRange leftRange = NSMakeRange(location, oldJson.length - location);
        oldRange = [oldJson rangeOfString:@"\\'" options:NSCaseInsensitiveSearch range:leftRange];
    }
    
    NSMutableString* preSlashString = [NSMutableString stringWithCapacity:0];
    NSMutableString* findedString = [NSMutableString stringWithCapacity:0];
    NSMutableString* resultString = [NSMutableString stringWithCapacity:0];
    NSMutableArray* typeArray = [NSMutableArray arrayWithCapacity:0];
    int curIndex = 0;
    BOOL bDoubleQurtIn = NO;
    BOOL bStart = NO;
    while (curIndex<[oldJson length]) {
        BOOL oldStart = bStart;
        NSString* charStr = [oldJson substringWithRange:NSMakeRange(curIndex, 1)];
        if (![preSlashString isEqualToString:@"\\"]) {
            if([charStr isEqualToString:@"{"]&&!bDoubleQurtIn)
            {
                [typeArray addObject:@"{"];
                bStart = YES;
            }
            else if([charStr isEqualToString:@","]&&!bDoubleQurtIn)
            {
                NSString* lastType = [typeArray lastObject];
                if ([lastType isEqualToString:@"{"]) {
                    bStart = YES;
                }
                
            }
            else if(bStart&&[charStr isEqualToString:@"}"]&&!bDoubleQurtIn)
            {
                [typeArray removeLastObject];
                bStart = NO;
            }
            else if(bStart&&[charStr isEqualToString:@":"]&&!bDoubleQurtIn)
            {
                bStart = NO;
            }
            else if(bStart&&[charStr isEqualToString:@"("]&&!bDoubleQurtIn)
            {
                [typeArray addObject:@"("];
                bStart = NO;
            }
            else if(bStart&&[charStr isEqualToString:@")"]&&!bDoubleQurtIn)
            {
                [typeArray removeLastObject];
                bStart = NO;
            }
            else if(bStart&&[charStr isEqualToString:@"["]&&!bDoubleQurtIn)
            {
                [typeArray addObject:@"["];
                bStart = NO;
            }
            else if(bStart&&[charStr isEqualToString:@"]"]&&!bDoubleQurtIn)
            {
                [typeArray removeLastObject];
                bStart = NO;
            }
            else if ([charStr isEqualToString:@"\""]) {
                bDoubleQurtIn = !bDoubleQurtIn;
            }
            else{
                
            }
        }
        
        if (bStart) {
            if (!oldStart) {
                [findedString appendString:charStr];
                [resultString appendString:findedString];
                [findedString setString:@""];
            }
            else {
                BOOL hasOldStringStart = NO;
                if (curIndex>0) {
                    NSString* oldCharStr = [oldJson substringWithRange:NSMakeRange(curIndex-1, 1)];
                    if ([oldCharStr isEqualToString:@","]&&!bDoubleQurtIn&&[charStr isEqualToString:@"{"]) {
                        hasOldStringStart = YES;
                    }
                }
                
                if (!hasOldStringStart) {
                    [findedString appendString:charStr];
                }
                else {
                    [findedString appendString:charStr];
                    [resultString appendString:findedString];
                    [findedString setString:@""];
                }
            }
        }
        else
        {
            if (!oldStart) {
                [findedString appendString:charStr];
            }
            else {
                NSString* thisString = @"";
                if (![findedString hasPrefix:@"\""]) {
                    thisString = [thisString stringByAppendingString:@"\""];
                }
                thisString = [thisString stringByAppendingString:findedString];
                if (![findedString hasSuffix:@"\""]) {
                    thisString = [thisString stringByAppendingString:@"\""];
                }
                [resultString appendString:thisString];
                [findedString setString:charStr];
            }
        }
        curIndex++;
        if ([charStr isEqualToString:@"\\"]) {
            if ([preSlashString length]>0) {
                [preSlashString setString:@""];
            }
            else
            {
                [preSlashString appendString:charStr];
            }
        }
        else
        {
            [preSlashString setString:@""];
        }
    }
    if ([findedString length]>0) {
        [resultString appendString:findedString];
    }
    if ([resultString length]!=0) {
        rtval = resultString;
    }
    return rtval;
}

+(UIColor *)colorWithHexString:(NSString *)color
{
    if ([color isKindOfClass:[NSString class]]) {
        NSString *cString = [[color stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
        
        // String should be 6 or 8 characters
        if ([cString length] < 6) {
            return [UIColor clearColor];
        }
        
        // strip 0X if it appears
        if ([cString hasPrefix:@"0X"])
            cString = [cString substringFromIndex:2];
        if ([cString hasPrefix:@"#"])
            cString = [cString substringFromIndex:1];
        if ([cString length] != 6)
            return [UIColor clearColor];
        
        // Separate into r, g, b substrings
        NSRange range;
        range.location = 0;
        range.length = 2;
        
        //r
        NSString *rString = [cString substringWithRange:range];
        
        //g
        range.location = 2;
        NSString *gString = [cString substringWithRange:range];
        
        //b
        range.location = 4;
        NSString *bString = [cString substringWithRange:range];
        
        // Scan values
        BOOL ret = YES;
        unsigned int r, g, b;
        if (ret) {
            ret = [[NSScanner scannerWithString:rString] scanHexInt:&r];
        }
        if (ret) {
            ret = [[NSScanner scannerWithString:gString] scanHexInt:&g];
        }
        if (ret) {
            ret = [[NSScanner scannerWithString:bString] scanHexInt:&b];
        }
        if (ret) {
            return [UIColor colorWithRed:((float) r / 255.0f) green:((float) g / 255.0f) blue:((float) b / 255.0f) alpha:1.0f];
        }
        else {
            return [UIColor clearColor];
        }
    }
    else if([color isKindOfClass:[UIColor class]]){
        return (UIColor*)color;
    }
    else {
        return [UIColor clearColor];
    }
}

+(NSString *)IPStringWtihLastComponetHiden: (NSString *)ipString
{
    NSString* rtval = nil;
    if (ipString) {
        NSArray* ipComponet = [ipString componentsSeparatedByString:@"."];
        NSMutableArray* newArray = [NSMutableArray arrayWithCapacity:0];
        [newArray addObjectsFromArray:ipComponet];
        [newArray removeLastObject];
        [newArray addObject:@"*"];
        rtval = [newArray componentsJoinedByString:@"."];
    }
    return rtval;
}
+ (void)removeExcessCellOfTableView:(UITableView *)table {
    UIView *divisionView = [[UIView alloc] initWithFrame:CGRectZero];
    [table setTableFooterView:divisionView];
}
@end
