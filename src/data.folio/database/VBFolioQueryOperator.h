//
//  VBFolioQueryOperator.h
//  VedabaseB
//
//  Created by Peter Kollath on 9/15/13.
//
//

#import <Foundation/Foundation.h>

@interface VBFolioQueryOperator : NSObject
{
    BOOL _valid;
    BOOL _eof;
}

@property (assign) NSInteger hitCount;

-(uint32_t)currentRecord;
-(BOOL)gotoNextRecord;
-(void)validate;
-(BOOL)valid;
-(BOOL)endOfStream;
-(void)setEndOfStream:(BOOL)val;
-(BOOL)moveToRecord:(uint32_t)rec;
-(uint16_t)currentProximity;
-(BOOL)gotoNextProximity;
-(void)printAtLevel:(int)level toString:(NSMutableString *)target;
-(void)printSpaces:(int)level toString:(NSMutableString *)target;
-(void)gotoLastRecord;

@end
