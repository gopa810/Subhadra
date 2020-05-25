//
//  FolioFileActive.h
//  VedabaseB
//
//  Created by Peter Kollath on 12/30/12.
//  Copyright (c) 2012 GPSL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FolioFileBase.h"

@interface FolioFileActive : FolioFileBase

@property (assign, readwrite) BOOL updatePossible;
@property (nonatomic, copy) NSString * filePath;
@property (nonatomic, retain) NSString * collection;
@property (nonatomic, retain) NSString * date;
@property (nonatomic, retain) NSString * abstract;
@property (nonatomic, retain) UIImage * image;
@property (nonatomic, retain) NSString * sortKey;
@property (nonatomic, retain) NSArray * inclusionPath;

-(id)initWithFilePath:(NSString *)path;

@end
