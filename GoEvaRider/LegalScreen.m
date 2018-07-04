//
//  LegalScreen.m
//  GoEvaRider
//
//  Created by Kalyan Mohan Paul on 6/21/17.
//  Copyright © 2017 Kalyan Paul. All rights reserved.
//

#import "LegalScreen.h"
#import "MFSideMenu.h"
#import "MyUtils.h"
#import "RestCallManager.h"
#import "DataStore.h"
#import "LegalCell.h"
#import "LegalMaster.h"
#import "LegalDetailScreen.h"
#import "HelpDetailsMaster.h"

@interface LegalScreen ()

@end

@implementation LegalScreen

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    appDel = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    _tableLegal.separatorStyle=NO;
    _tableLegal.rowHeight = UITableViewAutomaticDimension;
    _tableLegal.estimatedRowHeight=60;
    if (_pageModeForHelpAndLegalMenu==1) {
        if([RestCallManager hasConnectivity]){
            [self.view setUserInteractionEnabled:NO];
            UIWindow *currentWindow = [UIApplication sharedApplication].keyWindow;
            loadingView = [MyUtils customLoader:self.window];
            [currentWindow addSubview:loadingView];
            [NSThread detachNewThreadSelector:@selector(requestToServerForFetchLegalMenu) toTarget:self withObject:nil];
        }
        else{
            UIAlertView *loginAlert = [[UIAlertView alloc]initWithTitle:@"Attention!" message:@"Please make sure you phone is coneccted to the internet to use GoEva app." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [loginAlert show];
        }
    }
    else if(_pageModeForHelpAndLegalMenu==2){
        helpObj = [[DataStore sharedInstance] getHelpMenuByID:_helpMenuID];
        legalArray = [helpObj valueForKey:@"sub_cat_array"];
        [_tableLegal reloadData];
    }
    
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    UILabel *lblTitle = [[UILabel alloc] init];
    if (_pageModeForHelpAndLegalMenu==1) {
        lblTitle.text = @"Legal";
    }
    else{
        lblTitle.text = [helpObj valueForKey:@"cat_name"];
    }
    lblTitle.backgroundColor = [UIColor clearColor];
    lblTitle.textColor = [UIColor whiteColor];
    lblTitle.shadowOffset = CGSizeMake(0, 1);
    lblTitle.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:18.0];
    [lblTitle sizeToFit];
    self.navigationItem.titleView = lblTitle;
    
    
    MyUtils *utils= [[MyUtils alloc] init];
    if (_pageModeForHelpAndLegalMenu==1) {
        [utils setupMenuBarButtonItems:self tilteLable:@"Legal"];
    }
    else if(_pageModeForHelpAndLegalMenu==2){
        [utils setupMenuBarButtonItems:self tilteLable:[helpObj valueForKey:@"cat_name"]];
    }
    self.navigationItem.rightBarButtonItem = nil;
    self.navigationItem.rightBarButtonItem.enabled = NO;
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
    [loadingView removeFromSuperview];
    [self.view setUserInteractionEnabled:YES];
    legalArray = [NSMutableArray arrayWithArray:[[DataStore sharedInstance] getAllLegalMenu]];
    [_tableLegal reloadData];
}

-(void)responseFailed{
    [loadingView removeFromSuperview];
    [self.view setUserInteractionEnabled:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [legalArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"LegalCell";
    
    LegalCell *cell = (LegalCell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"LegalCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    if (_pageModeForHelpAndLegalMenu==1) {
        LegalMaster *legalObj = [legalArray objectAtIndex:indexPath.row];
        cell.lblLegalMenu.text = [legalObj cat_name];
        return cell;
    }
    else if (_pageModeForHelpAndLegalMenu==2){
        HelpDetailsMaster *helpDetailObj = [legalArray objectAtIndex:indexPath.row];
        cell.lblLegalMenu.text = [helpDetailObj valueForKey:@"sub_cat_name"];
        return cell;
    }
    return nil;
}

/*- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}*/

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    LegalDetailScreen *legalController;
    if (appDel.iSiPhone5) {
        legalController = [[LegalDetailScreen alloc] initWithNibName:@"LegalDetailScreen" bundle:nil];
    }
    else{
        legalController = [[LegalDetailScreen alloc] initWithNibName:@"LegalDetailScreenLow" bundle:nil];
    }
    if (_pageModeForHelpAndLegalMenu==1) {
        LegalMaster * legalObj = [legalArray objectAtIndex:indexPath.row];
        legalController.screenModeForLegalHelp=1;
        legalController.legalHelpMenuID = [legalObj id];
    }
    else if (_pageModeForHelpAndLegalMenu==2){
        HelpDetailsMaster *helpDetailObj = [legalArray objectAtIndex:indexPath.row];
        legalController.screenModeForLegalHelp=2;
        legalController.legalHelpMenuID = [helpDetailObj valueForKey:@"content"];
    }
    [self.navigationController pushViewController:legalController animated:YES];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
