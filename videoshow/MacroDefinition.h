//
//  MacroDefinition.h
//  HelloHaHa
//
//  Created by MrNing on 15/1/8.
//  Copyright (c) 2015年 NingSir. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import "MagicalRecord.h"
#import "Utils.h"
#import "BabyDataSource.h"
#import "MJExtension.h"


#ifndef HelloHaHa_MacroDefinition_h
#define HelloHaHa_MacroDefinition_h
#endif


#define APPDELEGATE [(AppDelegate*)[UIApplication sharedApplication]  delegate]

//-------------------获取设备大小-------------------------
//NavBar高度
#define NavigationBar_HEIGHT 64
//StatusBar 高度
#define StatusBar_height [[UIApplication sharedApplication] statusBarFrame].size.height
//顶部高度
#define TopBar_height (NavigationBar_HEIGHT + StatusBar_height)
//TabBar
#define TabBar_height 49
//获取屏幕 宽度、高度
#define SCREEN_WIDTH ([UIScreen mainScreen].bounds.size.width)
#define SCREEN_HEIGHT ([UIScreen mainScreen].bounds.size.height)
#define SCREEN_SCALE ([UIScreen mainScreen].scale)
#define SCREEN_ORIGIN_H (SCREEN_HEIGHT * SCREEN_SCALE)
#define APP_WIDTH ([[UIScreen mainScreen]applicationFrame].size.width)
#define APP_HEIGHT ([[UIScreen mainScreen]applicationFrame].size.height)
#define SCREEN_FACTORY  SCREEN_WIDTH/320.0f

//-------------------获取设备大小-------------------------


//-------------------打印日志-------------------------
//DEBUG  模式下打印日志,当前行
#ifdef DEBUG
#   define DLog(fmt, ...) NSLog((@"<INFO>%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#   define DLogV(fmt, ...) NSLog((@"<VERBOSE>%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#   define DLogW(fmt, ...) NSLog((@"<WARNING>%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#   define DLogE(fmt, ...) NSLog((@"<ERROR>%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#   define DLog(...)
#   define DLogV(...)
#   define DLogW(...)
#   define DLogE(...)
#endif


////重写NSLog,Debug模式下打印日志和当前行数
//#if DEBUG
//#define NSLog(FORMAT, ...) fprintf(stderr,"\nfunction:%s line:%d content:%s\n", __FUNCTION__, __LINE__, [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);
//#else
//#define NSLog(FORMAT, ...) nil
//#endif

//DEBUG  模式下打印日志,当前行 并弹出一个警告
#ifdef DEBUG
#   define ULog(fmt, ...)  { UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"%s\n [Line %d] ", __PRETTY_FUNCTION__, __LINE__] message:[NSString stringWithFormat:fmt, ##__VA_ARGS__]  delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil]; [alert show]; }
#else
#   define ULog(...)
#endif


#define ITTDEBUG
#define ITTLOGLEVEL_INFO     10
#define ITTLOGLEVEL_WARNING  3
#define ITTLOGLEVEL_ERROR    1

#ifndef ITTMAXLOGLEVEL

#ifdef DEBUG
#define ITTMAXLOGLEVEL ITTLOGLEVEL_INFO
#else
#define ITTMAXLOGLEVEL ITTLOGLEVEL_ERROR
#endif

#endif

// The general purpose logger. This ignores logging levels.
#ifdef ITTDEBUG
#define ITTDPRINT(xx, ...)  NSLog(@"%s(%d): " xx, __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#else
#define ITTDPRINT(xx, ...)  ((void)0)
#endif

// Prints the current method's name.
#define ITTDPRINTMETHODNAME() ITTDPRINT(@"%s", __PRETTY_FUNCTION__)

// Log-level based logging macros.
#if ITTLOGLEVEL_ERROR <= ITTMAXLOGLEVEL
#define ITTDERROR(xx, ...)  ITTDPRINT(xx, ##__VA_ARGS__)
#else
#define ITTDERROR(xx, ...)  ((void)0)
#endif

#if ITTLOGLEVEL_WARNING <= ITTMAXLOGLEVEL
#define ITTDWARNING(xx, ...)  ITTDPRINT(xx, ##__VA_ARGS__)
#else
#define ITTDWARNING(xx, ...)  ((void)0)
#endif

