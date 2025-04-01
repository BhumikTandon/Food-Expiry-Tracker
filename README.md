🍎 Food Expiry Tracker 🥕

Food Expiry Tracker is an iOS application designed to help users manage their grocery items by tracking expiry dates, sending reminders before items expire, and providing recipe suggestions based on available food items. The app uses a SwiftUI front end and a Parse/Back4App backend for authentication and data storage.

Features

🧑‍🤝‍🧑 User Authentication:
Register and log in using custom Parse-based authentication.
Account management for user data.
🛒 Grocery Management:
Add new grocery items with names, quantities, and expiry dates.
View a list of all food items in the inventory.
Delete items that are no longer needed.
⏰ Expiry Notifications:
Schedule local notifications to remind users when an item is nearing its expiry.
Immediate reminder showing how many days remain before an item expires.
🍽 Recipe Suggestions:
Fetch recipe suggestions from an external API (e.g., Spoonacular) based on the ingredients available in the user's food list.
🎨 Custom Styling:
A green-themed color palette for a fresh, clean look.
Custom fonts and bold text for a unique user experience.
Architecture

💻 Front End:
SwiftUI: Built using SwiftUI, leveraging SwiftUI views and modifiers for styling, layout, and animations.
Local Notifications: Implements local notifications via the UserNotifications framework to remind users when items are about to expire.
🔒 Back End:
Parse Server (Back4App): Uses a Parse Server hosted on Back4App for storing user and food item data. Provides secure authentication, user management, and object persistence.
🌐 External API:
Recipe Suggestions: Integrates with an external recipe API (such as Spoonacular) to fetch recipe suggestions based on the ingredients available in the user’s inventory.
Requirements

Xcode 12 or later
iOS 13 or later
A Back4App account with your Parse credentials (Application ID and Client Key)
A valid API key for the recipe suggestion service (e.g., Spoonacular)
Setup Instructions

1. 📂 Clone the Repository
Clone this repository to your local machine using the following command:

git clone https://github.com/yourusername/FoodExpiryTracker.git

2. 🔌 Install Dependencies
This project uses Parse-Swift to interact with the Parse backend. To install dependencies, you will need to use Swift Package Manager (SPM).

Open the project in Xcode.
Go to File > Swift Packages > Add Package Dependency.
Enter the Parse-Swift repository URL:
https://github.com/parse-community/Parse-Swift
Follow the instructions in Xcode to install the package.
3. 🔑 Configure the Parse API (Back4App)

Create an account at Back4App.
Set up a new Parse app.
Retrieve your Application ID and Client Key from the App Settings page in Back4App.
Add these keys to your project’s configuration file:
Open the AppDelegate.swift file or any appropriate place in your app and configure Parse like this:

import Parse

func initializeParse() {
    let parseConfig = ParseClientConfiguration {
        $0.applicationId = "YOUR_APPLICATION_ID"
        $0.clientKey = "YOUR_CLIENT_KEY"
        $0.server = "https://parseapi.back4app.com/"
    }
    Parse.initialize(with: parseConfig)
}
Replace YOUR_APPLICATION_ID and YOUR_CLIENT_KEY with your credentials from Back4App.

Dependencies
This project uses the Parse-Swift library for handling the backend interactions.

Parse-Swift: Parse SDK for Swift, used for managing authentication and data persistence.
To install Parse-Swift, follow the instructions above to use Swift Package Manager


   
   
