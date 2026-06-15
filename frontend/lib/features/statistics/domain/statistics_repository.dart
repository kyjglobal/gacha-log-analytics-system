import 'statistics_models.dart';

abstract interface class StatisticsRepository {
  Future<ProbabilityStatistics> getMyStatistics({int? bannerId});
}
