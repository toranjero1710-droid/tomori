import 'package:flutter/material.dart';

import '../data/local/app_database.dart';
import '../data/models/tomori_models.dart';

class TomoriViewModel extends ChangeNotifier {
  TomoriViewModel() {
    final screen = int.tryParse(Uri.base.queryParameters['screen'] ?? '');
    if (screen != null && screen >= 0 && screen <= 5) currentIndex = screen;
    loadSprint6Workflow();
  }

  int currentIndex = 0;
  bool isRecording = false;
  bool dataLoaded = false;
  bool hasStoredData = false;
  bool letterSaved = true;
  String recordingTime = '00:00';
  String aiDraft = testAiDraft;
  String note = '紫陽花の写真を添えてお送りします。';
  String voiceMemo = testVoiceMemo;
  String visitWeather = '晴れ';
  String visitDate = '2026-07-18';
  String visitActions = '外観確認, ポスト確認, 換気, 通水, 玄関前の簡単な掃き掃除, 庭の草を少し整える, 施錠確認';
  String annualSummary = '2026-07-18 晴れ: 玄関前の掃き掃除、紫陽花、松、換気・通水、施錠確認を記録。';
  String houseImportant = '庭の紫陽花\nお父様が植えた松\n仏壇\n玄関前をきれいに保つこと';
  String houseNextChecks = '松の状態\nポスト\n紫陽花\n雨どい\n玄関まわり';
  String houseMemo = '紫陽花の写真を毎回楽しみにされている\n年末に帰省予定\n勝手な修理や処分は絶対に行わない\n気になる点は写真付きで事前相談する';

  static const homeImage = 'assets/images/hero/tomori-hero-home.png';

  List<Customer> customers = const [];

  List<PhotoGuide> photoGuides = const [
    PhotoGuide('家全体', true, homeImage),
    PhotoGuide('玄関', true, homeImage),
    PhotoGuide('庭', true, 'assets/images/services/care.webp'),
    PhotoGuide('室内', true, 'assets/images/services/home-watch.webp'),
    PhotoGuide('気になった場所', true, 'assets/images/services/photo-seven.webp'),
    PhotoGuide('季節の一枚', true, 'assets/images/services/tomori-letter.webp'),
    PhotoGuide('巡回終了後のお家', true, 'assets/images/services/annual-letter.webp'),
  ];

  List<SeasonAlbum> seasons = const [
    SeasonAlbum('春', '3月〜5月', 'assets/images/annual-letter/season-album.webp'),
    SeasonAlbum('夏', '6月〜8月', homeImage),
    SeasonAlbum('秋', '9月〜11月', 'assets/images/services/annual-letter.webp'),
    SeasonAlbum('冬', '12月〜2月', 'assets/images/services/tomori-letter.webp'),
  ];

  List<Map<String, String>> fiveTalks = const [
    {'question': '今、一番気になっていること', 'answer': '台風や大雨の後のお家の状態が心配。'},
    {'question': 'このお家で大切にされていること', 'answer': '庭の紫陽花と、お父様が植えた松。'},
    {'question': '今はどなたが見守られているか', 'answer': '長女の山田花子様。'},
    {'question': 'お家までどれくらい離れているか', 'answer': '東京から大阪のため、すぐには帰れない。'},
    {'question': 'これから、このお家をどうしていきたいか', 'answer': '今すぐ売却せず、しばらく家族の思い出として残したい。'},
  ];

  Future<void> loadSprint6Workflow() async {
    try {
      final snapshot = await AppDatabase.instance.loadSprint6Snapshot();
      if (snapshot != null) {
        _applySnapshot(snapshot);
        hasStoredData = true;
      }
    } on UnsupportedError {
      hasStoredData = true;
      customers = _previewCustomers;
    } catch (_) {
      // Keep the app usable even if a local test database is unavailable.
    }
    dataLoaded = true;
    notifyListeners();
  }

