import 'package:kuroshiro/kuroshiro.dart';

void main() async {
  final kuroshiro = Kuroshiro();
  final text = 'こんにちは';
  
  // Convert to Romaji
  final romaji = await kuroshiro.convert(text, to: ConvertTo.romaji);
  print(romaji); // → konnichiwa

  // Convert to Hiragana
  final hiragana = await kuroshiro.convert(text, to: ConvertTo.hiragana);
  print(hiragana); // → こんにちは

  // Convert to Katakana
  final katakana = await kuroshiro.convert(text, to: ConvertTo.katakana);
  print(katakana); // → コンニチハ
}
