//
//  TGTouchArea.h
//  VedabaseB
//
//  Created by Peter Kollath on 1/27/13.
//
//

#import <Foundation/Foundation.h>

@protocol TGTabBarTouches <NSObject>

@optional

-(IBAction)onTabButtonPressed:(id)sender;
-(IBAction)onTabButtonReleased:(id)sender;
-(IBAction)onTabButtonReleasedOut:(id)sender;
-(void)executeTouchCommand:(NSString *)command data:(NSDictionary *)aData;

@end

@interface TGTouchArea : UIView

@property (assign, nonatomic) IBOutlet UIViewController<TGTabBarTouches> * delegate;
@property (copy, nonatomic) NSString * touchCommand;
@property UIImage * backgroundImage;
@property CGSize backgroundImageSize;
@property UIColor * topColor;
@property UIColor * bottomColor;

@end
