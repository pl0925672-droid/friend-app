# UI/UX Design Specifications

## 🎨 Design System

### Color Palette

#### Primary Colors
```
Primary Gradient (Main CTA, Highlights):
- Start: #6C5CE7 (Purple)
- End: #A29BFE (Light Purple)

Secondary Gradient (Success, Positive):
- Start: #00B894 (Green)
- End: #55EFC4 (Light Green)

Danger/Error:
- #FF6B6B (Red)

Warning:
- #FFD93D (Yellow)

Info:
- #74B9FF (Light Blue)
```

#### Neutral Colors
```
Dark Mode:
- Background: #1A1A2E (Very Dark Blue)
- Surface: #16213E (Dark Blue)
- Surface Variant: #0F3460 (Card Background)
- Text Primary: #FFFFFF
- Text Secondary: #A0A0A0
- Border: #2E2E4A

Light Mode:
- Background: #F8F9FA (Almost White)
- Surface: #FFFFFF (White)
- Surface Variant: #F5F6F7 (Gray)
- Text Primary: #1A1A1A (Dark Gray)
- Text Secondary: #757575 (Medium Gray)
- Border: #E0E0E0
```

### Typography

```
Font Family: Inter (System Default)

Heading 1 (32px):
- Font Weight: 700 (Bold)
- Line Height: 1.25
- Letter Spacing: -0.5px
- Usage: Page titles, headers

Heading 2 (24px):
- Font Weight: 700 (Bold)
- Line Height: 1.3
- Letter Spacing: -0.3px
- Usage: Section headers

Heading 3 (20px):
- Font Weight: 600 (Semi-Bold)
- Line Height: 1.4
- Letter Spacing: 0px
- Usage: Subheadings

Body Large (16px):
- Font Weight: 400 (Regular)
- Line Height: 1.5
- Letter Spacing: 0.5px
- Usage: Primary text, body copy

Body Medium (14px):
- Font Weight: 400 (Regular)
- Line Height: 1.43
- Letter Spacing: 0.25px
- Usage: Secondary text

Label (12px):
- Font Weight: 500 (Medium)
- Line Height: 1.33
- Letter Spacing: 0.4px
- Usage: Labels, captions

Button Text (14px):
- Font Weight: 600 (Semi-Bold)
- Line Height: 1.43
- Letter Spacing: 0.5px
- Usage: All buttons
```

### Spacing System

```
Base Unit: 4px

xs: 4px (1x)
sm: 8px (2x)
md: 12px (3x)
lg: 16px (4x)
xl: 24px (6x)
xxl: 32px (8x)
xxxl: 48px (12x)

Grid: 4px to allow flexibility
Padding: Always multiples of 4px
Margins: Always multiples of 4px
```

### Border Radius

```
xs: 2px (Subtle)
sm: 4px (Inputs, small components)
md: 8px (Cards, buttons)
lg: 12px (Modals, large cards)
xl: 16px (Rounded cards)
pill: 999px (Badges, chips)
```

### Shadows

```
Elevation 1 (Small card, subtle):
Box Shadow: 0 1px 3px rgba(0,0,0,0.12), 0 1px 2px rgba(0,0,0,0.24)

Elevation 2 (Standard card):
Box Shadow: 0 3px 6px rgba(0,0,0,0.15), 0 2px 4px rgba(0,0,0,0.12)

Elevation 3 (Modal, large card):
Box Shadow: 0 10px 20px rgba(0,0,0,0.19), 0 6px 6px rgba(0,0,0,0.23)

Elevation 4 (Floating action button):
Box Shadow: 0 15px 25px rgba(0,0,0,0.15), 0 5px 10px rgba(0,0,0,0.05)

Dark Mode Adjustment:
Reduce opacity by 20% for dark background
```

### Animations

```
Transition Durations:
- Quick: 100ms (hover effects, tooltips)
- Standard: 300ms (fade in/out, slide)
- Slow: 500ms (large animations)

Easing Functions:
- Ease In: cubic-bezier(0.4, 0, 1, 1) - Open animations
- Ease Out: cubic-bezier(0, 0, 0.2, 1) - Close animations
- Ease In-Out: cubic-bezier(0.4, 0, 0.2, 1) - Movement

Common Animations:
- Fade: opacity 300ms ease-in-out
- Slide-up: translate Y -10px, opacity, 300ms ease-out
- Scale: transform scale(0.95) → scale(1), 200ms ease-out
- Bounce: Lottie animation for delightful moments
```

