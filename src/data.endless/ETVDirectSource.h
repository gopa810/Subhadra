//
//  ETVDirectSource.h
//  VedabaseB
//
//  Created by Peter Kollath on 14/08/14.
//
//

#import <Foundation/Foundation.h>
#import "EndlessTextViewDataSource.h"
#import "VBFolio.h"

@interface ETVDirectSource : NSObject <EndlessTextViewDataSource>

@property VBFolio * folio;
@property NSInteger maxRec;

@end
