import 'package:kuroshiro/src/models/tokenizer_response.dart';

enum RomanizationSystem { nippon, passport, hepburn }

final katakanaHiraganaShift = '\u3041'.codeUnitAt(0) - '\u30a1'.codeUnitAt(0);
final hiraganaKatakanaShift = '\u30a1'.codeUnitAt(0) - '\u3041'.codeUnitAt(0);

bool isHiragana(String char) => char >= '\u3040' && char <= '\u309f';

bool isKatakana(String char) => char >= '\u30a0' && char <= '\u30ff';

bool isKana(String char) => isHiragana(char) || isKatakana(char);

bool isKanji(String char) =>
    (char >= '\u4e00' && char <= '\u9fcf') ||
    (char >= '\uf900' && char <= '\ufaff') ||
    (char >= '\u3400' && char <= '\u4dbf');

bool isJapanese(String char) => isKana(char) || isKanji(char);

bool hasHiragana(String str) {
  for (final c in str.runes) {
    final char = String.fromCharCode(c);
    if (isHiragana(char)) {
      return true;
    }
  }

  return false;
}

bool hasKatakana(String str) {
  for (final c in str.runes) {
    final char = String.fromCharCode(c);
    if (isKatakana(char)) {
      return true;
    }
  }

  return false;
}

bool hasKana(String str) {
  for (final c in str.runes) {
    final char = String.fromCharCode(c);
    if (isKana(char)) {
      return true;
    }
  }

  return false;
}

bool hasKanji(String str) {
  for (final c in str.runes) {
    final char = String.fromCharCode(c);
    if (isKanji(char)) {
      return true;
    }
  }

  return false;
}

bool hasJapanese(String str) {
  for (final c in str.runes) {
    final char = String.fromCharCode(c);
    if (isJapanese(char)) {
      return true;
    }
  }

  return false;
}

String toRawHiragana(String str) {
  final sb = StringBuffer();
  for (final c in str.runes) {
    final char = String.fromCharCode(c);
    if (char > '\u30a0' && char < '\u30f7') {
      sb.write(String.fromCharCode(c + katakanaHiraganaShift));
    }
    sb.write(char);
  }
  return sb.toString();
}

String toRawKatakana(String str) {
  final sb = StringBuffer();
  for (final c in str.runes) {
    final char = String.fromCharCode(c);
    if (char > '\u3040' && char < '\u3097') {
      sb.write(String.fromCharCode(c + hiraganaKatakanaShift));
    }
    sb.write(char);
  }
  return sb.toString();
}

String toRawRomaji(
  String str, [
  RomanizationSystem system = RomanizationSystem.hepburn,
]) {
  final table = getRomajiSystem(system);
  final regTsu = RegExp(r'(っ|ッ)([bcdfghijklmnopqrstuvwyz])', multiLine: true);
  final regXtsu = RegExp(r'っ|ッ');

  int pnt = 0;
  String ch;
  String? r;
  String result = '';

  if (system == RomanizationSystem.passport) {
    str = str.replaceAll('ー', '');
  }

  if (system case RomanizationSystem.nippon || RomanizationSystem.hepburn) {
    final regHatu = RegExp(
      r'(ん|ン)(?=あ|い|う|え|お|ア|イ|ウ|エ|オ|ぁ|ぃ|ぅ|ぇ|ぉ|ァ|ィ|ゥ|ェ|ォ|や|ゆ|よ|ヤ|ユ|ヨ|ゃ|ゅ|ょ|ャ|ュ|ョ)',
    );
    RegExpMatch? match;
    final indices = <int>[];
    while ((match = regHatu.firstMatch(str)) != null) {
      indices.add(match!.start + 1);
    }

    if (indices.isNotEmpty) {
      var mStr = "";
      for (var i = 0; i < indices.length; i++) {
        if (i == 0) {
          mStr += "${str.substring(0, indices[i])}'";
        } else {
          mStr += "${str.substring(indices[i - 1], indices[i])}'";
        }
      }
      mStr += str.substring(indices.last);
      str = mStr;
    }
  }

  final max = str.length;
  while (pnt <= max) {
    String k = '';

    try {
      k = str.substring(pnt, pnt + 2);
    } on RangeError {
      k = '';
    }

    if ((r = table[k]) != null) {
      result += r!;
      pnt += 2;
    } else {
      String char = '';
      try {
        char = str.substring(pnt, pnt + 1);
      } on RangeError {
        char = '';
      }
      result += (r = table[(ch = char)]) != null ? r! : ch;
      pnt++;
    }
  }

  result = result.replaceAllMapped(regTsu, (m) => '${m[2]}${m[2]}');
  if (system case RomanizationSystem.passport || RomanizationSystem.hepburn) {
    result = result.replaceAll('cc', 'tc');
  }
  result = result.replaceAll(regXtsu, 'tsu');

  if (system case RomanizationSystem.passport || RomanizationSystem.hepburn) {
    result = result.replaceAll('nm', 'mm');
    result = result.replaceAll('nb', 'mb');
    result = result.replaceAll('np', 'mp');
  }

  if (system case RomanizationSystem.nippon) {
    result = result.replaceAll('aー', "â");
    result = result.replaceAll('iー', "î");
    result = result.replaceAll('uー', "û");
    result = result.replaceAll('eー', "ê");
    result = result.replaceAll('oー', "ô");
  }

  if (system case RomanizationSystem.hepburn) {
    result = result.replaceAll('aー', "ā");
    result = result.replaceAll('iー', "ī");
    result = result.replaceAll('uー', "ū");
    result = result.replaceAll('eー', "ē");
    result = result.replaceAll('oー', "ō");
  }

  return result;
}

