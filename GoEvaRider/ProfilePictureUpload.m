//
//  ProfilePictureUpload.m
//  GoEvaDriver
//
//  Created by Kalyan Paul on 27/06/17.
//  Copyright © 2017 Kalyan Paul. All rights reserved.
//

#import "ProfilePictureUpload.h"
#import "MyUtils.h"
#import "RestCallManager.h"
#import "DriverMaster.h"
#import "CarMaster.h"
#import "GlobalVariable.h"

#define UIColorFromRGB(rgbValue) \
[UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0x00FF00) >>  8))/255.0 \
blue:((float)((rgbValue & 0x0000FF) >>  0))/255.0 \
alpha:1.0]

@interface ProfilePictureUpload ()

@end

@implementation ProfilePictureUpload

@synthesize delegate;

- (void)viewDidLoad {
    [super viewDidLoad];
    appDel = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    documentMainType =[self.documentType integerValue];
    [btnSaveDocument setTitleColor:[UIColor colorWithWhite:1.0 alpha:0.3] forState:UIControlStateNormal];
    btnSaveDocument.userInteractionEnabled=NO;
    lblTitle.text = @"Profile Picture";
    bodyTitle.text =@"Profile Picture";
    imgDocumentPic.image = [UIImage imageNamed:@"ic_profile_picture"];
}

- (IBAction)takePhoto:(UIButton *)sender{
    
    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle:@"Take Photo"
                                  message:@"You can take picture from Camera or Gallery"
                                  preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* yesButton = [UIAlertAction
                                actionWithTitle:@"Open Camera"
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction * action)
                                {
                                    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                                        
                                        UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                                              message:@"Device has no camera"
                                                                                             delegate:nil
                                                                                    cancelButtonTitle:@"OK"
                                                                                    otherButtonTitles: nil];
                                        
                                        [myAlertView show];
                                        
                                    } else {
                                        
                                        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
                                        picker.delegate = self;
                                        picker.allowsEditing = YES;
                                        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
                                        
                                        [self presentViewController:picker animated:YES completion:NULL];
                                        
                                    }
                                }];
    
    
    UIAlertAction* noButton = [UIAlertAction
                               actionWithTitle:@"Open Gallery"
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * action)
                               {
                                   UIImagePickerController *picker = [[UIImagePickerController alloc] init];
                                   picker.delegate = self;
                                   picker.allowsEditing = YES;
                                   picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                                   
                                   [self presentViewController:picker animated:YES completion:NULL];
                                   
                               }];
    
    
    [alert addAction:noButton];
    [alert addAction:yesButton];
    
    [self presentViewController:alert animated:NO completion:nil];
    
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [btnSaveDocument setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btnSaveDocument.userInteractionEnabled=YES;
    chosenImage = info[UIImagePickerControllerEditedImage];
    
    /* NSData *imgData = UIImageJPEGRepresentation(chosenImage, 1);
    NSLog(@"Size of Image(KB):%lu",(unsigned long)[imgData length]/1024);
    
    UIImage *hh = [self imageWithImage:chosenImage convertToSize:CGSizeMake(400.0f, 400.0f)];
    NSData *imgData2 = UIImageJPEGRepresentation(hh, 1);
    NSLog(@"Size of resize Image(KB):%lu",(unsigned long)[imgData2 length]/1024);*/
    
    chosenImage = [self imageWithImage:chosenImage convertToSize:CGSizeMake(400.0f, 400.0f)];
    encodeBase64Image = [MyUtils encodeToBase64String:chosenImage];
    imgDocumentPic.contentMode = UIViewContentModeScaleAspectFit;
    imgDocumentPic.image = chosenImage;
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}


- (UIImage *)imageWithImage:(UIImage *)image convertToSize:(CGSize)size {
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *destImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return destImage;
}


/* -(NSString *) getEncodedString:(NSString *)NormalString{
    
    NSString *encodedString = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
                                                                                                    NULL,
                                                                                                    (CFStringRef)NormalString,                                                                                                    NULL,
                                                                                                    (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                                    kCFStringEncodingUTF8 ));
    
    return encodedString;
    
}*/


