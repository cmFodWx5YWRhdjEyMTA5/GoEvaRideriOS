//
//  SearchLocation.m
//  GoEvaRider
//


#import "PickupLocation.h"
#import "ChooseCar.h"

#if !defined(__has_feature) || !__has_feature(objc_arc)
#error "This file requires ARC support."
#endif

#import <GooglePlaces/GooglePlaces.h>

@interface PickupLocation () <UITextFieldDelegate,GMSAutocompleteTableDataSourceDelegate>

@end

@implementation PickupLocation {
    
    UITableViewController *_resultsController;
    GMSAutocompleteTableDataSource *_tableDataSource;
}

@synthesize delegate;

+ (NSString *)demoTitle {
    return NSLocalizedString(
                             @"Demo.Title.Autocomplete.UITextField",
                             @"Title of the UITextField autocomplete demo for display in a list or nav header");
}

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    // Configure the text field to our linking.
   
    _searchField.translatesAutoresizingMaskIntoConstraints = NO;
    //_searchField.borderStyle = UITextBorderStyleNone;
    //_searchField.backgroundColor = [UIColor whiteColor];
    _searchField.placeholder = NSLocalizedString(@"Demo.Content.Autocomplete.EnterPickupLocation",
                                                 @"Prompt to enter text for Pickup Location");
    _searchField.autocorrectionType = UITextAutocorrectionTypeNo;
    _searchField.keyboardType = UIKeyboardTypeDefault;
    _searchField.returnKeyType = UIReturnKeyDone;
    _searchField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _searchField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [_searchField becomeFirstResponder];
    [_searchField addTarget:self
                     action:@selector(textFieldDidChange:)
           forControlEvents:UIControlEventEditingChanged];
    _searchField.delegate = self;
    
    // Setup the results view controller.
    _tableDataSource = [[GMSAutocompleteTableDataSource alloc] init];
    /* Filter Not Working */
    _tableDataSource.autocompleteFilter.type = kGMSPlacesAutocompleteTypeFilterAddress;
    _tableDataSource.autocompleteFilter.country=@"US";
    
    
    /*GMSCoordinateBounds* bounds =  [[GMSCoordinateBounds alloc] init];
    NSMutableArray *array = [[NSMutableArray alloc]initWithObjects:[[NSDictionary alloc]initWithObjectsAndKeys:@"22.36",@"latitude",@"88.24",@"longitude", nil],
                             [[NSDictionary alloc]initWithObjectsAndKeys:@"32.43",@"latitude",@"74.54",@"longitude", nil],
                             [[NSDictionary alloc]initWithObjectsAndKeys:@"23.20",@"latitude",@"71.00",@"longitude", nil],
                             [[NSDictionary alloc]initWithObjectsAndKeys:@"11.00",@"latitude",@"77.00",@"longitude", nil],
                             [[NSDictionary alloc]initWithObjectsAndKeys:@"22.36",@"latitude",@"88.24",@"longitude", nil],nil];
    CLLocationCoordinate2D location;
    for (NSDictionary *dictionary in array)
    {
        location.latitude = [dictionary[@"latitude"] floatValue];
        location.longitude = [dictionary[@"longitude"] floatValue];
        // Creates a marker in the center of the map.
        GMSMarker *marker = [[GMSMarker alloc] init];
        marker.position = CLLocationCoordinate2DMake(location.latitude, location.longitude);
        bounds = [bounds includingCoordinate:marker.position];
    }
    //CLLocationCoordinate2D position = CLLocationCoordinate2DMake(22.00, 88.00);
    //bounds = [bounds includingCoordinate:position];
    _tableDataSource.autocompleteBounds=bounds;*/
    /* End */
    _tableDataSource.delegate = self;
    
    _resultsController = [[UITableViewController alloc] initWithStyle:UITableViewStylePlain];
    _resultsController.tableView.delegate = _tableDataSource;
    _resultsController.tableView.dataSource = _tableDataSource;
    
    [self.view addSubview:_searchField];
    // Use auto layout to place the text field, as we need to take the top layout guide into
    // consideration.
    [self.view
     addConstraints:[NSLayoutConstraint
                     constraintsWithVisualFormat:@"H:|-[_searchField]-|"
                     options:0
                     metrics:nil
                     views:NSDictionaryOfVariableBindings(_searchField)]];
    [NSLayoutConstraint constraintWithItem:_searchField
                                 attribute:NSLayoutAttributeTop
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:self.topLayoutGuide
                                 attribute:NSLayoutAttributeBottom
                                multiplier:1
                                  constant:50].active = YES;
    
    [self addResultViewBelow:_searchField];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    //[delegate sendDataBackToHomepage:@"0"];
}

