PFTwitterUtils-NativeTwitter
============================

Native Twitter Log In functionality for the Parse iOS SDK.

## Setup

1. Drop the *PFTwitterUtils+NativeTwitter* folder into your project.
2. Add `#import "PFTwitterUtils+NativeTwitter.h` wherever you want to perform your Twitter auth.
3. Make sure you are linking against the `Twitter`, `Accounts` and `Parse` frameworks.

## Usage

Native Twitter log in is a bit complicated so there are a few steps you need to take. 

First, provide a success handler (this is pretty standard).

```
// Handle Success
[PFTwitterUtils setNativeLogInSuccessBlock:^(PFUser *user, NSString *userTwitterId, NSError *error) {
    // Store user information...
}];
```

The second step, is to actually request the Twitter accounts that are stored on the device. You'll most likely want to show the user a list of the accounts so they can choose which account they want to log into. This is an array of `ACAccount` objects. You can get the Twitter username by using the `username` property.
 
```
// Get twitter accounts on device (this will prompt the user)
[PFTwitterUtils getTwitterAccounts:^(NSArray *twitterAccounts) {
	// Some method that displays an action sheet...
    [self promptUserToChooseNativeTwitterAccount:twitterAccounts];
}];
```

Lastly, you'll want to give an account back to `PFTwitterUtils` to log in.

```
[PFTwitterUtils logInWithAccount:twitterAccount];
```

Optionally, you can handle your own errors using `setNativeLogInErrorBlock:`

```
// Handle errors. This block is optional. PFTwitterUtils+NativeTwitter will provide default messages for all
// the types of errors we may encounter. Here we are customizing the way the user is presented the error.
[PFTwitterUtils setNativeLogInErrorBlock:^(TwitterLogInError logInError) {
    if (logInError == TwitterLogInErrorAccountAccessDenied) {
		// Handle error...
    }
    else if (logInError == TwitterLogInErrorNetworkError) {
       	// Handle error...
    }
    else if (logInError == TwitterLogInErrorAuthenticationError) {
       	// Handle error...
    }
    else if (logInError == TwitterLogInErrorNoAccountsOnDevice) {
    	// Handle error...
    }
}];
```

## Known Issues

I have run into an issue where the Reverse OAuth procedure in `TWAPIManager` crashes sometimes an iPad 2 I have running iOS 6.1.2. I have not be able to reproduce this on any other device.

## Credits

PFTwitterUtils+NativeTwitter was written by [Christopher Constable](https://github.com/mstrchrstphr).

Special thanks to [Loren Brichter](https://github.com/atebits) for `OAuth+Additions` and [Sean Cook](https://github.com/seancook) `TWAPIManager` and `TWSignedRequest`.