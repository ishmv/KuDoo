

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
#define     PF_USER_FLUENT_LANGUAGE             @"fluentLanguage"       //  String
#define     PF_USER_FRIENDSHIPS                 @"friendships"          //  Relations
#define     PF_USER_AVAILABILITY                @"available"            //  BOOL

/* -- Friend Requests -- */
#define     PF_FRIEND_REQUEST                   @"LMFriendRequest"      //  String
#define     PF_FRIEND_REQUEST_SENDER            @"sender"               //  String
#define     PF_FRIEND_REQUEST_RECEIVER          @"receiver"             //  String
#define     PF_FRIEND_REQUEST_ACCEPTED          @"accepted"             //  BOOL
#define     PF_FRIEND_REQUEST_DECLINED          @"declined"             //  BOOL
#define     PF_FRIEND_REQUEST_WAITING_RESPONSE  @"waiting"              //  BOOL

/* -- Chat Definitions -- */
#define		PF_CHAT_CLASS_NAME					@"LMChat"				//	Class name
#define     PF_CHAT_TITLE                       @"title"                //  Chat Title
#define		PF_CHAT_SENDER						@"sender"               //	Pointer
#define     PF_CHAT_SENDER_ID                   @"senderId"             //  String
#define     PF_CHAT_OBJECTID                    @"objectId"             //  String
#define     PF_CHAT_RECEIVER                    @"receiver"             //
#define		PF_CHAT_GROUPID						@"groupId"				//	String
#define		PF_CHAT_TEXT						@"text"					//	String
#define		PF_CHAT_PICTURE						@"picture"				//	File
#define		PF_CHAT_VIDEO						@"video"				//	File
#define		PF_CHAT_CREATEDAT					@"createdAt"			//	Date
#define		PF_CHAT_UPDATEDAT					@"updatedAt"			//	Date
#define     PF_CHAT_MEMBERS                     @"members"              //  Array
#define     PF_CHAT_MESSAGES                    @"LMMessages"           //  Array
#define     PF_CHAT_RANDOM                      @"random"               //  BOOL
#define     PF_CHAT_MESSAGECOUNT                @"messageCount"         //  Number
#define     PF_CHAT_LASTMESSAGE                 @"lastMessage"          

/* -- Group Definitions -- */
#define		PF_GROUPS_CLASS_NAME				@"Groups"				//	Class name
#define		PF_GROUPS_NAME						@"name"					//	String

/* -- Messages Definitions -- */
#define		PF_MESSAGE_CLASS_NAME				@"LMMessages"           //	Class name
#define     PF_MESSAGE_ID                       @"objectId"             //  String
#define		PF_MESSAGE_USER                     @"user"					//	Pointer to User Class
#define		PF_MESSAGE_GROUPID					@"groupId"				//	String
#define		PF_MESSAGE_DESCRIPTION				@"description"			//	String
#define		PF_MESSAGE_LASTUSER                 @"lastUser"				//	Pointer to User Class
#define		PF_MESSAGE_LASTMESSAGE				@"lastMessage"			//	String
#define		PF_MESSAGE_COUNTER					@"counter"				//	Number
#define		PF_MESSAGE_UPDATEDACTION			@"updatedAction"		//	Date
#define     PF_MESSAGE_SENDER_NAME              @"senderName"           //  String
#define     PF_MESSAGE_SENDER_ID                @"senderId"             //  NSString
#define     PF_MESSAGE_TEXT                     @"text"
#define     PF_MESSAGE_IMAGE                    @"image"
#define     PF_MESSAGE_VIDEO                    @"video"
#define     PF_MESSAGE_VOICETEXT                @"voiceText"
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