#if ITTLOGLEVEL_INFO <= ITTMAXLOGLEVEL
#define ITTDINFO(xx, ...)  ITTDPRINT(xx, ##__VA_ARGS__)
#else
#define ITTDINFO(xx, ...)  ((void)0)
#endif

#ifdef ITTDEBUG
#define ITTDCONDITIONLOG(condition, xx, ...) { if ((condition)) { \
ITTDPRINT(xx, ##__VA_ARGS__); \
} \
} ((void)0)
#else
#define ITTDCONDITIONLOG(condition, xx, ...) ((void)0)
#endif

#define ITTAssert(condition, ...)                                       \
do {                                                                      \
if (!(condition)) {                                                     \
[[NSAssertionHandler currentHandler]                                  \
handleFailureInFunction:[NSString stringWithUTF8String:__PRETTY_FUNCTION__] \
file:[NSString stringWithUTF8String:__FILE__]  \
lineNumber:__LINE__                                  \
description:__VA_ARGS__];                             \
}                                                                       \
} while(0)

//---------------------打印日志--------------------------


//----------------------系统----------------------------

//获取系统版本
#define IOS_VERSION [[[UIDevice currentDevice] systemVersion] floatValue]
#define CurrentSystemVersion [[UIDevice currentDevice] systemVersion]

//获取当前语言
#define CurrentLanguage ([[NSLocale preferredLanguages] objectAtIndex:0])

//判断是否 Retina屏、设备是否%fhone 5、是否是iPad
#define isRetina ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 960), [[UIScreen mainScreen] currentMode].size) : NO)
#define iPhone5 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) : NO)
#define isPad (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)


//判断是真机还是模拟器
#if TARGET_OS_IPHONE
//iPhone Device
#endif

#if TARGET_IPHONE_SIMULATOR
//iPhone Simulator
#endif

//检查系统版本
#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)


//----------------------系统----------------------------


//----------------------内存----------------------------

//使用ARC和不使用ARC
#if __has_feature(objc_arc)
//compiling with ARC
#else
// compiling without ARC
#endif

#pragma mark - common functions
#define RELEASE_SAFELY(__POINTER) { [__POINTER release]; __POINTER = nil; }

//释放一个对象
#define SAFE_DELETE(P) if(P) { [P release], P = nil; }

#define SAFE_RELEASE(x) [x release];x=nil



//----------------------内存----------------------------

//----------------------字体----------------------------

#define kFontSizeSmall [UIFont fontWithName:@"HelveticaNeue-Light" size:12.0f]
#define kFontSizeNormal [UIFont fontWithName:@"HelveticaNeue-Light" size:14.0f]
#define kFontSizeBig [UIFont fontWithName:@"HelveticaNeue-Light" size:16.0f]
#define kFontSize(s) [UIFont fontWithName:@"HelveticaNeue-Light" size:s]
#define kCellBorder 10
#define kCellBorderSmall 6

//----------------------字体----------------------------
//自定义颜色

#define BABYCOLOR_base_color 0xE62F17
#define BABYCOLOR_base_color_pre 0xB41E0A
#define BABYCOLOR_base_color_cur 0x8D1000
#define BABYCOLOR_base_color_trans 0xF7E62F17
#define BABYCOLOR_base_background_color 0xf0f0f0
#define BABYCOLOR_base_color_btn_pressed 0xfd5555
#define BABYCOLOR_gray 0xd8d9da
#define BABYCOLOR_light_gray 0x7A7E83
#define BABYCOLOR_background 0xf3f1ef
#define BABYCOLOR_comment_text 0xa4a4a4
#define BABYCOLOR_main_text 0x3d3030
#define BABYCOLOR_main_text_gray 0x333333
#define BABYCOLOR_trans_color 0x00000000
#define BABYCOLOR_bg_publish 0x2B2D42
#define BABYCOLOR_background_gray 0x8D99AE
#define BABYCOLOR_camera_progress_split 0xffcc42
#define BABYCOLOR_camera_progress_three 0x12a899
#define BABYCOLOR_camera_progress_overflow 0x1b5d89

#define BABYCOLOR_record_text_normal 0x818587
#define BABYCOLOR_record_text_pressed 0x4A5158

//----------------------图片----------------------------

