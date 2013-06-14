//
//  ILSLogger.h
//  ILSLogger
//
//  Created by bloodmagic on 13-5-7.
//  Copyright (c) 2013年 iLegendSoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

enum ILSLogLevel {ILSLogLevelError = 0, ILSLogLevelInfo = 1,};

/***********************************************************************
 使用方法：
 
 1，在 appDelegate 的 didFinishLaunch 中调用合适的 [[ILSLogger sharedLogger] configureXXX];
 2，在需要打印日志的地方调用 ILSLogXXX (domain是一个逻辑概念，可以用来把log分为不同的逻辑组，方便筛选。)
 
 启动iMac中的 NSLogger viewer 即可看到实时 Log。
 
 bonjourName的设置：
 bonjour协议是根据name来定位局域网内部的服务器的。如果不设置，Log客户端会随意连接第一个匹配的服务器。
 所以约定如下：
 1，在iMac的NSLogger 查看工具中，进入设置－》Network－》Bonjour Service Name －》设为当前登录的用户帐号。（基于用户帐号一般都是不重复的）
 2，在集成的App中点击Project，选中Project（不是target）－》build setting－》Preprocessor Macros 的 Debug，Release下分别添加宏定义 LOGGER_TARGET=@\"$(USER)\"
 3，在集成的App的 appDelegate 的didFinishLaunchingWithOptions 中加入 configure 调用，比如：[[ILSLogger sharedLogger] configureDebugMode:LOGGER_TARGET];
 
********** 如果上述方法导致重复，[[ILSLogger sharedLogger] configureDebugMode:@"填写iMac的hostname，即，系统设置－》分享，最上方有个电脑名称"];

 **********************************************************************/

@interface ILSLogger : NSObject

+(ILSLogger*) sharedLogger;

// 快捷设置：根据 Debug / Release 自动选择最合适的配置。
-(void) configureDebugMode:(NSString*)bonjourName;
-(void) configureReleaseMode:(NSString*)bonjourName;

// 手动设置
-(void) configureWithLogLevel:(enum ILSLogLevel) logLevel // 日志的级别
              domainWhiteList:(NSArray*)domainWhiteList // “domain”白名单，在白名单内的日志，无论是否到达级别都会被显示
                  bonjourName:(NSString*)bonjourName; // iMac NSLogger 的bonjour服务器名字，约定设定为当前登录用户的用户名，客户端连接时设置为：LOGGER_TARGET，
-(NSString*) getLocalLogString; // 返回本地的log

@end

#ifdef __cplusplus
extern "C" {
#endif
    extern void ILSLogString(NSString *domain, int level, NSString *format, ...) NS_FORMAT_FUNCTION(3,4);
    
    
    // Function APIs
    extern void ILSLogImage(UIImage* image);
    extern void ILSLogUIView(UIView* view);
    extern void ILSLogData(NSData* data);
    
    extern void ILSLogFlush();
#ifdef __cplusplus
};
#endif


// Macro APIs
#define ILSLogInfo(domain, ...)    ILSLogString(domain,ILSLogLevelInfo,__VA_ARGS__)
#define ILSLogError(domain, ...)    ILSLogString(domain,ILSLogLevelError,__VA_ARGS__)

// Override assert
#if defined(DEBUG) && !defined(NDEBUG)
#undef assert
#if __DARWIN_UNIX03
#define assert(e) \
(__builtin_expect(!(e), 0) ? (ILSLogFlush(), __assert_rtn(__func__, __FILE__, __LINE__, #e)) : (void)0)
#else
#define assert(e)  \
(__builtin_expect(!(e), 0) ? (ILSLogFlush(), __assert(#e, __FILE__, __LINE__)) : (void)0)
#endif
#endif
