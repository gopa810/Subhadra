//
//  ContentItemConstants.h
//  VedabaseB
//
//  Created by Peter Kollath on 20/11/14.
//
//

#ifndef VedabaseB_ContentItemConstants_h
#define VedabaseB_ContentItemConstants_h

#define DP_CHECK   0x01
#define DP_TEXT    0x02
#define DP_GOTO    0x03
#define DP_EXPAND  0x04

#define DL_CHECK_TEXT        0x0001
#define DL_CHECK_TEXT_GOTO   0x0002
#define DL_ALL_TEXT          0x0003
#define DL_CHECK_TEXT_EXPAND_GOTO 0x0004
#define DL_CHECK_TEXT_EXPAND      0x0005

//#define CHECK_MARK_AREA_WIDTH  60
//#define GOTO_MARK_AREA_WIDTH   60
#define AREA_INSET             8
#define FONT_SIZE_NORMAL       18

extern CGFloat CHECK_MARK_AREA_WIDTH;
extern CGFloat GOTO_MARK_AREA_WIDTH;

#endif
