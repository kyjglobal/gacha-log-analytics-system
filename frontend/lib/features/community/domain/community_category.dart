enum CommunityCategory {
  probability('확률 인증'),
  showcase('가챠 자랑'),
  analysis('통계 분석'),
  guide('공략 및 팁'),
  free('자유 게시판');

  const CommunityCategory(this.label);

  final String label;

  static CommunityCategory fromLabel(String label) {
    return values.firstWhere(
      (category) => category.label == label,
      orElse: () => CommunityCategory.free,
    );
  }
}
