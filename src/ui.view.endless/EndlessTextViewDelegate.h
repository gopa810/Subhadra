//
//  EndlessTextViewDelegate.h
//  VedabaseB
//
//  Created by Peter Kollath on 28/07/14.
//
//

#import <Foundation/Foundation.h>
@class EndlessTextView;

@protocol EndlessTextViewDelegate <NSObject>

@optional

-(void)endlessTextView:(UIView *)textView
       paraAreaClicked:(int)recId
              withRect:(CGRect)rect;

-(void)endlessTextView:(UIView *)textView
      topRecordChanged:(int)recordId;


@required


-(void)endlessTextView:(UIView *)textView
          navigateLink:(NSDictionary *)data;
//          navigateLink:(NSString *)link
//                ofType:(NSString *)type;


-(void)endlessTextView:(UIView *)textView
       leftAreaClicked:(int)recId
              withRect:(CGRect)rect;

-(void)endlessTextView:(UIView *)textView
   leftAreaLongClicked:(int)recId
              withRect:(CGRect)rect;

-(void)endlessTextView:(UIView *)textView
      rightAreaClicked:(int)recId
              withRect:(CGRect)rect;

-(void)endlessTextView:(UIView *)textView
  rightAreaLongClicked:(int)recId
              withRect:(CGRect)rect;

-(void)endlessTextView:(UIView *)textView
    selectionDidChange:(CGRect)rect;

-(void)endlessTextView:(UIView *)textView
    swipeLeft:(CGPoint)point;

-(void)endlessTextView:(UIView *)textView
    swipeRight:(CGPoint)point;

-(void)endlessTextViewTapWithoutSelection:(UIView *)textView;

@end
