class TokenizerResponse {
  String surfaceForm;
  String pos;
  String posDetail1;
  String posDetail2;
  String posDetail3;
  String conjugatedType;
  String conjugatedForm;
  String basicForm;
  String? reading;
  String? pronunciation;

  TokenizerResponse({
    required this.basicForm,
    required this.conjugatedForm,
    required this.conjugatedType,
    required this.pos,
    required this.posDetail1,
    required this.posDetail2,
    required this.posDetail3,
    required this.pronunciation,
    required this.reading,
    required this.surfaceForm,
  });

  factory TokenizerResponse.fromMap(Map<String, dynamic> raw) =>
      TokenizerResponse(
        basicForm: raw['basic_form'],
        conjugatedForm: raw['conjugated_form'],
        conjugatedType: raw['conjugated_type'],
        pos: raw['pos'],
        posDetail1: raw['pos_detail_1'],
        posDetail2: raw['pos_detail_2'],
        posDetail3: raw['pos_detail_3'],
        pronunciation: raw['pronounciation'],
        reading: raw['reading'],
        surfaceForm: raw['surface_form'],
      );
}
