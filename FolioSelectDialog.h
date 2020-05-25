//
//  FolioSelectDialog.h
//  VedabaseB
//
//  Created by Peter Kollath on 1/29/11.
//  Copyright 2011 GPSL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FolioTableController.h"

@protocol FolioSelectDialogDelegate;


@interface FolioSelectDialog : UIViewController {

	id <FolioSelectDialogDelegate> delegate;
    IBOutlet UILabel * versionLabel;
	UITableView * folios;
	FolioTableController * ftc;
	UILabel * waitLabel;
	UIButton * btnSelect;
    UIButton * btnRemove;
	UIActivityIndicatorView * activityView;
    UIImageView * shadowTop;
    UIImageView * shadowBottom;
	
	NSDictionary * selectedFolio;
	
}
@property (nonatomic,retain) IBOutlet UITableView * folios;
@property (nonatomic,retain) FolioTableController * ftc;
@property (nonatomic,retain) id <FolioSelectDialogDelegate> delegate;
@property (nonatomic,retain) IBOutlet UILabel * waitLabel;
@property (nonatomic,retain) IBOutlet UIButton * btnSelect;
@property (nonatomic,retain) IBOutlet UIButton * btnRemove;
@property (nonatomic, strong) IBOutlet UIButton * btnCancel;
@property (nonatomic,retain) NSDictionary * selectedFolio;
@property (nonatomic,retain) IBOutlet UIActivityIndicatorView * activityView;
@property (nonatomic,retain) IBOutlet UIImageView * shadowTop;
@property (nonatomic,retain) IBOutlet UIImageView * shadowBottom;


-(IBAction)done:(id)sender;
-(IBAction)doneCancel:(id)sender;


//-(void)backgroundReadFolios;
-(void)initializeTableView;
-(void)refreshTable;
@end

@protocol FolioSelectDialogDelegate
-(void)selectFolioControllerDidFinish:(FolioSelectDialog *)dialog;
//-(NSArray *)enumerateFolios;


@end
