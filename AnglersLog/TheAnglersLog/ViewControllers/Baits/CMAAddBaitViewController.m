//
//  CMAAddBaitViewController.m
//  AnglersLog
//
//  Created by Cohen Adair on 11/18/14.
//  Copyright (c) 2014 Cohen Adair. All rights reserved.
//  http://www.apache.org/licenses/LICENSE-2.0
//

#import "CMAAddBaitViewController.h"
#import "CMACameraButton.h"
#import "CMACameraActionSheet.h"
#import "CMADeleteActionSheet.h"
#import "CMAImagePickerViewController.h"
#import "CMAAppDelegate.h"
#import "CMAUtilities.h"

@interface CMAAddBaitViewController ()

@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelButton;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet CMACameraButton *cameraImageButton;
@property (weak, nonatomic) IBOutlet UITextView *descriptionTextView;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *sizeTextField;
@property (weak, nonatomic) IBOutlet UITextField *colorTextField;
@property (weak, nonatomic) IBOutlet UISegmentedControl *baitTypeControl;
@property (weak, nonatomic) IBOutlet UIButton *deleteBaitButton;

@property (strong, nonatomic) CMACameraActionSheet *cameraActionSheet;
@property (strong, nonatomic) CMADeleteActionSheet *removeImageActionSheet;
@property (strong, nonatomic) CMADeleteActionSheet *deleteBaitActionSheet;

@property (strong, nonatomic) CMAImage *imageData;

@property (nonatomic) BOOL isEditingBait;
@property (nonatomic) BOOL saveImageToCameraRoll;
@property (strong, nonatomic) NSString *oldName;

@end

#define PHOTO_ROW_HEIGHT 135
#define DESC_ROW_HEIGHT 170

#define kNumberOfSectionsWithoutDelete 2

#define kSectionPhoto 1
#define kRowPhoto 0

#define kImageViewSize 100

@implementation CMAAddBaitViewController

#pragma mark - Global Accessing

- (CMAJournal *)journal {
    return [[CMAStorageManager sharedManager] sharedJournal];
}

#pragma mark - View Management

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.isEditingBait = self.previousViewID == CMAViewControllerIDSingleBait;
    
    if (self.isEditingBait) {
        self.navigationItem.title = @"Edit Bait";
        self.imageData = self.bait.imageData;
        self.oldName = self.bait.name;
    } else {
        self.bait = [[CMAStorageManager sharedManager] managedBait];
        self.oldName = nil;
    }
    
    [self initTableView];
    [self initDeleteBaitActionSheet];
    [self initCameraActionSheet];
    [self initRemoveImageActionSheet];
    [self.descriptionTextView setContentInset:UIEdgeInsetsMake(-4, -5, 4, 5)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table View Initializing

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return kNumberOfSectionsWithoutDelete + self.isEditingBait;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (self.isEditingBait && section == [tableView numberOfSections] - 1)
        return TABLE_HEIGHT_FOOTER; // there's no header for this cell
    
    return TABLE_HEIGHT_HEADER;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (section == [tableView numberOfSections] - 1)
        return TABLE_HEIGHT_FOOTER;
    
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1 && indexPath.row == 0)
        if (self.imageData)
            return PHOTO_ROW_HEIGHT;
    
    if (indexPath.section == 0 && indexPath.row == 4)
        return DESC_ROW_HEIGHT;
    
    return 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == kSectionPhoto && indexPath.row == kRowPhoto)
        [self presentViewController:self.cameraActionSheet animated:YES completion:nil];
    
    NSLog(@"Tapped");
}