//-----------
#define APPNAME @"com.mengbaopai19890303"
//HOST
#define HOST @"http://www.mengbaopai.com"
//基础URL
#define BASEURL @"http://www.mengbaopai.com/api/"
//检查更新URL
#define SERVER_URL @"http://www.mengbaopai.com/api/version.xml"

#define APIURL @"http://www.mengbaopai.com/api/index.php/"

// 热门pins
#define PINS_HOTMULTI @"baby/getHotMulti"

//关注pins
#define PINS_INDEX  @"baby/getAllPins"
// 热门pins
#define PINS_HOT @"baby/getHotPins"
//pin
#define PINS_COMMENTS @"baby/getPinComments"
/**
 * pin详情
 */
#define PIN_INFO @"baby/getPinInfo"
#define SUBJECT_INFO @"baby/getSubjectInfo"
//user_boards
#define USER_BOARDS @"baby/getUserBoards"
// user_board_last_publish
#define USER_BOARD_LAST_PUBLISH @"baby/getUserBoardLastPublish"
//user_friends
#define USER_FRIENDS @"baby/getUserFriends"
#define USER_INFOS @"baby/getUserInfos"
//user_info
#define USER_INFOMATION @"baby/getUserInfo"
//user_info pins
#define USER_INFOMATION_PINS @"baby/getUserPins"
//pin_tags
#define PINS_TAG_INFO @"baby/getTagInfo"
#define PINS_TAG @"baby/getTagPins"
#define PINS_BOARD @"baby/getBoardPins"
//pin_discovery
#define PINS_DISCOVERY @"baby/getDiscovery"
#define USER_MESSAGE @"baby/getMessage"
#define USER_MESSAGE_SET @"dopost/setFeedView"
//登录
#define LOGIN_SELF @"dopost/login"


#define PIN_LIKE @"dopost/pinLike"
#define PIN_PLAY @"dopost/pinPlay"
#define PIN_PRIVATE @"dopost/pinPrivate"
#define PIN_COMMENTADD @"dopost/commentAdd"
#define PIN_COMMENTDEL @"dopost/commentDel"

#define USER_FOLLOW @"dopost/userFollow"
#define BOARD_ADD @"dopost/boardAdd"
#define BOARD_DEL @"dopost/boardDel"
#define PIN_ADD @"dopost/pinAdd"
#define PIN_DEL @"dopost/pinDel"
#define REPORT @"dopost/report"
#define FEEDBACK @"dopost/addFeedBack"
/**
 * 三方账号登录
 */
#define LOGIN_SYNC @"dopost/getSyncLogin"
/**
 * 手机号登录
 */
#define LOGIN_PHONE @"dopost/loginMobile"
/**
 * 手机号发送验证码
 */
#define LOGIN_MOBILE_VERITY @"dopost/sendMobileVerify"

/**
 * 手机注册
 */
#define REGISTER_MOBILE @"dopost/registerMobile"

/**
 * 手机重置密码
 */
#define LOGIN_FORGET_MOBILE @"dopost/forgetMobile"
/**
 * 绑定手机
 */
#define BIND_MOBILE @"dopost/bindMobile"
#define BIND_SYNC_TX @"bind_mobile"
#define BIND_UNSYNC_TX @"reset_mobile"

/**
 * 账号绑定
 */
#define BIND_SYNC @"dopost/setSyncBind"

/**
 * 解除账号绑定
 */
#define BIND_SYNC_DEL @"dopost/setSyncBindDel"

/**
 *  修改个人资料
 *
 */
#define USER_EDIT @"dopost/setUserInfo"

/**
 * 搜索
 */
#define SEARCH_WORD @"baby/getSearchWord"
#define SEARCH_ALL @"baby/getSearchAll"
#define SEARCH_USER @"baby/getSearchUser"
#define SEARCH_PIN @"baby/getSearchPin"

/**
 * video theme
 */
#define VIDEO_THEME @"baby/getVideoThemes"



#define UPLOADCR @"http://www.mengbaopai.com/api/upload.php"


#define REFRESH @"refresh"
#define INDEX @"index"
#define USRIIYA @"useriiya"
#define MESSAGE @"message"
#define REPLY @"reply"
#define FANS @"fans"
#define FOLLOWED @"followed"
#define CHATTINGMAIN @"chattingmain"
#define COMMENT @"comment"

