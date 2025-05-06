# LaughLab Prompt README for Cursor AI Agent

## Overview
LaughLab is a joke-sharing mobile app for iOS and Android, built by a solo software engineer with no budget, using Flutter, Firebase free tier, and Cursor’s AI Agent. 

## App Purpose
- Allow users to create, share, and rate text-based jokes in a social, comedy-focused platform.
- Include innovative features (Joke Remix Chain, AI Punchline Prompter) to differentiate from apps like Reddit or iFunny.

## Key Features
1. **Joke Creation and Sharing**:
   - Text-based editor (300 characters, 8 categories: puns, dad jokes, etc.).
   - Share via text links (X, WhatsApp, email).
   - Save drafts locally (SharedPreferences).
2. **Rating System**:
   - Upvote/downvote with score (upvotes – downvotes).
   - Comments (300 characters, 10/joke).
3. **Discovery**:
   - Home feed (recent/top-rated jokes).
   - Explore tab (filter by category).
4. **User Profiles**:
   - Username, profile picture, joke list, points.
   - Stats: jokes posted, upvotes received.
5. **Gamification**:
   - Points: 5/joke posted, 1/upvote, 2/remix received, 5/AI-assisted post.
6. **Joke Remix Chain**:
   - Remix a joke’s punchline, forming chains in a Remix tab.
   - Upvote/downvote remixes, 2 points to original creator.
7. **AI-Generated Punchline Prompter**:
   - Offline DistilBERT/ONNX suggests 3–5 punchlines for user setups.
   - “Get AI Help” in Create screen, Prompter screen, 5 points/AI-post.
8. **UI**:
   - 6 screens: Home, Create, Explore, Profile, Remix, Prompter.
   - Clean, colorful design (free Flutter template, Google Fonts).
   - Basic onboarding (category picker).
9. **Backend**:
   - Firebase free tier: Authentication (email/password), Firestore (1 GB), Notifications (1 million/month).
   - Polling (10-second feed refresh).
   - Moderation: regex filter (50 offensive words), Report button.
10. **Constraints**:
    - No budget: Use Flutter, Firebase free tier, open-source tools (DistilBERT/ONNX, Kaggle datasets).
    - 335–635 hours (20–40 hours/week, 2.5–4.5 months).
    - No video/audio, monetization, or advanced community features.
    - Optimize for low-end devices (2 GB RAM Android).

## Technical Requirements
- **Framework**: Flutter for iOS/Android.
- **Backend**: Firebase free tier (Auth, Firestore, Notifications).
- **AI**: DistilBERT/ONNX (~100 MB) bundled in assets with 1000-joke dataset.
- **Repo**: GitHub (free public, detailed README).
- **Performance**: Feed loads < 1 second, posting < 2 seconds.
- **Cursor AI Agent**:
  - Generate Flutter widgets, Firebase queries, ONNX integration.
  - Debug errors, optimize performance (e.g., cache feed).
  - Write README, Flippa pitch, marketing posts.

## Firestore Schema
- Users: user_id, username, profile_picture, points, created_at.
- Jokes: joke_id, user_id, content, category, upvotes, downvotes, created_at.
- Comments: comment_id, joke_id, user_id, content, created_at.
- Ratings: rating_id, joke_id, user_id, upvote/downvote, created_at.
- Remixes: remix_id, parent_joke_id, user_id, content, upvotes, downvotes, created_at.
- AI Flags: ai_post_id, joke_id, user_id, is_ai_assisted, created_at.

## Deliverables
- Flutter codebase with Firebase/ONNX, hosted on GitHub.
- APK/IPA for testing.
- README: Setup, features, Firebase guide.

## Notes for Cursor AI
- Reference this README before processing each prompt to ensure consistency.
- Keep code clean, commented, and sellable for Flippa buyers.
- Stay within Firebase free tier (1 GB storage, 20,000 DAU).
- Prioritize simplicity, reliability, and engagement (remixes, AI).

Last Updated: May 03, 2025
