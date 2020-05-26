//
//  ETVRecords.h
//  VedabaseB
//
//  Created by Peter Kollath on 04/11/14.
//
//

#import <Foundation/Foundation.h>
#import "EndlessTextViewDataSource.h"
@class VBFolio;

@interface ETVRecords : NSObject <EndlessTextViewDataSource>

@property VBFolio * folio;

// array of NSNumber objects
@property NSArray * records;
@property NSMutableArray * rawRecords;
@property NSString * title;

-(int)originalRecordAtIndex:(int)recid;

@end
