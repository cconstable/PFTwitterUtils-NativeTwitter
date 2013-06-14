//
//  PFTwitterUtils+NativeTwitter.m
//
//  Created by Christopher Constable on 6/13/13.
//  Copyright (c) 2013 Futura IO. All rights reserved.
//

#import <Accounts/Accounts.h>

#import "PFTwitterUtils+NativeTwitter.h"
#import <Twitter/Twitter.h>
#import "OAuth+Additions.h"
#import "TWAPIManager.h"
#import "TWSignedRequest.h"

TwitterLogInSuccess _nativeLogInSuccessBlock;
TwitterLogInErrorBlock _nativeLogInErrorBlock;

@implementation PFTwitterUtils (NativeTwitter)

+ (void)setNativeLogInSuccessBlock:(TwitterLogInSuccess)nativeLogInSuccessBlock
{
    _nativeLogInSuccessBlock = nativeLogInSuccessBlock;
}

+ (void)setNativeLogInErrorBlock:(TwitterLogInErrorBlock)nativeLogInErrorBlock
{
    _nativeLogInErrorBlock = nativeLogInErrorBlock;
}

+ (void)logInWithAccount:(ACAccount *)twitterAccount
{
    TWAPIManager *twitterAPIManager = [[TWAPIManager alloc] init];
    
    [twitterAPIManager
     performReverseAuthForAccount:twitterAccount
     withHandler:^(NSData *responseData, NSError *error) {
         if (!error) {
             [PFTwitterUtils twitterReverseAuthResponseReceived:responseData];
         }
         else {
             [PFTwitterUtils twitterErrorOccurred:TwitterLogInErrorNetworkError];
         }
     }];
}

+ (BOOL)isLocalTwitterAccountAvailable
{
    return [TWAPIManager isLocalTwitterAccountAvailable];
}

+ (void)getTwitterAccounts:(TwitterAccountFetchBlock)completionBlock
{
    ACAccountStore *accountStore = [[ACAccountStore alloc] init];
    ACAccountType *twitterType = [accountStore
                                  accountTypeWithAccountTypeIdentifier:
                                  ACAccountTypeIdentifierTwitter];
    
    ACAccountStoreRequestAccessCompletionHandler completionHandler =
    ^(BOOL granted, NSError *error) {
        if (granted) {
            NSArray *twitterAccounts = [accountStore accountsWithAccountType:twitterType];
            if (completionBlock) {
                if (twitterAccounts.count) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completionBlock(YES, twitterAccounts);
                    });
                }
                else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completionBlock(NO, nil);
                    });
                    
                    [PFTwitterUtils twitterErrorOccurred:TwitterLogInErrorNoAccountsOnDevice];
                }
            }
        }
        
        // We were denied by the user...
        else {
            [PFTwitterUtils twitterErrorOccurred:TwitterLogInErrorAccountAccessDenied];
            
            // Pass back nothing
            if (completionBlock) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completionBlock(NO, nil);
                });
            }
        }
    };
    
    // iOS 5 and iOS 6 have different APIs
    if ([accountStore
         respondsToSelector:@selector(requestAccessToAccountsWithType:
                                      options:
                                      completion:)]) {
             [accountStore requestAccessToAccountsWithType:twitterType
                                                    options:nil
                                                 completion:completionHandler];
         }
    else {
        [accountStore requestAccessToAccountsWithType:twitterType
                                 withCompletionHandler:completionHandler];
    }
}

+ (void)twitterReverseAuthResponseReceived:(NSData *)responseData
{
    if (responseData) {
        NSString *responseStr = [[NSString alloc]
                                 initWithData:responseData
                                 encoding:NSUTF8StringEncoding];
        
        NSArray *parts = [responseStr componentsSeparatedByString:@"&"];
        
        if (parts.count == 4) {
            NSString *oauthToken        = [[parts objectAtIndex:0] stringByReplacingOccurrencesOfString:@"oauth_token=" withString:@""];
            NSString *oauthTokenSecret  = [[parts objectAtIndex:1] stringByReplacingOccurrencesOfString:@"oauth_token_secret=" withString:@""];
            NSString *userId            = [[parts objectAtIndex:2] stringByReplacingOccurrencesOfString:@"user_id=" withString:@""];
            NSString *screenName        = [[parts objectAtIndex:3] stringByReplacingOccurrencesOfString:@"screen_name=" withString:@""];
            
            [PFTwitterUtils logInWithTwitterId:userId
                                    screenName:screenName
                                     authToken:oauthToken
                               authTokenSecret:oauthTokenSecret
                                         block:^(PFUser *user, NSError *error) {
                                             if (!error) {
                                                 if (_nativeLogInSuccessBlock) {
                                                     dispatch_async(dispatch_get_main_queue(), ^{
                                                         _nativeLogInSuccessBlock(user, userId, error);
                                                     });
                                                 }
                                             }
                                             else {
                                                 [PFTwitterUtils twitterErrorOccurred:TwitterLogInErrorAuthenticationError];
                                             }
                                         }];
        }
        else {
            [PFTwitterUtils twitterErrorOccurred:TwitterLogInErrorAuthenticationError];
        }
    }
}

+ (void)twitterErrorOccurred:(TwitterLogInError)error {
    if (_nativeLogInErrorBlock) {
        dispatch_async(dispatch_get_main_queue(), ^{
            _nativeLogInErrorBlock(error);
        });
    }
    else {
        [PFTwitterUtils showDefaultErrorAlert:error];
    }
}

+ (void)showDefaultErrorAlert:(TwitterLogInError)error
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (error == TwitterLogInErrorAccountAccessDenied) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Twitter Sign in Failed"
                                                                message:@"In order to sign in with Twitter, you will need to give this app access to the account. You can give this app access in your devices \"Settings\"."
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
            [alertView show];
        }
        else if (error == TwitterLogInErrorNetworkError) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Twitter Sign in Failed"
                                                                message:@"We had an issue authenticating with Twitter. Check your internet connection and verify that your Twitter account is working."
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
            [alertView show];
        }
        else if (error == TwitterLogInErrorAuthenticationError) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Twitter Sign in Failed"
                                                                message:@"Please verify that you are signed into Twitter in your devices \"Settings\"."
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
            [alertView show];
        }
        else if (error == TwitterLogInErrorNoAccountsOnDevice) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Twitter Sign in Failed"
                                                                message:@"No Twitter accounts were found on your device."
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
            [alertView show];
        }
    });
}

@end
