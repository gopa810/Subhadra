//
//  EndlessTextViewSkinDelegate.h
//  VedabaseB
//
//  Created by Peter Kollath on 13/08/14.
//
//

#import <Foundation/Foundation.h>

@protocol EndlessTextViewSkinDelegate <NSObject>

@required

-(UIImage *)endlessTextViewBackgroundImage;
-(UIImage *)endlessTextViewRecordNoteImage;
-(UIImage *)endlessTextViewBookmarkImage;
-(UIImage *)imageForName:(NSString *)strName;

@end
