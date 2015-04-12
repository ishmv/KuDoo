/*
 
 Uses Singleton Pattern
 These are global (application) variables
 
 */

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, LMLanguageChoice) {
    LMLanguageChoiceEnglish =   0,
    LMLanguageChoiceSpanish =   1,
    LMLanguageChoiceJapanese =  2,
    LMLanguageChoiceHindi =     3
};

typedef NS_ENUM(NSInteger, LMLanguageChoiceType) {
    LMLanguageChoiceTypeFluent =    0,
    LMLanguageChoiceTypeDesired =   1
};

@interface LMGlobalVariables : NSObject

+ (NSArray *) LMLanguageOptions;

@end