---

## 📱 Screen-wise UI Breakdown

### 1) AUTHENTICATION SCREENS

#### 1A - Splash/Onboarding Screen
```
[HERO IMAGE - Colorful gradient with app illustration]
                    
║                                              ║
║         Welcome to Friend Study              ║
║    Stay Productive, Study Together           ║
║                                              ║
║  🎯 Track productivity
║  👥 Connect with friends
║  📝 Share notes & insights
║                                              ║
║        [Get Started] [Login]                 ║
║                                              ║

Layout: Center-aligned, 1 column
Colors: Gradient background from purple to blue
Typography: Large heading (H1), description text
Spacing: Padding 16px on sides, elements 24px apart
```

#### 1B - Sign Up Screen
```
[HEADER]
[APP LOGO]
    Join Friend
    
[FORM FIELDS]
Full Name: [________] 🚀
Email: [______________]
Username: [___________] ✓ (available)
Password: [___________] 👁️
Confirm Password: [___________]

[STUDY FOCUS - Optional]
📚 Computer Science ▼

[TERMS CHECKBOX]
☑️ I agree to Terms & Privacy Policy

[SIGN UP BUTTON - Full Width, Gradient]
Already have account? Sign In

Validation:
- Real-time email availability check
- Password strength indicator (weak/fair/strong)
- Username availability with checkmark
- Visual password rules

Layout: Scrollable form, 1 column
Form Spacing: 12px between fields
Button Height: 48px (min-touch-target)
```

#### 1C - Login Screen
```
[HEADER - Minimal]
Friend
    
[FORM FIELDS]
Email: [______________]
Password: [___________] 👁️

[Forgot Password Link - Right aligned]

[LOGIN BUTTON - Full Width, Gradient]

[OR DIVIDER]

[Google Sign In] [Facebook Sign In]

Don't have account? Sign Up

Dialog for forgot password:
- Email input
- Send reset link CTA
```

#### 1D - Profile Setup Screen
```
[HEADER]
Complete Your Profile

[PROFILE PHOTO]
        [📷 Upload Photo]
        John Doe

[FORM FIELDS]
Study Focus: [🎓 Choose Field ▼]
Options: CS, Medicine, Commerce, Arts, etc.

Bio: [Write something about yourself...]
(Optional, max 150 chars)

[Continue Button]

Validation:
- Photo is optional but recommended
- Study focus has dropdown with search
```

---

### 2) MAIN DASHBOARD SCREENS

#### 2A - Home Dashboard (Main Screen)
```
[HEADER - Material You Style]
👋 Good Morning, John

[HEALTH CARDS - Horizontal Scrolling Row]
┌─────────────┐  ┌─────────────┐
│ 📚 6.5 hrs  │  │ 😴 8 hrs    │
│ Today Study │  │ Sleep       │
│ Productive  │  │ Excellent   │
└─────────────┘  └─────────────┘

[QUICK ACCESS BUTTONS]
[📝 Log Activity] [🎯 Add Goal] [📘 New Note]

[THIS WEEK PROGRESS]
┌──────────────────────────────┐
│ Study Hours: 42.5 / 50 hrs    │  ████████░░
│ Goal Completion: 85%          │  ████████░
└──────────────────────────────┘

[UPCOMING GOALS - Cards]
┌────────────────────────────────────┐
│ 📌 Complete React Course           │
│ 📅 Due in 3 days                   │
│ ████████░░ 75%                     │
│ [View Details]                     │
└────────────────────────────────────┘

[RECENT ACTIVITY - Timeline]
Today, 10:30 AM
  📚 Studied React (2.5 hrs)
  😊 Feeling great

Yesterday, 2:00 PM
  📝 Created note: "Hooks Guide"

[BOTTOM TAB]
[🏠Home] [👥Friends] [💬Chat] [📝Notes] [⚙️Settings]

Colors: 
- Header gradient background
- Card backgrounds with shadow elevation-1
- Icons with primary purple color
```

