//
//  RecordBulk.m
//  VedabaseB
//
//  Created by Peter Kollath on 01/08/14.
//
//

#import "FDRecordBaseBulk.h"
#import "FolioTextRecord.h"
#import "FDRecordBase.h"

@implementation FDRecordBaseBulk


-(id)init
{
	self = [super init];
	if (self) {
		self.records = [[NSMutableArray alloc] init];
		for(int i = 0; i < BULK_SIZE; i++) {
			[self.records addObject:[[FDRecordBase alloc] init]];
		}
	}
	return self;
}

@end