#pragma mark - GMSAutocompleteTableDataSourceDelegate

- (void)tableDataSource:(GMSAutocompleteTableDataSource *)tableDataSource
didAutocompleteWithPlace:(GMSPlace *)place {
    [_searchField resignFirstResponder];
    //[self autocompleteDidSelectPlace:place];
    _searchField.text = place.formattedAddress;
    
    [delegate sendDatafromPickupToDashboard:place];
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    [UIView commitAnimations];
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

- (void)tableDataSource:(GMSAutocompleteTableDataSource *)tableDataSource
didFailAutocompleteWithError:(NSError *)error {
    [_searchField resignFirstResponder];
    //[self autocompleteDidFail:error];
    _searchField.text = @"";
}

- (void)didRequestAutocompletePredictionsForTableDataSource:
(GMSAutocompleteTableDataSource *)tableDataSource {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [_resultsController.tableView reloadData];
}

- (void)didUpdateAutocompletePredictionsForTableDataSource:
(GMSAutocompleteTableDataSource *)tableDataSource {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [_resultsController.tableView reloadData];
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [self addChildViewController:_resultsController];
    
    // Add the results controller.
    _resultsController.view.translatesAutoresizingMaskIntoConstraints = NO;
    _resultsController.view.alpha = 0.0f;
    [self.view addSubview:_resultsController.view];
    
    // Layout it out below the text field using auto layout.
    [self.view addConstraints:[NSLayoutConstraint
                               constraintsWithVisualFormat:@"V:[_searchField]-[resultView]-(0)-|"
                               options:0
                               metrics:nil
                               views:@{
                                       @"_searchField" : _searchField,
                                       @"resultView" : _resultsController.view
                                       }]];
    [self.view addConstraints:[NSLayoutConstraint
                               constraintsWithVisualFormat:@"H:|-(0)-[resultView]-(0)-|"
                               options:0
                               metrics:nil
                               views:@{
                                       @"resultView" : _resultsController.view
                                       }]];
    
    // Force a layout pass otherwise the table will animate in weirdly.
    [self.view layoutIfNeeded];
    
    // Reload the data.
    [_resultsController.tableView reloadData];
    
    // Animate in the results.
    [UIView animateWithDuration:0.5
                     animations:^{
                         _resultsController.view.alpha = 1.0f;
                     }
                     completion:^(BOOL finished) {
                         [_resultsController didMoveToParentViewController:self];
                     }];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    // Dismiss the results.
    [_resultsController willMoveToParentViewController:nil];
    [UIView animateWithDuration:0.5
                     animations:^{
                         _resultsController.view.alpha = 0.0f;
                     }
                     completion:^(BOOL finished) {
                         [_resultsController.view removeFromSuperview];
                         [_resultsController removeFromParentViewController];
                     }];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    [textField resignFirstResponder];
    textField.text = @"";
    return NO;
}

#pragma mark - Private Methods

- (void)textFieldDidChange:(UITextField *)textField {
    [_tableDataSource sourceTextHasChanged:textField.text];
}

- (IBAction)homePage:(UIButton *)sender{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    [UIView commitAnimations];
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end

/* @interface PickupLocation ()

@end

@implementation PickupLocation

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    UIBezierPath *shadowBox = [UIBezierPath bezierPathWithRect:DestinationSearchShadow.bounds];
    
    DestinationSearchShadow.layer.masksToBounds = NO;
    DestinationSearchShadow.layer.shadowColor = [UIColor blackColor].CGColor;
    DestinationSearchShadow.layer.shadowOffset = CGSizeMake(0.0f, 1.5f);
    DestinationSearchShadow.layer.shadowOpacity = 0.5f;
    DestinationSearchShadow.layer.shadowPath = shadowBox.CGPath;
    
    imgDemo.userInteractionEnabled=YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(searchresult)];
    [imgDemo addGestureRecognizer:tap];
    
}

-(void)searchresult{
    ChooseCar *registerController = [[ChooseCar alloc] initWithNibName:@"ChooseCar" bundle:nil];
    registerController.modalTransitionStyle=UIModalTransitionStyleFlipHorizontal;
    [self presentViewController:registerController animated:YES completion:nil];
}

- (IBAction)homePage:(UIButton *)sender{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    [UIView commitAnimations];
    [self dismissViewControllerAnimated:YES completion:nil];
}

// Delegate Method of TextField
-(BOOL) textFieldShouldReturn:(UITextField *)textField{
    
    [textField resignFirstResponder];
    return YES;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end*/
