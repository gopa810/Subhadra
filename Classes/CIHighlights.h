//
//  CIHighlights.h
//  VedabaseB
//
//  Created by Peter Kollath on 9/1/13.
//
//

#import "CIBase.h"
#import "VBRecordNotes.h"
#import "VBFolio.h"

@interface CIHighlights : CIBase

@property (nonatomic,retain) VBRecordNotes * notes;
@property (nonatomic, retain) VBFolio * folio;

+(void)getChildren:(NSInteger)bid toArray:(NSMutableArray *)array folio:(VBFolio *)folio;


@end
