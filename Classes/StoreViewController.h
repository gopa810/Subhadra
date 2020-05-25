//
//  StoreViewController.h
//  VedabaseB
//
//  Created by Peter Kollath on 12/28/12.
//  Copyright (c) 2012 GPSL. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "VBMainServant.h"
#import "FolioFilesTableViewController.h"

@interface StoreViewController : UIViewController
{
	UITableView * folios;
	FolioFilesTableViewController * ftc;
    UIView * headerBarView;
}

@property (nonatomic,retain) IBOutlet UITableView * folios;
@property (nonatomic,retain) IBOutlet UIView * headerBarView;
@property (nonatomic,retain) FolioFilesTableViewController * ftc;

@end
