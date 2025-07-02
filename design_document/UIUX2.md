UI/UX design of SkillTalk app part 2 (design of the first part of sub pages of Skilltalk page (chat page))

Elements of each page
1- SkillTalk
SkillTalk page design 
Chat selection
Chat conversation screen
Sticker gallery of keyboard 

element of each page

1-SkillTalk

1-SkillTalk: Upgrade sticker(top left corner), select button(checklist Icon for selecting and deleting chats), title (“SkillTalk” top middle), Add Contact button (Add Contact Icon for QR code and connecting with Qr code), search bar, chats

Design Breakdown of the “Skill Talks” Page
1. Header Section
• Title: “Skill Talks” (Centered, Bold)
• Icons (Top Right Corner):
• checklist Icon (Three horizontal lines with a dropdown arrow)
• Add Contact Icon (Person with a plus sign)
.call icon
• Upgrade Button (Top Left Corner):
• “Upgrade VIP” Badge (Gold crown with “VIP” and a red “Upgrade” tag)
2. Search Bar
• Rounded Search Field (Light Gray Background, Placeholder Text):
• Placeholder: “See who’s online”
• Icon: Magnifying glass (Left side of the search bar)
3. 🔄 Feature Buttons Row:
• Quick access to:
• All Courses  → structured learning
• Pro partner
• Translate → quick text/voice translation
• Skill AI → likely an AI tutor/chatbot
• More (likely expandable)  reveals more features or tools 

4. Chat List Section
• Each Chat Entry Contains:
• Profile Picture (Circular, Left-Aligned)
• Contact Name (Bold Text, Left-Aligned)
• Verification Badge (“ST” with a teal check mark, next to verified contacts)
• Last Message Preview (Gray Text, Left-Aligned)
• Timestamp (Right-Aligned, Light Gray Text)
• Unread Message Count (bright teal Badge, Right-Aligned, Only on Unread Chats)
• some future of Chat Entries:
• Timestamp:
• Unread Messages: “1” (Bright teal Badge)
• Flag Icon (User country Flag) Next to Profile Picture

Design Notes:
• Minimalist UI with rounded elements (search bar, profile pictures, badges)
• Color-coded notifications:
• bright teal for unread messages
• Gold for VIP upgrade
• Gray for inactive states
• Left-to-right chat layout: Profile picture → Name → Message preview → Timestamp → Notification badge

UI/UX Breakdown: Pop-Up from “Add Contact” Icon (Top-Right Corner)
5. Pop-Up Design (Main Focus)
Visual Design:
• Style: iOS-native style pop-up with rounded corners and slight drop shadow.
• Background color: White.
• Text Color: Black.
• Icons: Solid black, minimalist icons aligned left.
Pop-Up Options (from top to bottom):
1. Group Chat / Group Call
• Icon: Chat bubble with a person inside.
• Opens an interface to start a group conversation or group voice/video call.
2. Add Partner
• Icon: Person with a “+”
• Likely opens a search/add friend feature by username or ID.
3. Scan QR Code
• Icon: QR code with a scan bar.
• Likely opens the device’s camera to scan another user’s SkillTalk QR code.
Spacing and Separation:
• Thin dividing lines between each option ensure clarity and usability.

6. Bottom Navigation Bar
Five-tab layout with labeled icons:
• SkillTalk (Chat Icon, Bright teal Notification Badge “the count of unread messages”, bright teal chat bubble icon, currently selected (highlighted in bright teal).)
• Match (handshake Icon, No Badge)
• Posts (post Icon, No Badge)
• Voiceroom (simple microphone Icon, No Badge)
• Me (Profile Icon, No Badge)

• The SkillTalk tab also has a badge with “4” in a red circle, indicating new unread chats or notifications.

