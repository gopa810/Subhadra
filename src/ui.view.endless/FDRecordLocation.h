//
//  FDRecordLocation.h
//  VedabaseB
//
//  Created by Peter Kollath on 02/08/14.
//
//

#import <Foundation/Foundation.h>


@class FDPartBase, FDParagraph;
@class FDRecordBase;

@interface FDRecordLocationBase : NSObject
@property int partNum;
@property int cellNum;
@property int recNum;
@end

@interface FDRecordLocation : FDRecordLocationBase

@property CGPoint hotSpot;
@property float x;
@property float y;
@property int areaType;
@property CGRect selectedRect;

// used for all areas
@property (weak) FDRecordBase * record;
@property FDPartBase * cell;
@property FDParagraph * para;
@property NSMutableArray * path;


+(int)AREA_UNDEFINED;
+(int)AREA_LEFT_SIDE;
+(int)AREA_RIGHT_SIDE;
+(int)AREA_PARA;

-(FDRecordLocation *)clone;
-(void)copyFrom:(FDRecordLocation *)loc;
-(void)resetHotSpots;

@end


@interface FDRecordLocationPair : NSObject 

@property FDRecordLocation * A;
@property FDRecordLocation * B;

-(void)resetHotSpots;

@end
