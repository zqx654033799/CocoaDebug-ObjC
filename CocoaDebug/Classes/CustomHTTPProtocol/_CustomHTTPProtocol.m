//
//  Example
//  man.li
//
//  Created by man.li on 11/11/2018.
//  Copyright © 2020 man.li. All rights reserved.
//

#import "_CustomHTTPProtocol.h"

#import "_CanonicalRequest.h"
#import "_CacheStoragePolicy.h"
#import "_QNSURLSessionDemux.h"

//liman
#import "_NetworkHelper.h"
#import "_HttpDatasource.h"
#import "NSObject+CocoaDebug.h"
#import "PMUserDefaults.h"
#import <objc/runtime.h>

// https://stackoverflow.com/questions/27604052/nsurlsessiontask-authentication-challenge-completionhandler-and-nsurlauthenticat
@interface CPURLSessionChallengeSender : NSObject <NSURLAuthenticationChallengeSender>

- (instancetype)initWithSessionCompletionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *credential))completionHandler;

@end

@implementation CPURLSessionChallengeSender
{
    void (^_sessionCompletionHandler)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *credential);
}

- (instancetype)initWithSessionCompletionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *credential))completionHandler
{
    self = [super init];

    if (self)
    {
        _sessionCompletionHandler = [completionHandler copy];
    }

    return self;
}

- (void)useCredential:(NSURLCredential *)credential forAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    _sessionCompletionHandler(NSURLSessionAuthChallengeUseCredential, credential);
}

- (void)continueWithoutCredentialForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    _sessionCompletionHandler(NSURLSessionAuthChallengeUseCredential, nil);
}

- (void)cancelAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge;
{
    _sessionCompletionHandler(NSURLSessionAuthChallengeCancelAuthenticationChallenge, nil);
}

- (void)performDefaultHandlingForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    _sessionCompletionHandler(NSURLSessionAuthChallengePerformDefaultHandling, nil);
}

- (void)rejectProtectionSpaceAndContinueWithChallenge:(NSURLAuthenticationChallenge *)challenge
{
    _sessionCompletionHandler(NSURLSessionAuthChallengeRejectProtectionSpace, nil);
}

@end

//liman
typedef NSURLSessionConfiguration *(*SessionConfigConstructor)(id,SEL);

static SessionConfigConstructor orig_defaultSessionConfiguration;
static SessionConfigConstructor orig_ephemeralSessionConfiguration;

static NSURLSessionConfiguration *replaced_defaultSessionConfiguration(id self, SEL _cmd)
{
    NSURLSessionConfiguration *config = orig_defaultSessionConfiguration(self,_cmd);
    
    if ([config respondsToSelector:@selector(protocolClasses)] && [config respondsToSelector:@selector(setProtocolClasses:)]) {
        NSMutableArray *urlProtocolClasses = [NSMutableArray arrayWithArray:config.protocolClasses];
        Class protoCls = _CustomHTTPProtocol.class;
        if (![urlProtocolClasses containsObject:protoCls]) {
            [urlProtocolClasses insertObject:protoCls atIndex:0];
        }
        
        config.protocolClasses = urlProtocolClasses;
    }
    
    return config;
}

static NSURLSessionConfiguration *replaced_ephemeralSessionConfiguration(id self, SEL _cmd)
{
    NSURLSessionConfiguration *config = orig_ephemeralSessionConfiguration(self,_cmd);
    
    if ([config respondsToSelector:@selector(protocolClasses)] && [config respondsToSelector:@selector(setProtocolClasses:)]) {
        NSMutableArray *urlProtocolClasses = [NSMutableArray arrayWithArray:config.protocolClasses];
        Class protoCls = _CustomHTTPProtocol.class;
        if (![urlProtocolClasses containsObject:protoCls]) {
            [urlProtocolClasses insertObject:protoCls atIndex:0];
        }
        
        config.protocolClasses = urlProtocolClasses;
    }
    
    return config;
}

// I use the following typedef to keep myself sane in the face of the wacky 
// Objective-C block syntax.

typedef void (^_ChallengeCompletionHandler)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential * credential);

@interface _CustomHTTPProtocol () <NSURLSessionDataDelegate>

@property (atomic, strong, readwrite) NSThread *                        clientThread;       ///< The thread on which we should call the client.