/* -(NSString *)urlEncodeUsingEncoding:(NSStringEncoding)encoding {
    return (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                                 (CFStringRef)self,
                                                                                 NULL,
                                                                                 (CFStringRef)@"!*'\"();:@&=+$,/?%#[]% ",
                                                                                 CFStringConvertNSStringEncodingToEncoding(encoding)));
}*/
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}
- (IBAction)saveDocument:(UIButton *)sender{
    
    if([RestCallManager hasConnectivity]){
        
            [self.view setUserInteractionEnabled:NO];
            loadingView = [MyUtils customLoaderWithText:self.window loadingText:@"Uploading..."];
            [self.view addSubview:loadingView];
            [btnSaveDocument setTitleColor:[UIColor colorWithWhite:1.0 alpha:0.3] forState:UIControlStateNormal];
            btnSaveDocument.userInteractionEnabled=NO;
            
            [NSThread detachNewThreadSelector:@selector(requestToServerSignIn) toTarget:self withObject:nil];
        
        
    }
    else{
        UIAlertView *loginAlert = [[UIAlertView alloc]initWithTitle:@"Attention!" message:@"Please make sure you phone is coneccted to the internet to use GoEva app." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [loginAlert show];
    }
    
}



-(void)requestToServerSignIn{
    
    BOOL bSuccess;
    RiderMaster *userObj = [self riderRegistration];
    NSString *jsonString = [userObj JSONRepresentation];
    bSuccess =  [[RestCallManager sharedInstance] riderProfileImageUpload:jsonString];
    
    if(bSuccess)
    {
        [self performSelectorOnMainThread:@selector(handlingResponseForSignIn) withObject:nil waitUntilDone:YES];
    
    }
    else{
        [self performSelectorOnMainThread:@selector(noCarFound) withObject:nil waitUntilDone:YES];
    }
}

-(RiderMaster *) riderRegistration{
    
    RiderMaster *user_master =[[RiderMaster alloc] init];
    user_master.id =@"";
    user_master.rider_id=[MyUtils getUserDefault:@"riderID"];
    user_master.user_type=[GlobalVariable getUserType];
    user_master.rider_name=@"";
    user_master.rider_mobile=@"";
    user_master.rider_email=@"";
    user_master.profile_pic=encodeBase64Image;
    user_master.signup_date =@"";
    user_master.password=@"";
    user_master.login_through_otp =@"";
    user_master.device_id =@"";
    user_master.status=@"";
    user_master.ratting =@"";
    user_master.device_type = @"";
    user_master.device_token = @"";
    
    return user_master;
    
}

-(void)handlingResponseForSignIn{
    [self.view setUserInteractionEnabled:YES];
    [MyUtils setUserDefault:@"profileImage" value:[GlobalVariable getGlobalMessage]];
    [delegate sendDataTobackToDocumentPage:chosenImage];
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    [UIView commitAnimations];
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)noCarFound{
    [btnSaveDocument setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btnSaveDocument.userInteractionEnabled=YES;
    [self.view setUserInteractionEnabled:YES];
    [loadingView removeFromSuperview];
    [self validationAlert:[GlobalVariable getGlobalMessage]];
}

-(void)validationAlert:(NSString *)message{
    
    UIWindow *currentWindow = [UIApplication sharedApplication].keyWindow;
    [currentWindow addSubview:backgroundView];
    alertViewWarning.center = CGPointMake(currentWindow.frame.size.width / 2, currentWindow.frame.size.height / 2);
    alertBodyMessage.text=message;
    [currentWindow addSubview:alertViewWarning];
}

- (IBAction)backToDocumentList:(id)sender{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    [UIView commitAnimations];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


//Attention! Please register your email IDs used in non-smtp mails through cpanel plugin. Unregistered email IDs will not be allowed in non-smtp emails sent through scripts. Go to Mail section and find "Registered Mail IDs" plugin in paper_lantern theme

@end
