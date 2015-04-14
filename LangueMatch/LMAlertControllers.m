//
//  LMAlertControllers.m
//  LangueMatch
//
//  Created by Travis Buttaccio on 4/11/15.
//  Copyright (c) 2015 LangueMatch. All rights reserved.
//

#import "LMAlertControllers.h"
#import "LMGlobalVariables.h"
#import "AppConstant.h"

@implementation LMAlertControllers

+(UIAlertController *) chooseLanguageAlertWithCompletionHandler:(LMCompletedWithLanguageSelection)completion
{
    UIAlertController *languageSelectorAlert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Choose a language", @"Choose a language")
                                                                                   message:nil
                                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    NSArray *languages = [LMGlobalVariables LMLanguageOptions];
    
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
    UIAlertController *pictureSourceTypeAlert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"From Where?", @"From Where?") message:NSLocalizedString(@"Choose location", @"Choose location") preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    
    UIAlertAction *fromLibraryAction = [UIAlertAction actionWithTitle:@"From Photo Library" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        completion(UIImagePickerControllerSourceTypePhotoLibrary);
    }];
    
    UIAlertAction *takePictureAction = [UIAlertAction actionWithTitle:@"Take Picture" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        completion(UIImagePickerControllerSourceTypeCamera);
    }];
    
    for (UIAlertAction *action in @[cancelAction, fromLibraryAction, takePictureAction]) {
        [pictureSourceTypeAlert addAction:action];
    }
    
    return pictureSourceTypeAlert;
    
}

+(UIAlertController *) chooseChatTypeAlertWithCompletion:(LMCompletedWithChatType)completion
{
    UIAlertController *chatTypeAlert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Choose Chat Type", @"Choose Chat Type") message:NSLocalizedString(@"Language Match can pair you with someone fluent in your desired language. Choose Random LangueMatch User below", @"Language Match can pair you with someone fluent in your desired language. Choose Random LangueMatch User below") preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    
    UIAlertAction *friendChatAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"From Friend List", @"From Friend List") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        completion(LMChatTypeFriend);
    }];
    
    UIAlertAction *groupChatAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Start Group Chat", @"Start Group Chat") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        completion(LMChatTypeGroup);
    }];
    
    UIAlertAction *randomUserAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Random LangueMatch User", @"Random LangueMatch User") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        completion(LMChatTypeRandom);
    }];
    
    for (UIAlertAction *action in @[cancelAction, friendChatAction, groupChatAction, randomUserAction]) {
        [chatTypeAlert addAction:action];
    }
    
    return chatTypeAlert;
}
@end
