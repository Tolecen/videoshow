//
//  VideoThemeEntity+CoreDataProperties.h
//  
//
//  Created by ning on 16/4/27.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "VideoThemeEntity.h"

NS_ASSUME_NONNULL_BEGIN

@interface VideoThemeEntity (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *themeIcon;
@property (nullable, nonatomic, retain) NSString *themeDisplayName;
@property (nullable, nonatomic, retain) NSString *themeName;
@property (nullable, nonatomic, retain) NSString *themeDownloadUrl;
@property (nullable, nonatomic, retain) NSString *themeUpdateAt;
@property (nullable, nonatomic, retain) NSNumber *isLock;
@property (nullable, nonatomic, retain) NSNumber *isBuy;
@property (nullable, nonatomic, retain) NSNumber *themeId;
@property (nullable, nonatomic, retain) NSNumber *pic_type;
@property (nullable, nonatomic, retain) NSString *banner;
@property (nullable, nonatomic, retain) NSString *desc;
@property (nullable, nonatomic, retain) NSNumber *price;
@property (nullable, nonatomic, retain) NSString *previewVideoPath;
@property (nullable, nonatomic, retain) NSString *themeUrl;
@property (nullable, nonatomic, retain) NSString *category;
@property (nullable, nonatomic, retain) NSNumber *themeType;
@property (nullable, nonatomic, retain) NSNumber *lockType;
@property (nullable, nonatomic, retain) NSNumber *isMv;
@property (nullable, nonatomic, retain) NSNumber *isMP4;
@property (nullable, nonatomic, retain) NSNumber *status;
@property (nullable, nonatomic, retain) NSNumber *percent;

@end

NS_ASSUME_NONNULL_END
