import 'dart:convert';
import 'dart:developer' as AppLogger;
import 'package:http/http.dart' as http;

class NetworkCaller {
  /// Form field name for JSON blob in product create/update (multipart, API doc §3.3).
  static const String productMultipartJsonField = 'data';

  // GET Request
  Future<dynamic> getRequest(String url, {String? token}) async {
    try {
      final headers = <String, String>{
        "accept": "application/json",
        "Content-Type": "application/json",
      };

      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = "Bearer $token";
      }   

      AppLogger.log("GET Request to: $url");
      AppLogger.log("Headers: $headers");

      final response = await http.get(Uri.parse(url), headers: headers);

      AppLogger.log("GET Status: ${response.statusCode}");
      AppLogger.log("GET Response: ${response.body}");

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 401) {
        throw Exception("Unauthorized: Invalid Token");
      } else {
        throw Exception(
            "Failed to load data: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      AppLogger.log("GET Request Error: $e");
      rethrow;
    }
  }

  // POST Request
  Future<dynamic> postRequest(String url, Map<String, dynamic> body,
      {String? token}) async {
    try {
      final headers = <String, String>{
        "accept": "application/json",
        "Content-Type": "application/json",
      };

      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = "Bearer $token";
      } else {
        AppLogger.log("POST $url: WARNING — Authorization token missing");
      }

      final logHeaders = Map<String, String>.from(headers);
      if (logHeaders.containsKey('Authorization')) {
        logHeaders['Authorization'] = 'Bearer <redacted len=${token?.length ?? 0}>';
      }

      AppLogger.log("POST Request to: $url");
      AppLogger.log("POST Headers (safe): $logHeaders");
      AppLogger.log("POST Body: $body");

      final response =
          await http.post(Uri.parse(url), headers: headers, body: jsonEncode(body));

      AppLogger.log("POST Status: ${response.statusCode}");
      AppLogger.log("POST Response body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception(
            "Failed to post data:$url ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      AppLogger.log("POST Request Error: $e");
      rethrow;
    }
  }

  /// JSON body with `Content-Type: application/json` (e.g. change password, doc §3.1 PUT).
  Future<dynamic> putRequest(String url, Map<String, dynamic> body,
      {String? token}) async {
    try {
      final headers = <String, String>{
        "accept": "application/json",
        "Content-Type": "application/json",
      };

      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = "Bearer $token";
      } else {
        AppLogger.log("PUT $url: WARNING — Authorization token missing");
      }

      final logHeaders = Map<String, String>.from(headers);
      if (logHeaders.containsKey('Authorization')) {
        logHeaders['Authorization'] =
            'Bearer <redacted len=${token?.length ?? 0}>';
      }

      AppLogger.log("PUT JSON to: $url");
      AppLogger.log("PUT Headers (safe): $logHeaders");
      AppLogger.log("PUT Body: $body");

      final response = await http.put(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(body),
      );

      AppLogger.log("PUT Status: ${response.statusCode}");
      AppLogger.log("PUT Response body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.body.isEmpty) return null;
        return jsonDecode(response.body);
      } else {
        throw Exception(
            "Failed to put data: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      AppLogger.log("PUT Request Error: $e");
      rethrow;
    }
  }

  /// Multipart request with one text field holding JSON (product create/update, doc §3.3).
  Future<dynamic> multipartJsonDataRequest(
    String method,
    String url,
    Map<String, dynamic> body, {
    String? token,
  }) async {
    try {
      final request = http.MultipartRequest(method, Uri.parse(url));
      request.headers['accept'] = 'application/json';
      if (token != null && token.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      request.fields[productMultipartJsonField] = jsonEncode(body);

      AppLogger.log("$method multipart to: $url");
      AppLogger.log("Field $productMultipartJsonField: ${jsonEncode(body)}");

      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);

      AppLogger.log("$method multipart status: ${response.statusCode}");
      AppLogger.log("$method multipart body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.body.isEmpty) return null;
        return jsonDecode(response.body);
      } else {
        throw Exception(
            "Failed $method multipart: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      AppLogger.log("Multipart request error: $e");
      rethrow;
    }
  }

  // PATCH Request (legacy / non-doc endpoints)
  Future<dynamic> patchRequest(String url, Map<String, dynamic> body,
      {String? token}) async {
    try {
      final headers = {
        "accept": "application/json",
        "Content-Type": "application/json",
      };

      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = "Bearer $token";
      }

      AppLogger.log("PATCH Request to: $url");
      AppLogger.log("Headers: $headers");
      AppLogger.log("Body: $body");

      final response =
          await http.patch(Uri.parse(url), headers: headers, body: jsonEncode(body));

      AppLogger.log("PATCH Status: ${response.statusCode}");
      AppLogger.log("PATCH Response: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception(
            "Failed to update data: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      AppLogger.log("PATCH Request Error: $e");
      rethrow;
    }
  }

  // DELETE Request
  Future<void> deleteRequest(String url, {String? token}) async {
    try {
      final headers = {
        "accept": "application/json",
        "Content-Type": "application/json",
      };

      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = "Bearer $token";
      }

      AppLogger.log("DELETE Request to: $url");
      AppLogger.log("Headers: $headers");

      final response = await http.delete(Uri.parse(url), headers: headers);

      AppLogger.log("DELETE Status: ${response.statusCode}");
      AppLogger.log("DELETE Response: ${response.body}");

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception(
            "Failed to delete data: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      AppLogger.log("DELETE Request Error: $e");
      rethrow;
    }
  }

  Future<String> googleSignInRequest(String url, String accessToken) async {
    try {
      final fullUrl = '$url?access_token=$accessToken';

      final response = await http.post(
        Uri.parse(fullUrl),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
        },
        body: jsonEncode({}),
      );

      AppLogger.log("url ====== $fullUrl");
      AppLogger.log("Status Code: ${response.statusCode}");
      AppLogger.log("Response: ${response.body}");

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw "Server Error: ${response.body}";
      }

      final data = jsonDecode(response.body);
      return data["access_token"];
    } catch (e) {
      throw "Google Authentication Request Failed: $e";
    }
  }
}
