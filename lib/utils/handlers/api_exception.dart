import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mapman/routes/app_routes.dart';
import 'package:mapman/utils/constants/enums.dart';
import 'package:mapman/utils/constants/strings.dart';
import 'package:mapman/utils/handlers/app_exceptions.dart';
import 'package:mapman/views/widgets/custom_snackbar.dart';

class ExceptionHandler {
  static AppException handleApiException(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      throw DataFetchException('Connection Timed Out');
    } else if (e.type == DioExceptionType.connectionError || e.error is SocketException) {
      final errorMessage = e.error.toString();
      if (errorMessage.contains('Network is unreachable') || errorMessage.contains('errno = 101')) {
        throw DataFetchException('Network restricted. Please disable Data Saver or allow this app in your Data Saver settings.');
      }
      throw DataFetchException(Strings.noInternet);
    } else if (e.response?.statusCode == 400) {
      String? type = e.response?.data['error']['type'];
      String? message = e.response?.data['error']['message'];
      if (type == Strings.unauthorizedException ||
          message == Strings.unauthorized) {
        // SessionManager.clearSession();
        message = Strings.tokenExpired;
      } else {
        message = e.response?.data['error']['message'];
      }
      throw BadRequestException(message ?? 'Bad Request');
    } else if (e.response?.statusCode == 401) {
      throw UnauthorizedException();
    } else if (e.response?.statusCode == 429) {
      throw TooManyRequestsException();
    } else if (e.response?.statusCode == 500) {
      throw InternalErrorException();
    } else {
      throw UnknownErrorException();
    }
  }

  static void handleUiException({
    required BuildContext context,
    required Status status,
    required String? message,
    bool? showDataNotFound,
    void Function()? onServerError,
  }) {
    if (status == Status.ERROR) {
      if (onServerError != null) {
        onServerError();
      }
      if ((message?.contains(Strings.unauthorizedException) ?? false) ||
          (message?.contains(Strings.tokenExpired) ?? false)) {
        CustomToast.show(
          context,
          title: message ?? 'Token Expired',
          isError: true,
        );
        context.goNamed(AppRoutes.login);
      } else if (message?.contains('Network restricted') ?? false) {
        CustomToast.show(
          context,
          title: 'Mobile Data Blocked: Please disable Data Saver or allow MapMan in Data Saver settings.',
          isError: true,
        );
      } else if (message?.contains(Strings.noInternet) ?? false) {
        //TODO: Design No internet page
        // context.goNamed(noInternetRoute);
        CustomToast.show(
          context,
          title: 'No Internet Connection',
          isError: true,
        );
      } else if (message?.contains('Connection Timed Out') ?? false) {
        CustomToast.show(
          context,
          title: 'Connection Timed Out. Server might be busy.',
          isError: true,
        );
      } else if (showDataNotFound ?? true) {
        CustomToast.show(
          context,
          title: message ?? 'Unknown Error',
          isError: true,
        );
      }
    }
  }
}
