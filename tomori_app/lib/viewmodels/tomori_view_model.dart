import 'package:flutter/material.dart';

import '../data/models/tomori_models.dart';

class TomoriViewModel extends ChangeNotifier {
  TomoriViewModel() {
    final screen = int.tryParse(Uri.base.queryParameters['screen'] ?? '');
    if (screen != null && screen >= 0 && screen <= 5) {
      currentIndex = screen;
    }
  }

  int currentIndex = 0;
  bool isRecording = false;
  String recordingTime = '00:00';
  String aiDraft = '山田様、\n今日もお家へ会いに行ってきました。\n玄関先を掃除し、庭の紫陽花がとてもきれいに咲いていました。\n窓の木も元気そうで、風に揺れる姿が印象的でした。\nお家は変わらず、穏やかな時間が流れていました。';
  String note = '';

  static const homeImage = 'assets/images/hero/tomori-hero-home.png';

  final customers = const [
    Customer(
      name: '山田様',
      time: '10:00',
      address: '神奈川県鎌倉市',
      imagePath: homeImage,
      nextVisit: '7/26（土）10:00',
    ),
    Customer(
      name: '田中様',
      time: '14:00',
      address: '東京都世田谷区',
      imagePath: homeImage,
      nextVisit: '7/27（日）14:00',
    ),
  ];

  final photoGuides = const [
    PhotoGuide('家全体', true, homeImage),
    PhotoGuide('玄関', true, homeImage),
    PhotoGuide('庭', true, homeImage),
    PhotoGuide('室内', false, 'assets/images/services/home-watch.webp'),
    PhotoGuide('気付き', false, 'assets/images/services/care.webp'),
    PhotoGuide('季節', false, 'assets/images/services/tomori-letter.webp'),
    PhotoGuide('最後にもう一枚', false, 'assets/images/services/annual-letter.webp'),
  ];

  final seasons = const [
    SeasonAlbum('春', '3月〜5月', 'assets/images/annual-letter/season-album.webp'),
    SeasonAlbum('夏', '6月〜8月', homeImage),
    SeasonAlbum('秋', '9月〜11月', 'assets/images/services/annual-letter.webp'),
    SeasonAlbum('冬', '12月〜2月', 'assets/images/services/tomori-letter.webp'),
  ];

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
    aiDraft = '山田様、\n今日もお家へ会いに行ってきました。\n玄関前の落ち葉をそっと掃き、庭の紫陽花がきれいに咲いていることを確認しました。\n郵便物は整理し、窓まわりにも大きな変化はありません。\n離れていても安心していただけるよう、今日の様子を写真と一緒にお届けします。';
    currentIndex = 3;
    notifyListeners();
  }

  void updateNote(String value) {
    note = value;
  }
}
