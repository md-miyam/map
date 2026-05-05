import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:http/http.dart' as http;

// ─────────────────────────────────────────────
//  ENUMS
// ─────────────────────────────────────────────

enum HttpMethod { get, post, put, patch, delete }

enum ContentType { json, formUrlEncoded, multipart }

// ─────────────────────────────────────────────
//  EXCEPTION
// ─────────────────────────────────────────────

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  const ApiException({
    required this.message,
    this.statusCode,
  });

  @override
  String toString() => 'ApiException: $message';
}

// ─────────────────────────────────────────────
//  RESPONSE WRAPPER
// ─────────────────────────────────────────────

class ApiResponse<T> {
  final bool success;
  final int statusCode;
  final T? data;
  final String? message;

  const ApiResponse({
    required this.success,
    required this.statusCode,
    this.data,
    this.message,
  });
}

// ─────────────────────────────────────────────
//  UPLOAD MODEL
// ─────────────────────────────────────────────

class UploadFile {
  final String fieldName;
  final String? filePath;
  final List<int>? bytes;
  final String? fileName;

  const UploadFile({
    required this.fieldName,
    this.filePath,
    this.bytes,
    this.fileName,
  }) : assert(filePath != null || bytes != null);
}

// ─────────────────────────────────────────────
//  INTERCEPTOR
// ─────────────────────────────────────────────

abstract class ApiInterceptor {
  Future<void> onRequest(http.BaseRequest request) async {}
  Future<void> onResponse(http.Response response) async {}
  Future<void> onError(ApiException error) async {}
}

// ─────────────────────────────────────────────
//  API SERVICE
// ─────────────────────────────────────────────

class ApiService {
  static ApiService? _instance;

  factory ApiService({
    String baseUrl = '',
    bool enableLog = true,
  }) {
    _instance ??= ApiService._internal(
      baseUrl: baseUrl,
      enableLog: enableLog,
    );
    return _instance!;
  }

  ApiService._internal({
    required this.baseUrl,
    required this.enableLog,
  });

  final String baseUrl;
  final bool enableLog;

  String? _token;
  final List<ApiInterceptor> _interceptors = [];

  // ─────────────────────────────────────────────
  //  TOKEN
  // ─────────────────────────────────────────────

  void setToken(String? token) {
    _token = token;
  }

  // ─────────────────────────────────────────────
  //  HEADERS
  // ─────────────────────────────────────────────

  Map<String, String> _headers({bool isMultipart = false}) {
    return {
      'Accept': 'application/json',
      if (!isMultipart) 'Content-Type': 'application/json',
      if (_token != null) 'Authorization': 'Bearer $_token',
    };
  }

  // ─────────────────────────────────────────────
  //  LOG
  // ─────────────────────────────────────────────

  void _log(String title, dynamic data) {
    if (!enableLog) return;
    log('[$title] $data');
  }

  // ─────────────────────────────────────────────
  //  INTERCEPTORS
  // ─────────────────────────────────────────────

  void addInterceptor(ApiInterceptor i) => _interceptors.add(i);

  Future<void> _runRequest(http.BaseRequest req) async {
    for (final i in _interceptors) {
      await i.onRequest(req);
    }
  }

  Future<void> _runResponse(http.Response res) async {
    for (final i in _interceptors) {
      await i.onResponse(res);
    }
  }

  Future<void> _runError(ApiException err) async {
    for (final i in _interceptors) {
      await i.onError(err);
    }
  }

  // ─────────────────────────────────────────────
  //  RESPONSE PARSER
  // ─────────────────────────────────────────────

  ApiResponse<T> _handle<T>(http.Response res) {
    _log('STATUS', res.statusCode);
    _log('BODY', res.body);

    dynamic jsonData;

    try {
      jsonData = res.body.isNotEmpty ? jsonDecode(res.body) : null;
    } catch (_) {
      jsonData = res.body;
    }

    final success = res.statusCode >= 200 && res.statusCode < 300;

    return ApiResponse<T>(
      success: success,
      statusCode: res.statusCode,
      data: jsonData as T?,
      message: jsonData is Map ? jsonData['message']?.toString() : null,
    );
  }

  // ─────────────────────────────────────────────
  //  GET
  // ─────────────────────────────────────────────

  Future<ApiResponse<T>> get<T>(String endpoint) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    final headers = _headers();

    final req = http.Request('GET', uri)..headers.addAll(headers);
    await _runRequest(req);

    try {
      final res = await http.get(uri, headers: headers);

      await _runResponse(res);
      return _handle<T>(res);
    } catch (e) {
      final err = ApiException(message: e.toString());
      await _runError(err);
      return ApiResponse(success: false, statusCode: 0, message: e.toString());
    }
  }

  // ─────────────────────────────────────────────
  //  POST
  // ─────────────────────────────────────────────

  Future<ApiResponse<T>> post<T>(
      String endpoint,
      Map<String, dynamic> body,
      ) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    final headers = _headers();

    _log('POST BODY', body);

    try {
      final res = await http.post(
        uri,
        headers: headers,
        body: jsonEncode(body),
      );

      await _runResponse(res);
      return _handle<T>(res);
    } catch (e) {
      return ApiResponse(success: false, statusCode: 0, message: e.toString());
    }
  }

  // ─────────────────────────────────────────────
  //  PUT
  // ─────────────────────────────────────────────

  Future<ApiResponse<T>> put<T>(
      String endpoint,
      Map<String, dynamic> body,
      ) async {
    final uri = Uri.parse('$baseUrl$endpoint');

    final res = await http.put(
      uri,
      headers: _headers(),
      body: jsonEncode(body),
    );

    return _handle<T>(res);
  }

  // ─────────────────────────────────────────────
  //  DELETE
  // ─────────────────────────────────────────────

  Future<ApiResponse<T>> delete<T>(String endpoint) async {
    final uri = Uri.parse('$baseUrl$endpoint');

    final res = await http.delete(
      uri,
      headers: _headers(),
    );

    return _handle<T>(res);
  }

  // ─────────────────────────────────────────────
  //  MULTIPART UPLOAD
  // ─────────────────────────────────────────────

  Future<ApiResponse<T>> upload<T>(
      String endpoint, {
        Map<String, String>? fields,
        List<UploadFile>? files,
      }) async {
    final uri = Uri.parse('$baseUrl$endpoint');

    final request = http.MultipartRequest('POST', uri)
      ..headers.addAll(_headers(isMultipart: true));

    // fields
    fields?.forEach((k, v) {
      request.fields[k] = v;
    });

    // files
    for (final f in (files ?? [])) {
      if (f.filePath != null) {
        final file = File(f.filePath!);

        if (!await file.exists()) {
          _log('FILE ERROR', f.filePath);
          continue;
        }

        request.files.add(
          await http.MultipartFile.fromPath(
            f.fieldName,
            f.filePath!,
            filename: f.fileName ?? file.path.split('/').last,
          ),
        );
      }
    }

    _log('UPLOAD', uri);

    final streamed = await request.send();
    final res = await http.Response.fromStream(streamed);

    return _handle<T>(res);
  }
}