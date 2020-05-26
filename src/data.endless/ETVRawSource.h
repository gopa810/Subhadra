//
//  ETVRawSource.h
//  VedabaseB
//
//  Created by Peter Kollath on 07/11/14.
//
//

#import <Foundation/Foundation.h>
#import "EndlessTextViewDataSource.h"
@class VBFolioStorage;

@interface ETVRawSource : NSObject <EndlessTextViewDataSource>

@property VBFolioStorage * folio;
@property NSMutableArray * records;
@property NSMutableDictionary * objects;


-(void)addFlatText:(NSString *)str;
-(void)addFlatText:(NSString *)str withLevel:(NSString *)strLevel;
-(void)clear;

@end
