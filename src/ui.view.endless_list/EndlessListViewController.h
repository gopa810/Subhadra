//
//  EndlessListViewController.h
//  VedabaseB
//
//  Created by Peter Kollath on 16/01/15.
//
//

#import <UIKit/UIKit.h>
#import "EndlessTextViewDataSource.h"
#import "FDDrawingProperties.h"
#import "FDSelectionContext.h"

@interface EndlessListViewController : UITableViewController

@property id<EndlessTextViewDataSource> dataSource;
@property FDDrawingProperties * drawer;
@property FDSelectionContext * selection;

@end
