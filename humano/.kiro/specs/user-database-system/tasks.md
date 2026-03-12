# Implementation Plan - User Database System

- [x] 1. Create UserData model and Firestore serialization


  - Implement UserData class that encapsulates all user information
  - Add toFirestore() method for serialization
  - Add fromFirestore() factory constructor for deserialization
  - Add initial() factory for new users with default values
  - Add copyWith() method for immutable updates
  - _Requirements: 1.2, 9.2, 9.3, 9.4, 9.5_



- [x] 1.1 Write property test for UserData serialization round-trip


  - **Property 2: Data persistence round-trip**
  - **Validates: Requirements 1.3, 1.4, 1.5**

- [ ] 2. Implement UserRepository with basic CRUD operations
  - Create UserRepository class with FirebaseFirestore dependency
  - Implement getUser() to fetch user document
  - Implement createUser() to initialize new user document


  - Implement updateUser() for full document updates


  - Add proper error handling for Firestore exceptions
  - _Requirements: 1.1, 10.1_

- [ ] 2.1 Write property test for user document creation
  - **Property 1: User document creation on authentication**
  - **Validates: Requirements 1.1**



- [x] 3. Add arc progress management to UserRepository

  - Implement updateArcProgress() to update specific arc
  - Implement addEvidenceToArc() to add evidence to arc's list
  - Use Firestore map updates to avoid overwriting entire document

  - Handle non-existent arc initialization
  - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5_



- [ ] 3.1 Write property test for arc status transitions
  - **Property 3: Arc status transitions**
  - **Validates: Requirements 2.1, 2.3**

- [ ] 3.2 Write property test for evidence collection
  - **Property 4: Evidence collection accumulation**


  - **Validates: Requirements 2.2, 8.1, 8.2**


- [ ] 3.3 Write property test for arc completion counter
  - **Property 5: Arc completion increments counter**


  - **Validates: Requirements 2.3, 5.2**

- [ ] 4. Implement inventory management in UserRepository
  - Implement updateInventory() for full inventory updates
  - Implement purchaseItem() as atomic transaction
  - Add validation for sufficient funds before purchase

  - Ensure atomic coin deduction and item addition
  - Handle transaction failures with proper rollback
  - _Requirements: 3.1, 3.2, 3.4, 3.5_


- [x] 4.1 Write property test for purchase transaction atomicity


  - **Property 6: Purchase transaction atomicity**
  - **Validates: Requirements 3.1, 3.5**

- [ ] 4.2 Write property test for coin balance calculations
  - **Property 7: Coin balance monotonicity**
  - **Validates: Requirements 3.2**


- [ ] 5. Add settings and stats management to UserRepository
  - Implement updateSettings() to persist game settings
  - Implement updateStats() to update user statistics

  - Use Firestore field updates for granular changes
  - Add validation for settings value ranges (0.0-1.0 for volumes)


  - _Requirements: 4.1, 4.2, 4.3, 4.4, 5.1, 5.2, 5.3_

- [ ] 5.1 Write property test for settings persistence
  - **Property 8: Settings update persistence**
  - **Validates: Requirements 4.1, 4.2, 4.3, 4.4**

- [x] 5.2 Write property test for stats accumulation

  - **Property 9: Stats accumulation**
  - **Validates: Requirements 5.1, 5.2, 5.3**



- [ ] 6. Implement retry strategy and error handling
  - Create RetryStrategy class with exponential backoff
  - Implement executeWithRetry() method
  - Add logic to identify retriable vs non-retriable errors
  - Configure max retries (3) and initial delay (500ms)

  - Integrate retry strategy into all UserRepository write operations
  - _Requirements: 6.1, 6.3_

- [ ] 6.1 Write property test for retry mechanism
  - **Property 10: Retry on network failure**
  - **Validates: Requirements 6.1**

- [ ] 6.2 Write property test for conflict resolution
  - **Property 11: Conflict resolution by timestamp**

  - **Validates: Requirements 6.3**

- [ ] 7. Add real-time listener support to UserRepository
  - Implement watchUser() that returns Stream<UserData?>
  - Set up Firestore snapshot listener
  - Handle listener errors and reconnection
  - Parse snapshots into UserData objects
  - Emit null when document doesn't exist

  - _Requirements: 7.1, 7.2, 7.3_


- [ ] 7.1 Write property test for listener reactivity
  - **Property 12: Real-time listener reactivity**
  - **Validates: Requirements 7.2, 7.3, 7.5**