  void _applySnapshot(Map<String, dynamic> snapshot) {
    final customer = snapshot['customer'] as Map<String, Object?>;
    final plannedVisit = snapshot['plannedVisit'] as Map<String, Object?>?;
    final completedVisit = snapshot['completedVisit'] as Map<String, Object?>?;
    final photos = (snapshot['photos'] as List).cast<Map<String, Object?>>();
    final talks = (snapshot['fiveTalks'] as List).cast<Map<String, Object?>>();
    final houseNote = snapshot['houseNote'] as Map<String, Object?>?;
    final letter = snapshot['letter'] as Map<String, Object?>?;
    final annual = snapshot['annual'] as Map<String, Object?>?;

    final nextVisit = '${plannedVisit?['scheduledAt'] ?? '2026-07-25 10:00'}';
    customers = [
      Customer(
        name: '${customer['name']}',
        displayName: '${customer['displayName'] ?? '山田様のお家'}',
        time: nextVisit.length >= 16 ? nextVisit.substring(11, 16) : '10:00',
        address: '${customer['address']}',
        plan: '${customer['plan']}',
        phone: '${customer['phone'] ?? ''}',
        lineId: '${customer['lineId'] ?? '未設定'}',
        keyNumber: '${customer['keyNumber'] ?? ''}',
        emergencyContact: '${customer['emergencyContact'] ?? ''}',
        emergencyPhone: '${customer['emergencyPhone'] ?? ''}',
        imagePath: '${customer['imagePath'] ?? homeImage}',
        nextVisit: nextVisit,
      ),
    ];

    if (completedVisit != null) {
      visitDate = '${completedVisit['scheduledAt'] ?? visitDate}';
      visitWeather = '${completedVisit['weather'] ?? visitWeather}';
      visitActions = '${completedVisit['actions'] ?? visitActions}';
      voiceMemo = '${completedVisit['voiceMemo'] ?? voiceMemo}';
    }
    if (photos.isNotEmpty) {
      photoGuides = photos.map((row) {
        return PhotoGuide('${row['guideName']}', row['captured'] == 1, '${row['imagePath']}');
      }).toList();
    }
    if (talks.isNotEmpty) {
      fiveTalks = talks.map((row) => {'question': '${row['question']}', 'answer': '${row['answer']}'}).toList();
    }
    if (houseNote != null) {
      houseImportant = '${houseNote['importantThings']}';
      houseNextChecks = '${houseNote['nextChecks']}';
      houseMemo = '${houseNote['tomoriMemo']}';
    }
    if (letter != null) {
      aiDraft = '${letter['draftText']}';
      note = '${letter['note'] ?? ''}';
      letterSaved = letter['sentAt'] != null;
    }
    if (annual != null) {
      annualSummary = '${annual['recordSummary'] ?? annualSummary}';
    }
  }

  void setScreen(int index) {
    currentIndex = index;
    notifyListeners();
  }

  void toggleRecording() {
    isRecording = !isRecording;
    recordingTime = isRecording ? '00:12' : '00:00';
    notifyListeners();
  }

  void createAiDraft() {
    aiDraft = testAiDraft;
    currentIndex = 4;
    notifyListeners();
  }

  Future<void> saveLetterNote() async {
    try {
      await AppDatabase.instance.saveManualLetterNote(note);
      final snapshot = await AppDatabase.instance.loadSprint6Snapshot();
      if (snapshot != null) _applySnapshot(snapshot);
    } on UnsupportedError {
      letterSaved = true;
    }
    notifyListeners();
  }

  void updateNote(String value) {
    note = value;
  }
}

const _previewCustomers = [
  Customer(
    name: '山田テスト様',
    displayName: '山田様のお家',
    time: '10:00',
    address: '大阪府高槻市テスト町1-2-3',
    plan: '基本プラン',
    phone: '090-0000-0000',
    lineId: '未設定',
    keyNumber: 'TEST-001',
    emergencyContact: '山田花子',
    emergencyPhone: '090-1111-1111',
    imagePath: TomoriViewModel.homeImage,
    nextVisit: '2026-07-25 10:00',
  ),
];
