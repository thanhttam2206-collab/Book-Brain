import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:book_brain/service/api_service/response/base_response.dart';
import 'package:book_brain/service/service_config/network_service.dart';
import 'package:book_brain/utils/core/common/dialog_alert.dart';

abstract class BaseApiService {
  final Dio dio = NetworkService().dio;

  Future<BaseResponse<T>> sendRequest<T>(
    String url, {
    required T Function(Map<String, dynamic>) fromJson,
    String method = 'GET',
    dynamic data,
  }) async {
    try {
      Response response;

      // Chọn phương thức HTTP
      switch (method) {
        case 'POST':
          response = await dio.post(url, data: data);
          break;
        case 'PUT':
          response = await dio.put(url, data: data);
          break;
        case 'DELETE':
          response = await dio.delete(url, data: data);
          break;
        default:
          response = await dio.get(url, queryParameters: data);
      }

      return _parseResponse<T>(
        response.data,
        statusCode: response.statusCode,
        fromJson: fromJson,
      );
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        DialogAlert.showTimeoutDialog(
          'connection_error'.tr(),
          'connection_timeout'.tr(),
        );
      }
      if (e.response != null) {
        return _parseResponse<T>(
          e.response!.data,
          statusCode: e.response!.statusCode,
          fromJson: fromJson,
        );
      } else {
        return BaseResponse<T>(error: 'DioError: ${e.message}');
      }
    } catch (e) {
      return BaseResponse<T>(error: 'Unexpected Error: $e');
    }
  }

  BaseResponse<T> _parseResponse<T>(
    dynamic payload, {
    required T Function(Map<String, dynamic>) fromJson,
    int? statusCode,
  }) {
    try {
      if (payload is Map) {
        return BaseResponse<T>.fromJson(
          Map<String, dynamic>.from(payload),
          fromJson,
        );
      }
      return BaseResponse<T>(
        status: statusCode?.toString(),
        error: payload?.toString() ?? 'Empty server response',
      );
    } catch (error) {
      return BaseResponse<T>(
        status: statusCode?.toString(),
        error: 'Invalid server response: $error',
      );
    }
  }
}
