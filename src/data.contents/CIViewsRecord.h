//
//  ContentItemViewRecord.h
//  VedabaseB
//
//  Created by Peter Kollath on 25/10/14.
//
//

#import <Foundation/Foundation.h>
#import "CIBase.h"
#import "VBViewRecord.h"
#import "VBFolio.h"

@interface CIViewsRecord : CIBase

@property NSInteger childrenFound;
@property VBViewRecord * views;
@property VBFolio * folio;

+(void)getChildren:(NSInteger)viewId array:(NSMutableArray *)arr folio:(VBFolio *)folio;


@end
