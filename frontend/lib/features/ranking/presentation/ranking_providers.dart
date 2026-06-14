import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_providers.dart';
import '../data/ranking_api_service.dart';
import '../data/ranking_repository_impl.dart';
import '../domain/ranking_models.dart';
import '../domain/ranking_repository.dart';

final rankingApiServiceProvider = Provider<RankingApiService>((ref) {
  return RankingApiService(ref.watch(apiClientProvider));
});

final rankingRepositoryProvider = Provider<RankingRepository>((ref) {
  return RankingRepositoryImpl(ref.watch(rankingApiServiceProvider));
});

final rankingBoardProvider = FutureProvider.autoDispose<RankingBoard>((ref) {
  return ref.watch(rankingRepositoryProvider).getRankings();
});
