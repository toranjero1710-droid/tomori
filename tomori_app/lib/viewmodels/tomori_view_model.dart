import 'package:flutter/material.dart';

import '../data/models/tomori_models.dart';
import '../data/repositories/tomori_repository.dart';
import '../services/tomori_workflow_service.dart';

class TomoriViewModel extends ChangeNotifier {
  TomoriViewModel({TomoriRepository? repository})
      : repository = repository ?? TomoriRepository(),
        service = const TomoriWorkflowService() {
    final screen = int.tryParse(Uri.base.queryParameters['screen'] ?? '');
    if (screen != null && screen >= 0 && screen <= 5) currentIndex = screen;
    loadFromSqlite();
  }

  final TomoriRepository repository;
  final TomoriWorkflowService service;

  int currentIndex = 0;
  int? currentVisitId;
  bool isRecording = false;
  bool dataLoaded = false;
  bool hasStoredData = false;
  bool letterSaved = false;
  String recordingTime = '00:00';
  String aiDraft = '';
  String note = '';
  String voiceMemo = '';
  String visitWeather = '';
  String visitDate = '';
  String visitActions = '';
  String annualSummary = '';
  String houseImportant = '';
  String houseNextChecks = '';
  String houseMemo = '';

  static const homeImage = 'assets/images/hero/tomori-hero-home.png';

  List<Customer> customers = const [];
  List<PhotoGuide> photoGuides = const [];
  List<Map<String, String>> fiveTalks = const [];

  final seasons = const [
    SeasonAlbum('春', '3月〜5月', 'assets/images/annual-letter/season-album.webp'),
    SeasonAlbum('夏', '6月〜8月', homeImage),
    SeasonAlbum('秋', '9月〜11月', 'assets/images/services/annual-letter.webp'),
    SeasonAlbum('冬', '12月〜2月', 'assets/images/services/tomori-letter.webp'),
  ];

  Future<void> loadFromSqlite() async {
    try {
      final snapshot = await repository.loadYamadaSnapshot();
      if (snapshot != null) {
        _applySnapshot(snapshot);
        hasStoredData = true;
      } else {
        _clearLoadedData();
      }
    } on UnsupportedError {
      _clearLoadedData();
    }
    dataLoaded = true;
    notifyListeners();
  }

  Future<void> registerYamadaHouse() async {
    await service.registerYamadaWorkflow();
    await loadFromSqlite();
  }

  void _applySnapshot(Map<String, dynamic> snapshot) {
    final customer = snapshot['customer'] as Map<String, Object?>;
    final visit = snapshot['visit'] as Map<String, Object?>?;
    final photos = (snapshot['photos'] as List).cast<Map<String, Object?>>();
    final talk = snapshot['fiveTalk'] as Map<String, Object?>?;
    final houseNote = snapshot['houseNote'] as Map<String, Object?>?;
    final letter = snapshot['letter'] as Map<String, Object?>?;
    final annual = snapshot['annual'] as Map<String, Object?>?;
    final nextVisit = '${customer['nextVisit'] ?? ''}';

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

    if (visit != null) {
      currentVisitId = visit['id'] as int?;
      visitDate = '${visit['scheduledAt'] ?? ''}';
      visitWeather = '${visit['weather'] ?? ''}';
      visitActions = '${visit['actions'] ?? ''}';
      voiceMemo = '${visit['voiceMemo'] ?? ''}';
    }
    photoGuides = photos.map((row) => PhotoGuide('${row['guideName']}', row['captured'] == 1, '${row['imagePath']}')).toList();
    if (talk != null) {
      fiveTalks = [{'question': '${talk['question']}', 'answer': '${talk['answer']}'}];
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
      annualSummary = '${annual['recordSummary'] ?? ''}';
    }
  }

  void _clearLoadedData() {
    hasStoredData = false;
    currentVisitId = null;
    customers = const [];
    photoGuides = const [];
    fiveTalks = const [];
    aiDraft = '';
    note = '';
    voiceMemo = '';
    visitWeather = '';
    visitDate = '';
    visitActions = '';
    annualSummary = '';
    houseImportant = '';
    houseNextChecks = '';
    houseMemo = '';
    letterSaved = false;
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
    aiDraft = yamadaAiDraft;
    currentIndex = 4;
    notifyListeners();
  }

  Future<void> saveLetterNote() async {
    final visitId = currentVisitId;
    if (visitId == null) return;
    await repository.saveTomoriLetter({'visitId': visitId, 'draftText': aiDraft, 'note': note, 'sentAt': '2026-07-18 11:00'});
    final snapshot = await repository.loadYamadaSnapshot();
    if (snapshot != null) _applySnapshot(snapshot);
    notifyListeners();
  }

  void updateNote(String value) {
    note = value;
  }
}
