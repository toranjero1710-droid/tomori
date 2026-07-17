class TomoriLetterInput {
  const TomoriLetterInput({
    required this.customerName,
    required this.homeName,
    required this.visitDate,
    required this.weather,
    required this.photoNotes,
    required this.workActions,
    required this.voiceMemo,
    required this.fiveTalk,
    required this.houseNote,
    required this.staffMemo,
  });

  final String customerName;
  final String homeName;
  final String visitDate;
  final String weather;
  final List<String> photoNotes;
  final String workActions;
  final String voiceMemo;
  final String fiveTalk;
  final String houseNote;
  final String staffMemo;

  String toPromptInput() {
    return [
      'お客様名: $customerName',
      '家名: $homeName',
      '訪問日: $visitDate',
      '天気: $weather',
      '写真メモ: ${photoNotes.join(', ')}',
      '作業内容:',
      workActions,
      '音声メモ:',
      voiceMemo,
      'FiveTalk:',
      fiveTalk,
      'HouseNote:',
      houseNote,
      '担当者メモ:',
      staffMemo,
    ].join('\n');
  }
}
