//
//  LMAlertControllers.m
//  LangueMatch
//
//  Created by Travis Buttaccio on 4/11/15.
//  Copyright (c) 2015 LangueMatch. All rights reserved.
//

#import "LMAlertControllers.h"
#import "NSArray+LanguageOptions.h"
#import "AppConstant.h"

@implementation LMAlertControllers

+(UIAlertController *) chooseLanguageAlertWithCompletionHandler:(LMCompletedWithLanguageSelection)completion
{
    UIAlertController *languageSelectorAlert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Choose a language", @"Choose a language")
                                                                                   message:nil
                                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    NSArray *languages = [NSArray lm_languageOptionsFull];
    
    NSMutableArray *actions = [NSMutableArray new];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    [actions addObject:cancelAction];
    
    for (int i = 0; i < [languages count]; i++) {
        UIAlertAction *languageOption = [UIAlertAction actionWithTitle:languages[i] style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            completion(i);
        }];
        [actions addObject:languageOption];
    }
    
    for (UIAlertAction *alert in actions) {
        [languageSelectorAlert addAction:alert];
    }
    
    
    return languageSelectorAlert;
}


+(UIAlertController *) changeUsernameAlertWithCompletion:(LMCompletedWithUsername)completion
{
    UIAlertController *changeUsernameAlert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Change User Name", @"Change User Name") message:NSLocalizedString(@"Change User Name", @"Change User Name") preferredStyle:UIAlertControllerStyleAlert];
    
    
    
    [changeUsernameAlert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"Username";
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *changeAction = [UIAlertAction actionWithTitle:@"Change" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        UITextField *newUsernameTextField = changeUsernameAlert.textFields[0];
        NSString *newUsername = newUsernameTextField.text;
        completion(newUsername);
    }];
    
    [changeUsernameAlert addAction:cancelAction];
    [changeUsernameAlert addAction:changeAction];
    
    return changeUsernameAlert;
}

+(UIAlertController *) choosePictureSourceAlertWithCompletion:(LMCompletedWithSourceType)completion
{
    UIAlertController *pictureSourceTypeAlert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Choose Source", @"Choose Source") message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel",@"Cancel") style:UIAlertActionStyleCancel handler:nil];
    
    UIAlertAction *fromLibraryAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Photo Library",@"Photo Library") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        completion(UIImagePickerControllerSourceTypePhotoLibrary);
    }];
    
    UIAlertAction *takePictureAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Camera",@"Camera") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        completion(UIImagePickerControllerSourceTypeCamera);
    }];
    
    for (UIAlertAction *action in @[cancelAction, fromLibraryAction, takePictureAction]) {
        [pictureSourceTypeAlert addAction:action];
    }
    
    return pictureSourceTypeAlert;
}

+(UIAlertController *) chooseCameraSourceAlertWithCompletion:(LMCompletedWithSourceType)completion
{
    UIAlertController *pictureSourceTypeAlert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Choose Source", @"Choose Source") message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel",@"Cancel") style:UIAlertActionStyleCancel handler:nil];
    
    UIAlertAction *fromLibraryAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Photo Library",@"Photo Library") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        completion(UIImagePickerControllerSourceTypePhotoLibrary);
    }];
    
    UIAlertAction *takePictureAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Camera",@"Camera") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        completion(UIImagePickerControllerSourceTypeCamera);
    }];
    
    UIAlertAction *takeVideoAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Video",@"Video") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        completion(UIImagePickerControllerCameraCaptureModeVideo);
    }];
    
    for (UIAlertAction *action in @[cancelAction, fromLibraryAction, takePictureAction, takeVideoAction]) {
        [pictureSourceTypeAlert addAction:action];
    }
    
    return pictureSourceTypeAlert;
}


@end
