//
//  SearchKeyboardAccessoryView.h
//  VedabaseB
//
//  Created by Peter Kollath on 9/18/13.
//
//

#import <UIKit/UIKit.h>


@interface SearchKeyboardAccessoryView : UIViewController
- (IBAction)onButtonPress:(id)sender;
- (IBAction)onButtonTap:(id)sender;

@property (assign) UITextField * textField;

@end
