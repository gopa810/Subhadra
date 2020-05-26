//
//  VBFolioDelegate.h
//  VedabaseB
//
//  Created by Peter Kollath on 03/08/14.
//
//

#import <Foundation/Foundation.h>

@class VBFolio;

@protocol VBFolioDelegate <NSObject>

-(void)recordDidLoad:(unsigned int)recordId folio:(VBFolio *)folio;

@end