- [ ] 8. Create UserDataProvider with state management
  - Create UserDataProvider extending ChangeNotifier
  - Add UserRepository dependency injection

  - Implement initialize() to set up listener when user authenticates
  - Add loading and error state management
  - Implement getters for userData, inventory, settings, stats, arcProgress
  - _Requirements: 1.3, 10.2, 10.3_

- [ ] 9. Implement data update methods in UserDataProvider
  - Implement updateArcProgress() that calls repository and notifies listeners


  - Implement addEvidence() for evidence collection
  - Implement updateInventory() for inventory changes
  - Implement purchaseItem() with validation and error handling
  - Implement updateSettings() for settings changes
  - Implement updateStats() for statistics updates
  - Add proper error handling and user feedback for all methods

  - _Requirements: 2.1, 2.2, 3.1, 3.2, 4.1, 5.1_


- [ ] 10. Implement listener lifecycle management in UserDataProvider
  - Subscribe to watchUser() stream in initialize()
  - Update local state when stream emits new data
  - Call notifyListeners() to update UI
  - Implement dispose() to cancel subscription
  - Handle listener errors gracefully
  - _Requirements: 7.1, 7.2, 7.3, 7.4, 7.5_



- [ ] 10.1 Write property test for listener cleanup
  - **Property 13: Listener cleanup on logout**
  - **Validates: Requirements 7.4**

- [ ] 11. Integrate UserDataProvider with AuthProvider
  - Listen to AuthProvider.authStateChanges in UserDataProvider

  - Call initialize() when user signs in
  - Call dispose() when user signs out
  - Handle user switching scenarios
  - Ensure proper cleanup between user sessions
  - _Requirements: 1.1, 1.4, 1.5_

- [x] 12. Update existing providers to use UserDataProvider


  - Refactor ArcProgressProvider to read from UserDataProvider

  - Refactor StoreProvider to use UserDataProvider for inventory
  - Refactor SettingsProvider to use UserDataProvider for settings
  - Remove duplicate data fetching logic
  - Ensure all providers listen to UserDataProvider changes
  - _Requirements: 10.3_



- [ ] 13. Add evidence preservation logic
  - Implement logic to preserve evidences when arc is restarted
  - Ensure evidencesCollected list is never cleared on restart
  - Add method to query all evidences across all arcs
  - Implement evidence aggregation for archive view
  - _Requirements: 8.3, 8.4, 8.5_

- [ ] 13.1 Write property test for evidence preservation
  - **Property 14: Evidence preservation on arc restart**
  - **Validates: Requirements 8.4**

- [ ] 14. Implement user initialization flow
  - Create helper method to check if user document exists
  - Implement first-time user initialization with default values
  - Set initial coins to 5000
  - Initialize empty arcProgress map
  - Set default settings (musicVolume: 0.7, sfxVolume: 0.8, etc.)
  - Initialize stats with accountCreatedAt timestamp
  - _Requirements: 1.2, 5.5_

- [ ] 15. Add Firestore security rules
  - Create firestore.rules file with user data access rules
  - Ensure users can only read/write their own documents
  - Add validation for required fields on write
  - Test security rules with Firebase emulator
  - Deploy rules to Firebase project
  - _Requirements: 1.1, 1.3_

- [ ] 16. Update app initialization to use new database system
  - Modify main.dart to provide UserDataProvider
  - Ensure UserDataProvider is initialized after AuthProvider
  - Update all screens to consume UserDataProvider
  - Remove old local-only state management
  - Test complete user flow from signup to gameplay
  - _Requirements: 1.1, 1.5, 10.3_

- [ ] 17. Checkpoint - Ensure all tests pass
  - Ensure all tests pass, ask the user if questions arise.

- [ ] 18. Add integration tests for complete user flows
  - Test signup → initialize → play → save → logout → login → load flow
  - Test purchase flow with insufficient funds
  - Test offline mode and sync on reconnection
  - Test concurrent updates from multiple devices
  - _Requirements: 1.5, 3.5, 6.2, 6.4_

- [ ] 19. Add monitoring and error logging
  - Integrate Firebase Crashlytics for error tracking
  - Add custom events for key operations (purchase, arc completion)
  - Log retry attempts and failures
  - Track listener disconnection frequency
  - Add performance monitoring for Firestore operations
  - _Requirements: 6.5_
