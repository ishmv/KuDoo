#import <Foundation/Foundation.h>

/* -- Installation Definitions -- */

#define		PF_INSTALLATION_CLASS_NAME			@"_Installation"		//	Class name
#define		PF_INSTALLATION_OBJECTID			@"objectId"				//	String
#define		PF_INSTALLATION_USER				@"user"					//	Pointer to User Class

/* -- User Definitions -- */
#define		PF_USER_CLASS_NAME					@"_User"				//	Class name
#define		PF_USER_OBJECTID					@"objectId"				//	String
#define		PF_USER_USERNAME					@"username"				//	String
#define     PF_USER_USERNAME_LOWERCASE          @"username_lower"       //  String
#define		PF_USER_PASSWORD					@"password"				//	String
#define		PF_USER_EMAIL						@"email"				//	String
#define		PF_USER_EMAILCOPY					@"emailCopy"			//	String
#define		PF_USER_FULLNAME					@"fullname"				//	String
#define		PF_USER_FULLNAME_LOWER				@"fullname_lower"		//	String
#define		PF_USER_FACEBOOKID					@"facebookId"			//	String
#define		PF_USER_PICTURE						@"picture"				//	File
#define		PF_USER_THUMBNAIL					@"thumbnail"			//	File
#define     PF_USER_BACKGROUND_PICTURE          @"backgroundPicture"    //  File
#define     PF_USER_DESIRED_LANGUAGE            @"desiredLanguage"      //  String
#define     PF_USER_FLUENT_LANGUAGE             @"nativeLanguage"       //  String
#define     PF_USER_FLUENT_LANGUAGE2            @"fluentLanguage2"      //  String
#define     PF_USER_FLUENT_LANGUAGE3            @"fluentLanguage3"      //  String
#define     PF_USER_FRIENDSHIPS                 @"friendships"          //  Relations
#define     PF_USER_LOCATION                    @"location"             //  String
#define     PF_USER_ONLINE                      @"online"               //  BOOL


/* -- Group Definitions -- */
#define		PF_GROUPS_CLASS_NAME				@"Groups"				//	Class name
#define		PF_GROUPS_NAME						@"name"					//	String

/* -- Messages Definitions -- */
#define		PF_MESSAGE_CLASS_NAME				@"LMMessages"           //	Class name
#define		PF_MESSAGE_GROUPID                  @"groupId"				//	String
#define		PF_MESSAGE_DESCRIPTION				@"description"			//	String
#define     PF_MESSAGE_SENDER_NAME              @"senderName"           //  String
#define     PF_MESSAGE_SENDER_ID                @"senderId"             //  String
#define     PF_MESSAGE_TEXT                     @"text"                 //  String
#define     PF_MESSAGE_IMAGE                    @"image"                //  File
#define     PF_MESSAGE_VIDEO                    @"video"                //  String
#define     PF_MESSAGE_TIMESENT                 @"date"                 //  Date
#define     PF_MESSAGE_AUDIO                    @"audio"                //  File

/* -- Notification Definitions -- */
#define		NOTIFICATION_APP_STARTED			@"NCAppStarted"
#define     NOTIFICATION_RECEIVED_NEW_MESSAGE   @"RNReceivedMessage"
#define     NOTIFICATION_RECEIVED_NEW_CHAT      @"NCReceivedChat"
#define		NOTIFICATION_USER_LOGGED_IN			@"NCUserLoggedIn"
#define		NOTIFICATION_USER_LOGGED_OUT		@"NCUserLoggedOut"
#define     NOTIFICATION_START_CHAT             @"LMInitiateChatNotification" // String
#define     NOTIFICATION_FRIEND_REQUEST         @"RNFriendRequest"
#define     NOTIFICATION_USER_TYPING            @"NCUserTyping"
#define     NOTIFICATION_SEND_CHAT_REQUEST      @"NCSendChatRequest"


typedef NS_ENUM(uint8_t, LMChatType) {
    LMChatTypeFriend            =   0,
    LMChatTypeGroup             =   1,
    LMChatTypeRandom            =   2
};

typedef NS_ENUM(uint8_t, LMRequestType) {
    LMRequestTypeChat           =   0,
    LMRequestTypeFriend         =   1,
    LMRequestTypeReportUser     =   2
};