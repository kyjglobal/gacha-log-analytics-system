import 'ranking_models.dart';

abstract interface class RankingRepository {
  Future<RankingBoard> getRankings({
    int? bannerId,
    int minimumDraws = 10,
    int limit = 20,
  });
}
