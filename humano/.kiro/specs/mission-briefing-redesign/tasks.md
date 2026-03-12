# Implementation Plan

- [x] 1. Update dialog container dimensions and constraints


  - Modify the Dialog widget in `_showArcBriefing` method to use new dimensions (maxWidth: 700, maxHeight: screenHeight * 0.7)
  - Update responsive breakpoint logic for small screens (< 700px)
  - Ensure container maintains proper constraints to prevent overflow
  - _Requirements: 1.1, 1.3, 1.4, 1.5, 4.1, 4.3_


- [ ] 2. Implement two-column layout structure
  - Replace the existing Column layout with a Row containing two Expanded widgets
  - Set flex factors: left column (flex: 3), right column (flex: 2)
  - Add vertical divider between columns with red accent color
  - Ensure proper spacing and padding for both columns

  - _Requirements: 1.2, 2.1, 3.1, 4.5_


- [ ] 3. Refactor left column with arc information
  - [ ] 3.1 Create arc title section with badge and name
    - Build Row layout with arc badge container and title text
    - Apply Press Start 2P font to arc title

    - Implement responsive font sizing based on screen height
    - _Requirements: 2.2, 4.1_
  
  - [ ] 3.2 Build information card components
    - Create reusable card widget structure with icon, title, and description
    - Implement three cards: Objective (yellow), Controls (blue), Danger (red)

    - Apply consistent spacing between cards
    - Use icons and colored borders to differentiate card types
    - _Requirements: 2.3, 2.4, 2.5_
  

  - [x] 3.3 Implement text overflow handling

    - Add maxLines and TextOverflow.ellipsis to all text widgets
    - Ensure descriptions fit within card constraints
    - Test with various content lengths
    - _Requirements: 1.5, 2.3_


- [ ] 4. Refactor right column with action buttons
  - [ ] 4.1 Create vertical button layout
    - Build Column with MainAxisAlignment.center
    - Add Spacer widgets for vertical centering
    - Implement consistent spacing between buttons (16px)
    - _Requirements: 3.2, 3.3, 3.4_

  
  - [ ] 4.2 Style cancel button
    - Create OutlinedButton with grey border
    - Apply Courier Prime font with proper sizing
    - Set full width using SizedBox or constraints

    - Implement onPressed to close dialog
    - _Requirements: 3.2, 3.5, 4.4_
  
  - [ ] 4.3 Style start button
    - Create ElevatedButton with red background
    - Add play icon next to text

    - Apply elevation and shadow for prominence
    - Set full width and implement onPressed to start arc
    - _Requirements: 3.2, 3.5, 4.4_

- [ ] 5. Implement responsive design adjustments
  - Add conditional logic for small screens (< 700px height)

  - Adjust font sizes, padding, and spacing based on screen size
  - Ensure buttons remain fully visible and accessible
  - Test layout on various screen dimensions
  - _Requirements: 1.3, 4.1, 4.2, 4.3, 4.4_



- [x] 6. Remove scroll functionality

  - Remove SingleChildScrollView wrapper from content
  - Verify all content fits within viewport without scroll
  - Add safety constraints to prevent overflow
  - Test on minimum supported screen size (600px height)
  - _Requirements: 1.1, 1.5_


- [ ] 7. Update header section for wider dialog
  - Adjust header padding and spacing for new dialog width
  - Ensure title and close button are properly aligned
  - Maintain consistent styling with new layout
  - _Requirements: 1.2, 4.3_


- [ ] 8. Test and validate implementation
  - [ ] 8.1 Test on multiple screen sizes
    - Verify layout on small phone (600-700px height)
    - Verify layout on medium phone (700-800px height)
    - Verify layout on large phone/tablet (800px+ height)
    - _Requirements: 1.3, 4.1, 4.2, 4.3_
  
  - [ ] 8.2 Verify functional behavior
    - Test close button dismisses dialog
    - Test cancel button dismisses dialog
    - Test start button launches arc correctly
    - Test dialog dismissal by tapping outside
    - _Requirements: 3.2, 4.4_
  
  - [ ] 8.3 Validate visual design
    - Verify no scroll appears on any screen size
    - Check text readability at all font sizes
    - Verify proper spacing and alignment
    - Confirm color scheme matches design
    - _Requirements: 1.1, 1.3, 2.4, 2.5, 3.5_