#### 2B - Daily Activity Logger Screen
```
[HEADER]
Log Activity - 9 Feb, 2024

[DATE SELECTOR]
◀️ Today: 9 Feb, 2024 ▶️

[STUDY SECTION]
📚 Study Hours
[5.5] hours ▲▼

Subject: [React.js] ▼
Available: React, Node.js, Docker, etc.

Study Notes: [____________________]
"Completed auth module, started chat"

[WELLNESS SECTION]
😴 Sleep Hours: [8.0] hours
[Good] ▼

[MOOD TRACKING]
How was your day? 
😭 😞 😐 😊 😄
   Selected: 😊

Mood Notes: [_____________________]
"Productive and energized"

[TAGS - Chip Style]
[🔖 productive] [🔖 networking]
[+ Add tag]

[SAVE BUTTON - Full Width]

[DELETE] (if editing existing)

Timeline validation:
- Can't log future activities
- Can edit past 30 days
- Auto-save draft every 30 seconds
```

#### 2C - Goals Screen
```
[HEADER]
My Goals

[TAB VIEW]
[Active] [Completed] [Failed]

[GOALS CARDS - Under Active Tab]
┌──────────────────────────────────┐
│ 🎯 50 Hours Study Goal           │
│ Weekly • Thu, 16 Feb             │
│ Progress: 32.5 / 50 hrs          │
│ ████████░░ 65%                   │
│ Days left: 3                      │
│ [+ Log] [View Details]           │
└──────────────────────────────────┘

┌──────────────────────────────────┐
│ 📖 Read 2 Books                  │
│ Monthly • Feb 2024               │
│ Progress: 1 / 2                  │
│ ██████░░░░ 50%                   │
│ Days left: 20                    │
│ [+ Log] [View Details]           │
└──────────────────────────────────┘

[Completed Goals Collapsed]
✅ 15 completed goals this year

[FLOATING ACTION BUTTON]
┌─────────┐
│ [➕ New] │  Purpose: Create new goal
└─────────┘

Dialog - Create Goal:
Title: [______________________]
Description: [_________________]
Type: [Weekly] ▼
Duration: From [9 Feb] To [16 Feb]
Target: [50] [hours] ▼
[Create] [Cancel]

Animations:
- Smooth expansion of completed section
- Card elevation on tap
- Progress bar animation on update
```

---

### 3) SOCIAL & FRIENDS SCREENS

#### 3A - Friends List Screen
```
[HEADER]
Friends • 47

[SEARCH / FILTER]
🔍 Search friends...
[Filter ▼]

[FRIENDS LIST - Grouped by Status]
ONLINE (23)
┌──────────────────────────────────┐
│ 👤 Alice Smith        ● Online   │
│ 📚 Medicine          ⏰ 2m ago   │
│ [👥] [💬]                        │
└──────────────────────────────────┘

┌──────────────────────────────────┐
│ 👤 Bob Johnson        ● Online   │
│ 📚 Computer Science   ⏰ Now    │
│ [👥] [💬]                        │
└──────────────────────────────────┘

OFFLINE (24)
┌──────────────────────────────────┐
│ 👤 Carol Williams     ○ Offline  │
│ 📚 Engineering        ⏰ 2h ago  │
│ [👥] [💬]                        │
└──────────────────────────────────┘

[View Profile] opens profile modal
[Message] opens chat with friend

Interactions:
- Long press for context menu (unfriend, block, etc.)
- Tap for profile card
```

#### 3B - Discover/Find Friends Screen
```
[HEADER]
Discover Friends

[SEARCH BAR]
🔍 Search by username or name...

[QUICK FILTERS]
[🎓 All Streams] [💻 CS] [🏥 Medicine] [🔧 Engineering]

[DISCOVERY CARDS - Infinite Scroll]
┌──────────────────────────────────────┐
│      👤 Profile Photo (Large)        │
│      John Developer                  │
│      📚 Computer Science             │
│      "Passionate about Flutter"      │
│      👥 124 friends • Online         │
│                                      │
│    [Add Friend] [View Profile]      │
└──────────────────────────────────────┘

[STATUS AFTER ACTION]
✅ Friend Request Sent (changes to "Pending")
✓ Already Friends (if already friends)

Pagination: Infinite scroll with loading indicator
```

