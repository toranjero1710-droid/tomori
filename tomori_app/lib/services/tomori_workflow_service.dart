import '../data/local/app_database.dart';
import '../data/local/tomori_dao.dart';

class TomoriWorkflowService {
  const TomoriWorkflowService();

  Future<void> registerYamadaWorkflow() async {
    final db = await AppDatabase.instance.open();
    await db.transaction((txn) async {
      final dao = TomoriDao(txn);
      final customerId = await dao.upsertByWhere(
        'Customer',
        values: yamadaCustomer,
        where: 'name = ?',
        whereArgs: [yamadaCustomer['name']],
      );
      final visitId = await dao.upsertByWhere(
        'Visit',
        values: {
          'customerId': customerId,
          'scheduledAt': '2026-07-18',
          'status': 'completed',
          'weather': '晴れ',
          'actions': '外観確認, ポスト確認, 換気, 通水, 玄関前の簡単な掃き掃除, 庭の草を少し整える, 施錠確認',
          'voiceMemo': yamadaVoiceMemo,
        },
        where: 'customerId = ? AND scheduledAt = ? AND status = ?',
        whereArgs: [customerId, '2026-07-18', 'completed'],
      );
      for (final photo in yamadaPhotos) {
        await dao.upsertByWhere(
          'Photo',
          values: {'visitId': visitId, ...photo},
          where: 'visitId = ? AND guideName = ?',
          whereArgs: [visitId, photo['guideName']],
        );
      }
      await dao.upsertByWhere(
        'FiveTalk',
        values: {
          'customerId': customerId,
          'questionNumber': 1,
          'question': '5つのお話',
          'answer': yamadaFiveTalk,
        },
        where: 'customerId = ? AND questionNumber = ?',
        whereArgs: [customerId, 1],
      );
      await dao.upsertByWhere(
        'HouseNote',
        values: {
          'customerId': customerId,
          'importantThings': '庭の紫陽花\nお父様が植えた松\n仏壇\n玄関前をきれいに保つこと',
          'nextChecks': '松の状態\nポスト\n紫陽花\n雨どい\n玄関まわり',
          'tomoriMemo': '紫陽花の写真を毎回楽しみにされている\n年末に帰省予定\n勝手な修理や処分は絶対に行わない\n気になる点は写真付きで事前相談する',
        },
        where: 'customerId = ?',
        whereArgs: [customerId],
      );
      await dao.upsertByWhere(
        'TomoriLetter',
        values: {
          'visitId': visitId,
          'draftText': yamadaAiDraft,
          'note': '紫陽花の写真を添えてお送りします。',
          'sentAt': '2026-07-18 11:00',
        },
        where: 'visitId = ?',
        whereArgs: [visitId],
      );
      await dao.upsertByWhere(
        'AnnualLetter',
        values: {
          'customerId': customerId,
          'year': 2026,
          'springImage': 'assets/images/annual-letter/season-album.webp',
          'summerImage': 'assets/images/hero/tomori-hero-home.png',
          'autumnImage': 'assets/images/services/annual-letter.webp',
          'winterImage': 'assets/images/services/tomori-letter.webp',
          'recordSummary': '2026-07-18 晴れ: 玄関前の掃き掃除、紫陽花、松、換気・通水、施錠確認を記録。',
        },
        where: 'customerId = ? AND year = ?',
        whereArgs: [customerId, 2026],
      );
      await dao.upsertByWhere(
        'Memo',
        values: {'customerId': customerId, 'body': yamadaVoiceMemo, 'createdAt': '2026-07-18'},
        where: 'customerId = ? AND createdAt = ?',
        whereArgs: [customerId, '2026-07-18'],
      );
    });
  }
}

const yamadaCustomer = {
  'name': '山田テスト様',
  'displayName': '山田様のお家',
  'address': '大阪府高槻市テスト町1-2-3',
  'plan': '基本プラン',
  'phone': '090-0000-0000',
  'lineId': '未設定',
  'keyNumber': 'TEST-001',
  'emergencyContact': '山田花子',
  'emergencyPhone': '090-1111-1111',
  'imagePath': 'assets/images/hero/tomori-hero-home.png',
  'nextVisit': '2026-07-25 10:00',
};

const yamadaPhotos = [
  {'guideName': '家全体', 'imagePath': 'assets/images/hero/tomori-hero-home.png', 'captured': 1},
  {'guideName': '玄関', 'imagePath': 'assets/images/hero/tomori-hero-home.png', 'captured': 1},
  {'guideName': '庭', 'imagePath': 'assets/images/services/care.webp', 'captured': 1},
  {'guideName': '室内', 'imagePath': 'assets/images/services/home-watch.webp', 'captured': 1},
  {'guideName': '気になった場所', 'imagePath': 'assets/images/services/photo-seven.webp', 'captured': 1},
  {'guideName': '季節の一枚', 'imagePath': 'assets/images/services/tomori-letter.webp', 'captured': 1},
  {'guideName': '巡回終了後のお家', 'imagePath': 'assets/images/services/annual-letter.webp', 'captured': 1},
];

const yamadaFiveTalk = '1. 台風や大雨の後のお家の状態が心配。\n2. 庭の紫陽花と、お父様が植えた松。\n3. 長女の山田花子様。\n4. 東京から大阪のため、すぐには帰れない。\n5. 今すぐ売却せず、しばらく家族の思い出として残したい。';

const yamadaVoiceMemo = '玄関前を掃きました。\n庭の紫陽花がきれいに咲いていました。\n郵便物はチラシが2通ありました。\n換気と通水を行いました。\n雨漏りや窓ガラスの破損は見当たりませんでした。\n松も元気そうでした。\n最後に窓と玄関の施錠を確認しました。';

const yamadaAiDraft = '今日も、お家へ会いに行ってきました。\n\n玄関前を掃き、庭の紫陽花がきれいに咲いていることを確認しました。郵便物はチラシが2通ありました。\n\n換気と通水を行い、雨漏りや窓ガラスの破損は見当たりませんでした。お父様が植えられた松も元気そうでした。\n\n最後に窓と玄関の施錠を確認しています。\n\n今日も、お家は変わらず元気でした。';
