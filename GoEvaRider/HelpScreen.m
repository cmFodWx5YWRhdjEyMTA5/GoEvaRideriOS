//
//  HelpScreen.m
//  GoEvaRider
//
//  Created by Kalyan Mohan Paul on 6/21/17.
//  Copyright © 2017 Kalyan Paul. All rights reserved.
//

#import "HelpScreen.h"
#import "MFSideMenu.h"
#import "MyUtils.h"
#import "RestCallManager.h"
#import "DataStore.h"
#import "HelpCell.h"
#import "LegalScreen.h"

@interface HelpScreen ()

@end

@implementation HelpScreen

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    appDel = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    _tableHelp.separatorStyle=NO;
    if([RestCallManager hasConnectivity]){
        [self.view setUserInteractionEnabled:NO];
        UIWindow *currentWindow = [UIApplication sharedApplication].keyWindow;
        loadingView = [MyUtils customLoader:self.window];
        [currentWindow addSubview:loadingView];
        [NSThread detachNewThreadSelector:@selector(requestToServerForFetchHelpMenu) toTarget:self withObject:nil];
    }
    else{
        UIAlertView *loginAlert = [[UIAlertView alloc]initWithTitle:@"Attention!" message:@"Please make sure you phone is coneccted to the internet to use GoEva app." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [loginAlert show];
    }
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    MyUtils *utils= [[MyUtils alloc] init];
    [utils setupMenuBarButtonItems:self tilteLable:@"Help"];
    self.navigationItem.rightBarButtonItem = nil;
    self.navigationItem.rightBarButtonItem.enabled = NO;
}


-(void)requestToServerForFetchHelpMenu{
    BOOL bSuccess;
    bSuccess = [[RestCallManager sharedInstance] getHelpMenu:@"1"];
    if(bSuccess)
    {
        [self performSelectorOnMainThread:@selector(responsefetchHelpMenu) withObject:nil waitUntilDone:YES];
    }
    else{
        [self performSelectorOnMainThread:@selector(responseFailed) withObject:nil waitUntilDone:YES];
    }
}

-(void) responsefetchHelpMenu{
    [loadingView removeFromSuperview];
    [self.view setUserInteractionEnabled:YES];
    helpArray = [NSMutableArray arrayWithArray:[[DataStore sharedInstance] getAllHelpMenu]];
    [_tableHelp reloadData];
}

-(void)responseFailed{
    [loadingView removeFromSuperview];
    [self.view setUserInteractionEnabled:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [helpArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"HelpCell";
    
    HelpCell *cell = (HelpCell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"HelpCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    HelpMaster *helpObj = [helpArray objectAtIndex:indexPath.row];
    cell.lblHelpMenu.text = [helpObj cat_name];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    HelpMaster *helpObj = [helpArray objectAtIndex:indexPath.row];
    LegalScreen *legalController;
    if (appDel.iSiPhone5) {
        legalController = [[LegalScreen alloc] initWithNibName:@"LegalScreen" bundle:nil];
    }
    else{
        legalController = [[LegalScreen alloc] initWithNibName:@"LegalScreenLow" bundle:nil];
    }
    legalController.pageModeForHelpAndLegalMenu = 2;
    legalController.helpMenuID=[helpObj id];
    [self.navigationController pushViewController:legalController animated:YES];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
