//
//  BabyUploadEntity+CoreDataProperties.h
//  
//
//  Created by ning on 16/4/27.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "BabyUploadEntity.h"

NS_ASSUME_NONNULL_BEGIN

@interface BabyUploadEntity (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *file_image_original;
@property (nullable, nonatomic, retain) NSString *file_image_path;
@property (nullable, nonatomic, retain) NSString *file_video_path;
@property (nullable, nonatomic, retain) NSString *file_video_obj;
@property (nullable, nonatomic, retain) NSString *file_format;
@property (nullable, nonatomic, retain) NSNumber *file_video_time;
@property (nullable, nonatomic, retain) NSNumber *file_progress;
@property (nullable, nonatomic, retain) NSNumber *file_isupload;
@property (nullable, nonatomic, retain) NSNumber *user_id;
@property (nullable, nonatomic, retain) NSNumber *board_id;
@property (nullable, nonatomic, retain) NSString *board_name;
@property (nullable, nonatomic, retain) NSString *raw_text;
@property (nullable, nonatomic, retain) NSString *at_uid;
@property (nullable, nonatomic, retain) NSString *tags;
@property (nullable, nonatomic, retain) NSString *tag_id;
@property (nullable, nonatomic, retain) NSString *media_object;
@property (nullable, nonatomic, retain) NSNumber *is_private;
@property (nullable, nonatomic, retain) NSNumber *share_qq;
@property (nullable, nonatomic, retain) NSNumber *share_wb;
@property (nullable, nonatomic, retain) NSNumber *share_wx;
@property (nullable, nonatomic, retain) NSNumber *is_draft;
@property (nullable, nonatomic, retain) NSNumber *is_publish;
@property (nullable, nonatomic, retain) NSNumber *province_id;
@property (nullable, nonatomic, retain) NSNumber *city_id;
@property (nullable, nonatomic, retain) NSNumber *area_id;
@property (nullable, nonatomic, retain) NSString *province;
@property (nullable, nonatomic, retain) NSString *city;
@property (nullable, nonatomic, retain) NSString *area;
@property (nullable, nonatomic, retain) NSString *addr;
@property (nullable, nonatomic, retain) NSNumber *longitude;
@property (nullable, nonatomic, retain) NSNumber *latitude;
@property (nullable, nonatomic, retain) NSString *keywords;
@property (nullable, nonatomic, retain) NSNumber *file_time;

@end

NS_ASSUME_NONNULL_END
