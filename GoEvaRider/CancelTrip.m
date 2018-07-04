//
//  CancelTrip.m
//  GoEva
//

#import "CancelTrip.h"
#import "CancelTripRow.h"
#import "DataStore.h"
#import "RestCallManager.h"
#import "MyUtils.h"
#import "DashboardCaller.h"
#import <AFNetworking/AFNetworking.h>
#import "Constant.h"
#import <Stripe/Stripe.h>
@interface CancelTrip ()

@end

@implementation CancelTrip {
    NSArray *tableData;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    appDel = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    cancelReasonArray =[NSMutableArray arrayWithArray: [[DataStore sharedInstance] getAllCancelReason]];
    //tableData = [NSArray arrayWithObjects:@"Rider requested cancel", @"Rider no-show", @"Rider is late", @"Rider denied to come", @"Other", nil];
    _tableCancelTrip.separatorStyle=NO;
    btnSubmit.userInteractionEnabled =NO;
    [btnSubmit setBackgroundColor:[UIColor lightGrayColor]];
    [btnSubmit setTitleColor:[UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:0.3f] forState:UIControlStateNormal];
    btnPolicy.layer.cornerRadius=5;
    if (self.isCancellationCharge) {
        UIColor *color = [UIColor blueColor];
        NSString *startText = @"GoEva charge you of ";
        NSString *priceText = @"$5.00";
        NSString *endingText = @" for cancellation of trip due to late response to cancel. Please refer to cancellation policy for further details.";
        NSString *lblCardDetails = [NSString stringWithFormat:@"%@ %@ %@",startText,priceText,endingText];
        NSMutableAttributedString *mutAttrStr = [[NSMutableAttributedString alloc]initWithString:lblCardDetails attributes:nil];
        NSString *priceStr = priceText;
        NSDictionary *attributes = @{NSForegroundColorAttributeName:color};
        [mutAttrStr setAttributes:attributes range:NSMakeRange([startText length]+1, priceStr.length)];
        lblcancellationCharge.attributedText = mutAttrStr;
    }
    else{
        lblcancellationCharge.hidden=YES;
    }
    
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [cancelReasonArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"CancelTripRow";
    
    CancelTripRow *cell = (CancelTripRow *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"CancelTripRow" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    CancelReason *reasonObj = [cancelReasonArray objectAtIndex:indexPath.row];
    cell.lblCancelRequest.text = [reasonObj cancel_reason];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CancelReason * reasonObj = [cancelReasonArray objectAtIndex:indexPath.row];
    reasonID = [reasonObj id];
    [btnSubmit setUserInteractionEnabled:YES];
    [btnSubmit setBackgroundColor:[UIColor blackColor]];
    [btnSubmit setTitleColor:[UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:1.0f] forState:UIControlStateNormal];
}

- (IBAction)submitCancelTripFeedback:(UIButton *)sender{
    if([RestCallManager hasConnectivity]){
        [self.view setUserInteractionEnabled:NO];
        UIWindow *currentWindow = [UIApplication sharedApplication].keyWindow;
        loadingView = [MyUtils customLoaderFullWindowWithText:self.window loadingText:@"CANCELLING TRIP..."];
        [currentWindow addSubview:loadingView];
        [NSThread detachNewThreadSelector:@selector(requestToServerForCancelTrip) toTarget:self withObject:nil];
    }
    else{
        UIAlertView *loginAlert = [[UIAlertView alloc]initWithTitle:@"Attention!" message:@"Please make sure you phone is coneccted to the internet to use GoEva app." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [loginAlert show];
    }
    
}

-(void)requestToServerForCancelTrip{
    BOOL bSuccess;
    NSString *isCharged;
    if (self.isCancellationCharge) {
        isCharged=@"1";
    }
    else{
        isCharged=@"0";
    }
    bSuccess = [[RestCallManager sharedInstance] cancelRide:_bookingID userType:@"1" isCharged:isCharged riderCurrentLat:_userCurrentLat riderCurrentLong:_userCurrentLong cancelReasonID:reasonID];
    if(bSuccess)
    {
        if (self.isCancellationCharge) {
            [self performSelectorOnMainThread:@selector(payNow) withObject:nil waitUntilDone:YES];
        }
        else{
            [self performSelectorOnMainThread:@selector(responseCancelTrip) withObject:nil waitUntilDone:YES];
        }
    }
    else{
        [self performSelectorOnMainThread:@selector(responseFailed) withObject:nil waitUntilDone:YES];
    }
}

-(void) responseCancelTrip{
    [loadingView removeFromSuperview];
    [self.view setUserInteractionEnabled:YES];
    [MyUtils removeParticularObjectFromNSUserDefault:@"pickupLocation"];
    [MyUtils removeParticularObjectFromNSUserDefault:@"dropLocation"];
    [MyUtils removeParticularObjectFromNSUserDefault:@"rideTimer"];
    UIAlertController * alert=[UIAlertController alertControllerWithTitle:@"Ride has been successfully cancelled. "
                                                                  message:@""
                                                           preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* yesButton = [UIAlertAction actionWithTitle:@"OK"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction * action)
                                {
                                    
                                    //[DashboardCaller homepageSelector:self];
                                    [self.presentingViewController.presentingViewController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
                                    
                                }];
    
    [alert addAction:yesButton];
    [self presentViewController:alert animated:YES completion:nil];
    
}

- (void)payNow{
    if (!BackendBaseURL) {
        NSError *error = [NSError errorWithDomain:StripeDomain
                                             code:STPInvalidRequestError
                                         userInfo:@{NSLocalizedDescriptionKey: @"You must set a backend base URL in Constants.m to create a charge."}];
        [self exampleViewController:self didFinishWithError:error];
        return;
    }
    NSString *URL = [NSString stringWithFormat:@"%@cancellation_charge_payment.php",BackendBaseURL];
    NSDictionary *params =  @{
                              @"rider_id": [MyUtils getUserDefault:@"riderID"],
                              @"cancel_by_user_type":@"1",
                              @"booking_id": _bookingID,
                              @"currency": @"usd",
                              @"description":[MyUtils getUserDefault:@"riderMobileNo"]
                              };
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager POST:URL parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //NSLog(@"Object: %@", responseObject);
        [self exampleViewController:self didFinishWithMessage:responseObject];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self exampleViewController:self didFinishWithError:error];
    }];
    
}

- (void)exampleViewController:(UIViewController *)controller didFinishWithMessage:(id)responseObject {
    
    if ([[responseObject objectForKey:@"status"] isEqualToString:@"0"]) {
        [loadingView removeFromSuperview];
        [self.view setUserInteractionEnabled:YES];
        [MyUtils removeParticularObjectFromNSUserDefault:@"pickupLocation"];
        [MyUtils removeParticularObjectFromNSUserDefault:@"dropLocation"];
        [MyUtils removeParticularObjectFromNSUserDefault:@"rideTimer"];
        UIAlertController * alert=[UIAlertController alertControllerWithTitle:@"Ride has been successfully cancelled. "
                                                                      message:@""
                                                               preferredStyle:UIAlertControllerStyleAlert];
        
        
        UIAlertAction* yesButton = [UIAlertAction actionWithTitle:@"OK"
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action)
                                    {
                                        //[DashboardCaller homepageSelector:self];
                                        [self.presentingViewController.presentingViewController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
                                        
                                    }];
        
        [alert addAction:yesButton];
        [self presentViewController:alert animated:YES completion:nil];
    }
    else{
        
    }
    
}

- (void)exampleViewController:(UIViewController *)controller didFinishWithError:(NSError *)error {
    [loadingView removeFromSuperview];
    [self.view setUserInteractionEnabled:YES];
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:[error localizedDescription] preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(__unused UIAlertAction *action) {
        //[self.navigationController popViewControllerAnimated:YES];
    }];
    [alertController addAction:action];
    [controller presentViewController:alertController animated:YES completion:nil];
    
}

