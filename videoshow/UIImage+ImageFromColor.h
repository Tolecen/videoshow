
#import <UIKit/UIKit.h>

@interface UIImage (ImageFromColor)

+ (UIImage *) buildImageWithColor:(UIColor *)color;
+ (UIImage *) buildImageWithColor:(UIColor *)color forSize:(CGSize)size;

@end
