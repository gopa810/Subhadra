//
//  VDTreeItem.h
//  VedabaseB
//
//  Created by Peter Kollath on 26/11/14.
//
//

#import <Foundation/Foundation.h>

@interface VDTreeItem : NSObject

@property NSString * title;
@property NSString * count;
@property id data;
@property CGPoint titlePos;
@property CGPoint countPos;
@property CGPoint startPoint;
@property CGPoint endPoint;
@property CGRect  itemRect;

@property NSMutableArray * children;

-(CGPoint)getEndpointWithFont:(NSDictionary *)font lastEndpoint:(CGRect *)currentRect;
-(void)draw:(CGContextRef)context styles:(NSDictionary *)styles;

@end
