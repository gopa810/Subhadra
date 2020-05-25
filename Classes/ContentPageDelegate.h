//
//  ContentPageDelegate.h
//  VedabaseB
//
//  Created by Peter Kollath on 23/08/14.
//
//

#import <Foundation/Foundation.h>

@class ContentPageController;

@protocol ContentPageDelegate <NSObject>


-(void)contentPage:(ContentPageController *)controller shouldHide:(BOOL)hide;
-(void)contentPage:(ContentPageController *)controller showTextRecord:(int)recordId;

@end