-(void)responseFailed{
    [loadingView removeFromSuperview];
    [self.view setUserInteractionEnabled:YES];
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Error!!!" message:@"Error occured during operation. please try again." preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(__unused UIAlertAction *action) {
        //[self.navigationController popViewControllerAnimated:YES];
    }];
    [alertController addAction:action];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (IBAction)backToPage:(UIButton *)sender{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    [UIView commitAnimations];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)cancellationPolicy:(UIButton *)sender {
    if([RestCallManager hasConnectivity]){
        [self.view setUserInteractionEnabled:NO];
        viewCancellation.frame = CGRectMake(0, 0, 320, 568);
        [self.view addSubview:viewCancellation];
        mySpinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        mySpinner.center = CGPointMake(viewCancellation.frame.size.width / 2, viewCancellation.frame.size.height / 2);
        mySpinner.color=[UIColor lightGrayColor];
        [viewCancellation addSubview:mySpinner];
        [mySpinner startAnimating];
        [NSThread detachNewThreadSelector:@selector(requestToServerForFetchLegalMenu) toTarget:self withObject:nil];
    }
    else{
        UIAlertView *loginAlert = [[UIAlertView alloc]initWithTitle:@"Attention!" message:@"Please make sure you phone is coneccted to the internet to use GoEva app." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [loginAlert show];
    }
}


-(void)requestToServerForFetchLegalMenu{
    BOOL bSuccess;
    bSuccess = [[RestCallManager sharedInstance] getLegalMenu:@"1"];
    if(bSuccess)
    {
        [self performSelectorOnMainThread:@selector(responsefetchLegalMenu) withObject:nil waitUntilDone:YES];
    }
    else{
        [self performSelectorOnMainThread:@selector(responseFailed) withObject:nil waitUntilDone:YES];
    }
}

-(void) responsefetchLegalMenu{
    [self.view setUserInteractionEnabled:YES];
    legalArray = [NSMutableArray arrayWithArray:[[DataStore sharedInstance] getAllLegalMenu]];
    legalObj = [[DataStore sharedInstance] getLegalMenuByID:@"10"];
    [self showContent];
}

-(void)showContent{
    NSString *myHTML;
    myHTML = [legalObj content];
    NSString *myDescriptionHTML = [NSString stringWithFormat:@"<html> \n"
                                   "<head> \n"
                                   "<style type=\"text/css\"> \n"
                                   "body {font-family: \"%@\"; font-size: %@;}\n"
                                   "</style> \n"
                                   "</head> \n"
                                   "<body>%@</body> \n"
                                   "</html>", @"helvetica", [NSNumber numberWithInt:18], myHTML];
    [cancellationPolicyWebView loadHTMLString:myDescriptionHTML baseURL:nil];
    
}


- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    NSString *fontSize;
    fontSize=@"80";
    NSString *jsString = [[NSString alloc]      initWithFormat:@"document.getElementsByTagName('body')[0].style.webkitTextSizeAdjust= '%d%%'",[fontSize intValue]];
    [cancellationPolicyWebView stringByEvaluatingJavaScriptFromString:jsString];
    [mySpinner stopAnimating];
}


-(BOOL) webView:(UIWebView *)inWeb shouldStartLoadWithRequest:(NSURLRequest *)inRequest navigationType:(UIWebViewNavigationType)inType {
    if ( inType == UIWebViewNavigationTypeLinkClicked ) {
        [[UIApplication sharedApplication] openURL:[inRequest URL]];
        return NO;
    }
    
    return YES;
}


- (IBAction)closeCancellationPolicyView:(UIButton *)sender{
    [viewCancellation removeFromSuperview];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
