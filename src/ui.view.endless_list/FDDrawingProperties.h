//
//  FDDrawingProperties.h
//  VedabaseB
//
//  Created by Peter Kollath on 16/01/15.
//
//

#import <Foundation/Foundation.h>
#import "VBSkinManager.h"
#import "FDTextHighlighter.h"
#import "FDRecordLocation.h"
#import "FDColor.h"

@interface FDDrawingProperties : NSObject

// configuration
@property CGFloat paddingLeft;
@property CGFloat paddingRight;
@property UIFont * recordNumberFont;
@property UIColor * recordNumberColor;
@property UIColor * recordMarkBackground;
@property UIFont * recordMarkFont;
@property UIColor * recordMarkColor;
@property UIImage * noteBitmap;
@property NSDictionary * recordMarkAttributes;
@property NSDictionary * recordNumberAttributes;

// runtime info
@property IBOutlet VBSkinManager * skinManager;
@property FDTextHighlighter * highlightPhrases;



@end
