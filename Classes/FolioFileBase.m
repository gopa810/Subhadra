//
//  FolioFileBase.m
//  VedabaseB
//
//  Created by Peter Kollath on 12/31/12.
//  Copyright (c) 2012 GPSL. All rights reserved.
//

#import "FolioFileBase.h"

@implementation FolioFileBase

@synthesize title, fileName, collectionName, download, fileSize;
@synthesize includeFiles, key, purchased, tbuild, lastUpdate;

@synthesize price;
@synthesize isMessage;
@synthesize product;
@synthesize supportParts;

-(id)init
{
    self = [super init];
    if (self) {
        self.includeFiles = [[NSMutableArray alloc] init];
        self.supportParts = NO;
    }
    return self;
}

@end
