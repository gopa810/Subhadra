//
//  VBFolioRecordMapping.h
//  VedabaseB
//
//  Created by Peter Kollath on 20/11/14.
//
//

#import <Foundation/Foundation.h>

@interface VBFolioRecordMappingItem : NSObject


@property int recordFrom;
@property int recordTo;
@property int correction;

@end


@interface VBFolioRecordMapping : NSObject


@property NSMutableArray * map;

-(void)readFile:(NSString *)fileName;
-(int)correctionForRecord:(int)recId;


@end