//
//  FolioTextRecord.h
//  VedabaseB
//
//  Created by Peter Kollath on 01/08/14.
//
//

#import <Foundation/Foundation.h>

@interface FolioTextRecord : NSObject

@property NSString * plainText;
@property NSString * levelName;
@property unsigned int recordId;


-(NSString *)getNamedPopup;

@end
