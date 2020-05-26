//
//  ContentItemPlaylist.h
//  VedabaseB
//
//  Created by Peter Kollath on 25/10/14.
//
//

#import <Foundation/Foundation.h>
#import "CIBase.h"
#import "VBPlaylist.h"
#import "VBFolio.h"

@interface CIPlaylist : CIBase
{
    int _child;
}

@property VBPlaylist * playlist;
@property VBFolio * folio;

+(void)getChildren:(NSInteger)playId array:(NSMutableArray *)arr folio:(VBFolio *)folio;

@end
