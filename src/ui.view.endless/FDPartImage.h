//
//  FDPartImage.h
//  VedabaseB
//
//  Created by Peter Kollath on 01/08/14.
//
//

#import <Foundation/Foundation.h>
#import "FDPartSized.h"

#define IMAGE_AUDIO 1

@interface FDPartImage : FDPartSized

@property (copy) NSString * imageName;
@property UIImage * bitmap;
@property int predefinedBitmap;
@property NSMutableDictionary * format;


@end
