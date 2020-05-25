//
//  FolioFileBase.h
//  VedabaseB
//
//  Created by Peter Kollath on 12/31/12.
//  Copyright (c) 2012 GPSL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FolioFileDownloaded.h"
#import <StoreKit/StoreKit.h>

@interface FolioFileBase : NSObject

@property (nonatomic, copy)   NSString * title;
@property (nonatomic, copy)   NSString * fileName;
@property (assign, readwrite) NSInteger  fileSize; 
@property (nonatomic, retain) NSString * collectionName;
@property (nonatomic, retain) FolioFileDownloaded * download;
@property (nonatomic, retain) NSMutableArray * includeFiles;
@property (nonatomic, retain) NSString * key;
@property (assign) BOOL purchased;
@property (assign) NSInteger tbuild;
@property (assign) BOOL supportParts;
@property (assign) NSInteger lastUpdate;

@property (nonatomic, copy) NSString * price;
@property (assign, readwrite) BOOL isMessage;
@property (nonatomic, retain) SKProduct * product;
@end
