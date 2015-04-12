

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
#define     PF_USER_DESIRED_LANGUAGE            @"desiredLanguage"      //  String
#define     PF_USER_FLUENT_LANGUAGE             @"fluentLanguage"       //  String
#define     PF_USER_FRIENDS                     @"friends"              //  Array

/* -- Chat Definitions -- */
#define		PF_CHAT_CLASS_NAME					@"LMChat"				//	Class name
#define     PF_CHAT_TITLE                       @"title"                //  Chat Title
#define		PF_CHAT_SENDER						@"sender"               //	Pointer to User Class
#define     PF_CHAT_RECEIVER                    @"receiver"             //
#define		PF_CHAT_GROUPID						@"groupId"				//	String
#define		PF_CHAT_TEXT						@"text"					//	String
#define		PF_CHAT_PICTURE						@"picture"				//	File
#define		PF_CHAT_VIDEO						@"video"				//	File
#define		PF_CHAT_CREATEDAT					@"createdAt"			//	Date
#define		PF_CHAT_UPDATEDAT					@"updatedAt"			//	Date
#define     PF_CHAT_MEMBERS                     @"members"              //  Array
#define     PF_CHAT_MESSAGES                    @"messages"             //  Array
#define     PF_CHAT_RANDOM                      @"random"               //  BOOL

/* -- Group Definitions -- */
#define		PF_GROUPS_CLASS_NAME				@"Groups"				//	Class name
#define		PF_GROUPS_NAME						@"name"					//	String

/* -- Messages Definitions -- */
#define		PF_MESSAGES_CLASS_NAME				@"LMMessages"           //	Class name
#define		PF_MESSAGES_USER					@"user"					//	Pointer to User Class
#define		PF_MESSAGES_GROUPID					@"groupId"				//	String
#define		PF_MESSAGES_DESCRIPTION				@"description"			//	String
#define		PF_MESSAGES_LASTUSER				@"lastUser"				//	Pointer to User Class
#define		PF_MESSAGES_LASTMESSAGE				@"lastMessage"			//	String
#define		PF_MESSAGES_COUNTER					@"counter"				//	Number
#define		PF_MESSAGES_UPDATEDACTION			@"updatedAction"		//	Date
#define     PF_MESSAGE_SENDER_NAME              @"senderName"           //  String
#define     PF_MESSAGE_SENDER_ID                @"senderId"             // NSString

/* -- Notification Definitions -- */
#define		NOTIFICATION_APP_STARTED			@"NCAppStarted"
#define		NOTIFICATION_USER_LOGGED_IN			@"NCUserLoggedIn"
#define		NOTIFICATION_USER_LOGGED_OUT		@"NCUserLoggedOut"
#define     NOTIFICATION_START_CHAT             @"LMInitiateChatNotification" // String

