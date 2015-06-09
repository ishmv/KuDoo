//
//  NSArray+LanguageOptions.h
//  LangueMatch
//
//  Created by Travis Buttaccio on 6/8/15.
//  Copyright (c) 2015 LangueMatch. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, LMLanguageSelection) {
    LMLanguageSelectionMandarin     = 1,
    LMLanguageSelectionSpanish      = 2,
    LMLanguageSelectionEnglish      = 3,
    LMLanguageSelectionHindi        = 4,
    LMLanguageSelectionArabic       = 5,
    LMLanguageSelectionPortuguese   = 6,
    LMLanguageSelectionBengali      = 7,
    LMLanguageSelectionRussian      = 8,
    LMLanguageSelectionFrench       = 9,
    LMLanguageSelectionItalian      = 10
};

typedef NS_ENUM(NSInteger, LMLanguageSelectionType) {
    LMLanguageSelectionTypeFluent1     = 0,
    LMLanguageSelectionTypeFluent2     = 1,
    LMLanguageSelectionTypeFluent3     = 2,
    LMLanguageSelectionTypeDesired     = 3
};

@interface NSArray (LanguageOptions)

+ (NSArray *) lm_languageOptionsFull;
+ (NSArray *) lm_languageOptionsEnglish;
+ (NSArray *) lm_languageOptionsNative;
+ (NSArray *) lm_countryFlagImages;

@end
