🌍 Food Passport - Travel Food Companion
<div align="center">
https://img.shields.io/badge/Flutter-3.19-blue?logo=flutter
https://img.shields.io/badge/Dart-3.3-blue?logo=dart
https://img.shields.io/badge/AI-Powered-orange
https://img.shields.io/badge/For-Travelers-lightblue

Your intelligent food guide for exploring cuisines in foreign countries

</div>
📱 Overview
Food Passport is a Flutter-based travel companion that helps tourists navigate foreign cuisines, understand local menus, and discover authentic dining experiences. Using AI-powered food recognition, it translates menus, identifies dishes, and provides cultural context to make every meal an adventure.

✨ Features
🗺️ Travel Food Assistance
Menu Translation: Real-time camera translation of foreign menus

Dish Identification: AI recognition of local foods and ingredients

Cultural Context: Learn about traditional dishes and eating customs

Allergy Alerts: Identify potential allergens in local cuisine

📸 Smart Camera Features
Live Menu Translation: Point your camera at menus for instant translation

Food Recognition: Identify unknown dishes through photos

Ingredient Analysis: Understand what's in your food

Nutrition Info: Get nutritional facts for local dishes

🌐 Local Food Discovery
Regional Specialties: Discover must-try local dishes

Food Dictionary: Learn food terms and pronunciation guides

Dining Etiquette: Understand local customs and table manners

Price Range Info: Know what to expect to pay

🎮 Travel Gamification
Culinary Passport: Collect stamps for trying local specialties

Food Challenges: Complete culinary adventures in each region

Achievement System: Earn badges for food exploration milestones

Travel Journal: Document your food journey with photos and notes

🛠️ Technical Stack
Frontend
Flutter 3.19 - Cross-platform framework

Dart 3.3 - Programming language

Material Design - UI components

Camera Plugin - Real-time menu capture

AI & API Services
Nutritionix API - Food recognition and ingredient analysis

Google Translate API - Menu translation capabilities

Google Maps - Local restaurant discovery

OCR Technology - Text extraction from menu photos

Database
SQLite - Local food journal and travel data

Cloud Storage - Sync across devices

Offline Cache - Basic functionality without internet

📁 Project Structure
text
lib/
├── main.dart                 # Application entry point
├── models/                   # Food, restaurant, and translation models
├── services/                 # AI and translation services
│   ├── menu_translator.dart  # Menu translation service
│   ├── food_guide.dart       # Local cuisine information
│   └── travel_journal.dart   # Travel diary management
├── screens/                  # App screens
│   ├── camera_screen.dart    # Menu translation camera
│   ├── food_scan_screen.dart # Dish identification
│   ├── travel_guide.dart     # Local food recommendations
│   └── passport_screen.dart  # Travel achievements
└── widgets/                  # Reusable components
    ├── menu_translator.dart  # Live translation overlay
    └── food_card.dart        # Dish information cards
🚀 Getting Started
Prerequisites
Flutter SDK 3.19+

Dart 3.3+

Nutritionix API key

Google Translate API key

Installation
bash
# Clone the repository
git clone https://github.com/Anasanas60/foodpassport.git

# Navigate to project
cd foodpassport

# Install dependencies
flutter pub get

# Configure API keys
# Create a .env file in the root of the project and add your API keys.
# You can use the .env.example file as a template.
cp .env.example .env

# Run the app
flutter run

🔧 API Configuration
Create a `.env` file in the root of the project with the following content:

# Spoonacular API Key
SPOONACULAR_API_KEY=your_spoonacular_key_here

# Nutritionix API Credentials
NUTRITIONIX_APP_ID=your_nutritionix_id_here
NUTRITIONIX_APP_KEY=your_nutritionix_key_here
🌍 Use Cases
For Travelers:
Menu Decoding: Understand foreign language menus instantly

Safe Eating: Identify ingredients and allergens

Local Discovery: Find authentic local dishes off the tourist path

Cultural Learning: Learn about food traditions and etiquette

Sample Scenarios:
Point camera at Japanese menu → Get English translation with dish explanations

Photo of street food in Thailand → Learn ingredients and spice levels

Italian restaurant menu → Understand regional specialties and wine pairings

Market shopping → Identify local produce and how to cook it

🎯 Roadmap
Phase 1: Core Features ✅
Basic food recognition

Camera integration

Nutrition information

Phase 2: Travel Features 🚧
Menu translation system

Local cuisine database

Offline phrasebook

Restaurant recommendations

Phase 3: Advanced Features 📅
Multi-language support

Augmented reality menu overlay

Social sharing features

Local guide integration

🤝 Contributing
We welcome contributions from travel enthusiasts and developers! Areas where you can help:

Translation Support: Add more languages and regional dialects

Local Cuisine Data: Contribute knowledge about specific regions

UI/UX Design: Improve the travel-focused interface

Feature Ideas: Suggest new travel food assistance features

📄 License
This project is licensed under the MIT License - see the LICENSE file for details.

🙏 Acknowledgments
Nutritionix API for food recognition data

Google Translate for menu translation capabilities

Flutter community for excellent packages and support

Made for travelers, by travelers ✈️🍜

Food Passport turns every meal abroad into a cultural adventure!