#define MESSAGE_MAIN 0
#define MESSAGE_MESSSAGE 1
#define MESSAGE_TAGMAIN 2
#define MESSAGE_PINDETAIL 3
#define MESSAGE_SUBJECTDETAIL 4

/**
 * NSUserDefauts
 */
#define DEFAULT_USER @"userInfo"
#define DEFAULT_HOT @"index_hot"
#define DEFAULT_FRIENDS @"index_friends"
#define DEFAULT_SQUARE @"index_square"

#define DEFAULT_SETTING_AUTOPLAY @"setting_auto_play"
#define DEFAULT_SETTING_SAVE_MP4 @"setting_save_mp4"
/**
 *  是否需要评分
 */
#define DEFAULT_SETTING_RATE @"setting_need_rate"

/**
 *  Notifications
 */
#define NOTIFICATION_USER @"notification_user"
#define NOTIFICATION_LOGIN @"notification_login"
#define NOTIFICATION_PIN_UPLOAD @"notification_pin_upload"
#define NOTIFICATION_TAB_CHANGE @"notification_tab_change"
#define NOTIFICATION_PUSH_MESSAGE @"notification_push_message"
/**
 *  是否需要跳转到pin
 */
#define NOTIFICATION_SCHEME_PIN @"notification_scheme_to_pin"
/**
 *  是否需要跳转到user
 */
#define NOTIFICATION_SCHEME_USER @"notification_scheme_to_user"
/**
 *  是否需要跳转到tagn
 */
#define NOTIFICATION_SCHEME_TAG @"notification_scheme_to_tag"
/**
 *  是否需要跳转到subject
 */
#define NOTIFICATION_SCHEME_SUBJECT @"notification_scheme_to_subject"
//file
#define FILE_FORMAT_IMAGE @"jpg"
#define FILE_FORMAT_MP3 @"mp3"
#define FILE_FORMAT_VIDEO @"mp4"
#define IMAGE_BUCKET_NAME @"babypai"
#define FILE_BUCKET_NAME @"babypai-video"
#define FILE_KEY @"lYB0ZxdluVIoTqcgxdyyjM7DMOc="
#define FILE_IMAGE_KEY @"qNwsBxXxNBAaNh/QP5SQertO4GM="

//AMap
#define AMAPAPIKEY @"093f1e6b4e37a3fcda20d38cffeb3360"

/**
 * 用户信息
 */
#define ACCOUNTS @"accounts"
#define USER_LOGIN_TYPE @"login_type"

#define USER_LOGIN_SELF @"login_self"
#define USER_INFO @"userInfo"

/**
 * pins 信息
 */
#define PINS_INFO @"pins_info"
#define PINS_HOME @"pins_home"

//第三方登录
#define QQ_APPID @"101037302"
#define QQ_LOGIN @"qq_login"
#define QQ_OPENID @"qq_openid"
#define QQ_TOKEN @"qq_token"
#define QQ_EXPIRESTIME @"qq_expirsetime"

#define WB_APPID @"3667854602"
#define WB_LOGIN @"wb_login"
#define WB_OPENID @"wb_openid"
#define WB_TOKEN @"wb_token"
#define WB_EXPIRESTIME @"wb_expirsetime"


//-------

//读取本地图片
#define LOADIMAGE(file,ext) [UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:file ofType:ext]]

//定义UIImage对象
#define IMAGE(A) [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:A ofType:nil]]

//定义UIImage对象
#define ImageNamed(_pointer) [UIImage imageNamed:_pointer]

//建议使用前两种宏定义,性能高于后者
//----------------------图片----------------------------



//----------------------颜色类---------------------------
// rgb颜色转换（16进制->10进制）
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

// rgb颜色转换（16进制->10进制）
#define UIColorFromRGBA(rgbValue, alphaValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:alphaValue]

//带有RGBA的颜色设置
#define COLOR(R, G, B, A) [UIColor colorWithRed:R/255.0 green:G/255.0 blue:B/255.0 alpha:A]

// 获取RGB颜色
#define RGBA(r,g,b,a) [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:a]
#define RGB(r,g,b) RGBA(r,g,b,1.0f)

//背景色
#define BACKGROUND_COLOR [UIColor colorWithRed:243.0/255.0 green:241.0/255.0 blue:239.0/255.0 alpha:1.0]

