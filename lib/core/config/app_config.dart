// lib/core/config/app_config.dart
class AppConfig {
  static const String stripePublishableKey = 'pk_test_51RbLKZQ7pm5NWh7m3hsyzQqokSPm9HuP6CsAgeR6pPJDXaECofmKz8g8qX99oqYIukTTTE21g5DgAshQovPjmPWD00KlHYoY8k';
  
  // REMOVED: stripeSecretKey - Now safely in server.js
  
  static const double deliveryFee = 3.0;
  static const double freeDeliveryThreshold = 50.0;
  
  static const Map<String, int> statusColors = {
    'placed': 0xFFFF9800,    // Orange
    'confirmed': 0xFF2196F3, // Blue
    'completed': 0xFF4CAF50, // Green
    'cancelled': 0xFFF44336, // Red
  };
}