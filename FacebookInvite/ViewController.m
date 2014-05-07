//
//  ViewController.m
//  FacebookInvite
//
//  Created by Ramdhas on May,02.
//  Copyright (c) 2014 Ram. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)InviteAction:(id)sender
{
        if (!FBSession.activeSession.isOpen)
        {
            // if the session is closed, then we open it here, and establish a handler for state changes
            [FBSession openActiveSessionWithReadPermissions:nil
                                               allowLoginUI:YES
                                          completionHandler:^(FBSession *session,
                                                              FBSessionState state,
                                                              NSError *error)
             {
                 if(error)
                 {

                 }
                 else if (session.isOpen)
                 {
                     [self InviteAction:sender];
                 }
             }];
            return;
        }
        
        if (self.friendPickerController == nil)
        {
            // Create friend picker, and get data loaded into it.
            self.friendPickerController = [[FBFriendPickerViewController alloc] init];
            self.friendPickerController.title = @"Pick Friends";
            self.friendPickerController.delegate = self;
        }
        
        [self.friendPickerController loadData];
        [self.friendPickerController clearSelection];
        
        [self presentViewController:self.friendPickerController animated:YES completion:nil];
}

- (void) performPublishAction:(void (^)(void)) action
{
    if ([FBSession.activeSession.permissions indexOfObject:@"publish_actions"] == NSNotFound)
    {
        [FBSession.activeSession requestNewPublishPermissions:@[@"publish_actions"]
                                              defaultAudience:FBSessionDefaultAudienceFriends
                                            completionHandler:^(FBSession *session, NSError *error)
         {
             if (!error)
             {
                 action();
             }
             else if (error.fberrorCategory != FBErrorCategoryUserCancelled)
             {
                 UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Permission Denied"
                                                                     message:@"Unable to obtain permission to post."
                                                                    delegate:nil
                                                           cancelButtonTitle:@"OK"
                                                           otherButtonTitles:nil];
                 [alertView show];
             }
         }];
    }
    else
    {
        action();
    }
    
}


- (void)loginViewFetchedUserInfo:(FBLoginView *)loginView
                            user:(id<FBGraphUser>)user
{
    self.loggedInUser = user;
}


- (void)facebookViewControllerDoneWasPressed:(id)sender
{
    NSMutableString *text = [[NSMutableString alloc] init];
    for (id<FBGraphUser> user in self.friendPickerController.selection)
    {
        if ([text length])
        {
            [text appendString:@","];
        }
        [text appendString:[NSString stringWithFormat:@"%@",user.id]];
    }
    // Its for Sending app request to selected friends
    
    NSDictionary *params = @{@"to":text};
    
    NSString *message = @"MESSAGE";
    NSString *title = @"TITLE";
    
    [FBWebDialogs presentRequestsDialogModallyWithSession:nil
                                                  message:message
                                                    title:title
                                               parameters:params handler:^(FBWebDialogResult result, NSURL *resultURL, NSError *error)
     {
         if (error)
         {
             UIAlertView *Alert = [[UIAlertView alloc]initWithTitle:@"Alert" message:@"Request Not Sent." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
             [Alert show];
         }
         else
         {
             if (result == FBWebDialogResultDialogNotCompleted)
             {
                 // Case B: User clicked the "x" icon
                 UIAlertView *Alert = [[UIAlertView alloc]initWithTitle:@"Alert" message:@"You have cancelled the request." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                 [Alert show];
                 NSLog(@"User canceled request.");
             }
             else
             {
                 UIAlertView *Alert = [[UIAlertView alloc]initWithTitle:@"Success" message:@"Request sent successfully." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                 [Alert show];
                 NSLog(@"Request Sent. %@", params);
             }
         }
     }];
    
    [self fillTextBoxAndDismiss:text.length > 0 ? text : @"<None>"];
}


- (void)facebookViewControllerCancelWasPressed:(id)sender {
    [self fillTextBoxAndDismiss:@"<Cancelled>"];
}

- (void)fillTextBoxAndDismiss:(NSString *)text
{
    [self dismissModalViewControllerAnimated:YES];
}

@end
