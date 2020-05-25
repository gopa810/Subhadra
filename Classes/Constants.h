//
//  Constants.h
//  VedabaseB
//
//  Created by Peter Kollath on 3/22/13.
//
//

#ifndef VedabaseB_Constants_h
#define VedabaseB_Constants_h

// application lifecycle
#define kNotifyApplicationStart @"ApplicationStart"

// commands
#define kCommandOpenFolio                @"CmdOpenFolio"
#define kNotifyCmdSelectFolio            @"CmdSelectFolio"
#define kNotifyCmdOpenUrl                @"CmdOpenUrl"
#define kNotifyCmdShowHtml               @"CmdShowHtml"
#define kNotifyCmdEditNote               @"CmdEditNote"
#define kNotifyCmdCloseAllDialogs        @"CmdCloseAllDialogs"
#define kNotifyCmdShowSearchResultsPage  @"CmdShowSearchResultsPage"

// folio document lifecycle
#define kNotifyFolioOpen               @"FolioOpen"
#define kNotifyLocalFolioListChanged   @"LocalFolioListChanged"
//#define kNotifyRemoteFolioListChanged  @"RemoteFolioListChanged"
#define kNotifyCollectionsListChanged  @"CollectionsListChanged"
#define kNotifyFolioContentChanged     @"FolioContentChanged"
#define kNotifyRecordNoteChanged       @"RecordNoteChanged"
#define kNotifyBookmarksListChanged    @"BookmarksListChanged"
#define kNotifyNotesListChanged        @"NotesListChanged"
#define kNotifyHighlightersListChanged @"HighlightersListChanged"

// payment constants
#define kNotifyPaymentSucceeded @"PaymentSucceeded"
#define kNotifyPaymentFailed    @"PaymentFailed"

#define kLocalStoreFilesVersionProperty  @"TextabaseLocalCopiesVersion"
#define kLocalStoreVersion               1
#define kASLocalCopyAllowed              @"local_copy_allowed"
#define kASStoreAvailable                @"app_store_available"

#endif
