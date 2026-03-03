# Implementation Plan: Complete Optional Features

## Overview

This implementation plan breaks down the optional features into discrete, incremental tasks. The approach follows a modular pattern: implement core services first, then build UI screens that consume those services, and finally integrate everything with testing. Each task builds on previous work to ensure no orphaned code.

The implementation is organized into three main phases:
1. **Real-time Messaging Enhancement** (Tasks 1-4)
2. **Complete Event Management** (Tasks 5-8)
3. **Enhanced Musician Profile** (Tasks 9-12)

## Tasks

### Phase 1: Real-time Messaging Enhancement

- [x] 1. Implement RealtimeService and MediaService
  - Create `lib/services/realtime_service.dart` with Supabase Realtime channel management
  - Implement subscription to conversation channels
  - Add typing indicator broadcast and listening
  - Create `lib/services/media_service.dart` for file handling
  - Implement image compression (max 2MB)
  - Add file validation (type and size)
  - Implement upload methods for images and audio to Supabase Storage
  - _Requirements: 1.1, 1.3, 1.8, 1.9, 3.1, 3.2_

- [ ] 1.1 Write property tests for RealtimeService
  - **Property 1: Real-time message delivery**
  - **Property 2: Typing indicator broadcast**
  - **Validates: Requirements 1.1, 1.2, 1.3**

- [ ] 1.2 Write property tests for MediaService
  - **Property 4: Media upload and URL generation**
  - **Property 5: File validation**
  - **Property 6: Image compression**
  - **Validates: Requirements 1.8, 1.9, 3.1, 3.2**

- [x] 2. Enhance ChatScreen with real-time features
  - Update `lib/screens/messages/chat_screen.dart`
  - Integrate RealtimeService for message streaming
  - Add typing indicator UI (display when other user is typing)
  - Implement typing detection (send indicator when user types)
  - Add 3-second timeout for typing indicator
  - Update message model to include delivery and read timestamps
  - Implement mark-as-read when conversation opens
  - _Requirements: 1.2, 1.3, 1.4, 1.6, 1.7_

- [x] 2.1 Write property tests for message status
  - **Property 3: Message read status update**
  - **Property 7: Message status consistency**
  - **Validates: Requirements 1.6, 1.7, 2.5**

- [x] 3. Add multimedia support to ChatScreen
  - Add image picker button to chat input
  - Add audio file picker button
  - Integrate MediaService for uploads
  - Display upload progress indicator
  - Show thumbnails for image messages
  - Add playback controls for audio messages
  - Implement full-screen image viewer
  - Add error handling and retry for failed uploads
  - _Requirements: 1.8, 3.1, 3.2, 3.3, 3.4, 3.5, 3.6, 3.7, 3.8_

- [x] 3.1 Write property tests for media messages
  - **Property 8: Media message rendering**
  - **Validates: Requirements 3.5, 3.6**

- [x] 4. Implement message status indicators
  - Update message bubble UI to show status icons
  - Add "sent" indicator (single checkmark)
  - Add "delivered" indicator (double checkmark)
  - Add "read" indicator (colored double checkmark)
  - Use theme-consistent colors (primary color for read)
  - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5_

- [x] 5. Checkpoint - Test messaging features
  - Ensure all tests pass, ask the user if questions arise.


### Phase 2: Complete Event Management

- [x] 6. Implement EventService with history and invitations
  - Create enhanced `lib/services/event_service.dart`
  - Add method to get event history (past events for user)
  - Add method to get upcoming events
  - Add method to get events for specific date
  - Implement send invitations method (create invitation records + notifications)
  - Implement RSVP method (update invitation status, modify lineup)
  - Add method to check if user can rate event
  - Add method to get participants to rate
  - _Requirements: 4.1, 4.2, 6.1, 6.2, 7.2, 7.3, 7.4, 7.5, 7.6, 9.2_

- [x] 6.1 Write property tests for EventService
  - **Property 9: Event history ordering**
  - **Property 10: Event history completeness**
  - **Property 14: Invitation notification creation**
  - **Property 15: Invitation initial state**
  - **Property 16: RSVP state transitions**
  - **Property 17: RSVP organizer notification**
  - **Property 20: Post-event rating verification**
  - **Validates: Requirements 4.1, 4.2, 6.2, 6.5, 7.2, 7.3, 7.4, 7.5, 7.6, 9.2**

