extension StringTurkishExtension on String {
  /// Converts Turkish characters to their English equivalents
  /// and transforms the string to lowercase for case/character insensitive search.
  String normalizeTurkish() {
    String text = toLowerCase();
    
    // Turkish characters to English characters
    const turkishChars = ['ç', 'ğ', 'ı', 'ö', 'ş', 'ü'];
    const englishChars = ['c', 'g', 'i', 'o', 's', 'u'];
    
    for (int i = 0; i < turkishChars.length; i++) {
      text = text.replaceAll(turkishChars[i], englishChars[i]);
    }
    
    return text;
  }
}
