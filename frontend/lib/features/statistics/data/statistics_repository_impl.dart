import '../domain/statistics_models.dart';
import '../domain/statistics_repository.dart';
import 'statistics_api_service.dart';

class StatisticsRepositoryImpl implements StatisticsRepository {
  StatisticsRepositoryImpl(this._api);

  final StatisticsApiService _api;

  @override
  Future<ProbabilityStatistics> getMyStatistics({int? bannerId}) async {
    return ProbabilityStatistics.fromJson(
      await _api.getMyStatistics(bannerId: bannerId),
    );
  }
}
