//
//  CMAInstagramActivity.h
//  TheAnglersLog
//
//  Created by Cohen Adair on 2015-01-19.
//  Copyright (c) 2015 Cohen Adair. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CMAInstagramActivity : UIActivity <UIDocumentInteractionControllerDelegate>

@property (strong, nonatomic)UIImage *shareImage;
@property (strong, nonatomic)NSString *shareString;
@property (strong, nonatomic)UIView *presentView;

@property (nonatomic, strong)UIDocumentInteractionController *documentController;

@end