/*! The run loop modes in which to call the client.
 *  \details The concurrency control here is complex.  It's set up on the client 
 *  thread in -startLoading and then never modified.  It is, however, read by code 
 *  running on other threads (specifically the main thread), so we deallocate it in 
 *  -dealloc rather than in -stopLoading.  We can be sure that it's not read before 
 *  it's set up because the main thread code that reads it can only be called after 
 *  -startLoading has started the connection running.
 */

@property (atomic, copy,   readwrite) NSArray *                         modes;
@property (atomic, assign, readwrite) NSTimeInterval                    startTime;          ///< The start time of the request; written by client thread only; read by any thread.
@property (atomic, strong, readwrite) NSURLSessionDataTask *            task;               ///< The NSURLSession task for that request; client thread only.
@property (atomic, strong, readwrite) NSURLAuthenticationChallenge *    pendingChallenge;
@property (atomic, copy,   readwrite) _ChallengeCompletionHandler        pendingChallengeCompletionHandler;  ///< The completion handler that matches pendingChallenge; main thread only.

//liman
@property (atomic, strong) NSMutableData         *data;

@end

@implementation _CustomHTTPProtocol

#pragma mark * Subclass specific additions

/*! The backing store for the class delegate.  This is protected by @synchronized on the class.
 */

static id<_CustomHTTPProtocolDelegate> sDelegate;

+ (void)start
{
    [NSURLProtocol registerClass:self];
}

+ (id<_CustomHTTPProtocolDelegate>)delegate
{
    id<_CustomHTTPProtocolDelegate> result;

    @synchronized (self) {
        result = sDelegate;
    }
    return result;
}

+ (void)setDelegate:(id<_CustomHTTPProtocolDelegate>)newValue
{
    @synchronized (self) {
        sDelegate = newValue;
    }
}

/*! Returns the session demux object used by all the protocol instances.
 *  \details This object allows us to have a single NSURLSession, with a session delegate, 
 *  and have its delegate callbacks routed to the correct protocol instance on the correct 
 *  thread in the correct modes.  Can be called on any thread.
 */

+ (_QNSURLSessionDemux *)sharedDemux
{
    static dispatch_once_t      sOnceToken;
    static _QNSURLSessionDemux * sDemux;
    dispatch_once(&sOnceToken, ^{
        NSURLSessionConfiguration *     config;
        
        config = [NSURLSessionConfiguration defaultSessionConfiguration];
        // You have to explicitly configure the session to use your own protocol subclass here 
        // otherwise you don't see redirects <rdar://problem/17384498>.
        config.protocolClasses = @[ self ];
        sDemux = [[_QNSURLSessionDemux alloc] initWithConfiguration:config];
    });
    return sDemux;
}

/*! Called by by both class code and instance code to log various bits of information. 
 *  Can be called on any thread.
 *  \param protocol The protocol instance; nil if it's the class doing the logging.
 *  \param format A standard NSString-style format string; will not be nil.
 */

#pragma mark * NSURLProtocol overrides

/*! Used to mark our recursive requests so that we don't try to handle them (and thereby 
 *  suffer an infinite recursive death).
 */

static NSString * kOurRecursiveRequestFlagProperty = @"com.apple.dts.CustomHTTPProtocol";

