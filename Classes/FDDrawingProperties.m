//
//  FDDrawingProperties.m
//  VedabaseB
//
//  Created by Peter Kollath on 16/01/15.
//
//

#import "FDDrawingProperties.h"
#import "FDColor.h"

@implementation FDDrawingProperties


-(id)init
{
    self = [super init];
    if (self) {
        
        self.recordMarkColor = [UIColor whiteColor];
        self.recordMarkBackground = [UIColor grayColor];
        self.recordNumberColor = [UIColor grayColor];
        self.recordNumberFont = [UIFont boldSystemFontOfSize:[UIFont systemFontSize]];
        self.recordMarkFont = [UIFont systemFontOfSize:[UIFont systemFontSize]];
        self.recordMarkAttributes = @{
                                      NSForegroundColorAttributeName: self.recordMarkColor,
                                      NSFontAttributeName: self.recordMarkFont
                                      };
        self.recordNumberAttributes = @{
                                        NSFontAttributeName:self.recordNumberFont
                                        };
        CGRect rect = [[UIScreen mainScreen] bounds];
        CGFloat width = MIN(rect.size.width, rect.size.height);
        
        self.paddingLeft = width / 12;
        self.paddingRight = width / 12;
    }
    return self;
}


@end
