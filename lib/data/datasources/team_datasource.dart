import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:kl_teams/core/constants/api_constants.dart';
import 'package:kl_teams/core/errors/exceptions.dart';
import 'package:kl_teams/data/models/api_response_model.dart';
import 'package:kl_teams/data/models/team_model.dart';

abstract class TeamDataSource {
  Future<List<TeamModel>> getTeams();
}

class TeamDataSourceImpl implements TeamDataSource {
  final http.Client client;

  TeamDataSourceImpl({required this.client});

  @override
  Future<List<TeamModel>> getTeams() async {
    try {
      final response = await client
          .get(
            Uri.parse('${ApiConstants.baseUrl}${ApiConstants.teamsEndpoint}'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(ApiConstants.timeout);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final apiResponse = ApiResponseModel.fromJson(jsonResponse);

        if (apiResponse.success) {
          return apiResponse.data;
        } else {
          throw ServerException(
            'Error en la respuesta de la API: ${apiResponse.message}',
          );
        }
      } else {
        throw ServerException('Error del servidor: ${response.statusCode}');
      }
    } on http.ClientException {
      throw ConnectionException('No hay conexión a internet');
    } catch (e) {
      if (e is ServerException || e is ConnectionException) {
        rethrow;
      }
      throw ServerException('Error inesperado :${e.toString()}');
    }
  }
}
