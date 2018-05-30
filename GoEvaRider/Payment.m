//
//  PaymentList.m
//  GoEvaRider
//
//  Created by Kalyan Mohan Paul on 6/21/17.
//  Copyright © 2017 Kalyan Paul. All rights reserved.
//

#import "Payment.h"
#import "MFSideMenu.h"
#import "MyUtils.h"
#import "AddCard.h"
#import "Constant.h"
#import "RestCallManager.h"
#import "DataStore.h"
#import "CardCell.h"
#import <AFNetworking/AFNetworking.h>
#import "CardMaster.h"

@interface Payment()

@end

@implementation Payment{
    NSArray *cardBrand;
}
@synthesize delegate;
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    appDel = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    cardBrand = [NSArray arrayWithObjects:@"Visa", @"MasterCard",@"JCB", @"Diners Club", @"Discover",@"American Express", nil];
    _tableViewCard.separatorStyle=NO;
    
    _tableViewCard.allowsMultipleSelectionDuringEditing = NO;
    
    [innerView setHidden:YES];
    [viewSwipeDelete setHidden:YES];
    [self getAllCardsServer];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return cardArray.count;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"CardCell";
    
    CardCell *cell = (CardCell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"CardCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    CardMaster *cardObj = [cardArray objectAtIndex:indexPath.row];
    NSInteger item = [cardBrand indexOfObject:[cardObj valueForKey:@"brand"]];
    switch (item) {
        case 0:
            cell.imgCard.image = [UIImage imageNamed:@"card_visa"];
            break;
        case 1:
            cell.imgCard.image = [UIImage imageNamed:@"card_mastercard"];
            break;
        case 2:
            cell.imgCard.image = [UIImage imageNamed:@"card_jcb"];
            break;
        case 3:
            cell.imgCard.image = [UIImage imageNamed:@"card_diners"];
            break;
        case 4:
            cell.imgCard.image = [UIImage imageNamed:@"card_discover"];
            break;
        case 5:
            cell.imgCard.image = [UIImage imageNamed:@"card_amex"];
            break;
        default:
            cell.imgCard.image = [UIImage imageNamed:@"card_unknown"];
            break;
    }
    //cell.lblCardHolderName.text = [cardObj valueForKey:@"card_holder_name"];
    if ([[cardObj valueForKey:@"default_source"] isEqualToString:@"1"]) {
        cell.imgCheck.image = [UIImage imageNamed:@"ic_check"];
    }
    else{
        cell.imgCheck.image = [UIImage imageNamed:@""];
    }
    if ([[cardObj valueForKey:@"card_holder_name"] isEqualToString:@""]) {
        cell.lblCardHolderName.text = @"XXXXXXXXXX";
    }
    else{
        cell.lblCardHolderName.text = [cardObj valueForKey:@"card_holder_name"];
    }
    UIColor *color = [UIColor blueColor];
    NSString *endingIn = @"Ending In";
    NSString *lblCardDetails = [NSString stringWithFormat:@"%@ %@ %@",[cardObj valueForKey:@"brand"],endingIn,[cardObj valueForKey:@"last4"]];
    NSMutableAttributedString *mutAttrStr = [[NSMutableAttributedString alloc]initWithString:lblCardDetails attributes:nil];
    NSString *privacyPolicyShortStr = endingIn;
    NSDictionary *attributes = @{NSForegroundColorAttributeName:color};
    [mutAttrStr setAttributes:attributes range:NSMakeRange([[cardObj valueForKey:@"brand"] length]+1, privacyPolicyShortStr.length)];
    cell.lblLast4Digit.attributedText = mutAttrStr;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CardMaster *cardObj = [cardArray objectAtIndex:indexPath.row];
    
    if (self.setDefaultCardMode==1) {
        if ([[cardObj valueForKey:@"default_source"] isEqualToString:@"1"]) {
            [self dismissViewControllerAnimated:YES completion:nil];
        }
        else{
            NSString *cardInfo = [NSString stringWithFormat:@"You are selected %@ ending In XXXX%@. The card also become your default card for further proceed to payment. Are you sure you want to continue?",[cardObj valueForKey:@"brand"], [cardObj valueForKey:@"last4"]];
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Message" message:cardInfo preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"Proceed" style:UIAlertActionStyleDefault handler:^(__unused UIAlertAction *action) {
                [self setCardToDefault:[cardObj valueForKey:@"id"]];
            }];
            UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(__unused UIAlertAction *action) {
                
            }];
            [alertController addAction:action2];
            [alertController addAction:action1];
            [self presentViewController:alertController animated:YES completion:nil];
        }
    }
}