#### 3C - Friend Requests Screen
```
[HEADER]
Friend Requests

[TAB VIEW]
[Received (5)] [Sent (2)]

[RECEIVED TAB]
┌──────────────────────────────────────┐
│ 👤 Alex Turner                       │
│ 📚 Arts                              │
│ Sent 2 hours ago                     │
│                                      │
│ [✓ Accept] [✗ Reject] [View Profile]│
└──────────────────────────────────────┘

[NO NEW REQUESTS - Empty State]
🎉 All caught up!
All your friend requests are handled.

[Sent Tab shows:]
Time ago, Status (Pending/Accepted)
```

---

### 4) CHAT SCREENS

#### 4A - Chat List Screen
```
[HEADER]
Messages
🔍

[SEARCH BAR]
🔍 Search conversations...

[ACTIVE CHATS]
┌────────────────────────────────────────┐
│ Study Community    🔔 (45 unread)     │
│ "Are you free tonight?" - 2m ago      │
│ 👥 150 members        Last seen: now  │
└────────────────────────────────────────┘

┌────────────────────────────────────────┐
│ 👤 Alice Smith              ● Online   │
│ "Sounds great!let's discuss" - 10m ago│
│ 2 unread messages                      │
└────────────────────────────────────────┘

┌────────────────────────────────────────┐
│ 👤 Bob Johnson              ○ 2h ago   │
│ "Thanks for the notes" - 1 hour ago   │
│ No unread                              │
└────────────────────────────────────────┘

[FLOATING ACTION BUTTON]
│ ✉️ New Chat │

Swipe actions:
- Left: Mark unread / Archive
- Right: Delete (with confirmation)

Material You elevation and shadows on cards
```

#### 4B - Group Chat Screen (Study Community)
```
[HEADER - Sticky]
Study Community    👥 150        ⓘ

[MESSAGE LIST - Scrollable, Date Dividers]

Today

[10:30]
👤 Alice Smith
"Anyone up for study session?"
✓✓ (seen)

[10:45]
👤 Bob Johnson
"Yes! When?"
✓ (delivered)

[10:50]
"You"
"Around 3 PM?"
✓✓ (seen by Bob, Alice)

[REACTIONS - Under message hover]
👍 😂 ❤️ 😍 ...

[IMAGE MESSAGE]
[Thumbnail of image]
"Check out this concept diagram"
✓✓

[TYPING INDICATOR]
Alice is typing...

[BOTTOM - Sticky Input]
┌────────────────────────────────────┐
│ [😊] [📎] [🎤]  Message...    [➤] │
└────────────────────────────────────┘

Features:
- Emoji picker (slide-up)
- File upload (documents, images)
- Voice message recording
- Message search
- Reply/Quote functionality
- Rich message formatting (beta)

Animation:
- Messages fade-slide in
- Typing dots floating animation
- Emoji reaction pop animation
```

#### 4C - Private 1-to-1 Chat Screen
```
[HEADER - Sticky]
Alice Smith
● Online
[ⓘ] [📱] [⋮]  (info, call, more options)

[MESSAGE THREAD - Same as group but 1-to-1]

[TYPING INDICATOR]
Alice is typing...

[BOTTOM INPUT]
Augmented with:
- Quick replies (suggestion chips)
- Share note button
- Status shown under messages

Read Receipt Indicators:
- Single ✓: Delivered
- Double ✓✓: Seen with timestamp

Status Icons:
- ⏱️ Sending
- ✓ Sent
- ✓✓ Delivered
- Read time "Seen 2m ago"
```

---

### 5) NOTES SHARING SCREENS

