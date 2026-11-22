import 'dart:io';
import 'package:dio/dio.dart';
import '../session/user_session.dart';

class ApiService {
  static String baseUrl = 'http://10.0.2.2:5002/api';
  late final Dio _dio;

  ApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: Duration(seconds: 10),
        receiveTimeout: Duration(seconds: 10),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = UserSession.instance.token;
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
      ),
    );
  }

  Future<Map<String, dynamic>> login(String login, String password) async {
    final response = await _dio.post(
      '/Auth/login',
      data: {'login': login, 'password': password},
    );
    return response.data;
  }

  Future<Response> register({
    required String fullNameUser,
    required String login,
    required String password,
    required String email,
  }) async {
    return await _dio.post(
      '/Auth/register',
      data: {
        'fullName_User': fullNameUser,
        'login': login,
        'password': password,
        'email': email,
      },
    );
  }

  Future<Response> getMyPlants() => _dio.get('/Plant');
  Future<Response> getPlantTypes() => _dio.get('/Plant/types');
  Future<Response> getPlantStatus() => _dio.get('/Plant/status');

  Future<Response> getPlantHistory(int plantId) =>
      _dio.get('/Plant/$plantId/history');

  Future<Response> createPlant({
    required String namePlant,
    required int idTypePlant,
    required String datePurchase,
    String? photoUrl,
  }) => _dio.post(
    '/Plant',
    data: {
      'Name_Plant': namePlant,
      'Id_TypePlant': idTypePlant,
      'DatePurchase': datePurchase,
      'PhotoPlant': photoUrl,
    },
  );
  Future<Response> uploadPlantPhoto(int plantId, File photoFile) async {
    String fileName = photoFile.path.split('/').last;
    FormData formData = FormData.fromMap({
      'photo': await MultipartFile.fromFile(photoFile.path, filename: fileName),
    });
    return await _dio.post('/Plant/$plantId/photo', data: formData);
  }

  Future<Response> updatePlant({
    required int plantId,
    required String namePlant,
    required int idTypePlant,
    required String datePurchase,
    String? photoUrl,
  }) => _dio.put(
    '/Plant/$plantId',
    data: {
      'Name_Plant': namePlant,
      'Id_TypePlant': idTypePlant,
      'DatePurchase': datePurchase,
      'PhotoPlant': photoUrl,
    },
  );

  Future<Response> deletePlant(int plantId) => _dio.delete('/Plant/$plantId');

  Future<Response> updateCare({
    required int plantId,
    String? lastWateringDate,
    String? lastFertilizingDate,
    String? notes,
  }) => _dio.put(
    '/Plant/$plantId/care',
    data: {
      'LastWateringDate': lastWateringDate,
      'LastFertilizingDate': lastFertilizingDate,
      'Notes': notes,
    },
  );
  Future<Response> updateProfile({
    String? fullName,
    String? email,
    File? avatar,
  }) async {
    final formData = <String, dynamic>{};

    if (fullName != null) formData['FullName_User'] = fullName;
    if (email != null) formData['Email'] = email;

    if (avatar != null) {
      formData['Avatar'] = await MultipartFile.fromFile(
        avatar.path,
        filename: avatar.path.split('/').last,
      );
    }

    return await _dio.put('/Auth/profile', data: FormData.fromMap(formData));
  }

  Future<Response> addDiaryEntry({
    required int plantId,
    String? note,
    String? photoUrl,
  }) => _dio.post(
    '/Plant/$plantId/diary',
    data: {'Note': note, 'PhotoUrl': photoUrl},
  );
  Future<Response> getMyInfo() => _dio.get('/Auth/me');
  Future<List<dynamic>> getEmergencyProblems() async {
    final response = await _dio.get('/EmergencyHelp/problems');
    return response.data;
  }

  Future<Map<String, dynamic>> getEmergencyProblemDetails(int problemId) async {
    final response = await _dio.get('/EmergencyHelp/problems/$problemId');
    return response.data;
  }

  Future<Map<String, dynamic>> submitEmergencyDiagnosis(
    int plantId,
    int problemId,
  ) async {
    final response = await _dio.post(
      '/EmergencyHelp/diagnose',
      data: {'id_Plant': plantId, 'id_Problem': problemId},
    );
    return response.data;
  }

  Future<List<dynamic>> getDiagnosisHistory() async {
    final response = await _dio.get('/EmergencyHelp/history');
    return response.data;
  }

  Future<Map<String, dynamic>> requestPasswordResetCode(String email) async {
    final response = await _dio.post(
      '/PasswordReset/request-code',
      data: {'email': email},
    );
    return response.data;
  }

  Future<Map<String, dynamic>> verifyResetCode(
    String email,
    String code,
  ) async {
    final response = await _dio.post(
      '/PasswordReset/verify-code',
      data: {'email': email, 'code': code},
    );
    return response.data;
  }

  Future<Map<String, dynamic>> resetPassword(
    String email,
    String code,
    String newPassword,
  ) async {
    final response = await _dio.post(
      '/PasswordReset/reset-password',
      data: {'email': email, 'code': code, 'newPassword': newPassword},
    );
    return response.data;
  }
}
