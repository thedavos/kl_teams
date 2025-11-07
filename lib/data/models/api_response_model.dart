import 'package:kl_teams/data/models/team_model.dart';

class ApiResponseModel {
  final bool success;
  final int statusCode;
  final String message;
  final List<TeamModel> data;
  final dynamic errors;

  ApiResponseModel({
    required this.success,
    required this.statusCode,
    required this.message,
    required this.data,
    this.errors,
  });

  factory ApiResponseModel.fromJson(Map<String, dynamic> json) {
    return ApiResponseModel(
      success: json['success'] as bool,
      statusCode: json['statusCode'] as int,
      message: json['message'] as String,
      data: (json['data'] as List<dynamic>)
          .map((team) => TeamModel.fromJson(team as Map<String, dynamic>))
          .toList(),
      errors: json['errors'],
    );
  }
}