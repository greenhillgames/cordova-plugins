/*
 Licensed to the Apache Software Foundation (ASF) under one
 or more contributor license agreements.  See the NOTICE file
 distributed with this work for additional information
 regarding copyright ownership.  The ASF licenses this file
 to you under the Apache License, Version 2.0 (the
 "License"); you may not use this file except in compliance
 with the License.  You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing,
 software distributed under the License is distributed on an
 "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 KIND, either express or implied.  See the License for the
 specific language governing permissions and limitations
 under the License.
 */

#import "CDVIntentWhitelistPlugin.h"
#import <Cordova/CDVViewController.h>

#pragma mark CDVIntentWhitelistConfigParser

@interface CDVIntentWhitelistConfigParser : NSObject <NSXMLParserDelegate> {}

@property (nonatomic, strong) NSMutableArray* whitelistHosts;

@end

@implementation CDVIntentWhitelistConfigParser

@synthesize whitelistHosts;

- (id)init
{
    self = [super init];
    if (self != nil) {
        self.whitelistHosts = [[NSMutableArray alloc] initWithCapacity:30];
    }
    return self;
}

- (void)parser:(NSXMLParser*)parser didStartElement:(NSString*)elementName namespaceURI:(NSString*)namespaceURI qualifiedName:(NSString*)qualifiedName attributes:(NSDictionary*)attributeDict
{
    if ([elementName isEqualToString:@"allow-intent"]) {
        [whitelistHosts addObject:attributeDict[@"href"]];
    }
}

- (void)parser:(NSXMLParser*)parser didEndElement:(NSString*)elementName namespaceURI:(NSString*)namespaceURI qualifiedName:(NSString*)qualifiedName
{
}

- (void)parser:(NSXMLParser*)parser parseErrorOccurred:(NSError*)parseError
{
    NSAssert(NO, @"config.xml parse error line %ld col %ld", (long)[parser lineNumber], (long)[parser columnNumber]);
}


@end

#pragma mark CDVIntentWhitelistPlugin

@interface CDVIntentWhitelistPlugin () {}
@property (nonatomic, strong) CDVWhitelist* whitelist;
@end

@implementation CDVIntentWhitelistPlugin

@synthesize whitelist;

- (void)setViewController:(UIViewController *)viewController
{
    if ([viewController isKindOfClass:[CDVViewController class]]) {
        CDVWhitelistConfigParser *whitelistConfigParser = [[CDVWhitelistConfigParser alloc] init];
        [(CDVViewController *)viewController parseSettingsWithParser:whitelistConfigParser];
        self.whitelist = [[CDVWhitelist alloc] initWithArray:whitelistConfigParser.whitelistHosts];
    }
}

- (BOOL)shouldOpenExternalURL:(NSURL *)url
{
    return [self.whitelist URLIsAllowed:url];
}
@end
