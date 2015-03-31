//
//  CMASettingsViewController.m
//  AnglersLog
//
//  Created by Cohen Adair on 10/16/14.
//  Copyright (c) 2014 Cohen Adair. All rights reserved.
//  http://www.apache.org/licenses/LICENSE-2.0
//

#import <StoreKit/StoreKit.h>
#import "CMASettingsViewController.h"
#import "CMAAppDelegate.h"
#import "SWRevealViewController.h"
#import "CMAAlerts.h"
#import "CMAStorageManager.h"
#import "CMAUtilities.h"
#import "CMAAdBanner.h"

@interface CMASettingsViewController ()

@property (weak, nonatomic) IBOutlet UIBarButtonItem *menuButton;
@property (weak, nonatomic) IBOutlet UISegmentedControl *unitsSegmentedControl;

@end

#define kSectionFeedback 1
    #define kRowRate 0
#define kSectionIAP 3
    #define kRowRestore 0
    #define kRowRemoveAds 1

@implementation CMASettingsViewController

#pragma mark - Global Accessing

- (CMAJournal *)journal {
    return [[CMAStorageManager sharedManager] sharedJournal];
}

#pragma mark - Side Bar Navigation

- (void)initSideBarMenu {
    [self.menuButton setTarget:self.revealViewController];
    [self.menuButton setAction:@selector(revealToggle:)];
    
    [self.view addGestureRecognizer:self.revealViewController.tapGestureRecognizer];
}

#pragma mark - View Management

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initSideBarMenu];
    [self.unitsSegmentedControl setSelectedSegmentIndex:[self journal].measurementSystem];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.toolbarHidden = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table View Initializing

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return TABLE_HEIGHT_HEADER;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == kSectionIAP)
        return 1 + [CMAAdBanner shouldDisplayBanners];
    
    return [super tableView:tableView numberOfRowsInSection:section];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == kSectionFeedback) {
        if (indexPath.row == kRowRate)
            [self handleRateEvent];
    }
    
    if (indexPath.section == kSectionIAP) {
        if (indexPath.row == kRowRemoveAds)
            [self handleRemoveAdsEvent];
        
        if (indexPath.row == kRowRestore)
            [self handleRestoreEvent];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Events

- (IBAction)clickUnitsSegmentedControl:(UISegmentedControl *)sender {
    [[self journal] setMeasurementSystem:(CMAMeasuringSystemType)[sender selectedSegmentIndex]];
    [[self journal] archive];
}

- (void)handleRateEvent {
    [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:kRowRate inSection:kSectionFeedback] animated:YES scrollPosition:UITableViewScrollPositionNone];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:APP_STORE_LINK]];
}

#pragma mark - In-App Purchases

#define kRemoveAdsID @"com.cohenadair.theanglerslog.removeads"

- (void)handleRemoveAdsEvent {
    NSLog(@"User requests to remove ads.");
    
    // make sure the user has sufficient privledges to make payments
    if ([SKPaymentQueue canMakePayments]) {
        SKProductsRequest *r = [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithObject:kRemoveAdsID]];
        [r setDelegate:self];
        [r start];
    } else
        NSLog(@"User does not have permission to make payments.");
}

- (void)handleRestoreEvent {
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

- (void)doRemoveAds {
    [CMAAdBanner setShouldDisplayBanners:NO];
    [self.tableView reloadData];
}

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    if ([response.products count] > 0) {
        NSLog(@"Products are available.");
        SKProduct *p = [response.products objectAtIndex:0];
        [self purchase:p];
    } else
        NSLog(@"Invalid product ID.");
}

- (void)purchase:(SKProduct *)product {
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    [[SKPaymentQueue defaultQueue] addPayment:[SKPayment paymentWithProduct:product]];
}

- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue {
    NSInteger numberOfPreviousPurchases = queue.transactions.count;
    NSLog(@"Number of previous purchanges: %li.", (long)numberOfPreviousPurchases);
    
    if (numberOfPreviousPurchases <= 0) {
        [CMAAlerts errorAlert:@"You have no previous purchases to restore." presentationViewController:self];
        return;
    }
    
    for (SKPaymentTransaction *t in queue.transactions){
        if (t.transactionState == SKPaymentTransactionStateRestored) {
            NSLog(@"Transactions restored.");
            [[SKPaymentQueue defaultQueue] finishTransaction:t];
            break;
        }
    }   
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions {
    for (SKPaymentTransaction *t in transactions) {
        switch (t.transactionState) {
            case SKPaymentTransactionStatePurchasing: // when the user is in the process of purchasing
                NSLog(@"Purchasing...");
                break;
                
            case SKPaymentTransactionStatePurchased: // when the user has successfully purchased
                NSLog(@"Purchased.");
                [self doRemoveAds];
                [[SKPaymentQueue defaultQueue] finishTransaction:t];
                break;
                
            case SKPaymentTransactionStateRestored: // when the user restores previous purchases
                NSLog(@"Restored purchases.");
                [self doRemoveAds];
                [CMAAlerts alertAlert:@"Your purchases have been restored." presentationViewController:self];
                [[SKPaymentQueue defaultQueue] finishTransaction:t];
                break;
                
            case SKPaymentTransactionStateFailed: // if a transaction fails
                NSLog(@"Error in trasaction: %@.", t.error.localizedDescription);
                [[SKPaymentQueue defaultQueue] finishTransaction:t];
                break;
                
            case SKPaymentTransactionStateDeferred: // final state is pending external action
                break;
                
            default:
                NSLog(@"Invalid transaction state in paymentQueue:updatedTransactions:");
        }
    }
}

@end
