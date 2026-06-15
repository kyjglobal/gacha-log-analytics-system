String rarityLabel(String rarity) {
  return switch (rarity.toLowerCase()) {
    'mythic' => '신화',
    'legendary' => '전설',
    'epic' => '영웅',
    'rare' => '희귀',
    _ => '일반',
  };
}

String itemDisplayName(String name) {
  return switch (name) {
    'Astra Crown' => '아스트라 왕관',
    'Abyss Codex' => '심연의 고서',
    'Starblade' => '별빛 검',
    'Spirit Ring' => '정령의 반지',
    'Mana Potion' => '마나 물약',
    'Guardian Shield' => '수호자의 방패',
    _ => name,
  };
}

String bannerDisplayName(String name) {
  return switch (name) {
    'Celestial Trace' => '천상의 궤적',
    _ => name,
  };
}

String userStatusLabel(String status) {
  return switch (status) {
    'active' => '활성',
    'suspended' => '정지',
    'blocked' => '차단',
    _ => status,
  };
}
