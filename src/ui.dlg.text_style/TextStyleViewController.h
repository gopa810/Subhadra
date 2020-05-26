//
//  TextStyleViewController.h
//  VedabaseB
//
//  Created by Peter Kollath on 1/26/13.
//
//

#import <UIKit/UIKit.h>
#import "TGTouchArea.h"
#import "HeaderBar.h"

@class VBUserInterfaceManager;

@interface TextStyleViewController : UIViewController <TGTabBarTouches>

- (IBAction)onCloseToolbar:(id)sender;
- (IBAction)onFontTypeSerif:(id)sender;
- (IBAction)onFontTypeSansSerif:(id)sender;


@property (assign) float currentTextSize;
@property (assign) float currentLineSpacing;

@property IBOutlet TGTouchArea * closeArea;
@property IBOutlet HeaderBar * visibleAreaView;
@property IBOutlet UIStepper * marginStepper;
@property IBOutlet UIStepper * textSizeStepper;
@property IBOutlet UIStepper * lineSpacingStepper;
@property VBUserInterfaceManager * userInterfaceManager;

@property (strong, nonatomic) UIColor * normalColor;
@property (strong, nonatomic) UIColor * highlightColor;

-(void)highlightFontTypeWithFont:(NSString *)fontName;



@end
