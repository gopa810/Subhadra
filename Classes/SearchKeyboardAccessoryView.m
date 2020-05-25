//
//  SearchKeyboardAccessoryView.m
//  VedabaseB
//
//  Created by Peter Kollath on 9/18/13.
//
//

#import "SearchKeyboardAccessoryView.h"

@interface SearchKeyboardAccessoryView ()

@end

@implementation SearchKeyboardAccessoryView

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.textField = nil;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onButtonPress:(id)sender {
    if (self.textField != nil)
    {
        UIButton * btn = (UIButton *)sender;
#ifdef ANDROID
        [self.textField setText:[[self.textField text] stringByAppendingString:btn.titleLabel.text]];
#else
        UITextField * field = self.textField;
        [self.textField replaceRange:field.selectedTextRange withText:btn.titleLabel.text];
#endif
    }
}

- (IBAction)onButtonTap:(id)sender {
#ifndef ANDROID
    [[UIDevice currentDevice] playInputClick];
#endif
}

@end