Map<String, String> getRomajiSystem(RomanizationSystem system) =>
    switch (system) {
      RomanizationSystem.nippon => {
        // 数字と記号
        '１': '1',
        '２': '2',
        '３': '3',
        '４': '4',
        '５': '5',
        '６': '6',
        '７': '7',
        '８': '8',
        '９': '9',
        '０': '0',
        '！': '!',
        '“': '"',
        '”': '"',
        '＃': '#',
        '＄': r'$',
        '％': '%',
        '＆': '&',
        '’': '',
        '（': '(',
        '）': ')',
        '＝': '=',
        '～': '~',
        '｜': '|',
        '＠': '@',
        '‘': '`',
        '＋': '+',
        '＊': '*',
        '；': ';',
        '：': ':',
        '＜': '<',
        '＞': '>',
        '、': ',',
        '。': '.',
        '／': '/',
        '？': '?',
        '＿': '_',
        '・': '･',
        '「': '"',
        '」': '"',
        '｛': '{',
        '｝': '}',
        '￥': r'\',
        '＾': '^',

        // 直音-清音(ア～ノ)
        'あ': 'a',
        'い': 'i',
        'う': 'u',
        'え': 'e',
        'お': 'o',
        'ア': 'a',
        'イ': 'i',
        'ウ': 'u',
        'エ': 'e',
        'オ': 'o',

        'か': 'ka',
        'き': 'ki',
        'く': 'ku',
        'け': 'ke',
        'こ': 'ko',
        'カ': 'ka',
        'キ': 'ki',
        'ク': 'ku',
        'ケ': 'ke',
        'コ': 'ko',

        'さ': 'sa',
        'し': 'si',
        'す': 'su',
        'せ': 'se',
        'そ': 'so',
        'サ': 'sa',
        'シ': 'si',
        'ス': 'su',
        'セ': 'se',
        'ソ': 'so',

        'た': 'ta',
        'ち': 'ti',
        'つ': 'tu',
        'て': 'te',
        'と': 'to',
        'タ': 'ta',
        'チ': 'ti',
        'ツ': 'tu',
        'テ': 'te',
        'ト': 'to',

        'な': 'na',
        'に': 'ni',
        'ぬ': 'nu',
        'ね': 'ne',
        'の': 'no',
        'ナ': 'na',
        'ニ': 'ni',
        'ヌ': 'nu',
        'ネ': 'ne',
        'ノ': 'no',

        // 直音-清音(ハ～ヲ)
        'は': 'ha',
        'ひ': 'hi',
        'ふ': 'hu',
        'へ': 'he',
        'ほ': 'ho',
        'ハ': 'ha',
        'ヒ': 'hi',
        'フ': 'hu',
        'ヘ': 'he',
        'ホ': 'ho',

        'ま': 'ma',
        'み': 'mi',
        'む': 'mu',
        'め': 'me',
        'も': 'mo',
        'マ': 'ma',
        'ミ': 'mi',
        'ム': 'mu',
        'メ': 'me',
        'モ': 'mo',

        'や': 'ya',
        'ゆ': 'yu',
        'よ': 'yo',
        'ヤ': 'ya',
        'ユ': 'yu',
        'ヨ': 'yo',

        'ら': 'ra',
        'り': 'ri',
        'る': 'ru',
        'れ': 're',
        'ろ': 'ro',
        'ラ': 'ra',
        'リ': 'ri',
        'ル': 'ru',
        'レ': 're',
        'ロ': 'ro',

        'わ': 'wa',
        'ゐ': 'wi',
        'ゑ': 'we',
        'を': 'wo',
        'ワ': 'wa',
        'ヰ': 'wi',
        'ヱ': 'we',
        'ヲ': 'wo',

        // 直音-濁音(ガ～ボ)、半濁音(パ～ポ)
        'が': 'ga',
        'ぎ': 'gi',
        'ぐ': 'gu',
        'げ': 'ge',
        'ご': 'go',
        'ガ': 'ga',
        'ギ': 'gi',
        'グ': 'gu',
        'ゲ': 'ge',
        'ゴ': 'go',

        'ざ': 'za',
        'じ': 'zi',
        'ず': 'zu',
        'ぜ': 'ze',
        'ぞ': 'zo',
        'ザ': 'za',
        'ジ': 'zi',
        'ズ': 'zu',
        'ゼ': 'ze',
        'ゾ': 'zo',

        'だ': 'da',
        'ぢ': 'di',
        'づ': 'du',
        'で': 'de',
        'ど': 'do',
        'ダ': 'da',
        'ヂ': 'di',
        'ヅ': 'du',
        'デ': 'de',
        'ド': 'do',

        'ば': 'ba',
        'び': 'bi',
        'ぶ': 'bu',
        'べ': 'be',
        'ぼ': 'bo',
        'バ': 'ba',
        'ビ': 'bi',
        'ブ': 'bu',
        'ベ': 'be',
        'ボ': 'bo',

        'ぱ': 'pa',
        'ぴ': 'pi',
        'ぷ': 'pu',
        'ぺ': 'pe',
        'ぽ': 'po',
        'パ': 'pa',
        'ピ': 'pi',
        'プ': 'pu',
        'ペ': 'pe',
        'ポ': 'po',

        // 拗音-清音(キャ～リョ)
        'きゃ': 'kya',
        'きゅ': 'kyu',
        'きょ': 'kyo',
        'しゃ': 'sya',
        'しゅ': 'syu',
        'しょ': 'syo',
        'ちゃ': 'tya',
        'ちゅ': 'tyu',
        'ちょ': 'tyo',
        'にゃ': 'nya',
        'にゅ': 'nyu',
        'にょ': 'nyo',
        'ひゃ': 'hya',
        'ひゅ': 'hyu',
        'ひょ': 'hyo',
        'みゃ': 'mya',
        'みゅ': 'myu',
        'みょ': 'myo',
        'りゃ': 'rya',
        'りゅ': 'ryu',
        'りょ': 'ryo',
        'キャ': 'kya',
        'キュ': 'kyu',
        'キョ': 'kyo',
        'シャ': 'sya',
        'シュ': 'syu',
        'ショ': 'syo',
        'チャ': 'tya',
        'チュ': 'tyu',
        'チョ': 'tyo',
        'ニャ': 'nya',
        'ニュ': 'nyu',
        'ニョ': 'nyo',
        'ヒャ': 'hya',
        'ヒュ': 'hyu',
        'ヒョ': 'hyo',
        'ミャ': 'mya',
        'ミュ': 'myu',
        'ミョ': 'myo',
        'リャ': 'rya',
        'リュ': 'ryu',
        'リョ': 'ryo',

        // 拗音-濁音(ギャ～ビョ)、半濁音(ピャ～ピョ)、合拗音(クヮ、グヮ)
        'ぎゃ': 'gya',
        'ぎゅ': 'gyu',
        'ぎょ': 'gyo',
        'じゃ': 'zya',
        'じゅ': 'zyu',
        'じょ': 'zyo',
        'ぢゃ': 'dya',
        'ぢゅ': 'dyu',
        'ぢょ': 'dyo',
        'びゃ': 'bya',
        'びゅ': 'byu',
        'びょ': 'byo',
        'ぴゃ': 'pya',
        'ぴゅ': 'pyu',
        'ぴょ': 'pyo',
        'くゎ': 'kwa',
        'ぐゎ': 'gwa',
        'ギャ': 'gya',
        'ギュ': 'gyu',
        'ギョ': 'gyo',
        'ジャ': 'zya',
        'ジュ': 'zyu',
        'ジョ': 'zyo',
        'ヂャ': 'dya',
        'ヂュ': 'dyu',
        'ヂョ': 'dyo',
        'ビャ': 'bya',
        'ビュ': 'byu',
        'ビョ': 'byo',
        'ピャ': 'pya',
        'ピュ': 'pyu',
        'ピョ': 'pyo',
        'クヮ': 'kwa',
        'グヮ': 'gwa',

        // 小書きの仮名、符号
        'ぁ': 'a',
        'ぃ': 'i',
        'ぅ': 'u',
        'ぇ': 'e',
        'ぉ': 'o',
        'ゃ': 'ya',
        'ゅ': 'yu',
        'ょ': 'yo',
        'ゎ': 'wa',
        'ァ': 'a',
        'ィ': 'i',
        'ゥ': 'u',
        'ェ': 'e',
        'ォ': 'o',
        'ャ': 'ya',
        'ュ': 'yu',
        'ョ': 'yo',
        'ヮ': 'wa',
        'ヵ': 'ka',
        'ヶ': 'ke',
        'ん': 'n',
        'ン': 'n',
        // 'ー': ',
        '　': ' ',

        // 外来音(イェ～グォ)
        'いぇ': 'ye',
        // 'うぃ': ',
        // 'うぇ': ',
        // 'うぉ': ',
        'きぇ': 'kye',
        // 'くぁ': ',
        'くぃ': 'kwi',
        'くぇ': 'kwe',
        'くぉ': 'kwo',
        // 'ぐぁ': ',
        'ぐぃ': 'gwi',
        'ぐぇ': 'gwe',
        'ぐぉ': 'gwo',
        'イェ': 'ye',
        // 'ウィ': ',
        // 'ウェ': ',
        // 'ウォ': ',
        // 'ヴ': ',
        // 'ヴァ': ',
        // 'ヴィ': ',
        // 'ヴェ': ',
        // 'ヴォ': ',
        // 'ヴュ': ',
        // 'ヴョ': ',
        'キェ': 'kya',
        // 'クァ': ',
        'クィ': 'kwi',
        'クェ': 'kwe',
        'クォ': 'kwo',
        // 'グァ': ',
        'グィ': 'gwi',
        'グェ': 'gwe',
        'グォ': 'gwo',

        // 外来音(シェ～フョ)
        'しぇ': 'sye',
        'じぇ': 'zye',
        'すぃ': 'swi',
        'ずぃ': 'zwi',
        'ちぇ': 'tye',
        'つぁ': 'twa',
        'つぃ': 'twi',
        'つぇ': 'twe',
        'つぉ': 'two',
        // 'てぃ': 'ti',
        // 'てゅ': 'tyu',
        // 'でぃ': 'di',
        // 'でゅ': 'dyu',
        // 'とぅ': 'tu',
        // 'どぅ': 'du',
        'にぇ': 'nye',
        'ひぇ': 'hye',
        'ふぁ': 'hwa',
        'ふぃ': 'hwi',
        'ふぇ': 'hwe',
        'ふぉ': 'hwo',
        'ふゅ': 'hwyu',
        'ふょ': 'hwyo',
        'シェ': 'sye',
        'ジェ': 'zye',
        'スィ': 'swi',
        'ズィ': 'zwi',
        'チェ': 'tye',
        'ツァ': 'twa',
        'ツィ': 'twi',
        'ツェ': 'twe',
        'ツォ': 'two',
        // 'ティ': 'ti',
        // 'テュ': 'tyu',
        // 'ディ': 'di',
        // 'デュ': 'dyu',
        // 'トゥ': 'tu',
        // 'ドゥ': 'du',
        'ニェ': 'nye',
        'ヒェ': 'hye',
        'ファ': 'hwa',
        'フィ': 'hwi',
        'フェ': 'hwe',
        'フォ': 'hwo',
        'フュ': 'hwyu',
        'フョ': 'hwyo',
      },
      RomanizationSystem.passport => {
        // 数字と記号
        '１': '1',
        '２': '2',
        '３': '3',
        '４': '4',
        '５': '5',
        '６': '6',
        '７': '7',
        '８': '8',
        '９': '9',
        '０': '0',
        '！': '!',
        '“': '"',
        '”': '"',
        '＃': '#',
        '＄': r'$',
        '％': '%',
        '＆': '&',
        '’': '',
        '（': '(',
        '）': ')',
        '＝': '=',
        '～': '~',
        '｜': '|',
        '＠': '@',
        '‘': '`',
        '＋': '+',
        '＊': '*',
        '；': ';',
        '：': ':',
        '＜': '<',
        '＞': '>',
        '、': ',',
        '。': '.',
        '／': '/',
        '？': '?',
        '＿': '_',
        '・': '･',
        '「': '"',
        '」': '"',
        '｛': '{',
        '｝': '}',
        '￥': r'\',
        '＾': '^',

        // 直音-清音(ア～ノ)
        'あ': 'a',
        'い': 'i',
        'う': 'u',
        'え': 'e',
        'お': 'o',
        'ア': 'a',
        'イ': 'i',
        'ウ': 'u',
        'エ': 'e',
        'オ': 'o',

        'か': 'ka',
        'き': 'ki',
        'く': 'ku',
        'け': 'ke',
        'こ': 'ko',
        'カ': 'ka',
        'キ': 'ki',
        'ク': 'ku',
        'ケ': 'ke',
        'コ': 'ko',

        'さ': 'sa',
        'し': 'shi',
        'す': 'su',
        'せ': 'se',
        'そ': 'so',
        'サ': 'sa',
        'シ': 'shi',
        'ス': 'su',
        'セ': 'se',
        'ソ': 'so',

        'た': 'ta',
        'ち': 'chi',
        'つ': 'tsu',
        'て': 'te',
        'と': 'to',
        'タ': 'ta',
        'チ': 'chi',
        'ツ': 'tsu',
        'テ': 'te',
        'ト': 'to',

        'な': 'na',
        'に': 'ni',
        'ぬ': 'nu',
        'ね': 'ne',
        'の': 'no',
        'ナ': 'na',
        'ニ': 'ni',
        'ヌ': 'nu',
        'ネ': 'ne',
        'ノ': 'no',

        // 直音-清音(ハ～ヲ)
        'は': 'ha',
        'ひ': 'hi',
        'ふ': 'fu',
        'へ': 'he',
        'ほ': 'ho',
        'ハ': 'ha',
        'ヒ': 'hi',
        'フ': 'fu',
        'ヘ': 'he',
        'ホ': 'ho',

        'ま': 'ma',
        'み': 'mi',
        'む': 'mu',
        'め': 'me',
        'も': 'mo',
        'マ': 'ma',
        'ミ': 'mi',
        'ム': 'mu',
        'メ': 'me',
        'モ': 'mo',

        'や': 'ya',
        'ゆ': 'yu',
        'よ': 'yo',
        'ヤ': 'ya',
        'ユ': 'yu',
        'ヨ': 'yo',

        'ら': 'ra',
        'り': 'ri',
        'る': 'ru',
        'れ': 're',
        'ろ': 'ro',
        'ラ': 'ra',
        'リ': 'ri',
        'ル': 'ru',
        'レ': 're',
        'ロ': 'ro',

        'わ': 'wa',
        'ゐ': 'i',
        'ゑ': 'e',
        'を': 'o',
        'ワ': 'wa',
        'ヰ': 'i',
        'ヱ': 'e',
        'ヲ': 'o',

        // 直音-濁音(ガ～ボ)、半濁音(パ～ポ)
        'が': 'ga',
        'ぎ': 'gi',
        'ぐ': 'gu',
        'げ': 'ge',
        'ご': 'go',
        'ガ': 'ga',
        'ギ': 'gi',
        'グ': 'gu',
        'ゲ': 'ge',
        'ゴ': 'go',

        'ざ': 'za',
        'じ': 'ji',
        'ず': 'zu',
        'ぜ': 'ze',
        'ぞ': 'zo',
        'ザ': 'za',
        'ジ': 'ji',
        'ズ': 'zu',
        'ゼ': 'ze',
        'ゾ': 'zo',

        'だ': 'da',
        'ぢ': 'ji',
        'づ': 'zu',
        'で': 'de',
        'ど': 'do',
        'ダ': 'da',
        'ヂ': 'ji',
        'ヅ': 'zu',
        'デ': 'de',
        'ド': 'do',

        'ば': 'ba',
        'び': 'bi',
        'ぶ': 'bu',
        'べ': 'be',
        'ぼ': 'bo',
        'バ': 'ba',
        'ビ': 'bi',
        'ブ': 'bu',
        'ベ': 'be',
        'ボ': 'bo',

        'ぱ': 'pa',
        'ぴ': 'pi',
        'ぷ': 'pu',
        'ぺ': 'pe',
        'ぽ': 'po',
        'パ': 'pa',
        'ピ': 'pi',
        'プ': 'pu',
        'ペ': 'pe',
        'ポ': 'po',

        // 拗音-清音(キャ～リョ)
        'きゃ': 'kya',
        'きゅ': 'kyu',
        'きょ': 'kyo',
        'しゃ': 'sha',
        'しゅ': 'shu',
        'しょ': 'sho',
        'ちゃ': 'cha',
        'ちゅ': 'chu',
        'ちょ': 'cho',
        'にゃ': 'nya',
        'にゅ': 'nyu',
        'にょ': 'nyo',
        'ひゃ': 'hya',
        'ひゅ': 'hyu',
        'ひょ': 'hyo',
        'みゃ': 'mya',
        'みゅ': 'myu',
        'みょ': 'myo',
        'りゃ': 'rya',
        'りゅ': 'ryu',
        'りょ': 'ryo',
        'キャ': 'kya',
        'キュ': 'kyu',
        'キョ': 'kyo',
        'シャ': 'sha',
        'シュ': 'shu',
        'ショ': 'sho',
        'チャ': 'cha',
        'チュ': 'chu',
        'チョ': 'cho',
        'ニャ': 'nya',
        'ニュ': 'nyu',
        'ニョ': 'nyo',
        'ヒャ': 'hya',
        'ヒュ': 'hyu',
        'ヒョ': 'hyo',
        'ミャ': 'mya',
        'ミュ': 'myu',
        'ミョ': 'myo',
        'リャ': 'rya',
        'リュ': 'ryu',
        'リョ': 'ryo',

        // 拗音-濁音(ギャ～ビョ)、半濁音(ピャ～ピョ)、合拗音(クヮ、グヮ)
        'ぎゃ': 'gya',
        'ぎゅ': 'gyu',
        'ぎょ': 'gyo',
        'じゃ': 'ja',
        'じゅ': 'ju',
        'じょ': 'jo',
        'ぢゃ': 'ja',
        'ぢゅ': 'ju',
        'ぢょ': 'jo',
        'びゃ': 'bya',
        'びゅ': 'byu',
        'びょ': 'byo',
        'ぴゃ': 'pya',
        'ぴゅ': 'pyu',
        'ぴょ': 'pyo',
        // 'くゎ': ',
        // 'ぐゎ': ',
        'ギャ': 'gya',
        'ギュ': 'gyu',
        'ギョ': 'gyo',
        'ジャ': 'ja',
        'ジュ': 'ju',
        'ジョ': 'jo',
        'ヂャ': 'ja',
        'ヂュ': 'ju',
        'ヂョ': 'jo',
        'ビャ': 'bya',
        'ビュ': 'byu',
        'ビョ': 'byo',
        'ピャ': 'pya',
        'ピュ': 'pyu',
        'ピョ': 'pyo',
        // 'クヮ': ',
        // 'グヮ': ',

        // 小書きの仮名、符号
        'ぁ': 'a',
        'ぃ': 'i',
        'ぅ': 'u',
        'ぇ': 'e',
        'ぉ': 'o',
        'ゃ': 'ya',
        'ゅ': 'yu',
        'ょ': 'yo',
        'ゎ': 'wa',
        'ァ': 'a',
        'ィ': 'i',
        'ゥ': 'u',
        'ェ': 'e',
        'ォ': 'o',
        'ャ': 'ya',
        'ュ': 'yu',
        'ョ': 'yo',
        'ヮ': 'wa',
        'ヵ': 'ka',
        'ヶ': 'ke',
        'ん': 'n',
        'ン': 'n',
        // 'ー': ',
        '　': ' ',

        // 外来音(イェ～グォ)
        // 'いぇ': ',
        // 'うぃ': ',
        // 'うぇ': ',
        // 'うぉ': ',
        // 'きぇ': ',
        // 'くぁ': ',
        // 'くぃ': ',
        // 'くぇ': ',
        // 'くぉ': ',
        // 'ぐぁ': ',
        // 'ぐぃ': ',
        // 'ぐぇ': ',
        // 'ぐぉ': ',
        // 'イェ': ',
        // 'ウィ': ',
        // 'ウェ': ',
        // 'ウォ': ',
        'ヴ': 'b',
        // 'ヴァ': ',
        // 'ヴィ': ',
        // 'ヴェ': ',
        // 'ヴォ': ',
        // 'ヴュ': ',
        // 'ヴョ': ',
        // 'キェ': ',
        // 'クァ': ',
        // 'クィ': ',
        // 'クェ': ',
        // 'クォ': ',
        // 'グァ': ',
        // 'グィ': ',
        // 'グェ': ',
        // 'グォ': ',

        // 外来音(シェ～フョ)
        // 'しぇ': ',
        // 'じぇ': ',
        // 'すぃ': ',
        // 'ずぃ': ',
        // 'ちぇ': ',
        // 'つぁ': ',
        // 'つぃ': ',
        // 'つぇ': ',
        // 'つぉ': ',
        // 'てぃ': ',
        // 'てゅ': ',
        // 'でぃ': ',
        // 'でゅ': ',
        // 'とぅ': ',
        // 'どぅ': ',
        // 'にぇ': ',
        // 'ひぇ': ',
        // 'ふぁ': ',
        // 'ふぃ': ',
        // 'ふぇ': ',
        // 'ふぉ': ',
        // 'ふゅ': ',
        // 'ふょ': ',
        // 'シェ': ',
        // 'ジェ': ',
        // 'スィ': ',
        // 'ズィ': ',
        // 'チェ': ',
        // 'ツァ': ',
        // 'ツィ': ',
        // 'ツェ': ',
        // 'ツォ': ',
        // 'ティ': ',
        // 'テュ': ',
        // 'ディ': ',
        // 'デュ': ',
        // 'トゥ': ',
        // 'ドゥ': ',
        // 'ニェ': ',
        // 'ヒェ': ',
        // 'ファ': ',
        // 'フィ': ',
        // 'フェ': ',
        // 'フォ': ',
        // 'フュ': ',
        // 'フョ': '
      },
      RomanizationSystem.hepburn => {
        // 数字と記号
        '１': '1',
        '２': '2',
        '３': '3',
        '４': '4',
        '５': '5',
        '６': '6',
        '７': '7',
        '８': '8',
        '９': '9',
        '０': '0',
        '！': '!',
        '“': '"',
        '”': '"',
        '＃': '#',
        '＄': r'$',
        '％': '%',
        '＆': '&',
        '’': '',
        '（': '(',
        '）': ')',
        '＝': '=',
        '～': '~',
        '｜': '|',
        '＠': '@',
        '‘': '`',
        '＋': '+',
        '＊': '*',
        '；': ';',
        '：': ':',
        '＜': '<',
        '＞': '>',
        '、': ',',
        '。': '.',
        '／': '/',
        '？': '?',
        '＿': '_',
        '・': '･',
        '「': '"',
        '」': '"',
        '｛': '{',
        '｝': '}',
        '￥': r'\',
        '＾': '^',

        // 直音-清音(ア～ノ)
        'あ': 'a',
        'い': 'i',
        'う': 'u',
        'え': 'e',
        'お': 'o',
        'ア': 'a',
        'イ': 'i',
        'ウ': 'u',
        'エ': 'e',
        'オ': 'o',

        'か': 'ka',
        'き': 'ki',
        'く': 'ku',
        'け': 'ke',
        'こ': 'ko',
        'カ': 'ka',
        'キ': 'ki',
        'ク': 'ku',
        'ケ': 'ke',
        'コ': 'ko',

        'さ': 'sa',
        'し': 'shi',
        'す': 'su',
        'せ': 'se',
        'そ': 'so',
        'サ': 'sa',
        'シ': 'shi',
        'ス': 'su',
        'セ': 'se',
        'ソ': 'so',

        'た': 'ta',
        'ち': 'chi',
        'つ': 'tsu',
        'て': 'te',
        'と': 'to',
        'タ': 'ta',
        'チ': 'chi',
        'ツ': 'tsu',
        'テ': 'te',
        'ト': 'to',

        'な': 'na',
        'に': 'ni',
        'ぬ': 'nu',
        'ね': 'ne',
        'の': 'no',
        'ナ': 'na',
        'ニ': 'ni',
        'ヌ': 'nu',
        'ネ': 'ne',
        'ノ': 'no',

        // 直音-清音(ハ～ヲ)
        'は': 'ha',
        'ひ': 'hi',
        'ふ': 'fu',
        'へ': 'he',
        'ほ': 'ho',
        'ハ': 'ha',
        'ヒ': 'hi',
        'フ': 'fu',
        'ヘ': 'he',
        'ホ': 'ho',

        'ま': 'ma',
        'み': 'mi',
        'む': 'mu',
        'め': 'me',
        'も': 'mo',
        'マ': 'ma',
        'ミ': 'mi',
        'ム': 'mu',
        'メ': 'me',
        'モ': 'mo',

        'や': 'ya',
        'ゆ': 'yu',
        'よ': 'yo',
        'ヤ': 'ya',
        'ユ': 'yu',
        'ヨ': 'yo',

        'ら': 'ra',
        'り': 'ri',
        'る': 'ru',
        'れ': 're',
        'ろ': 'ro',
        'ラ': 'ra',
        'リ': 'ri',
        'ル': 'ru',
        'レ': 're',
        'ロ': 'ro',

        'わ': 'wa',
        'ゐ': 'i',
        'ゑ': 'e',
        'を': 'o',
        'ワ': 'wa',
        'ヰ': 'i',
        'ヱ': 'e',
        'ヲ': 'o',

        // 直音-濁音(ガ～ボ)、半濁音(パ～ポ)
        'が': 'ga',
        'ぎ': 'gi',
        'ぐ': 'gu',
        'げ': 'ge',
        'ご': 'go',
        'ガ': 'ga',
        'ギ': 'gi',
        'グ': 'gu',
        'ゲ': 'ge',
        'ゴ': 'go',

        'ざ': 'za',
        'じ': 'ji',
        'ず': 'zu',
        'ぜ': 'ze',
        'ぞ': 'zo',
        'ザ': 'za',
        'ジ': 'ji',
        'ズ': 'zu',
        'ゼ': 'ze',
        'ゾ': 'zo',

        'だ': 'da',
        'ぢ': 'ji',
        'づ': 'zu',
        'で': 'de',
        'ど': 'do',
        'ダ': 'da',
        'ヂ': 'ji',
        'ヅ': 'zu',
        'デ': 'de',
        'ド': 'do',

        'ば': 'ba',
        'び': 'bi',
        'ぶ': 'bu',
        'べ': 'be',
        'ぼ': 'bo',
        'バ': 'ba',
        'ビ': 'bi',
        'ブ': 'bu',
        'ベ': 'be',
        'ボ': 'bo',

        'ぱ': 'pa',
        'ぴ': 'pi',
        'ぷ': 'pu',
        'ぺ': 'pe',
        'ぽ': 'po',
        'パ': 'pa',
        'ピ': 'pi',
        'プ': 'pu',
        'ペ': 'pe',
        'ポ': 'po',

        // 拗音-清音(キャ～リョ)
        'きゃ': 'kya',
        'きゅ': 'kyu',
        'きょ': 'kyo',
        'しゃ': 'sha',
        'しゅ': 'shu',
        'しょ': 'sho',
        'ちゃ': 'cha',
        'ちゅ': 'chu',
        'ちょ': 'cho',
        'にゃ': 'nya',
        'にゅ': 'nyu',
        'にょ': 'nyo',
        'ひゃ': 'hya',
        'ひゅ': 'hyu',
        'ひょ': 'hyo',
        'みゃ': 'mya',
        'みゅ': 'myu',
        'みょ': 'myo',
        'りゃ': 'rya',
        'りゅ': 'ryu',
        'りょ': 'ryo',
        'キャ': 'kya',
        'キュ': 'kyu',
        'キョ': 'kyo',
        'シャ': 'sha',
        'シュ': 'shu',
        'ショ': 'sho',
        'チャ': 'cha',
        'チュ': 'chu',
        'チョ': 'cho',
        'ニャ': 'nya',
        'ニュ': 'nyu',
        'ニョ': 'nyo',
        'ヒャ': 'hya',
        'ヒュ': 'hyu',
        'ヒョ': 'hyo',
        'ミャ': 'mya',
        'ミュ': 'myu',
        'ミョ': 'myo',
        'リャ': 'rya',
        'リュ': 'ryu',
        'リョ': 'ryo',

        // 拗音-濁音(ギャ～ビョ)、半濁音(ピャ～ピョ)、合拗音(クヮ、グヮ)
        'ぎゃ': 'gya',
        'ぎゅ': 'gyu',
        'ぎょ': 'gyo',
        'じゃ': 'ja',
        'じゅ': 'ju',
        'じょ': 'jo',
        'ぢゃ': 'ja',
        'ぢゅ': 'ju',
        'ぢょ': 'jo',
        'びゃ': 'bya',
        'びゅ': 'byu',
        'びょ': 'byo',
        'ぴゃ': 'pya',
        'ぴゅ': 'pyu',
        'ぴょ': 'pyo',
        // 'くゎ': ',
        // 'ぐゎ': ',
        'ギャ': 'gya',
        'ギュ': 'gyu',
        'ギョ': 'gyo',
        'ジャ': 'ja',
        'ジュ': 'ju',
        'ジョ': 'jo',
        'ヂャ': 'ja',
        'ヂュ': 'ju',
        'ヂョ': 'jo',
        'ビャ': 'bya',
        'ビュ': 'byu',
        'ビョ': 'byo',
        'ピャ': 'pya',
        'ピュ': 'pyu',
        'ピョ': 'pyo',
        // 'クヮ': ',
        // 'グヮ': ',

        // 小書きの仮名、符号
        'ぁ': 'a',
        'ぃ': 'i',
        'ぅ': 'u',
        'ぇ': 'e',
        'ぉ': 'o',
        'ゃ': 'ya',
        'ゅ': 'yu',
        'ょ': 'yo',
        'ゎ': 'wa',
        'ァ': 'a',
        'ィ': 'i',
        'ゥ': 'u',
        'ェ': 'e',
        'ォ': 'o',
        'ャ': 'ya',
        'ュ': 'yu',
        'ョ': 'yo',
        'ヮ': 'wa',
        'ヵ': 'ka',
        'ヶ': 'ke',
        'ん': 'n',
        'ン': 'n',
        // 'ー': ',
        '　': ' ',

        // 外来音(イェ～グォ)
        'いぇ': 'ye',
        'うぃ': 'wi',
        'うぇ': 'we',
        'うぉ': 'wo',
        'きぇ': 'kye',
        'くぁ': 'kwa',
        'くぃ': 'kwi',
        'くぇ': 'kwe',
        'くぉ': 'kwo',
        'ぐぁ': 'gwa',
        'ぐぃ': 'gwi',
        'ぐぇ': 'gwe',
        'ぐぉ': 'gwo',
        'イェ': 'ye',
        'ウィ': 'wi',
        'ウェ': 'we',
        'ウォ': 'wo',
        'ヴ': 'vu',
        'ヴァ': 'va',
        'ヴィ': 'vi',
        'ヴェ': 've',
        'ヴォ': 'vo',
        'ヴュ': 'vyu',
        'ヴョ': 'vyo',
        'キェ': 'kya',
        'クァ': 'kwa',
        'クィ': 'kwi',
        'クェ': 'kwe',
        'クォ': 'kwo',
        'グァ': 'gwa',
        'グィ': 'gwi',
        'グェ': 'gwe',
        'グォ': 'gwo',

        // 外来音(シェ～フョ)
        'しぇ': 'she',
        'じぇ': 'je',
        // 'すぃ': ',
        // 'ずぃ': ',
        'ちぇ': 'che',
        'つぁ': 'tsa',
        'つぃ': 'tsi',
        'つぇ': 'tse',
        'つぉ': 'tso',
        'てぃ': 'ti',
        'てゅ': 'tyu',
        'でぃ': 'di',
        'でゅ': 'dyu',
        'とぅ': 'tu',
        'どぅ': 'du',
        'にぇ': 'nye',
        'ひぇ': 'hye',
        'ふぁ': 'fa',
        'ふぃ': 'fi',
        'ふぇ': 'fe',
        'ふぉ': 'fo',
        'ふゅ': 'fyu',
        'ふょ': 'fyo',
        'シェ': 'she',
        'ジェ': 'je',
        // 'スィ': ',
        // 'ズィ': ',
        'チェ': 'che',
        'ツァ': 'tsa',
        'ツィ': 'tsi',
        'ツェ': 'tse',
        'ツォ': 'tso',
        'ティ': 'ti',
        'テュ': 'tyu',
        'ディ': 'di',
        'デュ': 'dyu',
        'トゥ': 'tu',
        'ドゥ': 'du',
        'ニェ': 'nye',
        'ヒェ': 'hye',
        'ファ': 'fa',
        'フィ': 'fi',
        'フェ': 'fe',
        'フォ': 'fo',
        'フュ': 'fyu',
        'フョ': 'fyo',
      },
    };

