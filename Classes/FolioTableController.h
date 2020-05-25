//
//  FolioTableController.h
//  VedabaseB
//
//  Created by Peter Kollath on 1/29/11.
//  Copyright 2011 GPSL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FolioSelectTableCell.h"

@interface FolioTableController : UITableViewController {

	//FolioSelectTableCell * tvCell;
	NSArray * arrFolios;
	int selectedRow;
    //UIButton * btnSelect;
	//UIButton * btnRemove;
}

@property (nonatomic,weak) IBOutlet FolioSelectTableCell * tvCell;
@property (nonatomic,strong) NSArray * arrFolios;
@property (assign) int selectedRow;
@property (nonatomic, weak) UIButton * btnSelect;
@property (nonatomic, weak) UIButton * btnRemove;
@end
