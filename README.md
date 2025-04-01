# Food Expiry Tracker

Food Expiry Tracker is an iOS application designed to help users manage their grocery items by tracking expiry dates, sending reminders before items expire, and providing recipe suggestions based on available food items. The app uses a SwiftUI front end and a Parse/Back4App backend for authentication and data storage.

## Features

- **User Authentication:**  
  - Register and log in using custom Parse-based authentication.
  
- **Grocery Management:**  
  - Add new grocery items with names and expiry dates.
  - View a list of all food items.
  - Delete items that are no longer needed.

- **Expiry Notifications:**  
  - Schedule local notifications to remind users when an item is nearing its expiry (immediate reminder showing how many days remain).

- **Recipe Suggestions:**  
  - Fetch recipe suggestions from an external API (e.g., Spoonacular) based on the ingredients available in the user's food list.

- **Custom Styling:**  
  - A green-themed color palette.
  - Custom fonts and bold text for a unique user experience.

## Architecture

- **Front End:**  
  - Built with SwiftUI.
  - Uses built-in SwiftUI views and modifiers for styling, layout, and animations.
  - Implements local notifications via `UserNotifications`.

- **Back End:**  
  - Uses Parse Server hosted on Back4App for storing user and food item data.
  - Provides secure authentication and object persistence.

- **External API:**  
  - Integrates with a recipe API (such as Spoonacular) to retrieve recipe suggestions based on user food items.

## Requirements

- Xcode 12 or later
- iOS 13 or later
- A Back4App account with your Parse credentials (Application ID and Client Key)
- A valid API key for the recipe suggestion service (e.g., Spoonacular)

##Dependencies 

https://github.com/parse-community/Parse-Swift


   
   