//清除背景色
#define CLEARCOLOR [UIColor clearColor]

#pragma mark - color functions
#define RGBCOLOR(r,g,b) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:1]
#define RGBACOLOR(r,g,b,a) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:(a)]


// 文字提示
#define NOMOREDATA @"没有更多了呢 ^_^"
#define NODATATIPS @"宝宝什么都没找到~"

// 图片大小
#define IMAGE_SQUARE @"_sq75"
#define IMAGE_NOR @"_fw236"
#define IMAGE_BIG @"_fw554"

// 定义分享
#define SHARE_WEIXIN 0
#define SHARE_PYQ 1
#define SHARE_QQ 2
#define SHARE_QZONE 3
#define SHARE_SINA 4
#define SHARE_LINK 5

#define SHARE_REPORT 6
#define SHARE_DELETE 7

// 定义登录
#define LOGIN_SINA 10
#define LOGIN_QQ 11
#define LOGIN_MOBILE 12

/**
 *  数据库相关字段等
 */

#define BABYPAIDB "babypai.db"
#define UPLOAD_TABLE "upload_info"
#define _ID "id"

#define UPLOAD_IMAGE_ORIGINAL "file_image_original"
#define UPLOAD_IMAGE_PATH "file_image_path"
#define UPLOAD_VIDEO_PATH "file_video_path"
#define UPLOAD_VIDEO_OBJ "file_video_obj"
#define UPLOAD_FORMAT "file_format"
#define UPLOAD_TIME "file_time"
#define UPLOAD_VIDEO_TIME "file_video_time"
#define UPLOAD_ISUPLOAD "file_isupload"
#define UPLOAD_USER_ID "user_id"
#define UPLOAD_BOARD_ID "board_id"
#define UPLOAD_BOARD_NAME "board_name"
#define UPLOAD_RAW_TEXT "raw_text"
#define UPLOAD_AT_UID "at_uid"
#define UPLOAD_TAGS "tags"
#define UPLOAD_TAG_ID "tag_id"
#define UPLOAD_IS_PRIVATE "is_private"
#define UPLOAD_SHARE_QQ "share_qq"
#define UPLOAD_SHARE_WB "share_wb"
#define UPLOAD_SHARE_WX "share_wx"
#define UPLOAD_IS_DRAFT "is_draft"
#define UPLOAD_IS_PUBLISH "is_publish"
#define UPLOAD_MediaObject "media_object"
#define UPLOAD_province_id "province_id"
#define UPLOAD_city_id "city_id"
#define UPLOAD_area_id "area_id"
#define UPLOAD_province "province"
#define UPLOAD_city "city"
#define UPLOAD_area "area"
#define UPLOAD_addr "addr"
#define UPLOAD_longitude "longitude"
#define UPLOAD_latitude "latitude"
#define UPLOAD_keywords "keywords"



#define THEME_TABLE "theme_info"

/**
 * 主题图标
 */
#define THEME_ICON "themeIcon"
/**
 * 主题名称
 */
#define THEME_DISPLAYNAME "themeDisplayName"
/**
 * 主题文件夹名称
 */
#define THEME_NAME "themeName"
/**
 * 主题下载地址
 */
#define THEME_DOWNLOADURL "themeDownloadUrl"
/**
 * 主题本地地址
 */
#define THEME_URL "themeUrl"
/**
 * 主题更新时间
 */
#define THEME_UPDATEAT "themeUpdateAt"
/**
 * 唯一编号
 */
#define THEME_ID "themeId"

/**
 * 下载状态
 */
#define THEME_STATUS "status"
/**
 * 下载进度
 */
#define THEME_PERCENT "percent"


//----------------------颜色类--------------------------



//----------------------其他----------------------------

//方正黑体简体字体定义
#define FONT(F) [UIFont fontWithName:@"FZHTJW--GB1-0" size:F]


//设置View的tag属性
#define VIEWWITHTAG(_OBJECT, _TAG)    [_OBJECT viewWithTag : _TAG]
//程序的本地化,引用国际化的文件
#define MyLocal(x, ...) NSLocalizedString(x, nil)

//G－C－D
#define BACK(block) dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), block)
#define MAIN(block) dispatch_async(dispatch_get_main_queue(),block)

//NSUserDefaults 实例化
#define USER_DEFAULT [NSUserDefaults standardUserDefaults]


