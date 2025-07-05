import 'package:kuromoji/kuromoji.dart';
// ignore: implementation_imports
import 'package:kuromoji/src/tokenizer.dart';
import 'package:kuroshiro/src/models/tokenizer_response.dart';
import 'package:kuroshiro/src/utils.dart';

enum ConvertTo { hiragana, katakana, romaji }

enum ConvertMode { normal, spaced, okurigana, furigana }

class Kuroshiro {
  late final Tokenizer tokenizer;

  Future<Kuroshiro> init() async {
    tokenizer = await TokenizerBuilder().build();
    return this;
  }

  Future<String> convert(
    String str, {
    ConvertTo to = ConvertTo.hiragana,
    ConvertMode mode = ConvertMode.normal,
    RomanizationSystem romajiSystem = RomanizationSystem.hepburn,
    String delimiterStart = '(',
    String delimiterEnd = ')',
  }) async {
    final rawTokens = tokenizer.tokenize(str);
    final mappedTokens = rawTokens.map(TokenizerResponse.fromMap).toList();
    final tokens = patchTokens(mappedTokens);

    if (mode case ConvertMode.normal || ConvertMode.spaced) {
      switch (to) {
        case ConvertTo.katakana when mode == ConvertMode.spaced:
          return tokens.map((token) => token.reading!).join();
        case ConvertTo.katakana when mode == ConvertMode.normal:
          return tokens.map((token) => token.reading!).join(' ');
        case ConvertTo.romaji:
          String romajiConv(TokenizerResponse token) {
            String preToken;
            if (hasJapanese(token.surfaceForm)) {
              preToken = token.pronunciation ?? token.reading!;
            } else {
              preToken = token.surfaceForm;
            }

            return toRawRomaji(preToken, romajiSystem);
          }

          if (mode == ConvertMode.normal) {
            return tokens.map(romajiConv).join();
          }

          if (mode == ConvertMode.spaced) {
            return tokens.map(romajiConv).join(' ');
          }
        case ConvertTo.hiragana:
          for (int hi = 0; hi < tokens.length; hi++) {
            if (hasKanji(tokens[hi].surfaceForm)) {
              if (!hasKatakana(tokens[hi].surfaceForm)) {
                tokens[hi].reading = toRawHiragana(tokens[hi].reading!);
              } else {
                // handle katakana-kanji-mixed tokens
                tokens[hi].reading = toRawHiragana(tokens[hi].reading!);
                var tmp = "";
                var hpattern = "";
                for (int hc = 0; hc < tokens[hi].surfaceForm.length; hc++) {
                  if (isKanji(tokens[hi].surfaceForm[hc])) {
                    hpattern += "(.*)";
                  } else {
                    hpattern += isKatakana(tokens[hi].surfaceForm[hc])
                        ? toRawHiragana(tokens[hi].surfaceForm[hc])
                        : tokens[hi].surfaceForm[hc];
                  }
                }
                final hreg = RegExp(hpattern);
                final hmatches = hreg.firstMatch(tokens[hi].reading!);
                if (hmatches != null) {
                  var pickKJ = 0;
                  for (
                    int hc1 = 0;
                    hc1 < tokens[hi].surfaceForm.length;
                    hc1++
                  ) {
                    if (isKanji(tokens[hi].surfaceForm[hc1])) {
                      tmp += hmatches[pickKJ + 1]!;
                      pickKJ++;
                    } else {
                      tmp += tokens[hi].surfaceForm[hc1];
                    }
                  }
                  tokens[hi].reading = tmp;
                }
              }
            } else {
              tokens[hi].reading = tokens[hi].surfaceForm;
            }
          }
          if (mode == ConvertMode.normal) {
            return tokens.map((token) => token.reading).join("");
          }
          return tokens.map((token) => token.reading).join(" ");
        default:
          throw Exception('Unhandled');
      }
    }

    throw Exception('TODO');
  }
}
