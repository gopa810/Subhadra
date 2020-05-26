//
//  RecordBulk.h
//  VedabaseB
//
//  Created by Peter Kollath on 01/08/14.
//
//

#import <Foundation/Foundation.h>


#define BULK_SIZE 16
#define MAX_BULK_AGE 16

@interface FDRecordBaseBulk : NSObject


@property int age;
@property int baseId;
@property int count;
@property int bulkPage;
@property NSMutableArray * records;


@end