// Override to support conditional editing of the table view.
// This only needs to be implemented if you are going to be returning NO
// for some items. By default, all items are editable.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return YES if you want the specified item to be editable.
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //NSLog(@"jasim");
    }
}

-(void) getAllCardsServer{
    
    if (!BackendBaseURL) {
        NSError *error = [NSError errorWithDomain:StripeDomain
                                             code:STPInvalidRequestError
                                         userInfo:@{NSLocalizedDescriptionKey: @"You must set a backend base URL in Constants.m to create a charge."}];
        [self exampleViewController:self didFinishWithError:error];
        return;
    }
    loadingView = [MyUtils customLoaderWithText:self.window loadingText:@"Loading..."];
    [self.view addSubview:loadingView];
    NSString *URL = [NSString stringWithFormat:@"%@list_card.php",BackendBaseURL];
    NSDictionary *params =  @{@"rider_id": [MyUtils getUserDefault:@"riderID"]
                              };
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager POST:URL parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //NSLog(@"Object: %@", responseObject);
        
        NSData *JSONdata = [[responseObject valueForKey:@"Mycard"] dataUsingEncoding:NSUTF8StringEncoding];
        if (JSONdata != nil) {
            NSError * error =nil;
            
            NSMutableArray *jsonUserInfo = [NSJSONSerialization JSONObjectWithData:JSONdata options:NSJSONReadingMutableLeaves error:&error];
            NSMutableArray * arr = [[NSMutableArray alloc]init];
            for (int i = 0; i < [jsonUserInfo count]; i++) {
                CardMaster * fund = [[CardMaster alloc] initWithJsonData:[jsonUserInfo objectAtIndex:i]];
                [arr addObject:fund];
            }
            [[DataStore sharedInstance] addCards:arr];
        }
        [self exampleViewController:self didFinishWithMessage:responseObject];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self exampleViewController:self didFinishWithError:error];
    }];
    
}

- (void)exampleViewController:(UIViewController *)controller didFinishWithMessage:(id)responseObject {
    [loadingView removeFromSuperview];
    [self.view setUserInteractionEnabled:YES];
    [innerView setHidden:NO];
    cardArray = [NSMutableArray arrayWithArray:[[DataStore sharedInstance] getAllCard]];
    [_tableViewCard reloadData];
    /*UIAlertController *alertController = [UIAlertController alertControllerWithTitle:[responseObject objectForKey:@"status"] message:[responseObject objectForKey:@"message"] preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(__unused UIAlertAction *action) {
        
    }];
    [alertController addAction:action];
    [controller presentViewController:alertController animated:YES completion:nil];*/
    
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

-(void) setCardToDefault:(NSString *)cardID{
    
    if (!BackendBaseURL) {
        NSError *error = [NSError errorWithDomain:StripeDomain
                                             code:STPInvalidRequestError
                                         userInfo:@{NSLocalizedDescriptionKey: @"You must set a backend base URL in Constants.m to create a charge."}];
        [self exampleViewController:self didFinishWithError:error];
        return;
    }
    loadingView = [MyUtils customLoaderWithText:self.window loadingText:@"Loading..."];
    [self.view addSubview:loadingView];
    NSString *URL = [NSString stringWithFormat:@"%@set_default_card.php",BackendBaseURL];
    NSDictionary *params =  @{
                              @"rider_id": [MyUtils getUserDefault:@"riderID"],
                              @"card_id": cardID
                              };
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager POST:URL parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //NSLog(@"Object: %@", responseObject);
        [delegate sendDatafromCardListToPayNowPage];
        [self dismissViewControllerAnimated:YES completion:nil];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self exampleViewController:self didFinishWithError:error];
    }];
    
}

- (IBAction)backToHome:(UIButton *)sender{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    [UIView commitAnimations];
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)sendDatafromAddCardToCardList
{
    [self getAllCardsServer];
}
- (IBAction)addCard:(id)sender{
    AddCard *addController;
    if (appDel.iSiPhone5) {
        addController = [[AddCard alloc] initWithNibName:@"AddCard" bundle:nil];
    }
    else{
        addController = [[AddCard alloc] initWithNibName:@"AddCardLow" bundle:nil];
    }
    addController.AddCardMode = 1;
    addController.delegate=self;
    addController.modalTransitionStyle=UIModalTransitionStyleCoverVertical;
    [self presentViewController:addController animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
