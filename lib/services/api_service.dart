import 'dart:convert';
import 'dart:async';

/// خدمة الاتصال بالخادم
class ApiService {
  // رابط الخادم الأساسي (سيتم تغييره لاحقاً)
  static const String baseUrl = 'https://api.alfaseelah.com';

  // Token للمصادقة
  String? _authToken;

  // Singleton pattern
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  /// تعيين Token المصادقة
  void setAuthToken(String token) {
    _authToken = token;
  }

  /// مسح Token المصادقة
  void clearAuthToken() {
    _authToken = null;
  }

  /// Headers الأساسية
  Map<String, String> get _headers {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    return headers;
  }

  /// طلب GET
  Future<ApiResponse> get(String endpoint) async {
    try {
      // محاكاة الاتصال بالخادم
      await Future.delayed(const Duration(milliseconds: 500));

      // TODO: استبدال هذا بـ http.get الحقيقي
      // final response = await http.get(
      //   Uri.parse('$baseUrl$endpoint'),
      //   headers: _headers,
      // );

      return ApiResponse(
        success: true,
        data: {},
        message: 'تم بنجاح',
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        data: null,
        message: 'حدث خطأ في الاتصال:  $e',
      );
    }
  }

  /// طلب POST
  Future<ApiResponse> post(String endpoint, Map<String, dynamic> body) async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));

      // TODO: استبدال هذا بـ http.post الحقيقي
      // final response = await http.post(
      //   Uri.parse('$baseUrl$endpoint'),
      //   headers: _headers,
      //   body: jsonEncode(body),
      // );

      return ApiResponse(
        success: true,
        data: body,
        message: 'تم بنجاح',
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        data: null,
        message:  'حدث خطأ في الاتصال:  $e',
      );
    }
  }

  /// طلب PUT
  Future<ApiResponse> put(String endpoint, Map<String, dynamic> body) async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));

      return ApiResponse(
        success: true,
        data: body,
        message: 'تم التحديث بنجاح',
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        data: null,
        message: 'حدث خطأ في الاتصال: $e',
      );
    }
  }

  /// طلب DELETE
  Future<ApiResponse> delete(String endpoint) async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));

      return ApiResponse(
        success: true,
        data: null,
        message: 'تم الحذف بنجاح',
      );
    } catch (e) {
      return ApiResponse(
        success:  false,
        data: null,
        message: 'حدث خطأ في الاتصال: $e',
      );
    }
  }
}

/// نموذج استجابة API
class ApiResponse {
  final bool success;
  final dynamic data;
  final String message;
  final int?  statusCode;

  ApiResponse({
    required this.success,
    required this.data,
    required this.message,
    this.statusCode,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    return ApiResponse(
      success: json['success'] ?? false,
      data: json['data'],
      message: json['message'] ?? '',
      statusCode: json['statusCode'],
    );
  }
}