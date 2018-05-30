//
//  ProfilePictureUpload.h
//  GoEvaDriver
//
//  Created by Kalyan Paul on 27/06/17.
//  Copyright © 2017 Kalyan Paul. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@protocol senddataProtocol <NSObject>

-(void)sendDataTobackToDocumentPage:(UIImage *)profileImage;

@end


@interface ProfilePictureUpload : UIViewController<UIImagePickerControllerDelegate, UINavigationControllerDelegate>{
    AppDelegate *appDel;
    IBOutlet UIButton *btnTakePhoto, *btnSaveDocument, *btnBack;
    IBOutlet UILabel *lblTitle, *bodyTitle;
    IBOutlet UIImageView *imgDocumentPic;
    NSString *encodeBase64Image;
    NSInteger documentMainType;
    UIView *loadingView;
    IBOutlet UIView *alertViewWarning, *alertViewInnerWarning;
    IBOutlet UILabel *alertTitle, *alertBodyMessage;
    IBOutlet UIButton *alertBtn;
    UIView *backgroundView;
    UIImage *chosenImage;
}
@property (strong, nonatomic) UIWindow *window;
@property(nonatomic,assign)id delegate;
@property (nonatomic) NSString *documentType;

- (IBAction)takePhoto:(UIButton *)sender;
- (IBAction)saveDocument:(UIButton *)sender;
- (IBAction)backToDocumentList:(UIButton *)sender;

@end