- [x] 7. Create EventHistoryScreen
  - Create `lib/screens/events/event_history_screen.dart`
  - Display list of past events (ordered by date, most recent first)
  - Show event card with title, date, location
  - Display rating status indicator (rated/not rated)
  - Add navigation to event detail screen
  - Show prompt to rate if not rated
  - Handle empty state (no past events)
  - _Requirements: 4.1, 4.2, 4.3, 4.4, 4.5_

- [x] 7.1 Write property tests for event history
  - **Property 11: Rating status display**
  - **Validates: Requirements 4.4, 4.5**

- [x] 8. Create EventCalendarScreen
  - Create `lib/screens/events/event_calendar_screen.dart`
  - Integrate calendar widget (use `table_calendar` package)
  - Highlight dates with confirmed events
  - Display event list when date is tapped
  - Show confirmation status for each event (confirmed/pending)
  - Add visual indicator for events within 24 hours
  - Handle navigation to event detail
  - _Requirements: 5.1, 5.2, 5.3, 5.4, 5.5_

- [x] 8.1 Write property tests for calendar
  - **Property 12: Calendar date filtering**
  - **Property 13: 24-hour event indicator**
  - **Validates: Requirements 5.3, 5.5**

- [x] 9. Create EventInvitationsScreen and enhance GigDetailScreen
  - Create `lib/screens/events/event_invitations_screen.dart`
  - Display list of pending invitations
  - Show event details for each invitation
  - Add accept/decline buttons
  - Integrate EventService for RSVP
  - Update invitation status on response
  - Navigate to event detail on tap
  - Enhance `lib/screens/events/gig_detail_screen.dart` to allow organizer to invite musicians
  - Add musician selector for invitations
  - Integrate EventService to send invitations
  - _Requirements: 6.1, 6.2, 6.3, 6.4, 6.5, 7.1, 7.2, 7.3, 7.4, 7.5, 7.6_

- [x] 9.1 Write property tests for invitations
  - **Property 18: Event update notifications**
  - **Property 19: Notification persistence**
  - **Validates: Requirements 8.3, 8.4, 8.5**

- [x] 10. Implement event notifications
  - Update NotificationService to handle event invitation notifications
  - Add notification for event invitations
  - Add notification for 24-hour event reminders (scheduled)
  - Add notification for event updates
  - Add notification for event cancellations
  - Ensure all notifications are stored in database
  - _Requirements: 8.1, 8.2, 8.3, 8.4, 8.5_

- [x] 11. Enhance rating system for post-event ratings
  - Update `lib/screens/ratings/leave_rating_screen.dart`
  - Add prompt after event ends
  - Verify user participated in event before allowing rating
  - Require star rating (1-5)
  - Allow optional comment
  - Update recipient's average rating on submission
  - Prevent duplicate ratings for same event
  - _Requirements: 9.1, 9.2, 9.3, 9.4, 9.5, 9.6_

- [x] 11.1 Write property tests for ratings
  - **Property 21: Rating validation**
  - **Property 22: Average rating recalculation**
  - **Property 23: Duplicate rating prevention**
  - **Validates: Requirements 9.3, 9.4, 9.5, 9.6**

- [x] 12. Checkpoint - Test event management features
  - Ensure all tests pass, ask the user if questions arise.


### Phase 3: Enhanced Musician Profile

- [x] 13. Implement ProfileService enhancements
  - Create enhanced `lib/services/profile_service.dart`
  - Add method to save musical genres (array)
  - Add method to get available genres from database
  - Add method to save experience and availability (JSON structure)
  - Add method to save base rate with currency
  - Add method to save social links (map of platform: URL)
  - Implement profile completion calculation (11 fields)
  - Add method to get missing fields list
  - _Requirements: 10.2, 10.3, 11.3, 12.3, 13.2, 15.1, 15.2, 15.5_

- [x] 13.1 Write property tests for ProfileService
  - **Property 24: Genre multi-selection**
  - **Property 26: Availability data structure**
  - **Property 27: Base rate storage**
  - **Property 29: Social link URL validation**
  - **Property 34: Profile completion calculation**
  - **Validates: Requirements 10.2, 10.3, 11.3, 12.3, 13.2, 15.1, 15.2**

- [x] 14. Enhance EditProfileScreen with new fields
  - Update `lib/screens/profile/edit_profile_screen.dart`
  - Add musical genres multi-select widget
  - Add years of experience input field (numeric)
  - Add availability selector (days of week + time ranges)
  - Add base rate input with currency dropdown (MXN, USD)
  - Add social links inputs (Instagram, YouTube, Spotify, SoundCloud)
  - Validate URLs before saving
  - Display validation errors for invalid URLs
  - Integrate ProfileService for saving
  - _Requirements: 10.1, 10.2, 10.3, 11.1, 11.2, 11.3, 12.1, 12.2, 12.3, 13.1, 13.2, 13.5_