Functionality of This Pop-Up
Trigger:
Appears when the user taps the “Add Contact” icon in the top right corner of the “Language Talks” screen.
Purpose:
• Provides quick actions related to connecting with others:
• Starting new group interactions.
• Adding individual contacts.
• Scanning codes for fast connections.
User Experience Highlights:
• Quick access to key social features in a central location.
• Minimal taps needed.
• Icons + labels improve accessibility and understanding.
• Maintains consistency with iOS design standards, aiding usability.
—------------------------------------------------------------------


Chat selection

Here’s a full UI/UX breakdown of the “Selected” (conversation selection) screen in SkillTalk, based on your screenshots (before and after a chat is selected):
This setting appears when the user tap the checklist Icon (Three horizontal lines with a dropdown arrow) in the top right corner of the “SkillTalk” page

Page Title & Status Bar
• Title: “Selected” / “Selected (1)”
• Centered, bold, black font
• Updates dynamically based on number of selected conversations
• Top-left icon:
• X (close) icon to exit selection mode
• Solid black, simple, easily tappable
• Status Bar:
• Shows time, network, and battery info at top

Promotional Banner
• Placement: Directly under the title
• Content:
• Text: “Get this limited time VIP offer!”
• Subtext: Countdown timer (e.g., 02:51:37)
• “View” button on the right
• Design:
• Horizontal gradient background (blue to pink/Teal)
• White text and button with rounded corners

Chat List Section
• Each Chat Item Includes:
• Profile Image(s): Circular thumbnails (1 or more depending on if group or individual)
• Name: Bold black text (group or user name)
• Status or Message Preview: Lighter gray text, single line, truncated if long
• Country Flag (if applicable): Small flag icon overlayed on bottom-left of profile
• VIP Badge: Golden-yellow “V VIP” tag for certain users
• Selection Circle:
• Empty gray circle at the left of each conversation
• When selected:
• Turns Teal with a white checkmark
• Background remains white
• Example Items from Screenshot:
• Group: “Elia Farhang, faezeh, Nicole”
• Preview: “The owner has enabled mem…”
• User: “Donyasiiiimin”
• Preview: “سلام”
• VIP badge + USA flag
• User: “faezeh”
• Preview in Persian + warning icon

Bottom Toolbar
Appears at the bottom to allow batch actions:
• Design:
• White background
• Icons and labels spaced evenly across the width
• When no item is selected: some options disabled (grayed out)
• Buttons:
1. Read All / Read
• Black speech bubble icon
• Text: “Read All” (when nothing selected) / “Read” (after selection)
2. Archive
• Gray archive box icon
• Disabled if nothing is selected
3. Delete
• Red trash can icon
• Disabled if nothing is selected; active when a conversation is selected

Functionality Summary
• Purpose: Manage chats via bulk actions
• Interaction Flow:
1. Tap “Select” from chat homepage (not shown here)
2. Enter selection mode
3. Select chats via circles
4. Toolbar updates with available actions (e.g., delete, archive, mark as read)
5. Exit via top-left “X” icon
• User Feedback:
• Visual highlight (Teal check) when an item is selected
• Live update of selected count in header
• Disabled/enabled buttons reinforce which actions are available




Chat conversation screen

Here’s a full transcription and analysis of the app screen you’ve shared from a design, UI/UX, and functionality perspective:

SCREEN TYPE
Chat Conversation Screen — One-on-one message thread between two users in the SkillTalk application.

