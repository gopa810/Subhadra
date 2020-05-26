//
//  FlatFolioValidator.h
//  VedabaseB
//
//  Created by Peter Kollath on 3/10/13.
//
//

#import <Foundation/Foundation.h>

@protocol FlatFolioValidator <NSObject>

-(BOOL)jumpIsValid:(NSString *)jumpText;

@end