- [x] 14.1 Write property tests for profile fields
  - **Property 25: Genre search filtering**
  - **Property 28: Default rate display**
  - **Property 30: Social link display**
  - **Validates: Requirements 10.5, 12.5, 13.3**

- [x] 15. Add profile completion indicator
  - Update `lib/screens/profile/unified_profile_screen.dart`
  - Calculate profile completion percentage
  - Display progress bar for incomplete profiles (<100%)
  - Display "Perfil Completo" badge for 100% profiles
  - Show missing fields suggestions on own profile
  - Use ProfileService for calculation
  - _Requirements: 15.1, 15.2, 15.3, 15.4, 15.5_

- [x] 15.1 Write property tests for profile completion
  - **Property 35: Profile completion display**
  - **Property 36: Missing fields suggestions**
  - **Validates: Requirements 15.3, 15.4, 15.5**

- [x] 16. Enhance portfolio with multimedia support
  - Update `lib/screens/profile/portfolio_screen.dart` (or create if doesn't exist)
  - Allow uploading multiple media items
  - Support images, videos (mp4), and audio (mp3, wav)
  - Validate file types before upload
  - Validate file sizes (videos <50MB, audio <10MB)
  - Display media in grid layout
  - Implement media viewer (full screen for images, player for audio/video)
  - Add delete functionality for media items
  - Remove from Supabase Storage on delete
  - _Requirements: 14.1, 14.2, 14.3, 14.4, 14.5, 14.6, 14.7, 14.8_

- [x] 16.1 Write property tests for portfolio
  - **Property 31: Media file type validation**
  - **Property 32: Media file size validation**
  - **Property 33: Media storage cleanup**
  - **Validates: Requirements 14.2, 14.3, 14.4, 14.8**

- [x] 17. Update search functionality for new profile fields
  - Update `lib/screens/dashboard/search_screen.dart`
  - Add filter by musical genre
  - Add filter by availability
  - Ensure filters work with new profile fields
  - _Requirements: 10.5, 11.5_

- [x] 18. Update profile display to show new fields
  - Update `lib/screens/profile/unified_profile_screen.dart`
  - Display musical genres as chips
  - Show years of experience
  - Display availability schedule
  - Show base rate or "Tarifa por consultar"
  - Display social media icons with links
  - Open social links in external browser
  - _Requirements: 10.4, 11.4, 12.4, 12.5, 13.3, 13.4_

- [x] 19. Checkpoint - Test profile enhancements
  - Ensure all tests pass, ask the user if questions arise.

### Phase 4: Integration and Final Testing

- [x] 20. Update database schema
  - Create migration script for new tables/columns
  - Add `message_status` table or columns (delivered_at, read_at)
  - Add `event_invitations` table
  - Add `profile_genres` table (many-to-many)
  - Add columns to profiles: years_experience, availability (JSON), base_rate, currency, social_links (JSON)
  - Add `portfolio_media` table
  - Run migration on Supabase
  - _Requirements: All_

- [x] 21. Update navigation routes
  - Update `lib/config/router.dart` (or equivalent GoRouter config)
  - Add route for EventHistoryScreen
  - Add route for EventCalendarScreen
  - Add route for EventInvitationsScreen
  - Add route for enhanced PortfolioScreen
  - Ensure all new screens are accessible from navigation
  - _Requirements: All_

- [x] 22. Integration testing
  - Test complete message flow with real-time updates
  - Test event invitation and RSVP flow end-to-end
  - Test profile update with all new fields
  - Test media upload and display
  - Test notification delivery for all event types
  - Verify calendar displays events correctly
  - Verify profile completion calculation
  - _Requirements: All_

- [x] 22.1 Write integration tests
  - End-to-end message flow
  - Complete event invitation flow
  - Profile update flow
  - Media upload flow

- [x] 23. Final checkpoint - Complete testing
  - Ensure all tests pass, ask the user if questions arise.

## Notes

- All tasks are required for comprehensive implementation
- Each task references specific requirements for traceability
- Checkpoints ensure incremental validation
- Property tests validate universal correctness properties
- Unit tests validate specific examples and edge cases
- The implementation follows a service-first approach to ensure reusability
- All new features integrate with existing authentication and navigation systems
- Supabase Realtime requires proper channel management to avoid memory leaks
- Media uploads should show progress to improve UX
- Profile completion calculation should be cached to avoid repeated computation
