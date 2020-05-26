//
//  BookmarkAddNewDialog.m
//  VedabaseB
//
//  Created by Peter Kollath on 8/21/13.
//
//

#import "GetUserStringDialog.h"
#import "VBMainServant.h"

@interface GetUserStringDialog ()

@end

@implementation GetUserStringDialog

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.view.backgroundColor = [VBMainServant colorForName:@"dark_papyrus"];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.touchBack.frame = self.view.frame;
    folio = [[VBMainServant instance] currentFolio];
    
    if (self->t1 != nil)
        self.labelTitle.text = self->t1;
    if (self->t2 != nil)
        self.labelSubtitle.text = self->t2;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.textField becomeFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onEditingDidEnd:(id)sender {
    [self.textField resignFirstResponder];
}

- (IBAction)onSave:(id)sender {
    if (self.textField.text.length > 0)
    {
        if (self.callbackDelegate)
        {
            [self.callbackDelegate userHasEnteredString:self.textField.text
                                               inDialog:self.tag
                                               userInfo:self.userInfo];
        }
        
        [self closeDialog];
    }
}

- (IBAction)onCancel:(id)sender {
    [self closeDialog];
}

- (IBAction)onTextFieldChanged:(id)sender {
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.textField resignFirstResponder];
    [self onSave:self];
    return YES;
}

-(void)setTitle:(NSString *)title subtitle:(NSString *)subtitle
{
    if (self.labelTitle == nil || self.labelSubtitle == nil)
    {
        t1 = title;
        t2 = subtitle;
    }
    else
    {
        self.labelTitle.text = title;
        self.labelSubtitle.text = subtitle;
    }
}


@end
