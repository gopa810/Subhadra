//
//  VedabaseURLProtocol.m
//  VedabaseB
//
//  Created by Peter Kollath on 12/9/12.
//  Copyright (c) 2012 GPSL. All rights reserved.
//

#import "VedabaseURLProtocol.h"
#import "VBMainServant.h"

@interface VedabaseProtocolArguments : NSObject

// input properties
@property (strong) NSURL * url;
@property (strong) NSString * urlHost;
@property (strong) NSString * urlPath;

// output properties
@property (strong) NSString * mimeType;
@property (strong) NSData   * data;

@end

@implementation VedabaseProtocolArguments

-(id)initWithURL:(NSURL *)iurl
{
    if ((self = [super init]) != nil)
    {
        self.url = iurl;
        self.urlHost = [iurl host];
        self.urlPath = ([[iurl path] hasPrefix:@"/"] ? [[iurl path] substringFromIndex:1] : [iurl path]);

        self.data = nil;
        self.mimeType = nil;
    }
    
    return self;
}

-(BOOL)isHost:(NSString *)str
{
    return [self.urlHost caseInsensitiveCompare:str] == NSOrderedSame;
}

-(NSURLResponse *)response
{
    if (self.mimeType == nil || self.data == nil) {
        return nil;
    }
    
    NSURLResponse * response = [[NSURLResponse alloc] initWithURL:self.url
                                                         MIMEType:self.mimeType
                                            expectedContentLength:[self.data length]
                                                 textEncodingName:nil];
    return response;
}

@end


@implementation VedabaseURLProtocol


//
// method that determines if request will be handled by this class
//
+(BOOL)canInitWithRequest:(NSURLRequest *)aRequest
{
    NSURL * url = aRequest.URL;
    NSLog(@"Catched URL: %@", url.absoluteString);
    if ([aRequest.URL.scheme caseInsensitiveCompare:@"vbase"] == NSOrderedSame)
    {
        NSString * host = [url host];
        if ([host isEqualToString:@"stylist_images"])
            return YES;
        if ([host isEqualToString:@"resources"])
            return YES;
        if ([host isEqualToString:@"objects"])
            return YES;
        if ([host isEqualToString:@"assets"])
            return YES;
        return NO;
    }
    else if ([aRequest.URL.scheme caseInsensitiveCompare:@"memory"] == NSOrderedSame)
    {
        int pageNUm = [[[url path] lastPathComponent] intValue];
        NSNumber * page = [NSNumber numberWithInt:pageNUm];
        NSDictionary * userInfo = [NSDictionary dictionaryWithObject:page forKey:@"page"];
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotifyCmdShowSearchResultsPage object:self userInfo:userInfo];
        return NO;
    }
    return NO;
}

+(NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)aRequest
{
    return aRequest;
}

//
// static method for retrieving MIME type from file extension
// may not be correct, if extension is not according actual content
// but this can be tolerated, because we use this function mainly
// for internal resources
//
+(NSString *)mimeTypeFromExtension:(NSString *)ext
{
    if ([ext isEqualToString:@"png"])
        return @"image/png";
    if ([ext isEqualToString:@"jpg"] || [ext isEqualToString:@"jpeg"])
        return @"image/jpeg";
    if ([ext isEqualToString:@"mp3"])
        return @"audio/mpeg";
    if ([ext isEqualToString:@"css"])
        return @"text/css";
    if ([ext isEqualToString:@"htm"] || [ext isEqualToString:@"html"])
        return @"text/html";
    if ([ext isEqualToString:@"js"])
        return @"text/javascript";
    
    return [NSString stringWithFormat:@"image/%@", ext];
}

//
// do not remove this method
// it is useful for NSURLProtocol
-(void)stopLoading
{
}


-(void)startLoading
{
    VedabaseProtocolArguments * args = [[VedabaseProtocolArguments alloc] initWithURL:[[self request] URL]];

    //NSLog(@"startLoading-- %@", url);
    if ([args isHost:@"stylist_images"])
    {
        args.mimeType = [VedabaseURLProtocol mimeTypeFromExtension:[args.urlPath pathExtension]];
        args.data = [VBMainServant imageDataForName:args.urlPath];
        NSLog(@"Image %@ %@ found", args.urlPath, (args.data != nil ? @"" : @"NOT"));
    }
    else if ([args isHost:@"resources"])
    {
        if ([args.urlPath caseInsensitiveCompare:@"styles.css"] == NSOrderedSame)
        {
            args.mimeType = @"text/css";
            VBMainServant * servant = [VBMainServant instance];
            VBFolio * currFolio = [servant currentFolio];
            [currFolio performSelectorOnMainThread:@selector(stylesDataCSS) withObject:nil waitUntilDone:YES];
            args.data = currFolio.stylesCache;
        }
        else if ([args.urlPath caseInsensitiveCompare:@"maintext.js"] == NSOrderedSame)
        {
            args.mimeType = @"text/javascript";
            args.data = [[VBMainServant instance].fileManager mainTextJavaScript];
        } else {
            args.mimeType = [VedabaseURLProtocol mimeTypeFromExtension:[args.urlPath pathExtension]];
            args.data = nil;
            NSString * resourcePath = [[NSBundle mainBundle] pathForResource:[args.urlPath lastPathComponent]
                                  ofType:[args.urlPath pathExtension]
                                  inDirectory:[args.urlPath stringByDeletingLastPathComponent]];
            if (resourcePath != nil) {
                args.data = [NSData dataWithContentsOfFile:resourcePath];
            }
        }
    }
    else if ([args isHost:@"assets"])
    {
        args.mimeType = [VedabaseURLProtocol mimeTypeFromExtension:[args.urlPath pathExtension]];
        args.data = nil;
        NSString * fileName = [[args.urlPath lastPathComponent] stringByDeletingPathExtension];
        NSString * resourcePath = [[NSBundle mainBundle] pathForResource:fileName
                                                                  ofType:[args.urlPath pathExtension]
                                                             inDirectory:@"assets"];
        if (resourcePath != nil) {
            args.data = [NSData dataWithContentsOfFile:resourcePath];
        }
    }
    else if ([args isHost:@"objects"])
    {
        [self loadObjectData:args];
    }
    
    NSURLResponse * response = [args response];
    if (response != nil) {
        
        [[self client] URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
        [[self client] URLProtocol:self didLoadData:args.data];
        [[self client] URLProtocolDidFinishLoading:self];

    }
}

-(void)loadObjectData:(VedabaseProtocolArguments *)args
{
    args.data = [[[VBMainServant instance] currentFolio] findObject:args.urlPath];
    args.mimeType = [VedabaseURLProtocol mimeTypeFromExtension:[args.urlPath pathExtension]];
}


@end
