# Gmail Star Types and Icons

Source: https://support.google.com/mail/answer/5904?hl=en

## Overview

Gmail supports multiple star types beyond the standard yellow star.
Users can cycle through available stars by clicking repeatedly on the star icon.

## Available Star Types (12 total)

### Color Stars (6)
- Yellow star (default)
- Orange star
- Red star
- Purple star
- Blue star
- Green star

### Symbol Stars (6)
- Red exclamation mark (red-bang)
- Orange guillemet (orange-guillemet) - French quotation marks
- Yellow exclamation mark (yellow-bang)
- Green checkmark (green-check)
- Blue info icon (blue-info)
- Purple question mark (purple-question)

## Enabling Multiple Star Types

1. Open Gmail Settings (gear icon)
2. Click "See all settings"
3. Find the "Stars" section
4. Drag stars between "Not in use" and "In use"
5. Or select presets: 1 star, 4 stars, all stars
6. Click "Save Changes"

## Searching by Star Type (Gmail UI only)

In Gmail search bar:
```
has:yellow-star
has:red-star
has:orange-star
has:purple-star
has:blue-star
has:green-star
has:red-bang
has:orange-guillemet
has:yellow-bang
has:green-check
has:blue-info
has:purple-question
```

## API Limitation

**IMPORTANT**: The Gmail API does NOT distinguish between star types.

- API exposes only: `STARRED` label (binary: present or absent)
- Star type information is NOT available via API
- `has:red-star` search syntax does NOT work via API `q` parameter
- Only `is:starred` works via API

This is a significant feature gap between Gmail UI and API capabilities.

## Workaround

For star-type-like functionality via API, use custom user labels:
- Create labels like "Priority-Red", "Review-Green", "Question"
- These ARE accessible via API
- But they won't display as visual stars in Gmail UI
