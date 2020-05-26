//
//  CIBookmarks.h
//  VedabaseB
//
//  Created by Peter Kollath on 9/1/13.
//
//

#import "CIBase.h"
#import "VBBookmark.h"
#import "VBFolio.h"

@interface CIBookmarks : CIBase

@property (nonatomic,retain) VBBookmark * bookmark;
@property (nonatomic, retain) VBFolio * folio;

+(void)getChildren:(NSInteger)bid folio:(VBFolio *)folio array:(NSMutableArray *)array;

@end
