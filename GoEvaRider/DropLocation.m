//
//  DropLocation.m
//  GoEvaRider
//
//  Created by Kalyan Mohan Paul on 6/30/17.
//  Copyright © 2017 Kalyan Paul. All rights reserved.
//

#import "DropLocation.h"
#import "ChooseCar.h"

#if !defined(__has_feature) || !__has_feature(objc_arc)
#error "This file requires ARC support."
#endif

#import <GooglePlaces/GooglePlaces.h>

@interface DropLocation () <UITextFieldDelegate,GMSAutocompleteTableDataSourceDelegate>

@end

@implementation DropLocation {
    
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
    _searchField.placeholder = NSLocalizedString(@"Demo.Content.Autocomplete.EnterDropLocation",
                                                 @"Prompt to enter text for Drop Location");
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
    _tableDataSource.autocompleteFilter.type = kGMSPlacesAutocompleteTypeFilterAddress;
    _tableDataSource.autocompleteFilter.country=@"IN";
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

#pragma mark - GMSAutocompleteTableDataSourceDelegate

- (void)tableDataSource:(GMSAutocompleteTableDataSource *)tableDataSource
didAutocompleteWithPlace:(GMSPlace *)place {
    [_searchField resignFirstResponder];
    //[self autocompleteDidSelectPlace:place];
    _searchField.text = place.formattedAddress;
    
    [delegate sendDatafromDropToDashboard:place];
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    [UIView commitAnimations];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)tableDataSource:(GMSAutocompleteTableDataSource *)tableDataSource
didFailAutocompleteWithError:(NSError *)error {
    [_searchField resignFirstResponder];
    [self autocompleteDidFail:error];
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

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    //[delegate sendDataBackToHomepage:@"0"];
}

@end
