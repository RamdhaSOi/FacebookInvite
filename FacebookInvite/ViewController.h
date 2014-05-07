//
//  ViewController.h
//  FacebookInvite
//
//  Created by Ramdhas on May,02.
//  Copyright (c) 2014 Ram. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>

@interface ViewController : UIViewController<FBFriendPickerDelegate,FBWebDialogsDelegate>

{
    
}

- (IBAction)InviteAction:(id)sender;


@property (strong, nonatomic) id<FBGraphUser> loggedInUser;
@property (nonatomic) ACAccountStore *accountStore;
- (void)fillTextBoxAndDismiss:(NSString *)text;
@property (retain, nonatomic) FBFriendPickerViewController *friendPickerController;

@end
