First of all, thank you for this opportunity! It is indeed a great trial assignment which reflects so many aspects.

The assignment took me **about 3 hours** to complete. I spent the time needed to design and implement the base functionality of the assignment and a bit more time to make sure the codebase was modular, quick to adjust, and low in the amount of potential technical debt. 

**The Most Difficult Part:** it was tempting to keep all the logic in one file to work faster. However, I found that the OrientationBuilder logic became difficult to read when combined with the card swiping mechanics. The hardest decision was choosing to pull the UI out into a separate RestaurantCard component halfway through the process. 

**What I spent time on:** I prioritized **architecture and long-term maintainability** over visual polish. I spent most of my time abstracting the UI into a reusable RestaurantCard component and implementing an OrientationBuilder to ensure the layout is robust and responsive on any device. 

**What I chose to ignore or do quickly:** I consciously chose to spend less time on **advanced design, custom styling, and aesthetic branding.** While I made sure the layout was professional and functional, I didn't spend time on custom color palettes, advanced typography, or high-end UI animations. 

**Above and Beyond Improvements :** 

Defensive Error Handling: Instead of letting the app crash when an image fails to load, I implemented an errorBuilder for all network images. 

Responsive Adaptation: I went beyond a standard portrait-only layout by integrating an OrientationBuilder. This ensures the UI is truly cross-platform ready 

To sum up, I focused on building this app to be truly maintainable, as I find this part of software development very important. Instead of a massive, messy build method, I extracted the UI into a reusable RestaurantCard component. If the design changes, I only have to update one file.

# Restaurant Deck

A responsive, cross-platform restaurant discovery application built with Flutter. Users can swipe through restaurant recommendations based on their current location.

## Features
- **Dynamic Data:** Fetches real-time restaurant data using the Yelp API.
- **Responsive Design:** Adaptive layout that switches between vertical (portrait) and side-by-side (landscape) modes.
- **Infinite Scrolling:** Seamlessly loads more results as the user approaches the end of the deck.
- **Geolocation:** Automatically prioritizes local restaurants based on user coordinates.

## Getting Started

### Prerequisites
- Flutter SDK (latest stable version recommended)
- An API Key for [Yelp Fusion](https://www.yelp.com/fusion)

### Installation
1. Clone the repository:
   ```bash
   git clone <your-repo-url>
