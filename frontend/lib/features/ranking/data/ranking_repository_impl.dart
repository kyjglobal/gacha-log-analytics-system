import '../domain/ranking_models.dart';
import '../domain/ranking_repository.dart';
import 'ranking_api_service.dart';

class RankingRepositoryImpl implements RankingRepository {
  RankingRepositoryImpl(this._api);

  final RankingApiService _api;

  @override
  Future<RankingBoard> getRankings({
    int? bannerId,
    int minimumDraws = 10,
    int limit = 20,
  }) async {
    return RankingBoard.fromJson(
      await _api.getRankings(
        bannerId: bannerId,
        minimumDraws: minimumDraws,
        limit: limit,
      ),
    );
  }
}
