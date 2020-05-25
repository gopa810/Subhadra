//
//  EndlessPosition.m
//  VedabaseB
//
//  Created by Peter Kollath on 17/01/15.
//
//

#import "EndlessPosition.h"

@implementation EndlessPosition

-(id)init
{
    self = [super init];
    if (self) {
        self.recordId = 0;
        self.offset = 0.0;
    }
    return self;
}


@end