#### 5A - Notes Feed Screen
```
[HEADER]
Notes Feed
[🔍] [⋮]

[TABS]
[🕐 Newest] [🔥 Trending] [👍 Popular]

[SORT OPTIONS]
By [Latest ▼] Filter [All ▼]

[NOTES CARDS - Infinite Scroll]
┌──────────────────────────────────────┐
│ React Hooks Complete Guide           │
│ John Developer • Computer Science    │
│ 2 hours ago                          │
│                                      │
│ Complete guide to React Hooks...    │
│ [Click to expand preview]            │
│                                      │
│ [❤️ 125] [💾 45] [👁️ 500] [↗️]    │
│ [#react] [#hooks] [#javascript]      │
│                                      │
│ [Read Note] [Share]                 │
└──────────────────────────────────────┘

[EMPTY STATE]
📝 No notes yet!
Create your first note to share.
[Create Note] [Browse Community]

Bottom Sheet on Note Card:
- Read full note
- Like/Unlike
- Save/Unsave
- Share to chat
- Report/Flag (future)
- View author profile

UI Notes:
- Card elevation 1
- Clean typography hierarchy
- Icons match primary color
- Smooth transitions
```

#### 5B - Create/Edit Note Screen
```
[HEADER]
Create Note    [Save] [✓]

[TITLE INPUT]
┌─────────────────────────────┐
│ React Hooks Complete Guide  │
└─────────────────────────────┘
(max 100 chars, counter)

[SUBJECT SELECTOR]
📚 Computer Science ▼

[CONTENT EDITOR - Rich Text]
┌──────────────────────────────────┐
│ [B] [I] [→] [•] [#] [...]        │ Formatting toolbar
├──────────────────────────────────┤
│ Complete guide to React Hooks    │
│                                  │
│ ## useState Hook                 │
│ The useState hook allows you...  │
│                                  │
│ ## useEffect Hook                │
│ Handle side effects...           │
│                                  │
│ [Insert Image] [Insert Code]    │
└──────────────────────────────────┘

[TAGS INPUT]
[🔖 react] [🔖 hooks] [🔖 javascript]
[+ Add tag]

[VISIBILITY]
☑️ Public (Everyone can see)
○ Private (Only me)

[Save Draft] [Publish] [Preview]

Auto-save: Every 10 seconds to draft
Keyboard: Auto-dismiss keyboard on scroll
```

#### 5C - View Note Screen
```
[HEADER - Sticky]
◀️ React Hooks Guide    [↗️] [⋮]

[AUTHOR INFO]
👤 John Developer
📚 Computer Science
2 hours ago | ❤️ 125 | 👁️ 500

[CONTENT]
[Beautiful rendered markdown with syntax highlighting]
- Code blocks with copy button
- Images displayed full-width
- Links clickable

[ENGAGEMENT]
┌────────────────────────────────────┐
│ [❤️ Like] [💾 Save] [↗️ Share]    │
└────────────────────────────────────┘

[TAGS]
[react] [hooks] [javascript]

[RELATED NOTES]
"Recommended for you"
┌─────────────────────────────────┐
│ Advanced React Patterns - Alice  │
│ "You may also like..."           │
└─────────────────────────────────┘

[COMMENTS - Future Feature]
Coming soon...

Bottom Action:
Share to Chat → Select chat room
```

---

### 6) ANALYTICS & REPORTS SCREENS

#### 6A - Weekly Report Screen
```
[HEADER]
Weekly Report
📅 Feb 5-11, 2024

[SUMMARY CARDS - Horizontal Scroll]
┌──────────────────┐
│ 📚 Total Study   │
│ 42.5 Hours       │
│ ↑ 11% vs last wk │
└──────────────────┘

┌──────────────────┐
│ 😴 Avg Sleep     │
│ 7.8 Hours        │
│ ✓ Excellent      │
└──────────────────┘

┌──────────────────┐
│ 🎯 Goals Done    │
│ 85%              │
│ ✓ On track!      │
└──────────────────┘

[CHART - Study Hours by Day]
Bar chart | Mon Tue Wed Thu Fri Sat Sun
[Interactive, tap for details]

[CHART - Subjects Breakdown]
Pie chart | React: 15h, Node: 12.5h, Docker: 15h

[BEST & WORST DAYS]
┌─────────────────────────────┐
│ 🌟 Best Day: Feb 9          │
│ 📚 8.5 hrs • Mood: 😊      │
│ [View Details]              │
└─────────────────────────────┘

┌─────────────────────────────┐
│ 📉 Worst Day: Feb 6         │
│ 📚 4 hrs • Mood: 😔        │
│ [View Details]              │
└─────────────────────────────┘

[INSIGHTS]
💡 AI Insights
✓ Your consistency is great! Keep it up.
ℹ️ Try balanced subjects next week.
⚠️ Sleep schedule varies. Maintain routine.

[View Full Report] [Export PDF]
```

