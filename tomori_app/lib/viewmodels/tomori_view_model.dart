import 'package:flutter/material.dart';

import '../ai/ai_service.dart';
import '../ai/models/tomori_letter_input.dart';
import '../ai/openai_service.dart';
import '../data/models/tomori_models.dart';
import '../data/repositories/tomori_repository.dart';
import '../services/tomori_workflow_service.dart';

class TomoriViewModel extends ChangeNotifier {
  TomoriViewModel({TomoriRepository? repository, AiService? aiService})
      : repository = repository ?? TomoriRepository(),
        service = const TomoriWorkflowService(),
        aiService = aiService ?? OpenAiService() {
    final screen = int.tryParse(Uri.base.queryParameters['screen'] ?? '');
    if (screen != null && screen >= 0 && screen <= 5) currentIndex = screen;
    loadFromSqlite();
  }

  final TomoriRepository repository;
  final TomoriWorkflowService service;
  final AiService aiService;

  int currentIndex = 0;
  int? currentVisitId;
  bool isRecording = false;
  bool dataLoaded = false;
  bool hasStoredData = false;
  bool isGeneratingAi = false;
  bool letterSaved = false;
  String aiError = '';
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
    photoGuides = photos
        .map(
          (row) => PhotoGuide(
            '${row['guideName']}',
            row['captured'] == 1,
            '${row['imagePath']}',
          ),
        )
        .toList();
    if (talk != null) {
      fiveTalks = [
        {'question': '${talk['question']}', 'answer': '${talk['answer']}'},
      ];
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

  Future<void> createAiDraft() async {
    if (currentVisitId == null || customers.isEmpty) return;
    isGeneratingAi = true;
    aiError = '';
    notifyListeners();
    try {
      final input = TomoriLetterInput(
        visitDate: visitDate,
        weather: visitWeather,
        photoLabels: photoGuides.map((photo) => photo.name).toList(),
        voiceMemo: voiceMemo,
        fiveTalk: fiveTalks.map((talk) => talk['answer'] ?? '').join('\n'),
        houseNote: [houseImportant, houseNextChecks]
            .where((value) => value.trim().isNotEmpty)
            .join('\n'),
        staffMemo: houseMemo,
      );
      final generated = await aiService.generateTomoriLetter(input);
      aiDraft = generated;
      await repository.saveTomoriLetter({
        'visitId': currentVisitId,
        'draftText': generated,
        'note': note,
        'sentAt': null,
      });
      final snapshot = await repository.loadYamadaSnapshot();
      if (snapshot != null) _applySnapshot(snapshot);
      currentIndex = 4;
    } on AiConfigurationException catch (error) {
      aiError = error.message;
      currentIndex = 3;
    } catch (_) {
      aiError = 'AI生成に失敗しました。設定と通信状態を確認してください。';
      currentIndex = 3;
    } finally {
      isGeneratingAi = false;
      notifyListeners();
    }
  }

  Future<void> saveLetterNote() async {
    final visitId = currentVisitId;
    if (visitId == null) return;
    await repository.saveTomoriLetter({
      'visitId': visitId,
      'draftText': aiDraft,
      'note': note,
      'sentAt': '2026-07-18 11:00',
    });
    final snapshot = await repository.loadYamadaSnapshot();
    if (snapshot != null) _applySnapshot(snapshot);
    notifyListeners();
  }

  void updateNote(String value) {
    note = value;
  }
}
