# KuDoo
This is the capstone project I built for my Bloc apprenticeship.

#### Usage
KuDoo's aim is to provide low-stress, real-time chat environment for language learners around the world.
On top of being a general purpose chat application, KuDoo adds in language pairing through user search which can filter for username, location, learning and native languages: browse, chat and learn.

#### Technologies
 - Firebase for real-time chat (See when users are in chat room and typing)
 - Parse to handle user base
 - Parse for storing media messages (audio, video and pictures)
 - Parse for push notifications (for new messages)
 - NSKeyedArchiving is used for persisting personal messages across application launches
 - [JSQMessages](https://github.com/jessesquires/JSQMessagesViewController) for chat UI
 - [AFNetworking](https://github.com/AFNetworking/AFNetworking) for saving and retrieving media messages
 - [IDMPhotoBrowser](https://github.com/ideaismobile/IDMPhotoBrowser) for displaying photos in chat window
 - [MBProgressHUD](https://github.com/jdg/MBProgressHUD) Used for displaying progress/errors to user
 - Login with facebook or twitter

#### Features
Signup and Forum Chat:
  - Realtime chat room for all supported languages
  - Current language list: Mandarin, Spanish, English, Hindi, Arabic, Portuguese, Russian, Japanese, German, Korean, French,        Italian
  - Sign in using Facebook or Twitter, or create your own KuDoo account

<img src="https://cloud.githubusercontent.com/assets/10274826/8628121/e08ad5f0-2715-11e5-885f-a291bcaeeac4.png" width="300" height=300"/> <img src="https://cloud.githubusercontent.com/assets/10274826/8660178/f26b6594-2974-11e5-9b92-c90e1a3f5bc5.png" width="300" height=300"/> 

Realtime Chat and User Profile:
 - Add profile picture
 - Add background picture
 - Specify up to three fluent languages
 - Choose a learning language
 - Send picture, text, video and audio messages
 - Configure your chat background view
 - Receive notifications when receiving private messages

<img src="https://cloud.githubusercontent.com/assets/10274826/8587874/5977cdfa-25c8-11e5-9faf-2e88fd286db9.png" width="300" height=300"/> <img src="https://cloud.githubusercontent.com/assets/10274826/8641530/97e1f61c-28dc-11e5-8f60-3760447ca105.png" width="300" height=300"/> 

Online users
 - Search and chat with other language learners
 - Filter searches by username, desired and learning language, location
 - Get paired with another learner
 - View other learner profile details

<img src="https://cloud.githubusercontent.com/assets/10274826/8712599/a7fcfee0-2b23-11e5-8c61-e0b34867275e.png" width="300" height=300"/> 

This project is currently under development. Feel free to contact me if you have any questions, comments, or are interested in contributing or becoming a beta tester.

#### Future Plans:
 - Add teacher support
 - Add pay-to-chat option for polyglots
 - Some primitive language learning tools (e.g. flashcards)
 - Blocking functionality
 - Chat with a bot
