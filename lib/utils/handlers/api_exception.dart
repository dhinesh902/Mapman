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
    if (e.error.runtimeType == SocketException) {
      throw DataFetchException('No Internet');
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
      } else if (message == Strings.noInternet) {
        //TODO: Design No internet page
        // context.goNamed(noInternetRoute);
        CustomToast.show(
          context,
          title: message ?? 'No Internet',
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
