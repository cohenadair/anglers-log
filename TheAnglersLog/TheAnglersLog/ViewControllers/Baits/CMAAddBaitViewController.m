//
//  CMAAddBaitViewController.m
//  MyFishingJournal
//
//  Created by Cohen Adair on 11/18/14.
//  Copyright (c) 2014 Cohen Adair. All rights reserved.
//

#import "CMAAddBaitViewController.h"
#import "CMACameraButton.h"
#import "CMACameraActionSheet.h"
#import "CMARemoveImageActionSheet.h"
#import "CMAImagePickerViewController.h"
#import "CMAAlerts.h"
#import "CMAAppDelegate.h"
#import "CMAStorageManager.h"

@interface CMAAddBaitViewController ()

@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelButton;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet CMACameraButton *cameraImageButton;
@property (weak, nonatomic) IBOutlet UITextView *descriptionTextView;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *sizeTextField;
@property (weak, nonatomic) IBOutlet UISegmentedControl *baitTypeControl;

@property (strong, nonatomic) CMACameraActionSheet *cameraActionSheet;
@property (strong, nonatomic) CMARemoveImageActionSheet *removeImageActionSheet;

@property (nonatomic) BOOL isEditingBait;
@property (strong, nonatomic) CMABait *nonEditedBait;

@end

#define PHOTO_ROW_HEIGHT 135
#define DESC_ROW_HEIGHT 170

@implementation CMAAddBaitViewController

#pragma mark - Global Accessing

- (CMAJournal *)journal {
    return [[CMAStorageManager sharedManager] sharedJournal];
}

#pragma mark - View Management

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.isEditingBait = self.previousViewID == CMAViewControllerIDSingleBait;
    
    if (!self.isEditingBait)
        self.bait = [CMABait new];
    else {
        self.navigationItem.title = @"Edit Bait";
        self.nonEditedBait = self.bait;
        self.bait = [self.nonEditedBait copy];
    }
    
    [self initTableView];
    [self initCameraActionSheet];
    [self initRemoveImageActionSheet];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table View Initializing

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return kTableSectionHeaderHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (section == [tableView numberOfSections] - 1)
        return kTableFooterHeight;
    
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1 && indexPath.row == 0)
        if (self.bait && self.bait.image)
            return PHOTO_ROW_HEIGHT;
    
    if (indexPath.section == 0 && indexPath.row == 3)
        return DESC_ROW_HEIGHT;
    
    return 44;
}

- (void)initTableView {
    if (self.isEditingBait) {
        // name
        [self.nameTextField setText:self.bait.name];
        
        // size
        if (self.bait.size)
            if (![self.bait.size isEqualToString:@""])
                [self.sizeTextField setText:self.bait.size];
        
        // artificial
        [self.baitTypeControl setSelectedSegmentIndex:[self.bait.baitType integerValue]];
    
        // description
        if (self.bait.baitDescription) {
            if ([self.bait.baitDescription isEqualToString:@""])
                [self.descriptionTextView setText:@"Description"];
            else
                [self.descriptionTextView setText:self.bait.baitDescription];
        }
    }
    
    // photo
    if (self.bait.image)
        [self.imageView setImage:self.bait.image];

    [self.cameraImageButton myInit:self action:@selector(tapCameraButton)];
}

#pragma mark - Text View Initializing

- (void)textViewDidBeginEditing:(UITextView *)textView {
    if ([textView.text isEqualToString:@"Description."])
        [textView setText:@""];
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    if ([textView.text isEqualToString:@""])
        [textView setText:@"Description."];
}

#pragma mark - Image Picker

