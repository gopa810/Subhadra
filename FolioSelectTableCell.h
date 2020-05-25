//
//  FolioSelectTableCell.h
//  VedabaseB
//
//  Created by Peter Kollath on 2/5/11.
//  Copyright 2011 GPSL. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface FolioSelectTableCell : UITableViewCell {

	UIImageView * fsImage;
	UILabel * fsTitle;
	UILabel * fsDate;
	UILabel * fsAbstract;
}


@property(nonatomic,retain) IBOutlet UIImageView * fsImage;
@property(nonatomic,retain) IBOutlet UILabel * fsTitle;
@property(nonatomic,retain) IBOutlet UILabel * fsDate;
@property(nonatomic,retain) IBOutlet UILabel * fsAbstract;

@end
