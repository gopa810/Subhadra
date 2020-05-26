//
//  BottomBarItem.h
//  VedabaseB
//
//  Created by Peter Kollath on 23/08/14.
//
//

#import <Foundation/Foundation.h>

@interface BottomBarItem : NSObject

@property UIImage * icon;
@property NSString * text;
@property NSString * tag;
@property CGRect itemRect;
@property int itemIndex;
@end
