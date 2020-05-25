//
//  VBAlertDelegate.m
//  VedabaseB
//
//  Created by Peter Kollath on 17/10/14.
//
//

#import "VBAlertDelegate.h"

@implementation VBAlertDelegate

-(id)initWithTag:(NSString *)iTag delegate:(id<VBAlertDelegateDelegate>)del
{
    self = [super init];
    if (self)
    {
        self.tag = iTag;
        self.delegate = del;
    }
    return self;
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self.delegate alertViewTag:self.tag clickedButtonIndex:buttonIndex];
}

@end
