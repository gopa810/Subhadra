//
//  BottomBarViewDelegate.h
//  VedabaseB
//
//  Created by Peter Kollath on 23/08/14.
//
//

#import <Foundation/Foundation.h>

@class BottomBarViewController;
@class BottomBarItem;

@protocol BottomBarViewDelegate <NSObject>

-(void)bottomBar:(BottomBarViewController *)controller selectedItem:(BottomBarItem *)item;

@end
