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
#import "CMAImagePickerViewController.h"
#import "CMAAlerts.h"
#import "CMAAppDelegate.h"

@interface CMAAddBaitViewController ()

@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelButton;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet CMACameraButton *cameraImageButton;
@property (weak, nonatomic) IBOutlet UITextView *descriptionTextView;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;

@property (strong, nonatomic) CMACameraActionSheet *cameraActionSheet;

@property (nonatomic) BOOL isEditingBait;
@property (strong, nonatomic) CMABait *nonEditedBait;

@end

#define PHOTO_ROW_HEIGHT 135
#define DESC_ROW_HEIGHT 170

@implementation CMAAddBaitViewController

#pragma mark - Global Accessing

- (CMAJournal *)journal {
    return [((CMAAppDelegate *)[[UIApplication sharedApplication] delegate]) journal];
}

#pragma mark - View Management

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.cameraActionSheet = [CMACameraActionSheet withDelegate:self];
    self.isEditingBait = self.previousViewID == CMAViewControllerID_SingleBait;
    
    if (!self.isEditingBait)
        self.bait = [CMABait new];
    else {
        self.navigationItem.title = @"Edit Bait";
        self.nonEditedBait = [self.bait copy];
    }
    
    [self initTableView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table View Initializing

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0)
        return TABLE_SECTION_SPACING;
    
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return TABLE_SECTION_SPACING;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1 && indexPath.row == 0)
        if (self.bait && self.bait.image)
            return PHOTO_ROW_HEIGHT;
    
    if (indexPath.section == 0 && indexPath.row == 1)
        return DESC_ROW_HEIGHT;
    
    return 44;
}

- (void)initTableView {
    if (self.isEditingBait) {
        // name
        [self.nameTextField setText:self.bait.name];
    
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

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if ([textField.text isEqualToString:@"Name"])
        textField.text = @"";
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if ([textField.text isEqualToString:@""])
        [textField setText:@"Name"];
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

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (actionSheet == self.cameraActionSheet) {
        // take photo
        if (buttonIndex == 0)
            if ([CMAImagePickerViewController cameraAvailable])
                [self presentImagePicker:UIImagePickerControllerSourceTypeCamera];
        
        // attach photo
        if (buttonIndex == 1)
            [self presentImagePicker:UIImagePickerControllerSourceTypePhotoLibrary];
    }
}

#pragma mark - Bait Creation

- (BOOL)checkUserInputAndSetBait:(CMABait *)aBait {
    // validate bait name
    if ([self.nameTextField.text isEqualToString:@""] || [self.nameTextField.text isEqualToString:@"Name"]) {
        [CMAAlerts errorAlert:@"Please enter a bait name."];
        return NO;
    }
    
    // make sure the bait name doesn't already exist
    if (!self.isEditingBait)
        if ([[[self journal] userDefineNamed:SET_LOCATIONS] objectNamed:self.nameTextField.text] != nil) {
            [CMAAlerts errorAlert:@"A bait by that name already exists. Please choose a new name or edit the existing bait."];
            return NO;
        }
    
    [aBait setName:[self.nameTextField.text mutableCopy]];
    
    if ([self.descriptionTextView.text isEqualToString:@"Description."])
        [aBait setBaitDescription:nil];
    else
        [aBait setBaitDescription:self.descriptionTextView.text];
    
    if (self.imageView)
        [aBait setImage:self.imageView.image];
    else
        [aBait setImage:nil];
    
    return YES;
}

#pragma mark - Events

- (void)tapCameraButton {
    [self.cameraActionSheet showInView:self.view];
}

- (IBAction)clickedDoneButton:(UIBarButtonItem *)sender {
    // add new event to journal
    CMABait *baitToAdd = [CMABait new];
    
    if ([self checkUserInputAndSetBait:baitToAdd]) {
        if (self.previousViewID == CMAViewControllerID_SingleBait) {
            [[self journal] editUserDefine:SET_BAITS objectNamed:self.bait.name newProperties:baitToAdd];
            [self setBait:baitToAdd];
        } else
            [[self journal] addUserDefine:SET_BAITS objectToAdd:baitToAdd];
        
        if (!self.previousViewID == CMAViewControllerID_SingleBait)
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

#pragma mark - Navigation

- (void)performSegueToPreviousView {
    switch (self.previousViewID) {
        case CMAViewControllerID_ViewBaits:
            [self performSegueWithIdentifier:@"unwindToViewBaitsFromAddBait" sender:self];
            break;
            
        case CMAViewControllerID_SingleBait:
            [self performSegueWithIdentifier:@"unwindToSingleBaitFromAddBait" sender:self];
            break;
            
        default:
            NSLog(@"Invalid previousViewID value: %ld", self.previousViewID);
            break;
    }
}

@end
