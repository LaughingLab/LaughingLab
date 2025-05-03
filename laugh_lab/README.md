# LaughLab

LaughLab is a joke-sharing mobile app where users can create, share, rate, and comment on jokes in various categories.

## Features

### Core Features
- **Authentication**: Email/password sign up and login
- **Joke Creation**: Create text-based jokes up to 300 characters in 8 different categories
- **Rating System**: Upvote/downvote jokes with scoring system
- **Comments**: Add and view comments on jokes
- **Feed**: Browse recent or top-rated jokes
- **Filtering**: Filter jokes by category
- **Profile**: View your profile, points, and jokes
- **Points System**: Earn points by posting jokes and receiving upvotes
- **Drafts**: Save drafts of jokes locally
- **Sharing**: Share jokes to other platforms

## Tech Stack

- **Flutter** for cross-platform mobile development
- **Firebase Authentication** for user management
- **Cloud Firestore** for database
- **Firebase Cloud Messaging** for notifications
- **Provider** for state management
- **SharedPreferences** for local storage

## Setup Instructions

### Prerequisites
- Flutter SDK (latest stable version)
- Dart SDK
- Android Studio or VS Code with Flutter extensions
- Firebase account

### Installation
1. Clone this repository:
   ```
   git clone https://github.com/yourusername/laugh_lab.git
   cd laugh_lab
   ```

2. Install dependencies:
   ```
   flutter pub get
   ```

3. Set up Firebase:
   - Create a new Firebase project at [Firebase Console](https://console.firebase.google.com/)
   - Enable Authentication (Email/Password)
   - Create a Cloud Firestore database
   - Download and add the `google-services.json` (Android) or `GoogleService-Info.plist` (iOS) to your project
   - Follow the Firebase Flutter setup guide for detailed instructions

4. Run the app:
   ```
   flutter run
   ```

## Firestore Schema

The app uses the following Firestore collections:

- **users**: User profiles with points and metadata
- **jokes**: Joke content, category, and metadata
- **comments**: Comments on jokes
- **ratings**: User ratings for jokes

## Performance Optimization

The app is optimized for low-end devices with:
- Efficient Firestore queries
- Polling instead of WebSockets
- Minimal dependencies
- Optimized image loading

## Contributing

This is an MVP project. If you'd like to contribute, please fork the repository and submit a pull request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.