- (void)initTableView {
    if (self.isEditingBait) {
        // name
        [self.nameTextField setText:self.bait.name];
        
        // size
        if (self.bait.size)
            if (![self.bait.size isEqualToString:@""])
                [self.sizeTextField setText:self.bait.size];
        
        // color
        if (self.bait.color)
            if (![self.bait.color isEqualToString:@""])
                [self.colorTextField setText:self.bait.color];
        
        // artificial
        [self.baitTypeControl setSelectedSegmentIndex:self.bait.baitType];
    
        // description
        if (self.bait.baitDescription) {
            if ([self.bait.baitDescription isEqualToString:@""])
                [self.descriptionTextView setText:@"Description"];
            else
                [self.descriptionTextView setText:self.bait.baitDescription];
        }
    }
    
    // photo
    if (self.imageData)
        [self.imageView setImage:[self.imageData image]];

    [self.cameraImageButton myInit:self action:NULL];
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
    UIImage *chosenImage = info[UIImagePickerControllerOriginalImage];
    
    // remove old image if there was one
    if (self.imageData)
        [[CMAStorageManager sharedManager] deleteManagedObject:self.imageData saveContext:YES];
    
    UIImage *scaledImage = [CMAUtilities scaleImageToScreenSize:chosenImage];
    
    CMAImage *img = [[CMAStorageManager sharedManager] managedImage];
    [img setFullImage:scaledImage];
    [self setImageData:img];
    [self setSaveImageToCameraRoll:(picker.sourceType == UIImagePickerControllerSourceTypeCamera)];
    [self.imageView setImage:[CMAUtilities imageWithImage:scaledImage scaledToSize:CGSizeMake(kImageViewSize, kImageViewSize)]];
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - Action Sheets

- (void)initDeleteBaitActionSheet {
    __weak typeof(self) weakSelf = self;
    
    self.deleteBaitActionSheet =
    [CMADeleteActionSheet alertControllerWithTitle:@"Delete Bait"
                                           message:@"Are you sure you want to delete this bait? It cannot be undone."
                                    preferredStyle:UIAlertControllerStyleActionSheet];
    
    self.deleteBaitActionSheet.deleteActionBlock = ^void(UIAlertAction *action) {
        [[weakSelf journal] removeUserDefine:UDN_BAITS objectNamed:weakSelf.bait.name];
        [weakSelf performSegueWithIdentifier:@"unwindToViewBaitsFromAddBait" sender:weakSelf];
    };
    
    [self.deleteBaitActionSheet addActions];
}

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
        [CMADeleteActionSheet alertControllerWithTitle:@"Remove Image"
                                               message:@"Are you sure you want to remove this image?"
                                        preferredStyle:UIAlertControllerStyleActionSheet];
    
    self.removeImageActionSheet.deleteActionBlock = ^void(UIAlertAction *action) {
        weakSelf.imageData = nil;
        
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
    
    NSString *newName = self.nameTextField.text;
    
    // make sure the bait name doesn't already exist
    if (![self.oldName isEqualToString:newName])
        if ([[[self journal] userDefineNamed:UDN_BAITS] objectNamed:newName] != nil) {
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
    
    // color
    if ([self.colorTextField.text isEqualToString:@""])
        [aBait setColor:nil];
    else
        [aBait setColor:self.colorTextField.text];
    
    // artificial
    [aBait setBaitType:(CMABaitType)[self.baitTypeControl selectedSegmentIndex]];
    
    // description
    if ([self.descriptionTextView.text isEqualToString:@"Description."])
        [aBait setBaitDescription:nil];
    else
        [aBait setBaitDescription:self.descriptionTextView.text];
    
    // photo
    if (self.imageData) {
        [aBait setImageData:self.imageData];
        [aBait.imageData saveWithIndex:0];
        
        if (self.saveImageToCameraRoll)
            UIImageWriteToSavedPhotosAlbum([self.imageData fullImage], nil, nil, nil);
    } else
        [aBait setImageData:nil];
    
    return YES;
}

#pragma mark - Events

- (IBAction)tapDeleteBaitButton:(UIButton *)sender {
    [self.deleteBaitActionSheet showInViewController:self];
}

- (IBAction)clickedDoneButton:(UIBarButtonItem *)sender {
    CMABait *baitToAdd = [[CMAStorageManager sharedManager] managedBait];
    
    [CMAUtilities addSceneConfirmWithObject:baitToAdd
                                  objToEdit:self.bait
                            checkInputBlock:^BOOL () { return [self checkUserInputAndSetBait:baitToAdd]; }
                             isEditingBlock:^BOOL () { return self.isEditingBait; }
                            editObjectBlock:^void () { [[self journal] editUserDefine:UDN_BAITS objectNamed:self.bait.name newProperties:baitToAdd]; }
                             addObjectBlock:^BOOL () { return [[self journal] addUserDefine:UDN_BAITS objectToAdd:baitToAdd]; }
                              errorAlertMsg:@"There was an error adding a bait. Please try again."
                             viewController:self
                                 segueBlock:^void () { [self performSegueToPreviousView]; }
                            removeObjToEdit:YES];
}

- (IBAction)clickedCancelButton:(UIBarButtonItem *)sender {
    // clean up core data
    if (!self.isEditingBait) {
        [[CMAStorageManager sharedManager] deleteManagedObject:self.bait saveContext:YES];
        self.bait = nil;
        
        if (self.imageData)
            [[CMAStorageManager sharedManager] deleteManagedObject:self.imageData saveContext:YES];
    }
    
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
