//
//  LegalDetailScreen.m
//  GoEvaRider
//
//  Created by Kalyan Mohan Paul on 9/20/17.
//  Copyright © 2017 Kalyan Paul. All rights reserved.
//

#import "LegalDetailScreen.h"
#import "MyUtils.h"
#import "DataStore.h"
#import "LegalMaster.h"

@interface LegalDetailScreen ()

@end

@implementation LegalDetailScreen

- (void)viewDidLoad {
    [super viewDidLoad];
    appDel = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    if (_screenModeForLegalHelp==1) {
        legalObj = [[DataStore sharedInstance] getLegalMenuByID:_legalHelpMenuID];
    }
    
    [self showContent];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    UILabel *lblTitle = [[UILabel alloc] init];
    if (_screenModeForLegalHelp==1) {
        lblTitle.text = [legalObj cat_name];
    }
    else if (_screenModeForLegalHelp==2) {
        lblTitle.text = @"Learn more";
    }
    lblTitle.backgroundColor = [UIColor clearColor];
    lblTitle.textColor = [UIColor whiteColor];
    lblTitle.shadowOffset = CGSizeMake(0, 1);
    lblTitle.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:18.0];
    [lblTitle sizeToFit];
    self.navigationItem.titleView = lblTitle;
    
    MyUtils *utils= [[MyUtils alloc] init];
    if (_screenModeForLegalHelp==1) {
        [utils setupMenuBarButtonItems:self tilteLable:[legalObj cat_name]];
    }
    else if (_screenModeForLegalHelp==2) {
        [utils setupMenuBarButtonItems:self tilteLable:@"Learn more"];
    }
    self.navigationItem.rightBarButtonItem = nil;
    self.navigationItem.rightBarButtonItem.enabled = NO;
}


-(void)showContent{
    NSString *myHTML;
    if (_screenModeForLegalHelp==1) {
        myHTML = [legalObj content];
    }
    else if (_screenModeForLegalHelp==2) {
        myHTML = _legalHelpMenuID;
    }
    NSString *myDescriptionHTML = [NSString stringWithFormat:@"<html> \n"
                                   "<head> \n"
                                   "<style type=\"text/css\"> \n"
                                   "body {font-family: \"%@\"; font-size: %@;}\n"
                                   "</style> \n"
                                   "</head> \n"
                                   "<body>%@</body> \n"
                                   "</html>", @"helvetica", [NSNumber numberWithInt:18], myHTML];
    
    
    [legalView loadHTMLString:myDescriptionHTML baseURL:nil];
    
}


- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    NSString *fontSize;
    fontSize=@"80";
    NSString *jsString = [[NSString alloc]      initWithFormat:@"document.getElementsByTagName('body')[0].style.webkitTextSizeAdjust= '%d%%'",[fontSize intValue]];
    [legalView stringByEvaluatingJavaScriptFromString:jsString];
    
}


-(BOOL) webView:(UIWebView *)inWeb shouldStartLoadWithRequest:(NSURLRequest *)inRequest navigationType:(UIWebViewNavigationType)inType {
    if ( inType == UIWebViewNavigationTypeLinkClicked ) {
        [[UIApplication sharedApplication] openURL:[inRequest URL]];
        return NO;
    }
    
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
