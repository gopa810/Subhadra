//
//  FDRecordLocation.m
//  VedabaseB
//
//  Created by Peter Kollath on 02/08/14.
//
//

#import "FDRecordLocation.h"


@implementation FDRecordLocationBase


@end


#pragma mark -
#pragma mark FDrecordLocationPair class

@implementation FDRecordLocationPair

-(void)resetHotSpots
{
    [self.A resetHotSpots];
    [self.B resetHotSpots];
}

@end


#pragma mark -
#pragma mark FDrecordLocation class

@implementation FDRecordLocation

-(id)init
{
    self = [super init];
    if (self) {
        self.path = [[NSMutableArray alloc] init];
    }
    return self;
}

+(int)AREA_UNDEFINED
{
    return 0;
}

+(int)AREA_LEFT_SIDE
{
    return 1;
}

+(int)AREA_PARA
{
    return 2;
}

+(int)AREA_RIGHT_SIDE
{
    return 3;
}


-(FDRecordLocation *)clone
{
    FDRecordLocation * loc = [[FDRecordLocation alloc] init];
    [loc copyFrom:self];
    return loc;
}

-(void)copyFrom:(FDRecordLocation *)loc
{
    _x = loc.x;
    _y = loc.y;
    _areaType = loc.areaType;
    _record = loc.record;
    self.recNum = loc.recNum;
    self.partNum = loc.partNum;
    self.cellNum = loc.cellNum;
    _cell = loc.cell;
    _para = loc.para;
    [self.path removeAllObjects];
    [self.path addObjectsFromArray:loc.path];
    
}

-(void)resetHotSpots
{
    self.hotSpot = CGPointMake(-1, -1);
}

@end