#### 6B - Monthly Report Screen
```
[HEADER]
Monthly Report
📅 February 2024

[KPI CARDS]
┌──────────────────────┐
│ 📚 Total Study       │
│ 165.5 Hours          │
│ vs Jan: ↑ 8%        │
└──────────────────────┘

┌──────────────────────┐
│ 📊 Consistency       │
│ 92%                  │
│ 28 / 30 days studied │
└──────────────────────┘

[LARGE LINE CHART - Study Hours Trend]
Daily study hours over the month
[Interactive, touch for data point details]

[SUBJECTS CONTRIBUTION]
┌────────────────────────────────────┐
│ React........... 45 hrs (27%)  ███ │
│ Node.js......... 35 hrs (21%)  ██░ │
│ Docker.......... 32 hrs (19%)  ██░ │
│ System Design.. 28 hrs (17%)  ██░ │
│ Other........... 25 hrs (16%)  ██░ │
└────────────────────────────────────┘

[MOOD TREND - Sparkline Chart]
Mood distribution over month
😭 0% | 😞 5% | 😐 15% | 😊 65% | 😄 15%

[AI-GENERATED INSIGHTS]
🤖 Smart Analysis
"Your productivity has improved 12% from last month.
Continue maintaining the 7.5h average sleep.
Diversify subjects for better learning engagement.

Prediction: If you maintain this pace, you'll exceed
March goals by 20%!"

[RECOMMENDATIONS]
→ Focus on weak areas (System Design)
→ Maintain sleep schedule
→ Increase time on fundamentals

[Export Options]
[📊 PDF Report] [📧 Email] [📱 Share]
```

#### 6C - Analytics Dashboard (Quick View)
```
[HEADER]
Analytics & Insights

[QUICK STATS - Cards]
┌──────────────────────────────────┐
│ This Week: 42.5 hrs              │
│ Last Week: 38.2 hrs              │
│ Trend: ↑ 11%                     │
│ [View Weekly Report]             │
└──────────────────────────────────┘

┌──────────────────────────────────┐
│ This Month: 165.5 hrs            │
│ Goals Completed: 3/4             │
│ Consistency: 92%                 │
│ [View Monthly Report]            │
└──────────────────────────────────┘

[QUICK INSIGHTS]
📌 Best Day: February 9
📌 Most Studied: React (45 hrs)
📌 Average Sleep: 7.8 hrs ✓
📌 Your Mood: Improving 📈

[COMPARE PERIODS]
┌─────────────────────────────────┐
│ [Last Week] [Last Month] [YTD]  │
│                                 │
│ Card shows comparison metrics   │
└─────────────────────────────────┘

Animations: Smooth transitions between periods
```

---

### 7) SETTINGS SCREENS

#### 7A - Profile Settings
```
[HEADER]
Profile Settings

[PROFILE HEADER]
[Large Photo]
John Doe
john_doe • Computer Science

[EDIT BUTTON]

[EDITABLE FIELDS]
Full Name: John Doe
[Edit]

Username: john_doe
[Edit] ← Shows availability check

Email: john@example.com
[Verified ✓]

Study Focus: Computer Science
[Edit ▼]

Bio: "Passionate about learning"
[Edit]

[SECTIONS]
Profile Photo
[Change Photo] [Remove]

Connected Accounts (Optional)
Google: Connected ✓
[Disconnect]

Privacy
Profile Visibility: Public ○ Private ○
Show Online Status: ON / OFF
Allow Friend Requests: ON / OFF
```

