//
//  GPClientService.m
//  pickaxe
//
//  Created by Kataoka Naoyuki on 2013/07/03.
//  Copyright (c) 2013年 SIROK, Inc. All rights reserved.
//

#import "GPClientService.h"
#import "GPUtils.h"

static GPClientService *sharedInstance = nil;

@implementation GPClientService

+ (GPClientService *) sharedInstance {
    @synchronized(self) {
        if (!sharedInstance)
            sharedInstance = [[self alloc] init];
        return sharedInstance;
    }
}

- (void) createWithApplicationId:(NSInteger)applicationId secret:(NSString *)secret token:(NSString *)token environment:(GPEnvironment)environment success:(void (^)(GPClient *client))success fail:(void (^)(NSInteger status, NSError *error))fail {

    NSString *path = @"/1/clients";
    NSMutableDictionary *body = [NSMutableDictionary dictionary];

    if (applicationId)
        [body setObject:@(applicationId) forKey:@"applicationId"];
    if (secret)
        [body setObject:secret forKey:@"secret"];
    if (token)
        [body setObject:token forKey:@"token"];
    if (NSStringFromGPOS(GPOSIos))
        [body setObject:NSStringFromGPOS(GPOSIos) forKey:@"os"];
    if (NSStringFromGPEnvironment(environment))
        [body setObject:NSStringFromGPEnvironment(environment) forKey:@"environment"];

    GPHttpRequest *httpRequest = [GPHttpRequest instanceWithRequestMethod:GPRequestMethodPost path:path query:nil body:body];

    [self httpRequest:httpRequest success:^(GPHttpResponse *httpResponse) {
        GPClient *client = [GPClient domainWithDictionary:httpResponse.body];
        if (success)
            success(client);
    } fail:^(GPHttpResponse *httpResponse) {
        if (fail)
            fail(httpResponse.httpUrlResponse.statusCode, httpResponse.error);
    }];

}

@end
