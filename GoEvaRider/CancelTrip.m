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
    bSuccess = [[RestCallManager sharedInstance] cancelRide:_bookingID userType:@"1" riderCurrentLat:_userCurrentLat riderCurrentLong:_userCurrentLong cancelReasonID:reasonID];
    if(bSuccess)
    {
        [self performSelectorOnMainThread:@selector(responseCancelTrip) withObject:nil waitUntilDone:YES];
    }
    else{
        [self performSelectorOnMainThread:@selector(responseFailed) withObject:nil waitUntilDone:YES];
    }
}

-(void) responseCancelTrip{
    [loadingView removeFromSuperview];
    [self.view setUserInteractionEnabled:YES];
    
    UIAlertController * alert=[UIAlertController alertControllerWithTitle:@"Ride has been successfully cancelled. "
                                                                  message:@""
                                                           preferredStyle:UIAlertControllerStyleAlert];
    
    
    UIAlertAction* yesButton = [UIAlertAction actionWithTitle:@"OK"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction * action)
                                {
                                    [MyUtils removeParticularObjectFromNSUserDefault:@"pickupLocation"];
                                    [MyUtils removeParticularObjectFromNSUserDefault:@"dropLocation"];
                                    //[DashboardCaller homepageSelector:self];
                                    [self.presentingViewController.presentingViewController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
                                    
                                }];
    
    [alert addAction:yesButton];
    [self presentViewController:alert animated:YES completion:nil];
    
}

-(void)responseFailed{
    
    [loadingView removeFromSuperview];
    [self.view setUserInteractionEnabled:YES];
    
}

- (IBAction)backToPage:(UIButton *)sender{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    [UIView commitAnimations];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