// Presents an image picker with sourceType.
- (void)presentImagePicker:(UIImagePickerControllerSourceType)sourceType {
    CMAImagePickerViewController *imagePicker = [CMAImagePickerViewController new];
    
    [imagePicker setDelegate:self];
    [imagePicker setSourceType:sourceType];
    
    [self presentViewController:imagePicker animated:YES completion:NULL];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    
    [self.bait setImage:chosenImage];
    [self.tableView reloadData];
    [self.bait setName:self.nameTextField.text];
    [self.bait setBaitDescription:self.descriptionTextView.text];
    [self initTableView];
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - Action Sheets

- (void)initCameraActionSheet {
    __weak id weakSelf = self;
    
    self.cameraActionSheet =
        [CMACameraActionSheet alertControllerWithTitle:nil
                                               message:nil
                                        preferredStyle:UIAlertControllerStyleActionSheet];
    
    self.cameraActionSheet.attachPhotoBlock = ^void(UIAlertAction *action) {
        [weakSelf presentImagePicker:UIImagePickerControllerSourceTypePhotoLibrary];
    };
    
    self.cameraActionSheet.takePhotoBlock = ^void(UIAlertAction *action) {
        if ([CMAImagePickerViewController cameraAvailable:weakSelf])
            [weakSelf presentImagePicker:UIImagePickerControllerSourceTypeCamera];
    };
    
    [self.cameraActionSheet addActions];
}

- (void)initRemoveImageActionSheet {
    __weak typeof(self) weakSelf = self;
    
    self.removeImageActionSheet =
        [CMARemoveImageActionSheet alertControllerWithTitle:nil
                                                    message:nil
                                             preferredStyle:UIAlertControllerStyleActionSheet];
    
    self.removeImageActionSheet.deleteActionBlock = ^void(UIAlertAction *action) {
        weakSelf.bait.image = nil;
        
        // Why CATransaction is used: http://stackoverflow.com/questions/7623771/how-to-detect-that-animation-has-ended-on-uitableview-beginupdates-endupdates
        [CATransaction begin];
        [CATransaction setCompletionBlock:^{
            [weakSelf.imageView setImage:nil];
        }];
        
        [UIView animateWithDuration:0.15 animations:^{
            [weakSelf.imageView setAlpha:0.0f];
        }];
        
        [weakSelf.tableView beginUpdates];
        [weakSelf.tableView endUpdates];
        
        [CATransaction commit];
    };
    
    [self.removeImageActionSheet addActions];
}

#pragma mark - Bait Creation

- (BOOL)checkUserInputAndSetBait:(CMABait *)aBait {
    // validate bait name
    if ([self.nameTextField.text isEqualToString:@""] || [self.nameTextField.text isEqualToString:@"Name"]) {
        [CMAAlerts errorAlert:@"Please enter a bait name." presentationViewController:self];
        return NO;
    }
    
    // make sure the bait name doesn't already exist
    if (!self.isEditingBait)
        if ([[[self journal] userDefineNamed:UDN_LOCATIONS] objectNamed:self.nameTextField.text] != nil) {
            [CMAAlerts errorAlert:@"A bait by that name already exists. Please choose a new name or edit the existing bait." presentationViewController:self];
            return NO;
        }
    
    // name
    [aBait setName:[self.nameTextField.text mutableCopy]];
    
    // size
    if ([self.sizeTextField.text isEqualToString:@""])
        [aBait setSize:nil];
    else
        [aBait setSize:self.sizeTextField.text];
    
    // artificial
    [aBait setBaitType:[NSNumber numberWithInteger:self.baitTypeControl.selectedSegmentIndex]];
    
    // description
    if ([self.descriptionTextView.text isEqualToString:@"Description."])
        [aBait setBaitDescription:nil];
    else
        [aBait setBaitDescription:self.descriptionTextView.text];
    
    // photo
    if (self.imageView)
        [aBait setImage:self.imageView.image];
    else
        [aBait setImage:nil];
    
    return YES;
}

#pragma mark - Events

- (void)tapCameraButton {
    [self presentViewController:self.cameraActionSheet animated:YES completion:nil];
}

- (IBAction)clickedDoneButton:(UIBarButtonItem *)sender {
    // add new event to journal
    CMABait *baitToAdd = [CMABait new];
    
    if ([self checkUserInputAndSetBait:baitToAdd]) {
        if (self.previousViewID == CMAViewControllerIDSingleBait) {
            [[self journal] editUserDefine:UDN_BAITS objectNamed:self.bait.name newProperties:baitToAdd];
        } else
            [[self journal] addUserDefine:UDN_BAITS objectToAdd:baitToAdd];
        
        if (!(self.previousViewID == CMAViewControllerIDSingleBait))
            [self setBait:nil];
        
        [[self journal] archive];
        [self performSegueToPreviousView];
    }
}

- (IBAction)clickedCancelButton:(UIBarButtonItem *)sender {
    self.bait = self.nonEditedBait;
    self.nonEditedBait = nil;
    
    if (!self.isEditingBait)
        self.bait = nil;
    
    [self performSegueToPreviousView];
}

- (IBAction)longPressedImage:(UILongPressGestureRecognizer *)sender {
    // only show at the beginning of the gesture
    if (sender.state == UIGestureRecognizerStateBegan)
        [self presentViewController:self.removeImageActionSheet animated:YES completion:nil];
}

#pragma mark - Navigation

- (void)performSegueToPreviousView {
    switch (self.previousViewID) {
        case CMAViewControllerIDViewBaits:
            [self performSegueWithIdentifier:@"unwindToViewBaitsFromAddBait" sender:self];
            break;
            
        case CMAViewControllerIDSingleBait:
            [self performSegueWithIdentifier:@"unwindToSingleBaitFromAddBait" sender:self];
            break;
            
        default:
            NSLog(@"Invalid previousViewID value: %ld", (long)self.previousViewID);
            break;
    }
}

@end
