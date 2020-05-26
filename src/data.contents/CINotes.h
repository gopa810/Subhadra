//
//  CINotes.h
//  VedabaseB
//
//  Created by Peter Kollath on 9/1/13.
//
//

#import "CIBase.h"
#import "VBRecordNotes.h"
#import "VBFolio.h"

@interface CINotes : CIBase

@property (nonatomic,retain) VBRecordNotes * notes;
@property (nonatomic, retain) VBFolio * folio;


+(void)getChildren:(NSInteger)bid folio:(VBFolio *)folio array:(NSMutableArray *)array;

@end