//由角度获取弧度 有弧度获取角度
#define degreesToRadian(x) (M_PI * (x) / 180.0)
#define radianToDegrees(radian) (radian*180.0)/(M_PI)

//----------------------其他----------------------------


// Generated by Apple Swift version 3.0.2 (swiftlang-800.0.63 clang-800.0.42.1)
#pragma clang diagnostic push

#if defined(__has_include) && __has_include(<swift/objc-prologue.h>)
# include <swift/objc-prologue.h>
#endif

#pragma clang diagnostic ignored "-Wauto-import"
#include <objc/NSObject.h>
#include <stdint.h>
#include <stddef.h>
#include <stdbool.h>

#if !defined(SWIFT_TYPEDEFS)
# define SWIFT_TYPEDEFS 1
# if defined(__has_include) && __has_include(<uchar.h>)
#  include <uchar.h>
# elif !defined(__cplusplus) || __cplusplus < 201103L
typedef uint_least16_t char16_t;
typedef uint_least32_t char32_t;
# endif
typedef float swift_float2  __attribute__((__ext_vector_type__(2)));
typedef float swift_float3  __attribute__((__ext_vector_type__(3)));
typedef float swift_float4  __attribute__((__ext_vector_type__(4)));
typedef double swift_double2  __attribute__((__ext_vector_type__(2)));
typedef double swift_double3  __attribute__((__ext_vector_type__(3)));
typedef double swift_double4  __attribute__((__ext_vector_type__(4)));
typedef int swift_int2  __attribute__((__ext_vector_type__(2)));
typedef int swift_int3  __attribute__((__ext_vector_type__(3)));
typedef int swift_int4  __attribute__((__ext_vector_type__(4)));
typedef unsigned int swift_uint2  __attribute__((__ext_vector_type__(2)));
typedef unsigned int swift_uint3  __attribute__((__ext_vector_type__(3)));
typedef unsigned int swift_uint4  __attribute__((__ext_vector_type__(4)));
#endif

#if !defined(SWIFT_PASTE)
# define SWIFT_PASTE_HELPER(x, y) x##y
# define SWIFT_PASTE(x, y) SWIFT_PASTE_HELPER(x, y)
#endif
#if !defined(SWIFT_METATYPE)
# define SWIFT_METATYPE(X) Class
#endif
#if !defined(SWIFT_CLASS_PROPERTY)
# if __has_feature(objc_class_property)
#  define SWIFT_CLASS_PROPERTY(...) __VA_ARGS__
# else
#  define SWIFT_CLASS_PROPERTY(...)
# endif
#endif

#if defined(__has_attribute) && __has_attribute(objc_runtime_name)
# define SWIFT_RUNTIME_NAME(X) __attribute__((objc_runtime_name(X)))
#else
# define SWIFT_RUNTIME_NAME(X)
#endif
#if defined(__has_attribute) && __has_attribute(swift_name)
# define SWIFT_COMPILE_NAME(X) __attribute__((swift_name(X)))
#else
# define SWIFT_COMPILE_NAME(X)
#endif
#if defined(__has_attribute) && __has_attribute(objc_method_family)
# define SWIFT_METHOD_FAMILY(X) __attribute__((objc_method_family(X)))
#else
# define SWIFT_METHOD_FAMILY(X)
#endif
#if defined(__has_attribute) && __has_attribute(noescape)
# define SWIFT_NOESCAPE __attribute__((noescape))
#else
# define SWIFT_NOESCAPE
#endif
#if !defined(SWIFT_CLASS_EXTRA)
# define SWIFT_CLASS_EXTRA
#endif
#if !defined(SWIFT_PROTOCOL_EXTRA)
# define SWIFT_PROTOCOL_EXTRA
#endif
#if !defined(SWIFT_ENUM_EXTRA)
# define SWIFT_ENUM_EXTRA
#endif
#if !defined(SWIFT_CLASS)
# if defined(__has_attribute) && __has_attribute(objc_subclassing_restricted)
#  define SWIFT_CLASS(SWIFT_NAME) SWIFT_RUNTIME_NAME(SWIFT_NAME) __attribute__((objc_subclassing_restricted)) SWIFT_CLASS_EXTRA
#  define SWIFT_CLASS_NAMED(SWIFT_NAME) __attribute__((objc_subclassing_restricted)) SWIFT_COMPILE_NAME(SWIFT_NAME) SWIFT_CLASS_EXTRA
# else
#  define SWIFT_CLASS(SWIFT_NAME) SWIFT_RUNTIME_NAME(SWIFT_NAME) SWIFT_CLASS_EXTRA
#  define SWIFT_CLASS_NAMED(SWIFT_NAME) SWIFT_COMPILE_NAME(SWIFT_NAME) SWIFT_CLASS_EXTRA
# endif
#endif

