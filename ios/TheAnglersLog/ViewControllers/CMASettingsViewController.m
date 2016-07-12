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
#import "CMADataImporter.h"
#import "CMAAlertController.h"

@interface CMASettingsViewController ()

@property (weak, nonatomic) IBOutlet UIBarButtonItem *menuButton;
@property (weak, nonatomic) IBOutlet UISegmentedControl *unitsSegmentedControl;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *exportIndicator;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *importIndicator;

@property (strong, nonatomic) NSURL *archiveURL;

@end

#define kSectionFeedback 1
    #define kRowFAQ 0
    #define kRowRate 1
#define kSectionBackup 2
    #define kRowExport 0
    #define kRowImport 1
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
    
    [self.exportIndicator setAlpha:0.0];
    [self.importIndicator setAlpha:0.0];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.toolbarHidden = YES;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
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
        if (indexPath.row == kRowExport)
            [self handleExportEvent];
        
        if (indexPath.row == kRowImport)
            [self handleImportEvent];
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

- (void)backupSheetWithTitle:(NSString *)aTitle
                     message:(NSString *)aMessage
           actionButtonTitle:(NSString *)aButtonTitle
                 actionBlock:(void (^)())anActionBlock
                 cancelBlock:(void (^)())aCancelBlock
             completionBlock:(void (^)())aCompletionBlock {
    
    CMAAlertController *alert = [CMAAlertController new];
    
    alert = [alert initWithTitle:aTitle
                         message:aMessage
               actionButtonTitle:aButtonTitle
                     actionBlock:^{
                         anActionBlock();
                     }
                     cancelBlock:^{
                         aCancelBlock();
                     }];
    
    [self presentViewController:alert animated:YES completion:^(void) { aCompletionBlock(); }];
}

- (void)handleExportEvent {
    [self backupSheetWithTitle:nil
                       message:@"Exporting will not delete any of your data. This process may take several minutes."
             actionButtonTitle:@"Export"
                   actionBlock:^{
                       [self export];
                   }
                   cancelBlock:^{
                       [self hideIndicatorView:self.exportIndicator];
                   }
                   completionBlock:^{
                       [self.exportIndicator startAnimating];
                       [self showIndicatorView:self.exportIndicator];
                   }];
}

- (void)handleImportEvent {
    [self backupSheetWithTitle:nil
                       message:@"Importing will add to your current log; it will not delete anything. Conflicts are resolved in favor of the importing file. This process may take a few minutes."
             actionButtonTitle:@"Import"
                   actionBlock:^{
                       [self import];
                   }
                   cancelBlock:^{
                       [self hideIndicatorView:self.importIndicator];
                   }
               completionBlock:^{
                   [self.importIndicator startAnimating];
                   [self showIndicatorView:self.importIndicator];
               }];
}

#pragma mark - Exporting and Importing

- (void)import {
    UIDocumentMenuViewController *menuController = [[UIDocumentMenuViewController alloc] initWithDocumentTypes:@[@"com.pkware.zip-archive"] inMode:UIDocumentPickerModeImport];
    [menuController setDelegate:self];
    
    [self presentViewController:menuController animated:YES completion:nil];
}

- (void)importFromURL:(NSURL *)aURL {
    NSString *errorMsg;
    
    if (![CMADataImporter importToJournal:[self journal] fromFilePath:aURL.path error:&errorMsg])
        [CMAAlerts errorAlert:[NSString stringWithFormat:@"Error importing data: %@\n\nSee Frequently Asked Questions for details.", errorMsg] presentationViewController:self];
    else
        [CMAAlerts alertAlert:@"Data imported successfully." presentationViewController:self];
    
    [self hideIndicatorView:self.importIndicator];
}

- (void)export {
    self.archiveURL = [CMADataExporter exportJournal:[self journal]];
    
    UIDocumentMenuViewController *menuController = [[UIDocumentMenuViewController alloc] initWithURL:self.archiveURL inMode:UIDocumentPickerModeExportToService];
    [menuController setDelegate:self];
    
    // options for built in activites like messages and mail
    [menuController addOptionWithTitle:@"Other" image:nil order:UIDocumentMenuOrderFirst handler:^{
        UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:@[self.archiveURL] applicationActivities:nil];
        activityController.popoverPresentationController.sourceView = self.view;

        [activityController setCompletionWithItemsHandler:^(NSString *activityType, BOOL completed, NSArray *returnedItems, NSError *activityError) {
            if (!completed || activityError) {
                NSLog(@"Activity not completed! Deleting archive...");
                [self deleteArchiveFile];

                if (activityError)
                    [self performSelector:@selector(backupError:) withObject:[NSString stringWithFormat:@"Error exporting: %@.", activityError.localizedDescription] afterDelay:0];
            }

            [self hideIndicatorView:self.exportIndicator];
        }];

        [self presentViewController:activityController animated:YES completion:nil];
    }];
    
    [self presentViewController:menuController animated:YES completion:nil];
}

#pragma mark - Document Picker Delegate

- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentAtURL:(NSURL *)aURL {
    // exporting
    if (controller.documentPickerMode == UIDocumentPickerModeExportToService) {
        NSLog(@"Export successful, deleting archive...");
        [self deleteArchiveFile];
        [self hideIndicatorView:self.exportIndicator];
        [self performSelector:@selector(backupSuccess:) withObject:@"Data exported successfully." afterDelay:0];
    }
    
    // importing
    if (controller.documentPickerMode == UIDocumentPickerModeImport) {
        NSLog(@"Import file picked...");
        [self performSelector:@selector(importFromURL:) withObject:aURL afterDelay:0];
    }
}

- (void)documentPickerWasCancelled:(UIDocumentPickerViewController *)controller {
    // exporting
    if (controller.documentPickerMode == UIDocumentPickerModeExportToService) {
        NSLog(@"Export cancelled! Deleting archive...");
        [self deleteArchiveFile];
        [self hideIndicatorView:self.exportIndicator];
    }
    
    // importing
    if (controller.documentPickerMode == UIDocumentPickerModeImport) {
        NSLog(@"Import cancelled!");
        [self hideIndicatorView:self.importIndicator];
    }
}

- (void)documentMenu:(UIDocumentMenuViewController *)documentMenu didPickDocumentPicker:(UIDocumentPickerViewController *)documentPicker {
    // show the document picker
    [documentPicker setDelegate:self];
    [self presentViewController:documentPicker animated:YES completion:nil];
}

- (void)documentMenuWasCancelled:(UIDocumentMenuViewController *)documentMenu {
    NSLog(@"Document menu cancelled. Deleting archive...");
    [self deleteArchiveFile];
    [self hideIndicatorView:self.importIndicator];
    [self hideIndicatorView:self.exportIndicator];
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

- (void)backupError:(NSString *)msg {
    [CMAAlerts errorAlert:msg presentationViewController:self];
}

- (void)backupSuccess:(NSString *)msg {
    [CMAAlerts alertAlert:msg presentationViewController:self];
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
