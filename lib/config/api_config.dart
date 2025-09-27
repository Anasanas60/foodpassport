class ApiConfig {
  // Spoonacular API (Primary - AI Food Recognition & Recipes)
  static const String spoonacularApiKey = 'ece7ade9abab4bd8af32a66dac3cbee4';
  static const String spoonacularBaseUrl = 'https://api.spoonacular.com';
  
  // Fallback APIs (No keys needed)
  static const String mealDbBaseUrl = 'https://www.themealdb.com/api/json/v1/1';
  static const String openFoodFactsUrl = 'https://world.openfoodfacts.org/api/v0/product';
  
  // Cultural/Geography APIs (Free) - ADDED for cultural_insights_screen.dart
  static const String restCountriesUrl = 'https://restcountries.com/v3.1/name';
  static const String wikipediaUrl = 'https://en.wikipedia.org/api/rest_v1/page/summary';
  
  // Spoonacular API endpoints
  static const String spoonacularAnalyzeImage = '/food/images/analyze';
  static const String spoonacularSearchRecipes = '/recipes/complexSearch';
  static const String spoonacularRecipeInfo = '/recipes/{id}/information';
  static const String spoonacularRandomRecipes = '/recipes/random';
  static const String spoonacularRecipeByIngredients = '/recipes/findByIngredients';
  static const String spoonacularIngredientSearch = '/food/ingredients/search';
  
  // API Configuration
  static const int spoonacularDailyLimit = 150;
  static const int spoonacularRequestTimeout = 30;
  static const int maxRetryAttempts = 3;
  
  // Feature Flags
  static const bool enableSpoonacular = true;
  static const bool enableMealDbFallback = true;
  
  // API Status Check
  static bool get isSpoonacularKeyValid {
    return spoonacularApiKey.isNotEmpty && spoonacularApiKey != 'YOUR_SPOONACULAR_API_KEY';
  }
  
  // API Endpoint Builder
  static String buildSpoonacularUrl(String endpoint, {Map<String, String>? params}) {
    var url = '=';
    if (params != null) {
      params.forEach((key, value) {
        url += '&=';
      });
    }
    return url;
  }
}

// Separate class for API Usage Stats
class ApiUsageStats {
  static int spoonacularRequestsToday = 0;
  static int mealDbRequestsToday = 0;
  static DateTime lastReset = DateTime.now();
  
  static void incrementRequest(String apiName) {
    switch (apiName) {
      case 'spoonacular':
        spoonacularRequestsToday++;
        break;
      case 'mealdb':
        mealDbRequestsToday++;
        break;
    }
    _checkDailyReset();
  }
  
  static void _checkDailyReset() {
    final now = DateTime.now();
    if (now.day != lastReset.day) {
      spoonacularRequestsToday = 0;
      mealDbRequestsToday = 0;
      lastReset = now;
    }
  }
}

// Separate class for Error Messages
class ApiErrorMessages {
  static const String spoonacularLimitReached = 
      'Daily API limit reached. Please try again tomorrow.';
  static const String networkError = 
      'Network connection error. Please check your internet connection.';
  
  static String getApiErrorMessage(int statusCode) {
    switch (statusCode) {
      case 400: return 'Invalid request. Please check your input.';
      case 401: return 'API key invalid or missing.';
      case 429: return 'Too many requests. Please slow down.';
      case 500: return 'Internal server error. Please try again later.';
      default: return 'An unexpected error occurred (Code: ).';
    }
  }
}