List<TokenizerResponse> patchTokens(List<TokenizerResponse> tokens) {
  for (int cr = 0; cr < tokens.length; cr++) {
    final token = tokens[cr];
    if (hasJapanese(token.surfaceForm)) {
      if (token.reading == null || token.reading?.isEmpty == true) {
        if (token.surfaceForm.split('').every(isKana)) {
          tokens[cr].reading = token.surfaceForm;
        }
      } else if (hasHiragana(token.reading!)) {
        tokens[cr].reading = toRawKatakana(token.reading!);
      }
    } else {
      tokens[cr].reading = token.surfaceForm;
    }
  }

  for (int i = 0; i < tokens.length; i++) {
    final token = tokens[i];
    if (token.pos.isNotEmpty &&
        token.pos == '助動詞' &&
        (token.surfaceForm == 'う' || token.surfaceForm == 'ウ')) {
      if (i - 1 >= 0 &&
          tokens[i - 1].pos.isNotEmpty &&
          tokens[i - 1].pos == '動詞') {
        tokens[i - 1].surfaceForm = 'う';
        if (tokens[i - 1].pronunciation != null) {
          tokens[i - 1].pronunciation = 'ー';
        } else {
          tokens[i - 1].pronunciation = '${tokens[i - 1].reading}ー';
        }
        tokens[i - 1].reading = '${tokens[i - 1].reading}ウ';
        tokens.sublist(i, 1);
        i--;
      }
    }
  }

  // patch for "っ" at the tail of 動詞、形容詞
  for (int j = 0; j < tokens.length; j++) {
    final token = tokens[j];
    if ((token.pos == '動詞' || token.pos == '形容詞') &&
        token.surfaceForm.length > 1 &&
        (token.surfaceForm.endsWith('っ') || token.surfaceForm.endsWith('ッ'))) {
      if (j + 1 < tokens.length) {
        final nextToken = tokens[j + 1];
        tokens[j].surfaceForm += nextToken.surfaceForm;
        if (token.pronunciation != null) {
          tokens[j].pronunciation =
              '${token.pronunciation}${nextToken.pronunciation ?? nextToken.reading ?? ''}'; // Handle potential nulls for nextToken.pronunciation/reading
        } else {
          tokens[j].pronunciation =
              '${token.reading ?? ''}${nextToken.reading ?? ''}'; // Handle potential nulls
        }
        tokens[j].reading =
            '${token.reading ?? ''}${nextToken.reading ?? ''}'; // Handle potential nulls
        tokens.removeAt(j + 1); // Remove the next token
        j--; // Decrement j after removing an element
      }
    }
  }

  return tokens;
}

