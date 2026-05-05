class Urls {
  // Base Configuration
  static const String baseUrl = "https://product-management-seven-xi.vercel.app/api/v1";
  static const String baseDomain = "https://product-management-seven-xi.vercel.app";

  // Auth Endpoints
  static const String register = "$baseUrl/users/register";
  static const String login = "$baseUrl/auth/login";
  static const String changePassword = "$baseUrl/auth/reset-password"; // PUT

  // User Endpoints
  static const String completeProfile = "$baseUrl/users/complete-profile";

  // Product Endpoints
  static const String createProduct = "$baseUrl/products";

}