#### 7B - App Settings
```
[HEADER]
Settings & Preferences

[THEME]
Theme
○ Light Mode
○ Dark Mode
○ System Default ✓

[NOTIFICATIONS]
Notifications
ON / OFF [Toggle]

Message Notifications: ON / OFF
Friend Request Alerts: ON / OFF
Daily Summary Email: ON / OFF
Goal Reminders: ON / OFF
Note Likes/Saves: ON / OFF

Notification Sound: [Chime ▼]
Vibration: ON / OFF

[LANGUAGE & LOCALIZATION]
Language: [English ▼]
Time Zone: [GMT+5:30 ▼]
Date Format: [DD/MM/YYYY ▼]

[DATA & PRIVACY]
Export My Data
[Download All My Data] (JSON format)

Delete Account
[⚠️ Delete My Account]
⚠️ This action is permanent

[SUPPORT]
About App
Version 1.0.0
[Build 2024.02]

[Help Center] [Report Bug] [Feedback]

[LEGAL]
[Terms of Service] [Privacy Policy]
```

---

## 🎬 Navigation Structure

```
Bottom Navigation (Primary):
  🏠 Home / Dashboard
  👥 Friends & Social
  💬 Chat & Messaging
  📝 Notes & Share
  ⚙️ Settings & Profile

Modal Layers (Secondary):
  ↳ Profile View
  ↳ Goal Details
  ↳ Note Full View
  ↳ User Preferences

Drawer/Side Menu (Tertiary):
  ↳ Quick Links
  ↳ Help & Support
  ↳ App Info

Floating Action Buttons:
  Home: Log Activity, Add Goal
  Friends: New Chat
  Chat: New Conversation
  Notes: Create Note
  Settings: Edit Profile
```

---

## 🎨 Key Design Principles

1. **Colorful but Premium**
   - Gradient accents for key actions
   - Muted secondary colors
   - High contrast for accessibility
   - Consistent color psychology

2. **Modern & Clean**
   - Material You Design principles
   - Generous whitespace
   - No unnecessary elements
   - Smooth micro interactions

3. **Accessibility**
   - WCAG AA compliance minimum
   - 48px minimum touch targets
   - High contrast text (4.5:1 ratio)
   - Clear focus indicators
   - Descriptive alt text for images

4. **Performance-Focused UI**
   - Skeleton loaders instead of spinners
   - Lazy-load images
   - Smooth 60 FPS animations
   - No jank or stuttering

5. **User-Centric**
   - Contextual help tooltips
   - Clear empty states
   - undo/redo for destructive actions
   - Progressive disclosure
   - Smart defaults

---

## 📐 Component Library (Reusable)

All screens use these components:

```
Buttons:
- Primary Button (Full width option)
- Secondary Button
- Tertiary Button
- FAB (Floating Action Button)
- Icon Button

Form Fields:
- Text Input (with error states)
- Email Input (with validation)
- Password Input (with strength)
- Number Input
- Select Dropdown
- Date Picker
- Time Picker
- Checkbox
- Radio Button
- Toggle Switch
- Text Area

Cards:
- Basic Card
- Elevated Card
- Chat Message Card
- Note Card
- Goal Card
- Activity Card
- User Card

Lists:
- Simple List
- List with Avatars
- Expandable List
- Sticky Headers

Indicators:
- Progress Bar
- Linear Progress
- Circular Progress
- Badge
- Chip
- Divider

Dialogs:
- Alert Dialog
- Confirmation Dialog
- Input Dialog
- Bottom Sheet
- Snackbar (Toast)

Navigation:
- Bottom Navigation
- Tab Bar
- Navigation Drawer
- Breadcrumbs

Other:
- Avatar (User Photo)
- Skeleton (Loading)
- Empty State
- Error State
- Loading Indicator
- Tooltip
```

---

## 🌙 Dark Mode Implementation

All colors have dark mode equivalents:
- Background shifts to dark blue
- Text becomes light gray
- Shadows reduce opacity
- Icons maintain vibrancy
- Accent colors slightly adjusted for readability

Dark mode toggle location: Settings → Theme

---

## 📱 Responsive Design

All designs are mobile-first:
- 360px minimum width (Mobile)
- Tablet optimized (600px+)
- Web responsive (1200px+)

Layout adjustments:
- Bottom nav sticky on mobile
- Tablet: Side drawer for navigation
- Desktop: Multi-column layouts possible
