# Design Document

## Overview

El rediseño del manual de misión transforma el diálogo actual de una columna vertical con scroll a un layout horizontal de dos columnas sin scroll. La información del arco se presenta en la columna izquierda (60% del ancho) y los botones de acción en la columna derecha (40% del ancho). El diseño utiliza todo el espacio disponible del viewport de manera eficiente, eliminando la necesidad de scroll y mejorando la experiencia visual.

## Architecture

### Component Structure

```
Dialog (Container)
├── Header (Row)
│   ├── Icon + Title
│   └── Close Button
└── Body (Row) - Two Column Layout
    ├── Left Column (Flex: 3)
    │   ├── Arc Badge + Title
    │   ├── Objective Section
    │   ├── Controls Section
    │   └── Danger Section
    └── Right Column (Flex: 2)
        ├── Spacer
        ├── Cancel Button
        ├── Spacing
        └── Start Button
```

### Layout Strategy

- **Dialog Container**: Fixed constraints with responsive sizing
  - Max width: 700px (increased from 380px)
  - Max height: 70% of screen height
  - Maintains aspect ratio and prevents overflow

- **Two-Column Layout**: Uses Row with Expanded widgets
  - Left column: Flex factor 3 (60%)
  - Right column: Flex factor 2 (40%)
  - Vertical divider between columns for visual separation

- **Responsive Behavior**:
  - Small screens (< 700px height): Reduced font sizes and padding
  - Maintains two-column layout on all supported screen sizes
  - Adaptive spacing based on available height

## Components and Interfaces

### 1. Dialog Container

**Purpose**: Main container for the briefing dialog

**Properties**:
- `maxWidth`: 700 (responsive)
- `maxHeight`: screenHeight * 0.7
- `backgroundColor`: Color(0xFF0A0A0A)
- `borderRadius`: 12
- `border`: Red accent with opacity 0.3

**Behavior**:
- Centers on screen
- Dismissible by tapping outside or close button
- Maintains fixed size regardless of content

### 2. Header Section

**Purpose**: Display title and close button

**Layout**: Row with space-between alignment

**Components**:
- Icon (article)
- Title text: "MANUAL DE MISIÓN"
- Close button (IconButton)

**Styling**:
- Background: Colors.red.shade900
- Height: Adaptive (40-50px)
- Border bottom: Red accent

### 3. Left Column - Arc Information

**Purpose**: Display all arc-related information

**Layout**: Column with MainAxisSize.min

**Sections**:

#### 3.1 Arc Title Section
- Arc badge (e.g., "ARCO 1")
- Arc name (e.g., "GULA")
- Horizontal layout with badge + title

#### 3.2 Information Cards
Each card follows this structure:
- Container with colored border
- Icon in colored background circle
- Title text (small, uppercase)
- Description text (larger, readable)

**Card Types**:
1. **Objective Card** (Yellow accent)
   - Icon: flag
   - Title: "OBJETIVO"
   - Description: Dynamic based on arc

2. **Controls Card** (Blue accent)
   - Icon: videogame_asset
   - Title: "CONTROLES"
   - Description: Control scheme info

3. **Danger Card** (Red accent)
   - Icon: warning
   - Title: "PELIGRO"
   - Description: Enemy/hazard info

### 4. Right Column - Action Buttons

**Purpose**: Provide action buttons for user decision

**Layout**: Column with MainAxisAlignment.center

**Components**:

#### 4.1 Cancel Button
- Style: OutlinedButton
- Border: Grey with 2px width
- Text: "CANCELAR"
- Full width of column
- Action: Close dialog

#### 4.2 Start Button
- Style: ElevatedButton
- Background: Colors.red.shade700
- Text: "INICIAR" with play icon
- Full width of column
- Elevated appearance (shadow)
- Action: Close dialog and start arc

**Spacing**:
- Vertical spacing between buttons: 16px
- Padding around buttons: 20px

### 5. Vertical Divider

**Purpose**: Visual separation between columns

**Properties**:
- Width: 1px
- Color: Red with opacity 0.2
- Height: Full body height
- Positioned between left and right columns

## Data Models

### Arc Data Structure (Existing)
```dart
class Arc {
  final String id;
  final String title;
  final String subtitle;
  final String description;
  // ... other properties
}
```

