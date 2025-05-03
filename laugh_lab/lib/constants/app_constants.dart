class AppConstants {
  // Joke categories
  static const List<String> jokeCategories = [
    'Puns',
    'Dad Jokes',
    'One-liners',
    'Knock-knock',
    'Wordplay',
    'Silly',
    'Observational',
    'Absurd',
  ];
  
  // Max character limits
  static const int maxJokeLength = 300;
  static const int maxCommentLength = 300;
  static const int maxCommentsPerJoke = 10;
  static const int maxRemixLength = 300;
  
  // Points system
  static const int pointsForNewJoke = 5;
  static const int pointsForUpvote = 1;
  static const int pointsForRemix = 2;
  static const int pointsForAIPost = 5;
  
  // Feed refresh interval in seconds
  static const int feedRefreshIntervalSeconds = 10;
  
  // Collection names for Firestore
  static const String usersCollection = 'users';
  static const String jokesCollection = 'jokes';
  static const String commentsCollection = 'comments';
  static const String ratingsCollection = 'ratings';
  static const String remixesCollection = 'remixes';
  static const String aiPostsCollection = 'ai_posts';
  
  // Shared preferences keys
  static const String draftJokeKey = 'draft_joke';
  static const String draftJokeCategoryKey = 'draft_joke_category';
  static const String onboardingCompletedKey = 'onboarding_completed';
  static const String preferredCategoriesKey = 'preferred_categories';
  static const String recentPromptsKey = 'recent_prompts';
  
  // Default avatar URL
  static const String defaultAvatarUrl = 'https://firebasestorage.googleapis.com/v0/b/laugh-lab.appspot.com/o/default_avatar.png?alt=media';
  
  // Username requirements
  static const int minUsernameLength = 3;
  static const int maxUsernameLength = 20;
  
  // Image sizes
  static const double avatarSizeSmall = 40;
  static const double avatarSizeMedium = 60;
  static const double avatarSizeLarge = 100;
  
  // Screen names for navigation
  static const String homeScreen = 'Home';
  static const String createScreen = 'Create';
  static const String exploreScreen = 'Explore';
  static const String profileScreen = 'Profile';
  static const String remixScreen = 'Remix';
  static const String prompterScreen = 'Prompter';
  
  // Moderation
  static const List<String> offensiveWords = [
    // This is just a placeholder - a real implementation would have a more comprehensive list
    'offensive1',
    'offensive2',
    'offensive3',
  ];
} 