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
#import "CMADataExporter.h"
#import "CMAAlertController.h"

@interface CMASettingsViewController ()

@property (weak, nonatomic) IBOutlet UIBarButtonItem *menuButton;
@property (weak, nonatomic) IBOutlet UISegmentedControl *unitsSegmentedControl;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *exportToCloudIndicator;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *exportToOtherIndicator;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *importFromCloudIndicator;

@property (strong, nonatomic) NSURL *archiveURL;

@end

#define kSectionFeedback 1
    #define kRowFAQ 0
    #define kRowRate 1
#define kSectionBackup 2
    #define kRowExportCloud 0
    #define kRowExportOther 1
    #define kRowImportCloud 2
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
    [self.exportToCloudIndicator setAlpha:0.0];
    [self.exportToOtherIndicator setAlpha:0.0];
    [self.importFromCloudIndicator setAlpha:0.0];
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    
    if (indexPath.section == kSectionIAP && indexPath.row == kRowRemoveAds && ![CMAAdBanner shouldDisplayBanners]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        cell.userInteractionEnabled = NO;
        cell.tintColor = [UIColor lightGrayColor];
        UILabel *label = (UILabel *)[cell viewWithTag:100];
        label.enabled = NO;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == kSectionFeedback) {
        if (indexPath.row == kRowRate)
            [self handleRateEvent];
        
        if (indexPath.row == kRowFAQ)
            [self handleFAQEvent];
    }
    
    if (indexPath.section == kSectionBackup) {
        if (indexPath.row == kRowExportCloud)
            [self handleExportCloudEvent];
        
        if (indexPath.row == kRowExportOther)
            [self handleExportOtherEvent];
        
        if (indexPath.row == kRowImportCloud)
            [self handleImportCloudEvent];
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
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:APP_STORE_LINK]];
}

- (void)handleFAQEvent {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:FAQ_LINK]];
}

- (void)handleExportEventWithBlock:(void (^)())anExportBlock cancelBlock:(void (^)())aCancelBlock completionBlock:(void (^)())aCompletionBlock {
    CMAAlertController *alert = [CMAAlertController new];
    alert = [alert initWithTitle:@"Export Data"
                         message:@"Exporting will not delete any of your data. This process may take several minutes."
               actionButtonTitle:@"Export"
                     actionBlock:anExportBlock
                     cancelBlock:aCancelBlock];
    
    [self presentViewController:alert animated:YES completion:^(void) {
        aCompletionBlock();
    }];
}

- (void)handleExportCloudEvent {
    [self handleExportEventWithBlock:
            ^(void) {
                [self documentPickerExport];
            }
            cancelBlock:^(void) {
                [self hideIndicatorView:self.exportToCloudIndicator];
            }
            completionBlock:^(void) {
                [self.exportToCloudIndicator startAnimating];
                [self showIndicatorView:self.exportToCloudIndicator];
            }];
}

- (void)handleExportOtherEvent {
    [self handleExportEventWithBlock:
         ^(void) {
             [self otherExport];
         }
         cancelBlock:^(void) {
             [self hideIndicatorView:self.exportToOtherIndicator];
         }
         completionBlock:^(void) {
             [self.exportToOtherIndicator startAnimating];
             [self showIndicatorView:self.exportToOtherIndicator];
         }];
}

- (void)handleImportCloudEvent {
    CMAAlertController *alert = [CMAAlertController new];
    alert = [alert initWithTitle:@"Import Data"
                         message:@"Exporting will not delete any of your data. This process may take several minutes."
               actionButtonTitle:@"Import"
                     actionBlock:^(void) {
                         [self importFromCloudIndicator];
                     }
                     cancelBlock:^(void) {
                         [self hideIndicatorView:self.importFromCloudIndicator];
                     }];
    
    [self presentViewController:alert animated:YES completion:^(void) {
        [self.importFromCloudIndicator startAnimating];
        [self showIndicatorView:self.importFromCloudIndicator];
    }];
}

#pragma mark - Exporting

- (void)documentPickerExport {
    self.archiveURL = [CMADataExporter exportJournal:[self journal]];
    
    UIDocumentPickerViewController *picker = [[UIDocumentPickerViewController alloc] initWithURL:self.archiveURL inMode:UIDocumentPickerModeExportToService];
    picker.delegate = self;
    picker.modalPresentationStyle = UIModalPresentationFormSheet;
    
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentAtURL:(NSURL *)url {
    if (controller.documentPickerMode == UIDocumentPickerModeExportToService) {
        NSLog(@"Export successful, deleting archive...");
        [self deleteArchiveFile];
        [self hideIndicatorView:self.exportToCloudIndicator];
    }
}

- (void)documentPickerWasCancelled:(UIDocumentPickerViewController *)controller {
    if (controller.documentPickerMode == UIDocumentPickerModeExportToService) {
        NSLog(@"Export cancelled! Deleting archive...");
        [self deleteArchiveFile];
        [self hideIndicatorView:self.exportToCloudIndicator];
    }
}

- (void)otherExport {
    self.archiveURL = [CMADataExporter exportJournal:[self journal]];
    
    UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:@[self.archiveURL] applicationActivities:nil];
    activityController.popoverPresentationController.sourceView = self.view;
   
    [activityController setCompletionWithItemsHandler:^(NSString *activityType, BOOL completed, NSArray *returnedItems, NSError *activityError) {
        if (!completed || activityError) {
            NSLog(@"Activity not completed! Deleting archive...");
            [self deleteArchiveFile];
            
            if (activityError)
                NSLog(@"Error: %@", activityError.localizedDescription);
        }
        
        [self hideIndicatorView:self.exportToOtherIndicator];
    }];
    
    [self presentViewController:activityController animated:YES completion:nil];
}

#pragma mark - Importing

- (void)importFromCloud {
    
}

#pragma mark - Hide/Show Views

- (void)showIndicatorView:(UIActivityIndicatorView *)activityIndicator {
    [UIView animateWithDuration:0.25 animations:^{
        [activityIndicator setAlpha:1.0];
    }];
}

- (void)hideIndicatorView:(UIActivityIndicatorView *)activityIndicator {
    [UIView animateWithDuration:0.25 animations:^{
        [activityIndicator setAlpha:0.0];
    }];
}

- (void)deleteArchiveFile {
    [CMAUtilities deleteFileAtPath:self.archiveURL.path];
    self.archiveURL = nil;
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