/// Represents the type of characters present in a string.
enum StringType {
  /// Contains only Kanji characters.
  kanjiOnly,

  /// Contains both Kanji and Hiragana/Katakana characters.
  kanjiAndKana,

  /// Contains only Hiragana/Katakana characters.
  kanaOnly,

  /// Contains neither Kanji nor Hiragana/Katakana characters (e.g., Roman characters, punctuation).
  other,
}

/// Determines the type of characters present in a given string.
///
/// Returns a [StringType] enum value indicating whether the string contains
/// Kanji, Kana (Hiragana or Katakana), both, or neither.
StringType getStrType(String str) {
  bool hasKJ = false;
  bool hasHK = false;

  for (int i = 0; i < str.length; i++) {
    final char = str[i];
    if (isKanji(char)) {
      hasKJ = true;
    } else if (isHiragana(char) || isKatakana(char)) {
      hasHK = true;
    }
  }

  if (hasKJ && hasHK) {
    return StringType.kanjiAndKana;
  }
  if (hasKJ) {
    return StringType.kanjiOnly;
  }
  if (hasHK) {
    return StringType.kanaOnly;
  }
  return StringType.other;
}

String kanaToHiragana(String str) => toRawHiragana(str);

String kanaToKatakana(String str) => toRawKatakana(str);

String kanaToRomaji(
  String str, [
  RomanizationSystem system = RomanizationSystem.hepburn,
]) => toRawRomaji(str, system);

extension on String {
  operator >(String other) => codeUnits.first > other.codeUnits.first;
  operator >=(String other) => codeUnits.first >= other.codeUnits.first;
  operator <(String other) => codeUnits.first < other.codeUnits.first;
  operator <=(String other) => codeUnits.first <= other.codeUnits.first;
}