//liman
+ (BOOL)canInitWithRequest:(NSURLRequest *)request
{
    if (![request.URL.scheme isEqualToString:@"http"] &&
        ![request.URL.scheme isEqualToString:@"https"]) {
        return NO;
    }
    
    if ([NSURLProtocol propertyForKey:kOurRecursiveRequestFlagProperty inRequest:request] ) {
        return NO;
    }
    
    if ([[_NetworkHelper shared] onlyURLs].count > 0) {
        NSString* url = [request.URL.absoluteString lowercaseString];
        for (NSString* _url in [_NetworkHelper shared].onlyURLs) {
            if ([url rangeOfString:[_url lowercaseString]].location != NSNotFound)
                return YES;
        }
        return NO;
    }
    
    return YES;
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request
{
    NSURLRequest *      result;
    
    //assert(request != nil);
    // can be called on any thread
    
    // Canonicalising a request is quite complex, so all the heavy lifting has 
    // been shuffled off to a separate module.
    
    result = CanonicalRequestForRequest(request);

    
    return result;
}

- (id)initWithRequest:(NSURLRequest *)request cachedResponse:(NSCachedURLResponse *)cachedResponse client:(id <NSURLProtocolClient>)client
{
    //assert(request != nil);
    // cachedResponse may be nil
    //assert(client != nil);
    // can be called on any thread

    self = [super initWithRequest:request cachedResponse:cachedResponse client:client];
    
    return self;
}

- (void)dealloc
{
    // can be called on any thread

    //assert(self->_task == nil);                     // we should have cleared it by now
    //assert(self->_pendingChallenge == nil);         // we should have cancelled it by now
    //assert(self->_pendingChallengeCompletionHandler == nil);    // we should have cancelled it by now
}

- (void)startLoading
{
    NSMutableURLRequest *   recursiveRequest;
    NSMutableArray *        calculatedModes;
    NSString *              currentMode;

    // At this point we kick off the process of loading the URL via NSURLSession. 
    // The thread that calls this method becomes the client thread.
    
    //assert(self.clientThread == nil);           // you can't call -startLoading twice
    //assert(self.task == nil);

    // Calculate our effective run loop modes.  In some circumstances (yes I'm looking at 
    // you UIWebView!) we can be called from a non-standard thread which then runs a 
    // non-standard run loop mode waiting for the request to finish.  We detect this 
    // non-standard mode and add it to the list of run loop modes we use when scheduling 
    // our callbacks.  Exciting huh?
    //
    // For debugging purposes the non-standard mode is "WebCoreSynchronousLoaderRunLoopMode" 
    // but it's better not to hard-code that here.
    
    //assert(self.modes == nil);
    calculatedModes = [NSMutableArray array];
    [calculatedModes addObject:NSDefaultRunLoopMode];
    currentMode = [[NSRunLoop currentRunLoop] currentMode];
    if ( (currentMode != nil) && ! [currentMode isEqual:NSDefaultRunLoopMode] ) {
        [calculatedModes addObject:currentMode];
    }
    self.modes = calculatedModes;
    //assert([self.modes count] > 0);

    // Create new request that's a clone of the request we were initialised with, 
    // except that it has our 'recursive request flag' property set on it.
    
    recursiveRequest = [[self request] mutableCopy];
    //assert(recursiveRequest != nil);
    
    [[self class] setProperty:@YES forKey:kOurRecursiveRequestFlagProperty inRequest:recursiveRequest];

    //liman
    self.startTime = [[NSDate date] timeIntervalSince1970];
    self.data = [NSMutableData data];
    
    // Latch the thread we were called on, primarily for debugging purposes.
    
    self.clientThread = [NSThread currentThread];
    
    // Once everything is ready to go, create a data task with the new request.

    self.task = [[[self class] sharedDemux] dataTaskWithRequest:recursiveRequest delegate:self modes:self.modes];
    //assert(self.task != nil);
    
    _HttpModel *model = [_HttpDatasource.shared cacheHttpModelForTask:self.task];
    if (!model) {
        model = [[_HttpModel alloc] initWithTask:self.task];
        // cache
        [_HttpDatasource.shared cacheHttpModel:model forTask:self.task];

        [model setRequest:recursiveRequest];
    }

    [self.task resume];
}

- (void)stopLoading
{
    // The implementation just cancels the current load (if it's still running).
    
    //assert(self.clientThread != nil);           // someone must have called -startLoading

    // Check that we're being stopped on the same thread that we were started 
    // on.  Without this invariant things are going to go badly (for example, 
    // run loop sources that got attached during -startLoading may not get 
    // detached here).
    //
    // I originally had code here to bounce over to the client thread but that 
    // actually gets complex when you consider run loop modes, so I've nixed it. 
    // Rather, I rely on our client calling us on the right thread, which is what 
    // the following //assert is about.
    
    //assert([NSThread currentThread] == self.clientThread);
    
    [self cancelPendingChallenge];
    if (self.task != nil) {
        [self.task cancel];
        self.task = nil;
        // The following ends up calling -URLSession:task:didCompleteWithError: with NSURLErrorDomain / NSURLErrorCancelled, 
        // which specificallys traps and ignores the error.
    }
    // Don't nil out self.modes; see property declaration comments for a a discussion of this.
}

#pragma mark * Authentication challenge handling

/*! Performs the block on the specified thread in one of specified modes.
 *  \param thread The thread to target; nil implies the main thread.
 *  \param modes The modes to target; nil or an empty array gets you the default run loop mode.
 *  \param block The block to run.
 */

- (void)performOnThread:(NSThread *)thread modes:(NSArray *)modes block:(dispatch_block_t)block
{
    // thread may be nil
    // modes may be nil
    //assert(block != nil);

    if (thread == nil) {
        thread = [NSThread mainThread];
    }
    if ([modes count] == 0) {
        modes = @[ NSDefaultRunLoopMode ];
    }
    [self performSelector:@selector(onThreadPerformBlock:) onThread:thread withObject:[block copy] waitUntilDone:NO modes:modes];
}

/*! A helper method used by -performOnThread:modes:block:. Runs in the specified context 
 *  and simply calls the block.
 *  \param block The block to run.
 */

- (void)onThreadPerformBlock:(dispatch_block_t)block
{
    //assert(block != nil);
    block();
}

/*! Called by our NSURLSession delegate callback to pass the challenge to our delegate.
 *  \description This simply passes the challenge over to the main thread.
 *  We do this so that all accesses to pendingChallenge are done from the main thread, 
 *  which avoids the need for extra synchronisation.
 *
 *  By the time this runes, the NSURLSession delegate callback has already confirmed with 
 *  the delegate that it wants the challenge.
 *  
 *  Note that we use the default run loop mode here, not the common modes.  We don't want 
 *  an authorisation dialog showing up on top of an active menu (-:
 *  
 *  Also, we implement our own 'perform block' infrastructure because Cocoa doesn't have 
 *  one <rdar://problem/17232344> and CFRunLoopPerformBlock is inadequate for the 
 *  return case (where we need to pass in an array of modes; CFRunLoopPerformBlock only takes 
 *  one mode).
 *  \param challenge The authentication challenge to process; must not be nil.
 *  \param completionHandler The associated completion handler; must not be nil.
 */

- (void)didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(_ChallengeCompletionHandler)completionHandler
{
    //assert(challenge != nil);
    //assert(completionHandler != nil);
    //assert([NSThread currentThread] == self.clientThread);

    [self performOnThread:nil modes:nil block:^{
        [self mainThreadDidReceiveAuthenticationChallenge:challenge completionHandler:completionHandler];
    }];
}

/*! The main thread side of authentication challenge processing.
 *  \details If there's already a pending challenge, something has gone wrong and 
 *  the routine simply cancels the new challenge.  If our delegate doesn't implement 
 *  the -customHTTPProtocol:canAuthenticateAgainstProtectionSpace: delegate callback, 
 *  we also cancel the challenge.  OTOH, if all goes well we simply call our delegate 
 *  with the challenge.
 *  \param challenge The authentication challenge to process; must not be nil.
 *  \param completionHandler The associated completion handler; must not be nil.
 */

- (void)mainThreadDidReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(_ChallengeCompletionHandler)completionHandler
{
    //assert(challenge != nil);
    //assert(completionHandler != nil);
    //assert([NSThread isMainThread]);
    
    if (self.pendingChallenge != nil) {

        // Our delegate is not expecting a second authentication challenge before resolving the 
        // first.  Likewise, NSURLSession shouldn't send us a second authentication challenge 
        // before we resolve the first.  If this happens, //assert, log, and cancel the challenge.
        //
        // Note that we have to cancel the challenge on the thread on which we received it, 
        // namely, the client thread.

        
        //assert(NO);
        [self clientThreadCancelAuthenticationChallenge:challenge completionHandler:completionHandler];
    } else {
        id<_CustomHTTPProtocolDelegate>  strongDelegate;

        strongDelegate = [[self class] delegate];

        // Tell the delegate about it.  It would be weird if the delegate didn't support this 
        // selector (it did return YES from -customHTTPProtocol:canAuthenticateAgainstProtectionSpace: 
        // after all), but if it doesn't then we just cancel the challenge ourselves (or the client 
        // thread, of course).
        
        if ( ! [strongDelegate respondsToSelector:@selector(customHTTPProtocol:canAuthenticateAgainstProtectionSpace:)] ) {
            
            //assert(NO);
            [self clientThreadCancelAuthenticationChallenge:challenge completionHandler:completionHandler];
        } else {

            // Remember that this challenge is in progress. 
            
            self.pendingChallenge = challenge;
            self.pendingChallengeCompletionHandler = completionHandler;

            // Pass the challenge to the delegate.
            
            
            [strongDelegate customHTTPProtocol:self didReceiveAuthenticationChallenge:self.pendingChallenge];
        }
    }
}

/*! Cancels an authentication challenge that hasn't made it to the pending challenge state.
 *  \details This routine is called as part of various error cases in the challenge handling 
 *  code.  It cancels a challenge that, for some reason, we've failed to pass to our delegate.
 * 
 *  The routine is always called on the main thread but bounces over to the client thread to 
 *  do the actual cancellation.
 *  \param challenge The authentication challenge to cancel; must not be nil.
 *  \param completionHandler The associated completion handler; must not be nil.
 */

- (void)clientThreadCancelAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(_ChallengeCompletionHandler)completionHandler
{
    #pragma unused(challenge)
    //assert(challenge != nil);
    //assert(completionHandler != nil);
    //assert([NSThread isMainThread]);

    [self performOnThread:self.clientThread modes:self.modes block:^{
        completionHandler(NSURLSessionAuthChallengeCancelAuthenticationChallenge, nil);
    }];
}

/*! Cancels an authentication challenge that /has/ made to the pending challenge state.
 *  \details This routine is called by -stopLoading to cancel any challenge that might be 
 *  pending when the load is cancelled.  It's always called on the client thread but 
 *  immediately bounces over to the main thread (because .pendingChallenge is a main 
 *  thread only value).
 */

- (void)cancelPendingChallenge
{
    //assert([NSThread currentThread] == self.clientThread);

    // Just pass the work off to the main thread.  We do this so that all accesses 
    // to pendingChallenge are done from the main thread, which avoids the need for 
    // extra synchronisation.

    [self performOnThread:nil modes:nil block:^{
        if (self.pendingChallenge == nil) {
            // This is not only not unusual, it's actually very typical.  It happens every time you shut down 
            // the connection.  Ideally I'd like to not even call -mainThreadCancelPendingChallenge when 
            // there's no challenge outstanding, but the synchronisation issues are tricky.  Rather than solve 
            // those, I'm just not going to log in this case.
            //
            // [[self class] customHTTPProtocol:self logWithFormat:@"challenge not cancelled; no challenge pending"];
        } else {
            id<_CustomHTTPProtocolDelegate>  strongeDelegate;
            NSURLAuthenticationChallenge *  challenge;

            strongeDelegate = [[self class] delegate];

            challenge = self.pendingChallenge;
            self.pendingChallenge = nil;
            self.pendingChallengeCompletionHandler = nil;
            
            if ([strongeDelegate respondsToSelector:@selector(customHTTPProtocol:didCancelAuthenticationChallenge:)]) {
                [strongeDelegate customHTTPProtocol:self didCancelAuthenticationChallenge:challenge];
            } else {
                // If we managed to send a challenge to the client but can't cancel it, that's bad.
                // There's nothing we can do at this point except log the problem.
                //assert(NO);
            }
        }
    }];
}

- (void)resolveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge withCredential:(NSURLCredential *)credential
{
    //assert(challenge == self.pendingChallenge);
    // credential may be nil
    //assert([NSThread isMainThread]);
    //assert(self.clientThread != nil);
    
    if (challenge != self.pendingChallenge) {
        // This should never happen, and we want to know if it does, at least in the debug build.
        //assert(NO);
    } else {
        _ChallengeCompletionHandler  completionHandler;
        
        // We clear out our record of the pending challenge and then pass the real work 
        // over to the client thread (which ensures that the challenge is resolved on 
        // the same thread we received it on).
        
        completionHandler = self.pendingChallengeCompletionHandler;
        self.pendingChallenge = nil;
        self.pendingChallengeCompletionHandler = nil;
        
        [self performOnThread:self.clientThread modes:self.modes block:^{
            if (credential == nil) {
                completionHandler(NSURLSessionAuthChallengePerformDefaultHandling, nil);
            } else {
                completionHandler(NSURLSessionAuthChallengeUseCredential, credential);
            }
        }];
    }
}

#pragma mark * NSURLSession delegate callbacks

//liman
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task willPerformHTTPRedirection:(NSHTTPURLResponse *)response newRequest:(NSURLRequest *)request completionHandler:(void (^)(NSURLRequest * _Nullable))completionHandler
{
    //重定向 状态码 >=300 && < 400
    if (response && [response isKindOfClass:[NSHTTPURLResponse class]]) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        NSInteger status = httpResponse.statusCode;
        if (status >= 300 && status < 400) {
            [[self client] URLProtocol:self wasRedirectedToRequest:request redirectResponse:response];
            // 记得设置成nil，要不然正常请求会请求两次
            request = nil;
        }
    }
    
    completionHandler(request);
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential *))completionHandler
{
    BOOL        result;
    id<_CustomHTTPProtocolDelegate> strongeDelegate;

    #pragma unused(session)
    #pragma unused(task)
    //assert(task == self.task);
    //assert(challenge != nil);
    //assert(completionHandler != nil);
    //assert([NSThread currentThread] == self.clientThread);

    // Ask our delegate whether it wants this challenge.  We do this from this thread, not the main thread, 
    // to avoid the overload of bouncing to the main thread for challenges that aren't going to be customised 
    // anyway.
    
    strongeDelegate = [[self class] delegate];
    
    result = NO;
    if ([strongeDelegate respondsToSelector:@selector(customHTTPProtocol:canAuthenticateAgainstProtectionSpace:)]) {
        result = [strongeDelegate customHTTPProtocol:self canAuthenticateAgainstProtectionSpace:[challenge protectionSpace]];
    }
    
    // If the client wants the challenge, kick off that process.  If not, resolve it by doing the default thing.

    if (result) {

        [self didReceiveAuthenticationChallenge:challenge completionHandler:completionHandler];
    } else {

//        completionHandler(NSURLSessionAuthChallengePerformDefaultHandling, nil);
        // Callback the original method
        NSURLAuthenticationChallenge* challengeWrapper = [[NSURLAuthenticationChallenge alloc] initWithAuthenticationChallenge:challenge sender:[[CPURLSessionChallengeSender alloc] initWithSessionCompletionHandler:completionHandler]];
        [self.client URLProtocol:self didReceiveAuthenticationChallenge:challengeWrapper];
    }
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler
{
    NSURLCacheStoragePolicy cacheStoragePolicy;
    NSInteger               statusCode;
    
    #pragma unused(session)
    #pragma unused(dataTask)
    //assert(dataTask == self.task);
    //assert(response != nil);
    //assert(completionHandler != nil);
    //assert([NSThread currentThread] == self.clientThread);

    // Pass the call on to our client.  The only tricky thing is that we have to decide on a 
    // cache storage policy, which is based on the actual request we issued, not the request 
    // we were given.

    if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
        cacheStoragePolicy = CacheStoragePolicyForRequestAndResponse(self.task.originalRequest, (NSHTTPURLResponse *) response);
        statusCode = [((NSHTTPURLResponse *) response) statusCode];
    } else {
        //assert(NO);
        cacheStoragePolicy = NSURLCacheStorageNotAllowed;
        statusCode = 42;
    }

    
    [[self client] URLProtocol:self didReceiveResponse:response cacheStoragePolicy:cacheStoragePolicy];
    
    completionHandler(NSURLSessionResponseAllow);
}

- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
didFinishCollectingMetrics:(NSURLSessionTaskMetrics *)metrics API_AVAILABLE(ios(10.0))
{
    _HttpModel *model = [_HttpDatasource.shared cacheHttpModelForTask:task];
    if (!model) return;
    NSURLSessionTaskTransactionMetrics *tMetrics = metrics.transactionMetrics.lastObject;
    model.domainStartDate = tMetrics.domainLookupStartDate;
    model.domainEndDate = tMetrics.domainLookupEndDate;
    model.secureStartDate = tMetrics.secureConnectionStartDate;
    model.secureEndDate = tMetrics.secureConnectionEndDate;
    model.requestStartDate = tMetrics.requestStartDate;
    model.requestEndDate = tMetrics.requestEndDate;
    model.responseStartDate = tMetrics.responseStartDate;
    model.responseEndDate = tMetrics.responseEndDate;
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data
{
    #pragma unused(session)
    #pragma unused(dataTask)
    //assert(dataTask == self.task);
    //assert(data != nil);
    //assert([NSThread currentThread] == self.clientThread);

    // Just pass the call on to our client.


    [[self client] URLProtocol:self didLoadData:data];
    [self.data appendData:data];//liman
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask willCacheResponse:(NSCachedURLResponse *)proposedResponse completionHandler:(void (^)(NSCachedURLResponse *))completionHandler
{
    #pragma unused(session)
    #pragma unused(dataTask)
    //assert(dataTask == self.task);
    //assert(proposedResponse != nil);
    //assert(completionHandler != nil);
    //assert([NSThread currentThread] == self.clientThread);

    // We implement this delegate callback purely for the purposes of logging.
    

    completionHandler(proposedResponse);
}

//liman
//- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
//    // An NSURLSession delegate callback.  We pass this on to the client.
//{
//    #pragma unused(session)
//    #pragma unused(task)
//    //assert( (self.task == nil) || (task == self.task) );        // can be nil in the 'cancel from -stopLoading' case
//    //assert([NSThread currentThread] == self.clientThread);
//
//    // Just log and then, in most cases, pass the call on to our client.
//
//    if (error == nil) {
//
//        [[self client] URLProtocolDidFinishLoading:self];
//    } else if ( [[error domain] isEqual:NSURLErrorDomain] && ([error code] == NSURLErrorCancelled) ) {
//        // Do nothing.  This happens in two cases:
//        //
//        // o during a redirect, in which case the redirect code has already told the client about
//        //   the failure
//        //
//        // o if the request is cancelled by a call to -stopLoading, in which case the client doesn't
//        //   want to know about the failure
//    } else {
//
//        [[self client] URLProtocol:self didFailWithError:error];
//    }
//
//    // We don't need to clean up the connection here; the system will call, or has already called,
//    // -stopLoading to do that.
//}

//liman
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    if (error) {
        [[self client] URLProtocol:self didFailWithError:error];
    } else {
        [[self client] URLProtocolDidFinishLoading:self];
    }
    
    _HttpModel *model = [_HttpDatasource.shared cacheHttpModelForTask:self.task];
    if (model) {
        NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)self.task.response;
        [model setResponse:httpResponse body:self.data error:error];
        // clean
        [_HttpDatasource.shared cacheHttpModel:nil forTask:self.task];
        
        // handler
        [_NetworkHelper.shared handleHttpWithModel:model];
    }
}