TOP BAR / HEADER
Elements:
• Back Arrow (Top Left): Returns to previous screen (e.g., chat list).
• User Info Block:
• Username: Andria
• Status Text: Active today (shown in light gray)
• Profile Picture: Circular, shows user’s image
• Gender & Age Badge: Pink icon (♀️) + 28 inside a pill-shaped rounded badge (#FFD9EC)
• Country: paris, france with french flag icon
• Zodiac Sign: Pisces in a pill-shaped bright Teal badge with symbol
• Call Icon (Top Right): For starting a voice call
• Settings/Gear Icon (Top Right): For chat settings, report/block options, etc.

MIDDLE AREA / CHAT BODY
Status Message:
• System Notification (Gray):
• "You recalled a message"
• "Tap here to turn on notifications and get replies from Skill Partners in real-time"
• Interactive Text: Go now (colored in #6D4AFF – vibrant bright Teal, tappable)
Chat Bubbles (Right-Aligned — Sent Messages):
• Language: Arabic (Right-to-left script)
• Bubble Color: Light lavender/bright Teal (#b3fff6)
• Text Color: Dark black (#000000)
• Messages shown:
سلام.
• Failed Message Indicator:
• Label: Failed
• Text Color: Red (#FF3B30)
• Placement: Below the last message

BOTTOM BAR / MESSAGE INPUT
UI Elements:
• Input Field:
• Placeholder Text: "Type a message..." (light gray)
• Background: White
• Rounded field with subtle border
• Action Icons (from left to right):
1. + (Plus Icon): Likely for attachments, more options
2. Image Icon: Attach image
3. Emoji Icon: Open emoji selector
4. Translate Icon (Globe + Letter): Likely for real-time translation or language selection
5. Microphone Icon (Far Right): Hold to record voice message

TYPOGRAPHY
• Username: Bold, ~17–18pt
• Status / Location: Light gray, ~14pt
• System Messages: Light gray, italic or semi-transparent, ~13pt
• Chat Text: Medium weight, ~15–16pt
• Action Text (“Go now”): bright Teal and underlined, ~14pt

COLORS USED
Element
Color Code
Background
#FFFFFF
System text
#999999
Chat bubble background
#e6fffc
Username
#000000
Action text (Go now)
#4dffea
Failed message
#FF3B30
Age badge background
#FFD9EC
Zodiac badge background
#80fff0 (with white text)
Icons
Black (#000000)


FUNCTIONALITY
Header / Top Section:
• User details are clearly visible for context
• Quick access to calling or reporting user
• Status (e.g., “Active today”) gives sense of real-time communication
Main Chat Area:
• Messages support right-to-left languages (important for global use)
• System alerts like “message recalled” enhance transparency
• Translation and correction likely available (icon present)
Input Bar:
• Flexible communication: text, image, emoji, voice, translation
• Minimal design to keep user focused on typing

UX INSIGHTS
• User-focused design: Large photo, zodiac, and location increase personalization
• Multilingual-friendly: Supports RTL scripts and translation tools
• Error recovery: Message failure alert provides clarity
• Quick navigation: Call/settings icons are always visible


SCREEN TYPE
Chat Screen – Message Action Menu Expanded
This is the same conversation view as before, but now the action panel (bottom sheet style) is expanded, showing extended interactive features.

TOP SECTION (Remains Constant)
• Header Bar (Top):
• Back Arrow (Top Left)
• Username: Andria
• Status Text: Active today
• Call Icon
• Settings Icon (Gear)
• Time & Battery Info (Top Right)

MESSAGE SECTION
• Chat Bubbles (Right-Aligned): Same light Teal color (#e6fffc) with black text.
• “Failed” Status Message: Red text, indicates message wasn’t delivered.
• System Message (Center, Gray Text):
• “You must receive a reply before sending further messages.”
• Font: Light, small (~13pt)
• Color: #999999

MESSAGE INPUT SECTION (DISABLED STATE)
• Input Field:
• Placeholder: Type a message…
• Background: #F2F2F2
• Rounded edges
• Slight opacity suggesting it’s temporarily disabled
• Voice Icon (Right Side): Still visible, black mic icon
• Icons (Left to Right):
1. Close (X) icon: Teal circle with white “x” — closes expanded menu
2. Image Icon: Upload photo
3. Emoji Icon: Opens emoji selector
4. Translate Icon (Globe + Letter): Real-time translation
5. Speech Bubble with Text Icon: Possibly opens voice-to-text or alternative input options

EXPANDED ACTION MENU (BOTTOM GRID)
This is a two-row grid of 8 action buttons. Each icon sits in a rounded-square background with soft color tones, making them distinguishable and friendly.
1st Row of Icons:
Icon
Label
BG Color
Icon Color
Phone
Voice Calls
#E6FAFB (light cyan)
Teal-blue
Gift Box
Gift
#E8EDFF (light periwinkle)
Royal Blue
Bookmark
Favorites
#E8EDFF (light blue)
Blue
Dollar Person
Paid Practice
#FFF3D9 (light yellow)
Gold

2nd Row of Icons:
Icon
Label
BG Color
Icon Color
Calendar
Create Plan
#FFF3D9 (light yellow)
Yellow-gold
Palette
Doodle
#E8EDFF (soft blue)
Blue
Group of People
Introduce
#F3FFCF (pastel green)
Lime Green
Pin Icon
Location
#FFE9DD (peach-pink)
Orange

• Font for Labels: Black, regular weight, ~13–14pt

PAGINATION DOTS (BOTTOM INDICATOR)
• Two dots: Signifies there are two pages of expanded menu options.
• Current page: Left dot is black (active), right dot is gray (inactive)

COLOR PALETTE OVERVIEW
Element
Hex Code
Background
#FFFFFF
System Message Text
#999999
Message Input Box BG
#F2F2F2
Failed Message Text
#FF3B30
Action Button Icons BG
Varies (pastels)
Icon Colors
Bright & clean (teal, blue, green, orange, etc.)
Close Icon (X) Circle
#4dffea (Teal)


FUNCTIONALITY OVERVIEW
Main Limitations:
• The message input field is locked (“You must receive a reply before sending further messages”). This suggests:
• Anti-spam feature
• Possibly a freemium restriction or system cooldown
Expanded Action Menu Buttons (Functional Description):
• Voice Calls: Initiate audio chat (maybe limited if blocked)
• Gift: Send virtual gifts (possibly in-app currency involved)
• Favorites: Save or favorite message/user profile
• Paid Practice: Connect with Skill partners for paid sessions
• Create Plan: Schedule a Skill session or chat time
• Doodle: Draw and share doodles (interactive communication)
• Introduce: Recommend this user to others or introduce yourself
• Location: Share current location or view theirs
X Icon (Teal Circle):
• Closes this action menu and returns to normal chat screen
Pagination Dots:
• Swiping horizontally reveals more options (not shown in this screen)

UX ANALYSIS
• Friendly & Welcoming: Pastel icons reduce friction and feel playful
• Locked Input Provides Clear Feedback: User understands they can’t proceed until a reply is received
• Bottom Sheet Style Menu: Easy thumb access, great for mobile UX
• Consistency in Iconography: Rounded-square buttons make scanning and tapping easy
• Microinteraction Ready: All icons suggest tappable animations (e.g., ripple on tap)


SCREEN TYPE
Chat Screen – Photo Upload Modal (Bottom Sheet Opened)
The user tapped the image icon to send a photo, triggering the iOS-style media picker modal.

TOP & CHAT SECTION (SAME AS BEFORE)
• Back Button, Username, Status:
• faezeh, Active today, back arrow
• Voice Call & Settings Icons: Top right
• Chat Bubble: Soft Teal message bubble (#e6fffc) right-aligned
• Failed Status: Red text (#FF3B30) aligned under a message

SYSTEM MESSAGE SECTION
• Text:
• “You must receive a reply before sending further messages.”
• Color: #999999
• Font: Regular, ~13pt
• Center-aligned

MESSAGE INPUT FIELD (DISABLED STATE)
• Input Placeholder:
• “Type a message…”
• Background: light gray (#F2F2F2)
• Rounded corners
• Microphone Icon: Right-side, black

BOTTOM INPUT TOOLBAR (ICONS)
From left to right:
Icon
Description
State
Color
➕ Plus Icon
Opens expanded menu
Default
Black
Image Icon
Opens media picker (current active icon)
Active
Teal #00d8c0
Smiley Face
Emoji picker
Inactive
Black
Globe + A
Translator
Inactive
Black
Speech Bubble/Text
Alt input?
Inactive
Black


MEDIA PICKER SECTION (BOTTOM SHEET UI)
Information Banner:
• Text:
“Only some photos are allowed to be accessed. Select more photos.”
• Font: Light gray text #666666, ~13pt
• Settings Button:
• Label: Settings
• Background: Teal #00d8c0, white bold text
• Rounded pill shape (capsule button)
Photo Options (2-column grid):
Thumbnail
Description
Icon/Text
Left
Camera
Black camera icon above “Camera” text
Right
Image Thumbnail (User’s photo)
Image preview with gray circle overlay for multi-select indicator

• Image Backgrounds: White
• Text under camera icon: #000000 black, center-aligned
• Grid Padding: Clean, rounded corner spacing, white background
• Photo Permission Notice: Triggered by iOS privacy system when the app only has access to limited images

BOTTOM NAV INDICATOR (INACTIVE)
• Floating App Switcher Dot Grid (Bottom Right Corner)
• 4-dot grid icon in black
• Hints at multitasking or module navigation

COLORS USED (DESIGN SYSTEM)
Element
Color
Background
#FFFFFF
Chat Bubble
#F1EDFF
System Message
#999999
Disabled Input
#F2F2F2
Failed Text
#FF3B30
Settings Button
#7A4DFF
Icons (Default)
#000000
Active Icon (Image)
#7A4DFF


FUNCTIONALITY OVERVIEW
Disabled Input:
• Same as previous screen – no messages can be sent until the user receives a reply.
Image Picker Modal:
• Triggered from image icon in toolbar
• iOS privacy restriction message suggests:
• App only has access to selected photos
• “Settings” button opens iOS privacy settings to grant more access
Camera Button:
• Launches the native camera app (or in-app camera view)
Photo Selection:
• Tapping an image selects it for sending (if messaging was allowed)
• Circular overlay may indicate multi-select capability
Settings Button:
• Opens iOS Settings (direct link to photo permissions for SkillTalk)

UX INSIGHTS
• Clear Privacy Prompt: Text + call to action lets users know why they can’t access all media
• Intuitive Icons: Clean design, predictable behavior
• Soft Shadows & White Space: Maintain a modern and minimal design system
• Disabled State Feedback: Gray input and blocked sending action are explicit and user-friendly

Here’s a comprehensive design and functionality breakdown of the chat screen in the chat conversation screen, focusing specifically on the emoji picker interface in the SkillTalk app:

SCREEN TYPE
Chat Screen – Emoji Picker Modal Opened
This is the chat screen where the user has tapped on the emoji icon, revealing the emoji and sticker drawer just above the keyboard area.

MESSAGE INPUT FIELD (DISABLED STATE)
• Input Box:
• Placeholder: Type a message...
• Background: light gray (#F2F2F2)
• Rounded corners
• Disabled (user cannot send messages)
• Microphone Icon:
• On the far right, black

TOOLBAR ICONS BELOW INPUT FIELD
These icons allow user interaction with multimedia and language options:
Position
Icon
Function
State
Color
1st
➕ Plus
Expand actions
Inactive
Black
2nd
Image
Open media picker
Inactive
Black
3rd
Emoji (Active)
Opens emoji drawer
Active
Teal ( #00D8C0)
4th
Globe + A
Translation feature
Inactive
Black
5th
Chat bubble
Possibly input toggle (voice/text)
Inactive
Black


EMOJI & STICKER DRAWER (BOTTOM HALF UI)
This section appears after tapping the Teal emoji icon. It’s designed to allow users to send visual reactions in chat.
Category Tabs (Top of Drawer)
Tab Icon
Description
Drawer icon
Recent or frequently used
Smiley face (highlighted in yellow)
Standard emoji tab (active)
Heart
Love-related emojis or favorites
Hand-drawn sticker
Cartoon-style stickers
Dog face sticker
Animal or funny stickers
Cartoon characters
Animated/emotive stickers

• The active tab has a soft yellow background circle with a slight shadow/glow
• All icons are center-aligned, evenly spaced, and have circular touch targets

EMOJI GRID DISPLAY
• Layout:
• Grid of emojis, arranged in 7 columns x ~6 rows
• Scrollable vertically
• Emojis Include:
• Common emotional states: smiling, crying, angry, etc.
• Reactions like hearts, sparkles, etc.
• Special icons: devil face, alien, broken heart
• Emoji Design Style:
• Apple native emoji rendering (iOS system style)
• Large enough to easily tap (touch targets ~48px)
• Background:
• Plain white, clean look, rounded top edges of drawer

COLORS & DESIGN SYSTEM
Element
Color
Background
#FFFFFF (main)
Input box
#F2F2F2
Emoji tab active
#FFF3CC / soft yellow
Toolbar icon active
#00d8c0 (emoji icon)
System text
#999999
Failed text
#FF3B30


FUNCTIONALITY OVERVIEW
• Emoji Picker Drawer:
• Opens on tapping the smiley icon
• Displays emoji categories as tabs
• Tap emoji to add it to message (disabled in this case due to block)
• Stickers:
• Alternative to emojis
• Tapping on a sticker likely sends it instantly or inserts into the chat bar
• Drawer UX:
• Partially overlays the keyboard area
• Responsive and animated (likely slides up from bottom)

UX & USABILITY NOTES
• Visual feedback: Active tab highlighted makes navigation intuitive
• Color contrast: Sufficient across buttons, icons, and emoji categories
• Emoji grid layout: Clean, touch-optimized spacing
• Disabled message field + emoji access: Despite message field being locked, emoji drawer is still accessible, possibly for copy-pasting or pre-loading messages


Here is a detailed breakdown of the new elements and UI changes specifically for:

1. After Tapping the Call Button (First Screenshot)
New UI Elements Displayed:
• New top horizontal menu with 3 options:
• Voice Calls
• Icon: Phone receiver
• Text: Black, sans-serif, aligned center
• Video Calls
• Icon: Video camera
• Text: Same style
• Skill Exchange
• Icon: Rotating arrows
• Indicates a feature related to conversation exchange or learning
Design Changes:
• The background of the message screen gets a dark translucent overlay indicating a modal or focus shift.
• Underneath, the chat remains visible but slightly dimmed to signal that interaction is disabled temporarily.
Functionality:
• Tapping the call icon triggers a modal header menu allowing the user to choose from:
• Making a voice call
• Starting a video call
• Beginning a Skill exchange session
• Purpose is to provide fast access to different communication options within a chat.

2. After Tapping the Message Selection Button (Multi-select)
New UI Elements Displayed:
• Top left corner:
• X button replaces the back arrow (used to exit selection mode)
• “Pisces” badge:
• Indicates the user’s zodiac sign
• Teal background with white Pisces glyph icon
• Top right:
• “All” button in a Teal rounded rectangle – selects all messages
• Checkboxes next to each message:
• Circular outlines appear to the left of each message bubble
• When selected, they become filled with a Teal checkmark
• Bottom action bar:
• Delete icon (trash bin) – left side
• Share icon (arrow) – right side
• Labels are in black text with simple, intuitive icons
Design Changes:
• Message bubbles become slightly lighter (more translucent violet) to indicate active selection mode.
• Selected message gets a blue/Teal checkmark beside it.
• “Go now” link remains active in Teal.
Functionality:
• User can select one or multiple messages for deleting or sharing.
• The “All” button quickly selects all messages in the chat.
• “Pisces” badge suggests that zodiac signs are shown when in selection mode (possibly for user info or filtering?).
• Once done, tapping the “X” button exits selection mode and returns to normal chat view.





Sticker gallery of keyboard 
Sticker gallery of keyboard in chat page in SkilTalk
the Sticker Gallery from the SkilTalk keyboard feature! Here’s your detailed UI/UX breakdown along with a full functionality analysis:

🎨 UI/UX Analysis – Sticker Gallery (SkilTalk Keyboard)

1. Full UI/UX Breakdown
🧩 Design Elements
✅ Visual Style
• Whimsical & playful aesthetic, fitting the tone of casual conversation and expressive chatting.
• Uses rounded, cartoon-style characters and icons, matching SkilTalk’s friendly brand personality.
• Consistent visual theme with vibrant colors and expressive avatars/stickers.
🟦 Shapes & Colors
• Rounded card layout for each sticker set.
• Teal circular buttons with either:
• ➕ icon for free sticker packs.
• 💰 coin price (ST 120) for premium ones.
• Soft color palette: Pastels, light backgrounds, vivid but non-jarring accents.
• Large header banner with animated stickers, visually anchoring the page.
🖋️ Typography
• Bold for sticker names (e.g., Ace, Lula).
• Lighter grey for sticker descriptions.
• Balanced font size — comfortably readable and optimized for mobile.
• Coin icons use ST logo for brand consistency and recognition.

🧱 Structure & Visual Hierarchy
Section
Purpose
Visual Priority
Top Banner (with characters)
Introduce the gallery visually; set the tone
High
Sticker Pack List
Core interaction area — browse/add stickers
Very High
Icons (Add/Purchase)
Primary actions — high contrast, always visible
Very High
Descriptions
Flavor text for personality and engagement
Medium

The structure ensures:
• Immediate emotional appeal (via visuals),
• Easy scanning (avatars + short descriptions),
• Quick action (right-aligned CTAs: add or buy).

♿ Usability & Accessibility
Factor
Assessment
Touch-Friendly
Excellent — large hit areas for buttons and icons.
Legibility
Good contrast between text and background, readable font sizes.
Consistency
Every sticker item follows the same layout — makes it intuitive.
Feedback
Visual cues (e.g., coin icon) clearly distinguish paid vs. free items.
Scalability
List format works well even with many sticker packs.


2. Functionality Explanation
🔍 Element-by-Element Breakdown
UI Element
Function
Top Left “X” Icon
Dismisses or closes the Sticker Gallery modal.
Title “Sticker Gallery”
Header indicating current screen context.
Share Icon (Top Right)
Possibly for sharing sticker packs with friends or on social.
Settings Icon (Top Right Gear)
Likely opens sticker-related settings (e.g., reorder, manage downloads).
Top Banner Image
Visual branding; non-functional but engaging.
Sticker Name (e.g., Ace, Lula)
Identifies the sticker character or pack.
Sticker Description
Adds emotional connection/personality — helps in choosing which pack suits your vibe.
Teal “+” Button
Adds free sticker packs directly to the keyboard or messaging app.
ST Coin Button (e.g., 120)
Indicates a paid pack; tapping likely opens a purchase/confirmation modal.


🔄 User Interaction Flow
1. Browse the sticker packs vertically.
2. Tap “+” to instantly add free packs.
3. Tap coin button to initiate a purchase flow for premium packs.
4. Use top icons to:
• Exit (X)
• Adjust settings (Gear)
• Possibly share (Arrow)
Each element is spaced out for finger-tap accuracy and clarity of intent.

📊 Metrics Like “ST 120”
Metric
Purpose
ST Coin Amount
Represents the cost of a premium sticker pack in SkillTalk’s virtual currency system. This gamifies the experience and encourages coin purchase or earning.

No “gifts income,” “events hosted,” or “audience” metrics appear in this view — those are likely relevant in different contexts (e.g., livestream or influencer profile areas).

✅ UX Summary
💪 Strengths
💡 Opportunities
Visually engaging, lighthearted theme
Consider adding hover/preview on sticker packs
Simple, predictable actions (add/buy)
Could benefit from filters/sorting by mood, language, or popularity
Accessible design with strong CTAs
Lacks real-time feedback (e.g., “Added” label after tapping “+”)
Balanced layout and mobile-optimized
Could include more info on coin cost (e.g., how to earn ST coins)





