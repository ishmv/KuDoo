//
//  LMUserViewModel.m
//  LangueMatch
//
//  Created by Travis Buttaccio on 6/14/15.
//  Copyright (c) 2015 LangueMatch. All rights reserved.
//

#import "LMUserViewModel.h"
#import "AppConstant.h"
#import "NSArray+LanguageOptions.h"
#import "NSString+Chats.h"

#import "ParseConnection.h"

typedef void (^LMIndexBlock)(NSInteger idx);

@interface LMUserViewModel()

@property(copy, nonatomic, readwrite) NSString *fluentLanguageString;
@property(copy, nonatomic, readwrite) NSString *desiredLanguageString;
@property(copy, nonatomic, readwrite) NSString *bioString;
@property(copy, nonatomic, readwrite) NSString *locationString;
@property(copy, nonatomic, readwrite) NSString *memberSinceString;

@property(strong, nonatomic, readwrite) UIImage *fluentImage;
@property(strong, nonatomic, readwrite) UIImage *desiredImage;

@end

@implementation LMUserViewModel

-(instancetype) initWithUser:(PFUser *)user
{
    if (self = [super init]) {
        _user = user;
        [self reloadData];
    }
    return self;
}

-(void) reloadData
{
    __block NSMutableString *fluentString;
    
    NSString *fluent1 = _user[PF_USER_FLUENT_LANGUAGE];
    NSString *fluent2 = _user[PF_USER_FLUENT_LANGUAGE2];
    NSString *fluent3 = _user[PF_USER_FLUENT_LANGUAGE3];
    
    [self p_getIndexForLanguage:fluent1 withCompletion:^(NSInteger idx) {
        NSString *nativeFluent1 = [NSArray lm_languageOptionsNative][idx];
        fluentString = [[NSMutableString alloc] initWithFormat:NSLocalizedString(@"Fluent in %@", @"Fluent in %@"), nativeFluent1];
        self.fluentImage = [NSArray lm_countryFlagImages][idx];
        self.fluentLanguageString = [fluentString copy];
    }];
    
    if (fluent2.length != 0) {
        
        [self p_getIndexForLanguage:fluent2 withCompletion:^(NSInteger idx) {
            [fluentString appendFormat:@", %@", [NSArray lm_languageOptionsNative][idx]];
            self.fluentLanguageString = [fluentString copy];
        }];
        
    } if (fluent3.length != 0) {
        
        [self p_getIndexForLanguage:fluent3 withCompletion:^(NSInteger idx) {
            [fluentString appendFormat:@", %@", [NSArray lm_languageOptionsNative][idx]];
            self.fluentLanguageString = [fluentString copy];
        }];
    }
    
    NSString *desiredLanguage = _user[PF_USER_DESIRED_LANGUAGE];
    
    [self p_getIndexForLanguage:desiredLanguage withCompletion:^(NSInteger idx) {
        self.desiredLanguageString = [NSString stringWithFormat:NSLocalizedString(@"Learning %@","Learning %@"), [NSArray lm_languageOptionsNative][idx]];
        self.desiredImage = [NSArray lm_countryFlagImages][idx];
    }];
    
    NSDate *date = _user.createdAt;
    self.memberSinceString = [NSString stringWithFormat:NSLocalizedString(@"Joined %@", @"Joined %@"), [NSString lm_dateToStringShortDateOnly:date]];
    self.locationString = (_user[PF_USER_LOCATION]) ? [NSString stringWithFormat:NSLocalizedString(@"%@", @"%@"), _user[PF_USER_LOCATION]] : NSLocalizedString(@"Somewhere over there", @"Somewhere over there");
    self.bioString = (_user[PF_USER_BIO]) ?: NSLocalizedString(@"Nothing yet", @"Nothing yet");
}


-(void) p_getIndexForLanguage:(NSString *)language withCompletion:(LMIndexBlock)completion
{
    [[NSArray lm_languageOptionsEnglish] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *compare = (NSString *)obj;
        NSComparisonResult result = [language caseInsensitiveCompare:compare];
        if (result == NSOrderedSame) {
            completion(idx);
            *stop = YES;
        }
    }];
}

@end
