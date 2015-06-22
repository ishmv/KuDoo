#import <Parse/Parse.h>

typedef void (^LMFinishedSendingRequestToUser)(BOOL sent, NSError *error);

typedef NS_ENUM(NSInteger, LMUserPicture) {
    LMUserPictureSelf           =   1,
    LMUserPictureBackground     =   2
};


typedef NS_ENUM(NSInteger, LMLanguageSelectionType) {
    LMLanguageSelectionTypeFluent1     = 0,
    LMLanguageSelectionTypeFluent2     = 1,
    LMLanguageSelectionTypeFluent3     = 2,
    LMLanguageSelectionTypeDesired     = 3
};

typedef NS_ENUM(NSInteger, LMSearchType) {
    LMSearchTypeOnline              = 0,
    LMSearchTypeUsername            = 1,
    LMSearchTypeLocation            = 2,
    LMSearchTypeFluentLanguage      = 3,
    LMSearchTypeLearningLanguage    = 4,
    LMSearchTypePairMe              = 5
};

@interface ParseConnection : NSObject

+(void) signupUser:(PFUser *)user withCompletion:(PFBooleanResultBlock)completion;
+(void) loginUser:(NSString *)username withPassword:(NSString *)password withCompletion:(PFUserResultBlock)completion;
+(void) setUserOnlineStatus:(BOOL)online;
+(void) searchForUsername:(NSString *)username withCompletion:(PFArrayResultBlock)completion;
+(void) searchForUserIds:(NSArray *)userIds withCompletion:(PFArrayResultBlock)completion;
+(void) saveUserLanguageSelection:(NSInteger)languageIndex forType:(LMLanguageSelectionType)type;
+(void) saveUserImage:(UIImage *)image forType:(LMUserPicture)pictureType;
+(void) saveUsersUsername:(NSString *)username;
+(void) saveUserLocation:(NSString *)location;
+(void) performSearchType:(LMSearchType)searchType withParameter:(NSString *)parameter withCompletion:(PFArrayResultBlock)completion;

@end