### Briefing Configuration
```dart
class BriefingConfig {
  final String objective;
  final String controls;
  final String danger;
  
  // Could be extended per arc
  static BriefingConfig forArc(String arcId) {
    switch (arcId) {
      case 'arc_1_gula':
        return BriefingConfig(
          objective: 'Recolecta 5 evidencias',
          controls: 'Joystick + Botón morado',
          danger: 'Enemigo agresivo',
        );
      // ... other arcs
    }
  }
}
```

## Styling and Theming

### Color Palette
- **Background**: Color(0xFF0A0A0A) - Near black
- **Border**: Colors.red with opacity 0.3
- **Header**: Colors.red.shade900
- **Accent Colors**:
  - Yellow: Colors.yellow (Objective)
  - Blue: Colors.blue (Controls)
  - Red: Colors.red (Danger)

### Typography
- **Font Family**: Google Fonts - Courier Prime (monospace theme)
- **Alternative**: Press Start 2P for arc titles

**Font Sizes** (Responsive):
- Header title: 12-13px
- Arc badge: 9-10px
- Arc title: 12-14px (Press Start 2P)
- Card title: 9-10px
- Card description: 10-11px
- Button text: 10-11px

### Spacing System
- **Small screens** (< 700px):
  - Container padding: 16px
  - Section spacing: 8-12px
  - Button padding: 10px vertical
  
- **Normal screens** (>= 700px):
  - Container padding: 20px
  - Section spacing: 12-16px
  - Button padding: 12px vertical

## Responsive Design

### Breakpoints
- **Small**: screenHeight < 700px
- **Normal**: screenHeight >= 700px

### Adaptive Elements

| Element | Small Screen | Normal Screen |
|---------|-------------|---------------|
| Dialog max width | 650px | 700px |
| Dialog max height | 65% | 70% |
| Header padding | 10px vertical | 12px vertical |
| Body padding | 16px | 20px |
| Icon size | 18px | 20px |
| Font sizes | -1 to -2px | Base size |
| Button padding | 10px vertical | 12px vertical |

### Layout Constraints
- Minimum dialog width: 500px
- Minimum dialog height: 400px
- Left column minimum width: 300px
- Right column minimum width: 180px

## Error Handling

### Overflow Prevention
1. **Text Overflow**: Use `maxLines` and `TextOverflow.ellipsis` for all text widgets
2. **Container Constraints**: Set explicit `maxHeight` and `maxWidth` on all containers
3. **Flexible Widgets**: Use `Expanded` and `Flexible` appropriately to prevent rigid sizing
4. **SingleChildScrollView Fallback**: While the goal is no scroll, wrap content in SingleChildScrollView with `physics: NeverScrollableScrollPhysics()` as safety measure

### Edge Cases
1. **Very small screens** (< 600px height): Show simplified version or warning
2. **Very wide screens**: Cap dialog width at 700px to maintain readability
3. **Missing arc data**: Show placeholder text instead of crashing
4. **Long text content**: Truncate with ellipsis after 2-3 lines

## Testing Strategy

### Visual Testing
1. Test on multiple screen sizes:
   - Small phone (600px height)
   - Medium phone (700px height)
   - Large phone (800px+ height)
   - Tablet (1000px+ height)

2. Verify no scroll appears on any supported screen size

3. Check text readability at all font sizes

4. Verify button accessibility (tap targets >= 44px)

### Functional Testing
1. Verify close button dismisses dialog
2. Verify cancel button dismisses dialog
3. Verify start button dismisses dialog and launches arc
4. Test dialog dismissal by tapping outside
5. Verify responsive behavior on screen rotation

### Integration Testing
1. Test with all 7 arcs to ensure content fits
2. Verify arc data loads correctly
3. Test navigation flow: selection → briefing → game
4. Verify dialog appearance with different arc states (locked/unlocked)

## Implementation Notes

### Key Changes from Current Design
1. **Layout**: Column → Row (two columns)
2. **Width**: 380px → 700px
3. **Scroll**: Removed completely
4. **Button placement**: Bottom footer → Right column
5. **Information density**: Increased with better space utilization

### Migration Strategy
1. Create new `_showArcBriefingRedesigned` method
2. Test alongside existing implementation
3. Switch flag to enable new design
4. Remove old implementation after validation

### Performance Considerations
- No scroll means no ScrollController overhead
- Fixed layout reduces rebuild complexity
- Minimal widget tree depth for better performance
