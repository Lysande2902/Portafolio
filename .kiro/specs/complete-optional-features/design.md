# Design Document

## Overview

This design document specifies the implementation of optional features for Óolale Mobile to complete the application to 100%. The features are organized into three main areas:

1. **Real-time Messaging System**: Enhance the existing messaging with Supabase Realtime, typing indicators, read receipts, and multimedia support
2. **Complete Event Management**: Add event history, calendar view, invitations system, RSVP functionality, and post-event ratings
3. **Enhanced Musician Profile**: Add genres, experience, availability, base rate, social links, improved portfolio, and profile completion tracking

The implementation will maintain consistency with the existing codebase, using Flutter/Dart with Supabase backend, GoRouter for navigation, and the established design system (Outfit font, #E8FF00 neon yellow primary color).

## Architecture

### High-Level Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     Flutter Application                      │
├─────────────────────────────────────────────────────────────┤
│  Presentation Layer                                          │
│  ├─ ChatScreen (enhanced with Realtime)                     │
│  ├─ EventHistoryScreen (new)                                │
│  ├─ EventCalendarScreen (new)                               │
│  ├─ EventInvitationsScreen (new)                            │
│  ├─ EditProfileScreen (enhanced)                            │
│  └─ PortfolioScreen (enhanced)                              │
├─────────────────────────────────────────────────────────────┤
│  Business Logic Layer                                        │
│  ├─ RealtimeService (new)                                   │
│  ├─ EventService (enhanced)                                 │
│  ├─ ProfileService (enhanced)                               │
│  └─ MediaService (new)                                      │
├─────────────────────────────────────────────────────────────┤
│  Data Layer                                                  │
│  ├─ Supabase Client                                         │
│  ├─ Supabase Realtime                                       │
│  └─ Supabase Storage                                        │
└─────────────────────────────────────────────────────────────┘
```

### Technology Stack

- **Frontend**: Flutter 3.x / Dart 3.x
- **Backend**: Supabase (PostgreSQL + Realtime + Storage)
- **State Management**: setState (existing pattern)
- **Navigation**: GoRouter
- **Real-time**: Supabase Realtime Channels
- **Storage**: Supabase Storage for media files
- **Notifications**: Firebase Cloud Messaging (existing)


## Components and Interfaces

### 1. Real-time Messaging Components

#### RealtimeService

```dart
class RealtimeService {
  final SupabaseClient _supabase;
  RealtimeChannel? _channel;
  
  // Subscribe to a conversation channel
  Future<void> subscribeToConversation(String userId, String otherUserId, Function(Message) onMessage);
  
  // Broadcast typing indicator
  Future<void> sendTypingIndicator(String conversationId, bool isTyping);
  
  // Listen for typing indicators
  Stream<TypingEvent> listenTypingIndicators(String conversationId);
  
  // Mark message as read
  Future<void> markMessageAsRead(String messageId);
  
  // Unsubscribe from channel
  Future<void> unsubscribe();
}
```

#### Enhanced ChatScreen

```dart
class ChatScreen extends StatefulWidget {
  // Existing properties
  final String userId;
  final String userName;
  
  // New state variables
  bool _isTyping = false;
  bool _otherUserTyping = false;
  Timer? _typingTimer;
  RealtimeChannel? _realtimeChannel;
}
```

#### MediaService

```dart
class MediaService {
  // Upload image with compression
  Future<String> uploadImage(File imageFile, String userId);
  
  // Upload audio file
  Future<String> uploadAudio(File audioFile, String userId);
  
  // Validate file type
  bool validateFileType(File file, List<String> allowedExtensions);
  
  // Validate file size
  bool validateFileSize(File file, int maxSizeInMB);
  
  // Compress image
  Future<File> compressImage(File imageFile, int maxSizeInMB);
}
```

### 2. Event Management Components

#### EventService

```dart
class EventService {
  final SupabaseClient _supabase;
  
  // Get event history for user
  Future<List<Event>> getEventHistory(String userId);
  
  // Get upcoming events for user
  Future<List<Event>> getUpcomingEvents(String userId);
  
  // Get events for specific date
  Future<List<Event>> getEventsForDate(DateTime date);
  
  // Send event invitations
  Future<void> sendInvitations(int eventId, List<String> musicianIds);
  
  // Respond to invitation (RSVP)
  Future<void> respondToInvitation(int invitationId, String status);
  
  // Check if user can rate event participants
  Future<bool> canRateEvent(int eventId, String userId);
  
  // Get participants to rate
  Future<List<Profile>> getParticipantsToRate(int eventId, String userId);
}
```

#### EventHistoryScreen

```dart
class EventHistoryScreen extends StatefulWidget {
  // Display past events
  // Show rating status
  // Navigate to event details
  // Prompt for ratings
}
```

#### EventCalendarScreen

```dart
class EventCalendarScreen extends StatefulWidget {
  // Display calendar view
  // Highlight dates with events
  // Show event list for selected date
  // Display confirmation status
  // Show 24-hour indicators
}
```

#### EventInvitationsScreen

```dart
class EventInvitationsScreen extends StatefulWidget {
  // Display pending invitations
  // Show event details
  // Accept/Decline buttons
  // Update invitation status
}
```


### 3. Enhanced Profile Components

#### ProfileService

```dart
class ProfileService {
  final SupabaseClient _supabase;
  
  // Save musical genres
  Future<void> saveGenres(String userId, List<String> genres);
  
  // Get available genres
  Future<List<String>> getAvailableGenres();
  
  // Save experience and availability
  Future<void> saveExperienceAndAvailability(String userId, int yearsExperience, Map<String, dynamic> availability);
  
  // Save base rate
  Future<void> saveBaseRate(String userId, double amount, String currency);
  
  // Save social links
  Future<void> saveSocialLinks(String userId, Map<String, String> socialLinks);
  
  // Calculate profile completion
  int calculateProfileCompletion(Map<String, dynamic> profile);
  
  // Get missing fields
  List<String> getMissingFields(Map<String, dynamic> profile);
}
```

#### Enhanced EditProfileScreen

```dart
class EditProfileScreen extends StatefulWidget {
  // Existing fields
  // + Genre multi-select
  // + Years of experience input
  // + Availability selector (days + time ranges)
  // + Base rate input with currency selector
  // + Social links inputs (Instagram, YouTube, Spotify, SoundCloud)
  // + Profile completion indicator
}
```

#### Enhanced PortfolioScreen

```dart
class PortfolioScreen extends StatefulWidget {
  // Display media grid
  // Upload multiple media items
  // Support images, videos, audio
  // Media viewer with full screen
  // Delete media functionality
}
```

## Data Models

### Message Model (Enhanced)

```dart
class Message {
  final String id;
  final String senderId;
  final String recipientId;
  final String content;
  final DateTime sentAt;
  final DateTime? deliveredAt;
  final DateTime? readAt;
  final String status; // 'sent', 'delivered', 'read'
  final String? mediaUrl;
  final String? mediaType; // 'image', 'audio', null
  
  MessageStatus get messageStatus {
    if (readAt != null) return MessageStatus.read;
    if (deliveredAt != null) return MessageStatus.delivered;
    return MessageStatus.sent;
  }
}

enum MessageStatus { sent, delivered, read }
```

### Event Model (Enhanced)

```dart
class Event {
  final int id;
  final String title;
  final String description;
  final DateTime date;
  final String time;
  final String location;
  final String type;
  final String organizerId;
  final String? flyerUrl;
  final bool isPast;
  final bool hasRated;
  
  bool get isWithin24Hours {
    final now = DateTime.now();
    final eventDateTime = DateTime(date.year, date.month, date.day);
    return eventDateTime.difference(now).inHours <= 24 && eventDateTime.isAfter(now);
  }
}
```

### Invitation Model (New)

```dart
class Invitation {
  final int id;
  final int eventId;
  final String musicianId;
  final String organizerId;
  final String status; // 'pending', 'accepted', 'declined'
  final DateTime createdAt;
  final Event event;
  final Profile organizer;
}
```

### Profile Model (Enhanced)

```dart
class Profile {
  // Existing fields
  final String id;
  final String nombreArtistico;
  final String? bio;
  final String? ubicacion;
  final String? instrumentoPrincipal;
  final String? fotoPerfil;
  final double? rating;
  
  // New fields
  final List<String> genres;
  final int? yearsExperience;
  final Map<String, dynamic>? availability;
  final double? baseRate;
  final String? currency;
  final Map<String, String>? socialLinks;
  final int profileCompletion;
  
  // Calculate completion
  int calculateCompletion() {
    int completed = 0;
    int total = 11;
    
    if (nombreArtistico.isNotEmpty) completed++;
    if (bio != null && bio!.isNotEmpty) completed++;
    if (ubicacion != null && ubicacion!.isNotEmpty) completed++;
    if (instrumentoPrincipal != null) completed++;
    if (fotoPerfil != null) completed++;
    if (genres.isNotEmpty) completed++;
    if (yearsExperience != null) completed++;
    if (availability != null) completed++;
    if (baseRate != null) completed++;
    if (socialLinks != null && socialLinks!.isNotEmpty) completed++;
    if (hasPortfolioItems) completed++;
    
    return ((completed / total) * 100).round();
  }
}
```

### MediaItem Model (New)

```dart
class MediaItem {
  final String id;
  final String userId;
  final String url;
  final String type; // 'image', 'video', 'audio'
  final String? thumbnail;
  final DateTime uploadedAt;
  final int? duration; // for audio/video in seconds
}
```


## Correctness Properties

*A property is a characteristic or behavior that should hold true across all valid executions of a system—essentially, a formal statement about what the system should do. Properties serve as the bridge between human-readable specifications and machine-verifiable correctness guarantees.*

### Property Reflection

After analyzing all acceptance criteria, I identified several areas where properties can be consolidated:

**Redundancy Analysis:**
- Message status indicators (2.1, 2.2, 2.3) can be combined into one property about status display
- Media validation properties (3.1, 3.2, 14.2, 14.3, 14.4) share similar validation logic
- Event notification properties (8.1, 8.3, 8.4) all follow the same notification pattern
- Profile display properties (10.4, 11.4, 12.4, 13.3) all verify data is shown correctly
- RSVP state transitions (7.2, 7.3) can be combined into one state machine property

**Consolidated Properties:**
The following properties represent the unique, non-redundant validation requirements:

### Messaging Properties

**Property 1: Real-time Message Delivery**
*For any* message sent through Supabase Realtime channels, the message should appear in the recipient's conversation stream without requiring manual refresh.
**Validates: Requirements 1.1, 1.2**

**Property 2: Typing Indicator Broadcast**
*For any* typing event, when a user is actively typing, a typing indicator should be broadcast to the recipient through the Realtime channel.
**Validates: Requirements 1.3**

**Property 3: Message Read Status Update**
*For any* conversation, when a user opens it, all unread messages in that conversation should be marked as read and their read_at timestamp should be set.
**Validates: Requirements 1.6, 1.7**

**Property 4: Media Upload and URL Generation**
*For any* valid image or audio file, uploading it to Supabase Storage should return a valid URL that can be included in a message.
**Validates: Requirements 1.8, 3.4**

**Property 5: File Validation**
*For any* file selected for upload, if it exceeds size limits or has an unsupported format, the system should reject it before attempting upload.
**Validates: Requirements 1.9, 3.2**

**Property 6: Image Compression**
*For any* image larger than 2MB, compressing it should result in a file size at or below 2MB while maintaining reasonable quality.
**Validates: Requirements 3.1**

**Property 7: Message Status Consistency**
*For any* sent message, its displayed status should match its most recent state (sent → delivered → read) based on the presence of delivery and read timestamps.
**Validates: Requirements 2.5**

**Property 8: Media Message Rendering**
*For any* message with a media URL, the system should display appropriate UI elements: thumbnails for images, playback controls for audio.
**Validates: Requirements 3.5, 3.6**

### Event Management Properties

**Property 9: Event History Ordering**
*For any* user's event history, events should be ordered by date with the most recent events appearing first.
**Validates: Requirements 4.2**

**Property 10: Event History Completeness**
*For any* user, their event history should include all past events where they were a confirmed participant.
**Validates: Requirements 4.1**

**Property 11: Rating Status Display**
*For any* past event in a user's history, the system should correctly indicate whether the user has left ratings for all participants.
**Validates: Requirements 4.4, 4.5**

**Property 12: Calendar Date Filtering**
*For any* date selected in the calendar, tapping it should display only events scheduled for that specific date.
**Validates: Requirements 5.3**

**Property 13: 24-Hour Event Indicator**
*For any* event occurring within the next 24 hours, the system should display a visual indicator to highlight its urgency.
**Validates: Requirements 5.5**

**Property 14: Invitation Notification Creation**
*For any* set of musicians invited to an event, each invitation should create a corresponding notification record in the database.
**Validates: Requirements 6.2, 6.3**

**Property 15: Invitation Initial State**
*For any* newly created invitation, its status should be set to "pending" upon creation.
**Validates: Requirements 6.5**

**Property 16: RSVP State Transitions**
*For any* invitation, responding with accept or decline should update its status to "accepted" or "declined" respectively, and trigger appropriate side effects (add to lineup or remove from pending).
**Validates: Requirements 7.2, 7.3, 7.5, 7.6**

**Property 17: RSVP Organizer Notification**
*For any* RSVP submission (accept or decline), a notification should be created for the event organizer.
**Validates: Requirements 7.4**

**Property 18: Event Update Notifications**
*For any* event that is updated or cancelled, all confirmed participants should receive a notification.
**Validates: Requirements 8.3, 8.4**

**Property 19: Notification Persistence**
*For any* notification sent, it should be stored in the notifications table with all required fields (user_id, tipo, titulo, mensaje, leido, data).
**Validates: Requirements 8.5**

**Property 20: Post-Event Rating Verification**
*For any* rating submission, the system should verify that the user was a confirmed participant in the event before allowing the rating.
**Validates: Requirements 9.2**

**Property 21: Rating Validation**
*For any* rating submission, it must include a star rating between 1 and 5, and may optionally include a comment.
**Validates: Requirements 9.3, 9.4**

**Property 22: Average Rating Recalculation**
*For any* new rating submitted, the recipient's average rating should be recalculated to include the new rating.
**Validates: Requirements 9.5**

**Property 23: Duplicate Rating Prevention**
*For any* user-participant pair for a specific event, only one rating should be allowed.
**Validates: Requirements 9.6**


### Profile Enhancement Properties

**Property 24: Genre Multi-Selection**
*For any* profile edit, the system should allow selecting and saving multiple musical genres, and all selected genres should be stored and displayed.
**Validates: Requirements 10.2, 10.3, 10.4**

**Property 25: Genre Search Filtering**
*For any* genre filter applied in musician search, results should only include musicians who have that genre in their profile.
**Validates: Requirements 10.5**

**Property 26: Availability Data Structure**
*For any* availability data saved, it should be stored in a structured format (JSON) containing days and time ranges, and should be retrievable for display and filtering.
**Validates: Requirements 11.3, 11.4, 11.5**

**Property 27: Base Rate Storage**
*For any* base rate entered, it should be stored as a numeric value with an associated currency code, and displayed correctly on the profile.
**Validates: Requirements 12.3, 12.4**

**Property 28: Default Rate Display**
*For any* profile without a set base rate, the system should display "Tarifa por consultar" as the default text.
**Validates: Requirements 12.5**

**Property 29: Social Link URL Validation**
*For any* social media URL entered, the system should validate its format before saving, and reject invalid URLs with an error message.
**Validates: Requirements 13.2, 13.5**

**Property 30: Social Link Display**
*For any* profile with saved social links, the system should display an icon for each linked platform.
**Validates: Requirements 13.3**

**Property 31: Media File Type Validation**
*For any* file uploaded to the portfolio, the system should validate it is an allowed type (image, video mp4, audio mp3/wav) before proceeding with upload.
**Validates: Requirements 14.2**

**Property 32: Media File Size Validation**
*For any* video file, it should be rejected if larger than 50MB; for any audio file, it should be rejected if larger than 10MB.
**Validates: Requirements 14.3, 14.4**

**Property 33: Media Storage Cleanup**
*For any* media item deleted from a portfolio, the corresponding file should be removed from Supabase Storage.
**Validates: Requirements 14.8**

**Property 34: Profile Completion Calculation**
*For any* profile, the completion percentage should be calculated by counting completed fields (name, bio, location, instrument, photo, genres, experience, availability, rate, social links, portfolio) divided by total fields, multiplied by 100.
**Validates: Requirements 15.1, 15.2**

**Property 35: Profile Completion Display**
*For any* profile with completion less than 100%, a progress bar should be displayed; for any profile at 100%, a "Perfil Completo" badge should be displayed.
**Validates: Requirements 15.3, 15.4**

**Property 36: Missing Fields Suggestions**
*For any* incomplete profile viewed by its owner, the system should display suggestions for which fields are missing.
**Validates: Requirements 15.5**


## Error Handling

### Real-time Messaging Errors

1. **Connection Failures**
   - Detect when Realtime channel disconnects
   - Display connection status indicator
   - Attempt automatic reconnection with exponential backoff
   - Queue messages locally if offline, send when reconnected

2. **Message Send Failures**
   - Catch Supabase insert errors
   - Display error indicator on failed message
   - Provide retry button
   - Log error details for debugging

3. **Media Upload Failures**
   - Catch storage upload errors
   - Display progress and error states
   - Allow retry with same file
   - Clean up partial uploads on failure

4. **File Validation Errors**
   - Display user-friendly error messages for:
     - File too large
     - Unsupported file type
     - Corrupted file
   - Prevent upload attempt for invalid files

### Event Management Errors

1. **Event Loading Failures**
   - Handle empty event lists gracefully
   - Display appropriate empty states
   - Retry mechanism for network errors
   - Cache events locally for offline viewing

2. **Invitation Errors**
   - Validate musician IDs before sending invitations
   - Handle duplicate invitation attempts
   - Display error if notification creation fails
   - Rollback invitation if notification fails

3. **RSVP Errors**
   - Validate invitation exists and is pending
   - Prevent duplicate RSVP submissions
   - Handle concurrent RSVP attempts
   - Display error if lineup update fails

4. **Rating Errors**
   - Verify event participation before allowing rating
   - Prevent rating before event ends
   - Handle duplicate rating attempts
   - Validate rating values (1-5 stars)

### Profile Enhancement Errors

1. **Profile Update Failures**
   - Catch database update errors
   - Display specific error messages
   - Preserve user input on failure
   - Retry mechanism for transient errors

2. **Genre Selection Errors**
   - Validate genre exists in catalog
   - Handle empty genre selections
   - Limit maximum number of genres

3. **Availability Parsing Errors**
   - Validate JSON structure
   - Handle malformed availability data
   - Provide default availability if parsing fails

4. **Social Link Validation Errors**
   - Display specific error for each invalid URL
   - Highlight problematic field
   - Provide format examples
   - Allow saving other valid links even if one fails

5. **Portfolio Upload Errors**
   - Handle storage quota exceeded
   - Display upload progress and errors
   - Clean up failed uploads
   - Validate file before upload to prevent wasted bandwidth

## Testing Strategy

### Dual Testing Approach

This feature will use both unit tests and property-based tests to ensure comprehensive coverage:

- **Unit Tests**: Verify specific examples, edge cases, and error conditions
- **Property Tests**: Verify universal properties across all inputs using randomized test data

### Property-Based Testing Configuration

- **Library**: Use `faker` package for Dart to generate random test data
- **Iterations**: Minimum 100 iterations per property test
- **Tagging**: Each property test must reference its design document property

Tag format: `// Feature: complete-optional-features, Property {number}: {property_text}`

### Test Coverage by Component

#### Real-time Messaging Tests

**Unit Tests:**
- Typing indicator timeout (3 seconds)
- Message status icon display
- Media thumbnail rendering
- Full-screen image viewer
- Audio playback controls
- Error message display and retry

**Property Tests:**
- Property 1: Real-time message delivery
- Property 3: Message read status update
- Property 4: Media upload and URL generation
- Property 5: File validation
- Property 6: Image compression
- Property 7: Message status consistency
- Property 8: Media message rendering

#### Event Management Tests

**Unit Tests:**
- Calendar date selection
- 24-hour event indicator display
- Empty event history state
- Invitation accept/decline buttons
- Rating form validation
- Event reminder scheduling

**Property Tests:**
- Property 9: Event history ordering
- Property 10: Event history completeness
- Property 11: Rating status display
- Property 12: Calendar date filtering
- Property 13: 24-hour event indicator
- Property 14: Invitation notification creation
- Property 15: Invitation initial state
- Property 16: RSVP state transitions
- Property 17: RSVP organizer notification
- Property 18: Event update notifications
- Property 19: Notification persistence
- Property 20: Post-event rating verification
- Property 21: Rating validation
- Property 22: Average rating recalculation
- Property 23: Duplicate rating prevention

#### Profile Enhancement Tests

**Unit Tests:**
- Genre selection UI
- Experience input field
- Availability time picker
- Currency selector
- Social link input fields
- Profile completion progress bar
- "Perfil Completo" badge display
- Missing fields suggestions

**Property Tests:**
- Property 24: Genre multi-selection
- Property 25: Genre search filtering
- Property 26: Availability data structure
- Property 27: Base rate storage
- Property 28: Default rate display
- Property 29: Social link URL validation
- Property 30: Social link display
- Property 31: Media file type validation
- Property 32: Media file size validation
- Property 33: Media storage cleanup
- Property 34: Profile completion calculation
- Property 35: Profile completion display
- Property 36: Missing fields suggestions

### Integration Tests

- End-to-end message flow with Realtime
- Complete event invitation and RSVP flow
- Profile update with all new fields
- Media upload and display flow
- Notification delivery for all event types

### Manual Testing Checklist

- [ ] Real-time messaging works across devices
- [ ] Typing indicators appear and disappear correctly
- [ ] Media uploads and displays correctly
- [ ] Calendar view shows events accurately
- [ ] Event invitations send and receive properly
- [ ] RSVP updates lineup correctly
- [ ] Post-event rating prompts appear
- [ ] Profile completion percentage is accurate
- [ ] Social links open in external browser
- [ ] Portfolio media viewer works correctly

