//
//  EditNoteDialogController.m
//  VedabaseB
//
//  Created by Peter Kollath on 8/17/13.
//
//

#import "EditNoteDialogController.h"
#import "VBFolio.h"
#import "VBMainServant.h"

@interface EditNoteDialogController ()

@end

@implementation EditNoteDialogController
@synthesize noteText;
@synthesize selectedObject;
@synthesize globalRecordID;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    //self.touchBack.frame = self.view.frame;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (self.selectedObject)
    {
        [self.noteText setText:self.selectedObject.noteText];
    }
    self.view.backgroundColor = [VBMainServant colorForName:@"darkGradientA"];
    [self.noteText becomeFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark -
#pragma mark Touch Delegates


-(void)onTabButtonPressed:(id)sender
{
    self.view.alpha = 0.5;
}

-(void)onTabButtonReleased:(id)sender
{
    [self onSaveButton:sender];
}

-(void)onTabButtonReleasedOut:(id)sender
{
    self.view.alpha = 1.0;
}

- (IBAction)onSaveButton:(id)sender {
    [self.noteText resignFirstResponder];
    if (self.selectedObject)
    {
        [self.selectedObject setNoteText:self.noteText.text];
        [self.selectedObject setModifyDate:[NSDate date]];
        if (self.delegate)
        {
            NSDictionary * dict = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:self.globalRecordID] forKey:@"record"];
            [self.delegate executeTouchCommand:@"refreshRecord" data:dict];
            
            VBFolio * currentFolio = [[VBMainServant instance] currentFolio];
            NSDictionary * userInfo = [NSDictionary dictionaryWithObject:[currentFolio htmlTextForRecordText:self.noteText.text recordId:globalRecordID] forKey:@"htmlText"];
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotifyRecordNoteChanged object:self userInfo:userInfo];
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotifyNotesListChanged object:self];
        }
    }
    self.view.alpha = 1.0;
    //[self hideDialog];
    [self closeDialog];
}

- (IBAction)onCloseButton:(id)sender {
    [self.noteText resignFirstResponder];
    self.view.alpha = 1.0;
    [self closeDialog];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.noteText resignFirstResponder];
    [self onSaveButton:self];
    return YES;
}


@end
