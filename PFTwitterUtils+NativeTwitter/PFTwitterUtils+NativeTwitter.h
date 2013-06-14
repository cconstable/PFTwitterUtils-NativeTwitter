//
//  PFTwitterUtils+NativeTwitter.h
//
//  Created by Christopher Constable on 6/13/13.
//  Copyright (c) 2013 Futura IO. All rights reserved.
//

#import <Parse/Parse.h>

@class ACAccount;

typedef NS_ENUM(NSInteger, TwitterLogInError) {
    TwitterLogInErrorNoAccountsOnDevice,
    TwitterLogInErrorAccountAccessDenied,
    TwitterLogInErrorAuthenticationError,
    TwitterLogInErrorNetworkError
};

typedef void (^TwitterAccountFetchBlock)(BOOL accountsWereFound, NSArray *twitterAccounts);
typedef void (^TwitterLogInSuccess)(PFUser *user, NSString *userTwitterId, NSError *error);
typedef void (^TwitterLogInErrorBlock)(TwitterLogInError logInError);

/** Adds native Twitter log in to PFTwitterUtils. */
@interface PFTwitterUtils (NativeTwitter) <UIActionSheetDelegate>

+ (void)setNativeLogInSuccessBlock:(TwitterLogInSuccess) nativeLogInSuccessBlock;
+ (void)setNativeLogInErrorBlock:(TwitterLogInErrorBlock) nativeLogInErrorBlock;

/** A simple turn-key log in would be nice but we'd have to present an action sheet or
 something to let the user choose an account and that would take some thought (i.e. we'd
 have to present some UI to the user). */
//+ (void)logIn;

/** Attempts native Twitter log in. */
+ (void)logInWithAccount:(ACAccount *)twitterAccount;

/** This is called automatically. */
+ (BOOL)isLocalTwitterAccountAvailable;

/** This is used to get the accounts to pass to the native log in method
 logInWithAccount:.*/
+ (void)getTwitterAccounts:(TwitterAccountFetchBlock)completionBlock;

@end