#if !defined(SWIFT_PROTOCOL)
# define SWIFT_PROTOCOL(SWIFT_NAME) SWIFT_RUNTIME_NAME(SWIFT_NAME) SWIFT_PROTOCOL_EXTRA
# define SWIFT_PROTOCOL_NAMED(SWIFT_NAME) SWIFT_COMPILE_NAME(SWIFT_NAME) SWIFT_PROTOCOL_EXTRA
#endif

#if !defined(SWIFT_EXTENSION)
# define SWIFT_EXTENSION(M) SWIFT_PASTE(M##_Swift_, __LINE__)
#endif

#if !defined(OBJC_DESIGNATED_INITIALIZER)
# if defined(__has_attribute) && __has_attribute(objc_designated_initializer)
#  define OBJC_DESIGNATED_INITIALIZER __attribute__((objc_designated_initializer))
# else
#  define OBJC_DESIGNATED_INITIALIZER
# endif
#endif
#if !defined(SWIFT_ENUM)
# define SWIFT_ENUM(_type, _name) enum _name : _type _name; enum SWIFT_ENUM_EXTRA _name : _type
# if defined(__has_feature) && __has_feature(generalized_swift_name)
#  define SWIFT_ENUM_NAMED(_type, _name, SWIFT_NAME) enum _name : _type _name SWIFT_COMPILE_NAME(SWIFT_NAME); enum SWIFT_COMPILE_NAME(SWIFT_NAME) SWIFT_ENUM_EXTRA _name : _type
# else
#  define SWIFT_ENUM_NAMED(_type, _name, SWIFT_NAME) SWIFT_ENUM(_type, _name)
# endif
#endif
#if !defined(SWIFT_UNAVAILABLE)
# define SWIFT_UNAVAILABLE __attribute__((unavailable))
#endif
#if defined(__has_feature) && __has_feature(modules)


#pragma clang diagnostic pop


//----------------------视图相关----------------------------
//设置需要粘贴的文字或图片
#define PasteString(string)   [[UIPasteboard generalPasteboard] setString:string];
#define PasteImage(image)     [[UIPasteboard generalPasteboard] setImage:image];

//得到视图的left top的X,Y坐标点
#define VIEW_TX(view) (view.frame.origin.x)
#define VIEW_TY(view) (view.frame.origin.y)

//得到视图的right bottom的X,Y坐标点
#define VIEW_BX(view) (view.frame.origin.x + view.frame.size.width)
#define VIEW_BY(view) (view.frame.origin.y + view.frame.size.height)

//得到视图的尺寸:宽度、高度
#define VIEW_W(view)  (view.frame.size.width)
#define VIEW_H(view)  (view.frame.size.height)
//得到frame的X,Y坐标点
#define FRAME_TX(frame)  (frame.origin.x)
#define FRAME_TY(frame)  (frame.origin.y)
//得到frame的宽度、高度
#define FRAME_W(frame)  (frame.size.width)
#define FRAME_H(frame)  (frame.size.height)
//----------------------视图相关----------------------------


//单例化一个类
#define SYNTHESIZE_SINGLETON_FOR_CLASS(classname) \
\
static classname *shared##classname = nil; \
\
+ (classname *)shared##classname \
{ \
@synchronized(self) \
{ \
if (shared##classname == nil) \
{ \
shared##classname = [[self alloc] init]; \
} \
} \
\
return shared##classname; \
} \
\
+ (id)allocWithZone:(NSZone *)zone \
{ \
@synchronized(self) \
{ \
if (shared##classname == nil) \
{ \
shared##classname = [super allocWithZone:zone]; \
return shared##classname; \
} \
} \
\
return nil; \
} \
\
- (id)copyWithZone:(NSZone *)zone \
{ \
return self; \
}



#endif
