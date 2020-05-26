//
//  EditNoteDialogController.h
//  VedabaseB
//
//  Created by Peter Kollath on 8/17/13.
//
//

#import "TGTouchArea.h"
#import "VBDialogController.h"
#import "VBRecordNotes.h"

@interface EditNoteDialogController : VBDialogController


@property (nonatomic,retain) IBOutlet UITextView * noteText;
@property (nonatomic, retain) VBRecordNotes * selectedObject;
- (IBAction)onCloseButton:(id)sender;
@property (assign) int globalRecordID;
- (IBAction)onSaveButton:(id)sender;
@end
