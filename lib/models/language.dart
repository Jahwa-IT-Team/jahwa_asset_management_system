class Language {
  final int id;
  final String flag;
  final String name;
  final String languageCode;

  Language(this.id, this.flag, this.name, this.languageCode);

  //국기 List of country flag emojis
  //https://emojipedia.org/flags/
  static List<Language> languageList() {
    return <Language>[
      Language(1, "🇰🇷", "한국어", "ko"),
      Language(2, "🇻🇳", "tiếng Việt", "vi"),

    ];
  }
}