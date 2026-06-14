import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_providers.dart';
import '../data/statistics_api_service.dart';
import '../data/statistics_repository_impl.dart';
import '../domain/statistics_models.dart';
import '../domain/statistics_repository.dart';

final statisticsApiServiceProvider = Provider<StatisticsApiService>((ref) {
  return StatisticsApiService(ref.watch(apiClientProvider));
});

final statisticsRepositoryProvider = Provider<StatisticsRepository>((ref) {
  return StatisticsRepositoryImpl(ref.watch(statisticsApiServiceProvider));
});

final probabilityStatisticsProvider =
    FutureProvider.autoDispose<ProbabilityStatistics>((ref) {
      return ref.watch(statisticsRepositoryProvider).getMyStatistics();
    });
