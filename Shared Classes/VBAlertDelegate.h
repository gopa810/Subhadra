//
//  VBAlertDelegate.h
//  VedabaseB
//
//  Created by Peter Kollath on 17/10/14.
//
//

#import <Foundation/Foundation.h>


@protocol VBAlertDelegateDelegate <NSObject>

-(void)alertViewTag:(NSString *)tag clickedButtonIndex:(NSInteger)btnIndex;

@end

@interface VBAlertDelegate : NSObject <UIAlertViewDelegate>


@property NSString * tag;
@property id<VBAlertDelegateDelegate> delegate;

-(id)initWithTag:(NSString *)iTag delegate:(id<VBAlertDelegateDelegate>)del;

@end
