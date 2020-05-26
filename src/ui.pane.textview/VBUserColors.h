//
//  VBUserColors.h
//  VedabaseA
//
//  Created by Gopal on 4.6.2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface VBUserColors : NSObject {
}

+(void)saveUserDefaults;
+(void)loadUserDefaults;
+(NSString *)colorString:(NSString *)colorName;
+(void)setColor:(UIColor *)colorVal withName:(NSString *)name;
+(NSString *)colorToString:(UIColor *)color;
+(UIColor *)color:(NSString *)colorName;
+(UIColor *)stringToColor:(NSString *)str;

@end
