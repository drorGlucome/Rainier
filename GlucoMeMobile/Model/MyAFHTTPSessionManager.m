//
//  MyAFHTTPSessionManager.m
//  GlucoMe - Mobile
//
//  Created by dovi winberger on 11/11/2015.
//  Copyright © 2015 Yiftah Ben Aharon. All rights reserved.
//

#import "MyAFHTTPSessionManager.h"
#import "ProfileViewController.h"
@implementation MyAFHTTPSessionManager : AFHTTPSessionManager

- (NSURLSessionDataTask *)GET:(NSString *)URLString
                   parameters:(id)parameters
                      success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                      failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure
{
    NSURLSessionDataTask* task = [super GET:URLString parameters:parameters success:success
                                    failure:^void(NSURLSessionDataTask * task, NSError * err) {
                                        
                                        NSString* message = [[NSString alloc] initWithData:err.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] encoding:NSUTF8StringEncoding];
                                        NSLog(@"%@",message);
                                        if(![URLString containsString:@"/users"])
                                        {
                                            if([((NSHTTPURLResponse*)[[err userInfo] objectForKey:AFNetworkingOperationFailingURLResponseErrorKey]) statusCode] == 401)
                                            {
                                                dispatch_async(dispatch_get_main_queue(), ^{
                                                    [ProfileViewController Logout];
                                                });
                                            }
                                        }
                                        if(failure)failure(task,err);
                                        
                                    }];
    
    return task;
}

- (NSURLSessionDataTask *)HEAD:(NSString *)URLString
                             parameters:(nullable id)parameters
                                success:(nullable void (^)(NSURLSessionDataTask *task))success
                                failure:(nullable void (^)(NSURLSessionDataTask *task, NSError *error))failure


{
    NSURLSessionDataTask* task = [super HEAD:URLString parameters:parameters success:success
                                    failure:^void(NSURLSessionDataTask * task, NSError * err) {
                                        if(![URLString containsString:@"/users"])
                                        {
                                            if([((NSHTTPURLResponse*)[[err userInfo] objectForKey:AFNetworkingOperationFailingURLResponseErrorKey]) statusCode] == 401)
                                            {
                                                dispatch_async(dispatch_get_main_queue(), ^{
                                                    [ProfileViewController Logout];
                                                });
                                            }
                                        }
                                        if(failure)failure(task,err);
                                        
                                    }];
    
    return task;
}



- (NSURLSessionDataTask *)POST:(NSString *)URLString
                             parameters:(nullable id)parameters
                                success:(nullable void (^)(NSURLSessionDataTask *task, id responseObject))success
                                failure:(nullable void (^)(NSURLSessionDataTask *task, NSError *error))failure;
{
    NSURLSessionDataTask* task = [super POST:URLString parameters:parameters success:success
                                     failure:^void(NSURLSessionDataTask * task, NSError * err) {
                                         if(![URLString containsString:@"/users"])
                                         {
                                             if([((NSHTTPURLResponse*)[[err userInfo] objectForKey:AFNetworkingOperationFailingURLResponseErrorKey]) statusCode] == 401)
                                             {
                                                 dispatch_async(dispatch_get_main_queue(), ^{
                                                     [ProfileViewController Logout];
                                                 });
                                             }
                                         }
                                         if(failure)failure(task,err);
                                         
                                     }];
    
    return task;
}

- (NSURLSessionDataTask *)POST:(NSString *)URLString
                             parameters:(nullable id)parameters
              constructingBodyWithBlock:(nullable void (^)(id <AFMultipartFormData> formData))block
                                success:(nullable void (^)(NSURLSessionDataTask *task, id responseObject))success
                                failure:(nullable void (^)(NSURLSessionDataTask *task, NSError *error))failure
{
    NSURLSessionDataTask* task = [super POST:URLString parameters:parameters constructingBodyWithBlock:block success:success
                                     failure:^void(NSURLSessionDataTask * task, NSError * err) {
                                         if(![URLString containsString:@"/users"])
                                         {
                                             if([((NSHTTPURLResponse*)[[err userInfo] objectForKey:AFNetworkingOperationFailingURLResponseErrorKey]) statusCode] == 401)
                                             {
                                                 dispatch_async(dispatch_get_main_queue(), ^{
                                                     [ProfileViewController Logout];
                                                 });
                                             }
                                         }
                                         if(failure)failure(task,err);
                                         
                                     }];
    
    return task;
}

- (NSURLSessionDataTask *)PUT:(NSString *)URLString
                            parameters:(nullable id)parameters
                               success:(nullable void (^)(NSURLSessionDataTask *task, id responseObject))success
                               failure:(nullable void (^)(NSURLSessionDataTask *task, NSError *error))failure
{
    NSURLSessionDataTask* task = [super PUT:URLString parameters:parameters success:success
                                     failure:^void(NSURLSessionDataTask * task, NSError * err) {
                                         if(![URLString containsString:@"/users"])
                                         {
                                             if([((NSHTTPURLResponse*)[[err userInfo] objectForKey:AFNetworkingOperationFailingURLResponseErrorKey]) statusCode] == 401)
                                             {
                                                 dispatch_async(dispatch_get_main_queue(), ^{
                                                     [ProfileViewController Logout];
                                                 });
                                             }
                                         }
                                         if(failure)failure(task,err);
                                         
                                     }];
    
    return task;
}

- (NSURLSessionDataTask *)PATCH:(NSString *)URLString
                              parameters:(nullable id)parameters
                                 success:(nullable void (^)(NSURLSessionDataTask *task, id responseObject))success
                                 failure:(nullable void (^)(NSURLSessionDataTask *task, NSError *error))failure
{
    NSURLSessionDataTask* task = [super PATCH:URLString parameters:parameters success:success
                                     failure:^void(NSURLSessionDataTask * task, NSError * err) {
                                         if(![URLString containsString:@"/users"])
                                         {
                                             if([((NSHTTPURLResponse*)[[err userInfo] objectForKey:AFNetworkingOperationFailingURLResponseErrorKey]) statusCode] == 401)
                                             {
                                                 dispatch_async(dispatch_get_main_queue(), ^{
                                                     [ProfileViewController Logout];
                                                 });
                                             }
                                         }
                                         if(failure)failure(task,err);
                                         
                                     }];
    
    return task;
}

- (NSURLSessionDataTask *)DELETE:(NSString *)URLString
                               parameters:(nullable id)parameters
                                  success:(nullable void (^)(NSURLSessionDataTask *task, id responseObject))success
                                  failure:(nullable void (^)(NSURLSessionDataTask *task, NSError *error))failure
{
    NSURLSessionDataTask* task = [super DELETE:URLString parameters:parameters success:success
                                     failure:^void(NSURLSessionDataTask * task, NSError * err) {
                                         if(![URLString containsString:@"/users"])
                                         {
                                             if([((NSHTTPURLResponse*)[[err userInfo] objectForKey:AFNetworkingOperationFailingURLResponseErrorKey]) statusCode] == 401)
                                             {
                                                 dispatch_async(dispatch_get_main_queue(), ^{
                                                     [ProfileViewController Logout];
                                                 });
                                             }
                                         }
                                         if(failure)failure(task,err);
                                         
                                     }];
    
    return task;
}
@end
