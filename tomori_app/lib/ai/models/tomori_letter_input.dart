class TomoriLetterInput {
  const TomoriLetterInput({
    required this.visitDate,
    required this.weather,
    required this.photoLabels,
    required this.voiceMemo,
    required this.fiveTalk,
    required this.houseNote,
    required this.staffMemo,
  });

  final String visitDate;
  final String weather;
  final List<String> photoLabels;
  final String voiceMemo;
  final String fiveTalk;
  final String houseNote;
  final String staffMemo;

  String toPromptInput() {
    return [
      '訪問日時: $visitDate',
      '天気: $weather',
      '写真情報: ${photoLabels.join(', ')}',
      '音声メモ:',
      voiceMemo,
      '5つのお話:',
      fiveTalk,
      'お家ノート:',
      houseNote,
      '担当者メモ:',
      staffMemo,
    ].join('\n');
  }
}
