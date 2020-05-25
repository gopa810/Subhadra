//
//  FolioFileActive.m
//  VedabaseB
//
//  Created by Peter Kollath on 12/30/12.
//  Copyright (c) 2012 GPSL. All rights reserved.
//

#import "FolioFileActive.h"
#import "VBFolio.h"

@implementation FolioFileActive

@synthesize date, abstract, image;
@synthesize updatePossible;
@synthesize filePath;
@synthesize sortKey, collection, inclusionPath;

-(id)initWithFilePath:(NSString *)path
{
    self = [super init];
    if (self)
    {
        self.filePath = path;
        self.fileName = [path lastPathComponent];
        
        NSDictionary * dict = [VBFolio infoDictionaryFromFile:path];
        if (dict != nil)
        {
            self.collection = [dict objectForKey:@"Collection"];
            if (!self.collection)
                self.collection = @"Untitled";
            self.collectionName = [dict objectForKey:@"CollectionName"];
            if (self.collectionName == nil)
                self.collectionName = @"<Untitled>";
            self.title = [dict objectForKey:@"TT"];
            self.tbuild = [[dict objectForKey:@"TBUILD"] integerValue];
            self.date = [dict objectForKey:@"DATE"];
            self.abstract = [dict objectForKey:@"AS"];
            self.image = [dict objectForKey:@"Image"];
            self.sortKey = [dict objectForKey:@"SortKey"];
            self.inclusionPath = [dict objectForKey:@"InclusionPath"];
            
            id includes = [dict objectForKey:@"Includes"];
            if ([includes isKindOfClass:[NSString class]]) {
                [self.includeFiles addObject:includes];
            } else if ([includes isKindOfClass:[NSArray class]]) {
                [self.includeFiles addObjectsFromArray:(NSArray *)includes];
            }
        }

    }
    return self;
}


@end