/**
 *  Replaces the selector's associated method implementation with the
 *  given implementation (or adds it, if there was no existing one).
 *
 *  @param selector      The selector entry in the dispatch table.
 *  @param newImpl       The implementation that will be associated with
 *                       the given selector.
 *  @param affectedClass The class whose dispatch table will be altered.
 *  @param isClassMethod Set to YES if the selector denotes a class
 *                       method, or NO if it is an instance method.
 *  @return              The previous implementation associated with
 *                       the swizzled selector. You should store the
 *                       implementation and call it when overwriting
 *                       the selector.
 */
IMP replaceMethod(SEL selector, IMP newImpl, Class affectedClass, BOOL isClassMethod) {
    Method origMethod = isClassMethod ? class_getClassMethod(affectedClass, selector) : class_getInstanceMethod(affectedClass, selector);
    IMP origImpl = method_getImplementation(origMethod);

    if (!class_addMethod(isClassMethod ? object_getClass(affectedClass) : affectedClass, selector, newImpl, method_getTypeEncoding(origMethod))) {
        method_setImplementation(origMethod, newImpl);
    }

    return origImpl;
}

#pragma mark -
//liman
+ (void)load {
    
    if (![[PMUserDefaults standardUserDefaults] boolForKey:@"disableNetworkMonitoring_CocoaDebug"]) {
        
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            
            orig_defaultSessionConfiguration = (SessionConfigConstructor)replaceMethod(@selector(defaultSessionConfiguration), (IMP)replaced_defaultSessionConfiguration, [NSURLSessionConfiguration class], YES);
            
            orig_ephemeralSessionConfiguration = (SessionConfigConstructor)replaceMethod(@selector(ephemeralSessionConfiguration), (IMP)replaced_ephemeralSessionConfiguration, [NSURLSessionConfiguration class], YES);
        });
    }
}
@end
