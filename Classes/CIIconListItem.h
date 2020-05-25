//
//  CIIconListItem.h
//  VedabaseB
//
//  Created by Peter Kollath on 21/07/16.
//
//

#import <Foundation/Foundation.h>

@interface CIIconListItem : NSObject

@property NSString * name;
@property NSString * imageName;
@property UIImage * image;

@property NSString * actionText;

@property CGRect usedRect;
@property CGSize textSize;

@end
